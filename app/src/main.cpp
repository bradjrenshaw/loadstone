// Loadstone Mod Manager — wxWidgets shell over the Rust core.
//
// Two views, both built from typed models the cxx bridge returns:
//   - the catalog: every mod visible through the profile's registries,
//     merged with installed state;
//   - the mod page: status, install/update/uninstall, a live settings
//     form, and declared actions.
//
// Operations (install/update/uninstall/actions) run the Rust engine on a
// worker thread. The engine talks back through a UiCallbacks object: logs
// and progress are posted to the GUI thread with wxTheApp->CallAfter
// (thread-safe); questions (confirm, retry/skip/cancel, pick-directory)
// block the worker on a std::future until the user answers a native
// dialog on the GUI thread. An alive flag cleared by the frame's
// destructor guards every hop; a dead frame answers "cancel", which the
// engine turns into a clean rollback.
//
// Everything is native wx controls with real labels, so screen readers see
// a proper list, checkboxes, and buttons.
//
// Smoke mode: when the LOADSTONE_SMOKE_OUT environment variable names a
// file, the app writes what it got from the bridge there and exits without
// showing a window — CI and terminal sessions verify the stack headlessly.
// LOADSTONE_SMOKE_MOD dumps a mod page; LOADSTONE_SMOKE_INSTALL runs a
// real install through the bridge with auto-answered callbacks (see the
// LOADSTONE_SMOKE_GAME_DIR / _STATE / _RELEASE overrides).

#include <wx/wx.h>
#include <wx/choice.h>
#include <wx/dirdlg.h>
#include <wx/listbox.h>
#include <wx/scrolwin.h>

#include <atomic>
#include <cstdlib>
#include <fstream>
#include <future>
#include <memory>
#include <string>
#include <thread>
#include <vector>

#include "rust/cxx.h"
#include "loadstone-bridge/include/ui_callbacks.h"
#include "loadstone-bridge/src/lib.rs.h"

// ENCODING RULE: narrow ("...") string literals must stay pure ASCII.
// wxString converts char* through the ANSI code page, not UTF-8, so a
// UTF-8 em dash in a literal renders as mojibake. Text from Rust always
// goes through FromRust (explicit UTF-8); anything else non-ASCII needs
// a wide L"..." literal or wxString::FromUTF8.

// The compile-time distribution profile. "null" = resolve at runtime
// (loadstone.json sidecar, else the default manager profile). Branded
// installer builds will inject real JSON here.
static const char* kEmbeddedProfile = "null";

namespace {

wxString FromRust(const rust::String& s) {
    return wxString::FromUTF8(s.data(), s.size());
}

wxString FromRust(rust::Str s) {
    return wxString::FromUTF8(s.data(), s.size());
}

std::string ToStd(const wxString& s) {
    return std::string(s.utf8_str());
}

} // namespace

// ---------------------------------------------------------------------------

enum class OpKind { Install, Update, Uninstall, Action };

class LoadstoneFrame : public wxFrame {
public:
    LoadstoneFrame(loadstone::UiProfile profile, wxString coreVersion);
    ~LoadstoneFrame() override { alive_->store(false); }

    // Called (on the GUI thread) by the operation callbacks.
    void AppendOpLog(const wxString& line);
    void SetOpProgress(unsigned percent);

private:
    // Catalog view.
    void BuildCatalogPanel();
    void StartCatalogFetch();
    void OnCatalog(const loadstone::Catalog& catalog);

    // Mod page view.
    void OpenMod(const wxString& id);
    void OnModPage(const loadstone::ModPage& page);
    void BuildModPage(const loadstone::ModPage& page);
    void GoBack();

    // Operations.
    void RunOperation(OpKind kind, const wxString& actionId = wxString());
    void OnOpDone(const std::string& result, const std::string& error);

    // The settings form writes through the bridge as controls change.
    // Returns false (and shows the error) when the value was rejected.
    bool ApplySetting(const wxString& settingId, const wxString& rawValue);

    void OnCharHook(wxKeyEvent& event);

    loadstone::UiProfile profile_;
    wxString coreVersion_;
    bool singleMod_;

    wxPanel* catalogPanel_ = nullptr;
    wxListBox* modList_ = nullptr;
    wxButton* detailsBtn_ = nullptr;
    wxButton* refreshBtn_ = nullptr;
    wxStaticText* catalogNotes_ = nullptr;
    std::vector<wxString> entryIds_;

    wxScrolledWindow* pagePanel_ = nullptr;
    wxString pageModId_;
    wxString pageGame_;
    wxString pageChannel_;
    // Interactive page controls, disabled while an operation runs.
    std::vector<wxWindow*> pageControls_;
    wxTextCtrl* gameDirCtrl_ = nullptr;
    wxTextCtrl* opLog_ = nullptr;

    bool fetchInFlight_ = false;
    bool opInFlight_ = false;
    std::shared_ptr<std::atomic<bool>> alive_ = std::make_shared<std::atomic<bool>>(true);
};

// ---------------------------------------------------------------------------
// The engine's callbacks, marshalled between the worker and GUI threads.

class GuiUiCallbacks final : public loadstone::UiCallbacks {
public:
    GuiUiCallbacks(std::shared_ptr<std::atomic<bool>> alive, LoadstoneFrame* frame)
        : alive_(std::move(alive)), frame_(frame) {}

    void log(rust::Str message) override {
        wxString text = FromRust(message);
        Post([text](LoadstoneFrame* f) { f->AppendOpLog(text); });
    }

    void progress(std::uint32_t percent) override {
        Post([percent](LoadstoneFrame* f) { f->SetOpProgress(percent); });
    }

    bool confirm(rust::Str message) override {
        wxString text = FromRust(message);
        return Ask<bool>(false, [text](LoadstoneFrame* f) {
            return wxMessageBox(text, "Loadstone", wxYES_NO | wxICON_QUESTION, f) == wxYES;
        });
    }

    std::uint8_t retry_skip_cancel(rust::Str message) override {
        wxString text = FromRust(message);
        return Ask<std::uint8_t>(2, [text](LoadstoneFrame* f) -> std::uint8_t {
            wxMessageDialog dlg(f, text, "Problem during the operation",
                                wxYES_NO | wxCANCEL | wxICON_WARNING);
            dlg.SetYesNoCancelLabels("&Retry", "&Skip", "&Cancel");
            switch (dlg.ShowModal()) {
                case wxID_YES: return 0; // retry
                case wxID_NO: return 1;  // skip
                default: return 2;       // cancel
            }
        });
    }

    rust::String pick_directory(rust::Str id, rust::Str prompt, rust::Str suggest) override {
        (void)id; // GUI has no preset answers; test drivers use them
        wxString text = FromRust(prompt);
        wxString start = FromRust(suggest);
        std::string picked = Ask<std::string>(std::string(), [text, start](LoadstoneFrame* f) {
            wxDirDialog dlg(f, text, start, wxDD_DEFAULT_STYLE | wxDD_DIR_MUST_EXIST);
            if (dlg.ShowModal() != wxID_OK) return std::string();
            return std::string(dlg.GetPath().utf8_str());
        });
        return rust::String(picked);
    }

private:
    // Fire-and-forget onto the GUI thread.
    template <typename Fn>
    void Post(Fn fn) {
        auto alive = alive_;
        auto frame = frame_;
        wxTheApp->CallAfter([alive, frame, fn] {
            if (alive->load()) fn(frame);
        });
    }

    // Run a dialog on the GUI thread; block this worker for the answer.
    // A dead frame answers `fallback` (the cancelling choice).
    template <typename T, typename Fn>
    T Ask(T fallback, Fn fn) {
        auto prom = std::make_shared<std::promise<T>>();
        auto fut = prom->get_future();
        auto alive = alive_;
        auto frame = frame_;
        wxTheApp->CallAfter([prom, alive, frame, fallback, fn] {
            prom->set_value(alive->load() ? fn(frame) : fallback);
        });
        return fut.get();
    }

    std::shared_ptr<std::atomic<bool>> alive_;
    LoadstoneFrame* frame_;
};

// ---------------------------------------------------------------------------

LoadstoneFrame::LoadstoneFrame(loadstone::UiProfile profile, wxString coreVersion)
    : wxFrame(nullptr, wxID_ANY, FromRust(profile.title), wxDefaultPosition,
              wxSize(720, 560)),
      profile_(std::move(profile)),
      coreVersion_(std::move(coreVersion)),
      singleMod_(std::string(profile_.mode) == "single-mod") {
    CreateStatusBar();
    Bind(wxEVT_CHAR_HOOK, &LoadstoneFrame::OnCharHook, this);
    Bind(wxEVT_CLOSE_WINDOW, [this](wxCloseEvent& ev) {
        if (opInFlight_ && ev.CanVeto()) {
            if (wxMessageBox("An operation is still running. Closing now may leave "
                             "it unfinished. Close anyway?",
                             "Operation in progress", wxYES_NO | wxICON_WARNING,
                             this) != wxYES) {
                ev.Veto();
                return;
            }
        }
        ev.Skip();
    });

    if (singleMod_) {
        // The standalone-installer shape: straight to the one mod's page.
        SetStatusText("Loading...");
        OpenMod(FromRust(profile_.mod_id));
    } else {
        BuildCatalogPanel();
        StartCatalogFetch();
    }
}

// ---------------------------------------------------------------------------
// Catalog view.

void LoadstoneFrame::BuildCatalogPanel() {
    catalogPanel_ = new wxPanel(this);
    auto* sizer = new wxBoxSizer(wxVERTICAL);

    auto* heading = new wxStaticText(
        catalogPanel_, wxID_ANY,
        wxString::Format("%s (core %s)", FromRust(profile_.title), coreVersion_));
    sizer->Add(heading, 0, wxALL, 8);

    auto* listLabel = new wxStaticText(catalogPanel_, wxID_ANY, "&Mods:");
    sizer->Add(listLabel, 0, wxLEFT | wxRIGHT, 8);

    modList_ = new wxListBox(catalogPanel_, wxID_ANY);
    sizer->Add(modList_, 1, wxEXPAND | wxALL, 8);
    modList_->Bind(wxEVT_LISTBOX_DCLICK, [this](wxCommandEvent&) {
        if (modList_->GetSelection() != wxNOT_FOUND)
            OpenMod(entryIds_[modList_->GetSelection()]);
    });

    auto* buttons = new wxBoxSizer(wxHORIZONTAL);
    detailsBtn_ = new wxButton(catalogPanel_, wxID_ANY, "&Details");
    detailsBtn_->SetDefault(); // Enter in the list opens the selected mod
    detailsBtn_->Bind(wxEVT_BUTTON, [this](wxCommandEvent&) {
        if (modList_->GetSelection() != wxNOT_FOUND)
            OpenMod(entryIds_[modList_->GetSelection()]);
    });
    refreshBtn_ = new wxButton(catalogPanel_, wxID_ANY, "&Refresh");
    refreshBtn_->Bind(wxEVT_BUTTON, [this](wxCommandEvent&) { StartCatalogFetch(); });
    buttons->Add(detailsBtn_, 0, wxRIGHT, 8);
    buttons->Add(refreshBtn_, 0);
    sizer->Add(buttons, 0, wxALL, 8);

    catalogNotes_ = new wxStaticText(catalogPanel_, wxID_ANY, "");
    sizer->Add(catalogNotes_, 0, wxEXPAND | wxALL, 8);

    catalogPanel_->SetSizer(sizer);
}

void LoadstoneFrame::StartCatalogFetch() {
    if (fetchInFlight_) return;
    fetchInFlight_ = true;
    SetStatusText("Fetching the mod catalog...");
    detailsBtn_->Enable(false);
    refreshBtn_->Enable(false);
    // Placeholder so the list never reads as empty while the fetch runs.
    modList_->Clear();
    entryIds_.clear();
    modList_->Append("Loading mod list...");

    auto alive = alive_;
    std::thread([alive, this] {
        try {
            auto catalog = std::make_shared<loadstone::Catalog>(
                loadstone::fetch_catalog(kEmbeddedProfile, ""));
            wxTheApp->CallAfter([alive, this, catalog] {
                if (alive->load()) OnCatalog(*catalog);
            });
        } catch (const std::exception& e) {
            std::string msg = e.what();
            wxTheApp->CallAfter([alive, this, msg] {
                if (!alive->load()) return;
                fetchInFlight_ = false;
                refreshBtn_->Enable(true);
                modList_->Clear();
                modList_->Append("Could not load the mod list. Press Refresh to retry.");
                SetStatusText("Catalog fetch failed.");
                wxMessageBox(wxString::FromUTF8(msg.c_str()),
                             "Could not load the mod catalog", wxOK | wxICON_ERROR, this);
            });
        }
    }).detach();
}

void LoadstoneFrame::OnCatalog(const loadstone::Catalog& catalog) {
    fetchInFlight_ = false;
    refreshBtn_->Enable(true);

    modList_->Clear();
    entryIds_.clear();
    for (const auto& e : catalog.entries) {
        entryIds_.push_back(FromRust(e.id));
        wxString line =
            wxString::Format("%s, %s", FromRust(e.name), FromRust(e.status));
        wxString summary = FromRust(e.summary);
        if (!summary.empty()) line += ", " + summary;
        modList_->Append(line);
    }
    bool any = !entryIds_.empty();
    detailsBtn_->Enable(any);
    if (any) {
        modList_->SetSelection(0);
    } else {
        modList_->Append("No mods available.");
    }

    wxString notes;
    for (const auto& n : catalog.notes) {
        if (!notes.empty()) notes += "\n";
        notes += FromRust(n);
    }
    catalogNotes_->SetLabel(notes);
    catalogNotes_->Wrap(GetClientSize().GetWidth() - 32);
    catalogPanel_->Layout();

    SetStatusText(wxString::Format("Catalog loaded: %zu mods.", entryIds_.size()));
    // Only steal focus when the catalog view is what's showing.
    if (!pagePanel_) modList_->SetFocus();
}

// ---------------------------------------------------------------------------
// Mod page view.

void LoadstoneFrame::OpenMod(const wxString& id) {
    if (fetchInFlight_ || opInFlight_) return;
    fetchInFlight_ = true;
    SetStatusText(wxString::Format("Loading %s...", id));

    auto alive = alive_;
    std::string modId = ToStd(id);
    std::thread([alive, this, modId] {
        try {
            auto page = std::make_shared<loadstone::ModPage>(
                loadstone::fetch_mod_page(kEmbeddedProfile, "", modId));
            wxTheApp->CallAfter([alive, this, page] {
                if (alive->load()) OnModPage(*page);
            });
        } catch (const std::exception& e) {
            std::string msg = e.what();
            wxTheApp->CallAfter([alive, this, msg] {
                if (!alive->load()) return;
                fetchInFlight_ = false;
                SetStatusText("Could not load the mod page.");
                wxMessageBox(wxString::FromUTF8(msg.c_str()), "Could not load mod",
                             wxOK | wxICON_ERROR, this);
            });
        }
    }).detach();
}

void LoadstoneFrame::OnModPage(const loadstone::ModPage& page) {
    fetchInFlight_ = false;
    BuildModPage(page);
    if (catalogPanel_) catalogPanel_->Hide();
    Layout();
    SetStatusText(FromRust(page.status));
    // Land keyboard focus on the page's first control.
    if (wxWindow* first = pagePanel_->GetChildren().IsEmpty()
                              ? nullptr
                              : pagePanel_->GetChildren().front())
        first->SetFocus();
}

void LoadstoneFrame::GoBack() {
    if (!pagePanel_ || singleMod_ || opInFlight_) return;
    pagePanel_->Destroy();
    pagePanel_ = nullptr;
    opLog_ = nullptr;
    gameDirCtrl_ = nullptr;
    pageControls_.clear();
    catalogPanel_->Show();
    Layout();
    SetStatusText("");
    modList_->SetFocus();
    // Refresh so installed statuses stay honest after operations.
    StartCatalogFetch();
}

void LoadstoneFrame::BuildModPage(const loadstone::ModPage& page) {
    if (pagePanel_) {
        pagePanel_->Destroy();
        pagePanel_ = nullptr;
    }
    opLog_ = nullptr;
    gameDirCtrl_ = nullptr;
    pageControls_.clear();
    pageModId_ = FromRust(page.id);
    pageGame_ = FromRust(page.installed_game);
    pageChannel_ = FromRust(page.channel);

    pagePanel_ = new wxScrolledWindow(this);
    pagePanel_->SetScrollRate(0, 12);
    auto* sizer = new wxBoxSizer(wxVERTICAL);

    if (!singleMod_) {
        auto* back = new wxButton(pagePanel_, wxID_ANY, "&Back to mod list");
        back->Bind(wxEVT_BUTTON, [this](wxCommandEvent&) { GoBack(); });
        pageControls_.push_back(back);
        sizer->Add(back, 0, wxALL, 8);
    }

    wxString headingText = FromRust(page.name);
    wxString authors = FromRust(page.authors);
    if (!authors.empty()) headingText += " by " + authors;
    auto* heading = new wxStaticText(pagePanel_, wxID_ANY, headingText);
    heading->SetFont(heading->GetFont().MakeBold().Scaled(1.2f));
    sizer->Add(heading, 0, wxALL, 8);

    auto* status = new wxStaticText(pagePanel_, wxID_ANY, FromRust(page.status));
    sizer->Add(status, 0, wxLEFT | wxRIGHT | wxBOTTOM, 8);

    // Game directory row: label, editable path, Browse — the shape every
    // per-mod installer used, so the folder is visible and overridable
    // before installing.
    wxString gameName = FromRust(page.game_name);
    wxString dirLabelText =
        gameName.empty() ? wxString("&Game directory:")
                         : wxString::Format("&%s directory:", gameName);
    auto* dirRow = new wxBoxSizer(wxHORIZONTAL);
    dirRow->Add(new wxStaticText(pagePanel_, wxID_ANY, dirLabelText), 0,
                wxALIGN_CENTER_VERTICAL | wxRIGHT, 8);
    gameDirCtrl_ = new wxTextCtrl(pagePanel_, wxID_ANY, FromRust(page.game_dir));
    // Installed: the folder is fixed in state; show it read-only.
    gameDirCtrl_->Enable(!page.can_uninstall);
    dirRow->Add(gameDirCtrl_, 1, wxALIGN_CENTER_VERTICAL | wxRIGHT, 8);
    auto* browse = new wxButton(pagePanel_, wxID_ANY, "Bro&wse...");
    browse->Enable(!page.can_uninstall);
    browse->Bind(wxEVT_BUTTON, [this, gameName](wxCommandEvent&) {
        wxString prompt = gameName.empty()
                              ? wxString("Select the game folder")
                              : wxString::Format("Select the %s folder", gameName);
        wxDirDialog dlg(this, prompt, gameDirCtrl_->GetValue(),
                        wxDD_DEFAULT_STYLE | wxDD_DIR_MUST_EXIST);
        if (dlg.ShowModal() == wxID_OK) gameDirCtrl_->SetValue(dlg.GetPath());
    });
    dirRow->Add(browse, 0);
    if (!page.can_uninstall) {
        pageControls_.push_back(gameDirCtrl_);
        pageControls_.push_back(browse);
    }
    sizer->Add(dirRow, 0, wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 8);

    wxString description = FromRust(page.description);
    if (!description.empty()) {
        auto* descLabel = new wxStaticText(pagePanel_, wxID_ANY, "Description:");
        sizer->Add(descLabel, 0, wxLEFT | wxRIGHT, 8);
        auto* desc = new wxTextCtrl(pagePanel_, wxID_ANY, description,
                                    wxDefaultPosition, wxSize(-1, 70),
                                    wxTE_MULTILINE | wxTE_READONLY | wxTE_BESTWRAP);
        sizer->Add(desc, 0, wxEXPAND | wxALL, 8);
    }

    if (!page.settings.empty()) {
        auto* box = new wxStaticBoxSizer(wxVERTICAL, pagePanel_, "Settings");
        wxWindow* parent = box->GetStaticBox();
        for (const auto& s : page.settings) {
            wxString kind = FromRust(s.kind);
            wxString label = FromRust(s.label);
            wxString value = FromRust(s.value);
            wxString sid = FromRust(s.id);
            wxString describe = FromRust(s.description);

            if (kind == "boolean") {
                auto* check = new wxCheckBox(parent, wxID_ANY, label);
                check->SetValue(value == "true");
                check->Enable(page.settings_editable);
                if (!describe.empty()) check->SetToolTip(describe);
                check->Bind(wxEVT_CHECKBOX, [this, sid, check](wxCommandEvent& ev) {
                    if (!ApplySetting(sid, ev.IsChecked() ? "true" : "false"))
                        check->SetValue(!ev.IsChecked()); // rejected: revert
                });
                if (page.settings_editable) pageControls_.push_back(check);
                box->Add(check, 0, wxALL, 6);
            } else if (kind == "choice") {
                auto* row = new wxBoxSizer(wxHORIZONTAL);
                row->Add(new wxStaticText(parent, wxID_ANY, label + ":"), 0,
                         wxALIGN_CENTER_VERTICAL | wxRIGHT, 8);
                auto* choice = new wxChoice(parent, wxID_ANY);
                int selected = 0;
                std::vector<wxString> values;
                for (const auto& o : s.options) {
                    values.push_back(FromRust(o.value));
                    choice->Append(FromRust(o.label));
                    if (values.back() == value) selected = choice->GetCount() - 1;
                }
                if (!values.empty()) choice->SetSelection(selected);
                choice->Enable(page.settings_editable);
                if (!describe.empty()) choice->SetToolTip(describe);
                int previous = selected;
                choice->Bind(wxEVT_CHOICE,
                             [this, sid, choice, values, previous](wxCommandEvent& ev) mutable {
                                 int idx = ev.GetSelection();
                                 if (idx < 0 || idx >= static_cast<int>(values.size())) return;
                                 if (ApplySetting(sid, values[idx]))
                                     previous = idx;
                                 else
                                     choice->SetSelection(previous);
                             });
                if (page.settings_editable) pageControls_.push_back(choice);
                row->Add(choice, 0);
                box->Add(row, 0, wxALL, 6);
            } else { // string / number: edit, apply with Enter
                auto* row = new wxBoxSizer(wxHORIZONTAL);
                row->Add(new wxStaticText(parent, wxID_ANY, label + ":"), 0,
                         wxALIGN_CENTER_VERTICAL | wxRIGHT, 8);
                auto* text = new wxTextCtrl(parent, wxID_ANY, value,
                                            wxDefaultPosition, wxSize(180, -1),
                                            wxTE_PROCESS_ENTER);
                text->Enable(page.settings_editable);
                if (!describe.empty()) text->SetToolTip(describe);
                wxString last = value;
                text->Bind(wxEVT_TEXT_ENTER, [this, sid, text, last](wxCommandEvent&) mutable {
                    if (ApplySetting(sid, text->GetValue()))
                        last = text->GetValue();
                    else
                        text->SetValue(last); // rejected: restore
                });
                if (page.settings_editable) pageControls_.push_back(text);
                row->Add(text, 0);
                row->Add(new wxStaticText(parent, wxID_ANY, "(press Enter to save)"), 0,
                         wxALIGN_CENTER_VERTICAL | wxLEFT, 8);
                box->Add(row, 0, wxALL, 6);
            }
        }
        wxString note = FromRust(page.settings_note);
        if (!note.empty())
            box->Add(new wxStaticText(parent, wxID_ANY, note), 0, wxALL, 6);
        sizer->Add(box, 0, wxEXPAND | wxALL, 8);
    }

    for (const auto& n : page.notes) {
        auto* note = new wxStaticText(pagePanel_, wxID_ANY, FromRust(n));
        note->Wrap(640);
        sizer->Add(note, 0, wxLEFT | wxRIGHT | wxBOTTOM, 8);
    }

    // Activity log, always present so operations narrate into a familiar
    // place (and screen-reader users can review it afterwards).
    sizer->Add(new wxStaticText(pagePanel_, wxID_ANY, "Activity:"), 0,
               wxLEFT | wxRIGHT, 8);
    opLog_ = new wxTextCtrl(pagePanel_, wxID_ANY, "", wxDefaultPosition,
                            wxSize(-1, 130), wxTE_MULTILINE | wxTE_READONLY);
    sizer->Add(opLog_, 1, wxEXPAND | wxALL, 8);

    // Bottom button row, installer style: one primary button that reads
    // Install or Update per state, Uninstall, then the mod's actions.
    auto* buttons = new wxBoxSizer(wxHORIZONTAL);
    auto* primary = new wxButton(pagePanel_, wxID_ANY,
                                 page.can_update ? "&Update" : "&Install");
    primary->Enable(page.can_install || page.can_update);
    OpKind primaryKind = page.can_update ? OpKind::Update : OpKind::Install;
    primary->Bind(wxEVT_BUTTON,
                  [this, primaryKind](wxCommandEvent&) { RunOperation(primaryKind); });
    if (primary->IsEnabled()) pageControls_.push_back(primary);
    buttons->Add(primary, 0, wxRIGHT, 8);

    auto* uninstall = new wxButton(pagePanel_, wxID_ANY, "U&ninstall");
    uninstall->Enable(page.can_uninstall);
    uninstall->Bind(wxEVT_BUTTON,
                    [this](wxCommandEvent&) { RunOperation(OpKind::Uninstall); });
    if (page.can_uninstall) pageControls_.push_back(uninstall);
    buttons->Add(uninstall, 0, wxRIGHT, 8);

    for (const auto& a : page.actions) {
        auto* b = new wxButton(pagePanel_, wxID_ANY, FromRust(a.label));
        b->Enable(page.actions_available);
        wxString describe = FromRust(a.description);
        if (!describe.empty()) b->SetToolTip(describe);
        wxString actionId = FromRust(a.id);
        b->Bind(wxEVT_BUTTON, [this, actionId](wxCommandEvent&) {
            RunOperation(OpKind::Action, actionId);
        });
        if (page.actions_available) pageControls_.push_back(b);
        buttons->Add(b, 0, wxRIGHT, 8);
    }
    sizer->Add(buttons, 0, wxALL, 8);

    pagePanel_->SetSizer(sizer);
    pagePanel_->FitInside();
}

// ---------------------------------------------------------------------------
// Operations.

void LoadstoneFrame::AppendOpLog(const wxString& line) {
    if (opLog_) opLog_->AppendText(line + "\n");
}

void LoadstoneFrame::SetOpProgress(unsigned percent) {
    SetStatusText(wxString::Format("Working... %u%%", percent));
}

void LoadstoneFrame::RunOperation(OpKind kind, const wxString& actionId) {
    if (opInFlight_ || fetchInFlight_) return;
    if (kind == OpKind::Uninstall) {
        if (wxMessageBox(wxString::Format("Uninstall %s?", pageModId_),
                         "Confirm uninstall", wxYES_NO | wxICON_QUESTION,
                         this) != wxYES)
            return;
    }
    opInFlight_ = true;
    for (auto* c : pageControls_) c->Enable(false);
    if (opLog_) opLog_->Clear();
    SetStatusText("Working...");

    auto alive = alive_;
    auto cb = std::make_shared<GuiUiCallbacks>(alive_, this);
    std::string modId = ToStd(pageModId_);
    std::string game = ToStd(pageGame_);
    std::string channel = ToStd(pageChannel_);
    std::string action = ToStd(actionId);
    // The path the user sees (and may have browsed to) is the one the
    // engine gets; empty falls back to auto-detection.
    std::string gameDir = gameDirCtrl_ ? ToStd(gameDirCtrl_->GetValue()) : "";
    std::thread([alive, this, cb, kind, modId, game, channel, action, gameDir] {
        std::string result, error;
        try {
            switch (kind) {
                case OpKind::Install:
                    result = std::string(loadstone::run_install(
                        kEmbeddedProfile, "", modId, "", false, gameDir, "", *cb));
                    break;
                case OpKind::Update:
                    result = std::string(loadstone::run_install(
                        kEmbeddedProfile, "", modId, channel, true, gameDir, "", *cb));
                    break;
                case OpKind::Uninstall:
                    result = std::string(loadstone::run_uninstall("", game, modId, *cb));
                    break;
                case OpKind::Action:
                    result = std::string(
                        loadstone::run_mod_action("", game, modId, action, *cb));
                    break;
            }
        } catch (const std::exception& e) {
            error = e.what();
        }
        wxTheApp->CallAfter([alive, this, result, error] {
            if (alive->load()) OnOpDone(result, error);
        });
    }).detach();
}

void LoadstoneFrame::OnOpDone(const std::string& result, const std::string& error) {
    opInFlight_ = false;
    if (!error.empty()) {
        SetStatusText("The operation failed.");
        AppendOpLog(wxString::FromUTF8(error.c_str()));
        wxMessageBox(wxString::FromUTF8(error.c_str()), "Operation failed",
                     wxOK | wxICON_ERROR, this);
    } else {
        SetStatusText(wxString::FromUTF8(result.c_str()));
        wxMessageBox(wxString::FromUTF8(result.c_str()), "Done",
                     wxOK | wxICON_INFORMATION, this);
    }
    // Reload the page so status, buttons, and settings reflect reality.
    OpenMod(pageModId_);
}

// ---------------------------------------------------------------------------

bool LoadstoneFrame::ApplySetting(const wxString& settingId, const wxString& rawValue) {
    try {
        rust::String note = loadstone::apply_setting(
            "", ToStd(pageGame_), ToStd(pageModId_), ToStd(settingId), ToStd(rawValue));
        wxString msg = "Setting saved.";
        wxString noteText = FromRust(note);
        if (!noteText.empty()) msg += " " + noteText;
        SetStatusText(msg);
        return true;
    } catch (const std::exception& e) {
        wxMessageBox(wxString::FromUTF8(e.what()), "Setting not changed",
                     wxOK | wxICON_ERROR, this);
        return false;
    }
}

void LoadstoneFrame::OnCharHook(wxKeyEvent& event) {
    // Escape returns from a mod page to the list (manager mode only).
    if (event.GetKeyCode() == WXK_ESCAPE && pagePanel_ && !singleMod_ && !opInFlight_) {
        GoBack();
        return;
    }
    event.Skip();
}

// ---------------------------------------------------------------------------
// Smoke-mode callbacks: auto-answer, record everything.

class SmokeUi final : public loadstone::UiCallbacks {
public:
    explicit SmokeUi(std::ofstream& out) : out_(out) {}

    void log(rust::Str m) override { out_ << "op-log: " << std::string(m) << "\n"; }
    void progress(std::uint32_t) override {}
    bool confirm(rust::Str m) override {
        out_ << "op-confirm: " << std::string(m) << " -> yes\n";
        return true;
    }
    std::uint8_t retry_skip_cancel(rust::Str m) override {
        out_ << "op-rsc: " << std::string(m) << " -> cancel\n";
        return 2;
    }
    rust::String pick_directory(rust::Str id, rust::Str, rust::Str) override {
        out_ << "op-pickdir: " << std::string(id) << " -> cancel\n";
        return rust::String();
    }

private:
    std::ofstream& out_;
};

// ---------------------------------------------------------------------------

class LoadstoneApp : public wxApp {
public:
    bool OnInit() override;
};

wxIMPLEMENT_APP(LoadstoneApp);

bool LoadstoneApp::OnInit() {
    rust::String version;
    loadstone::UiProfile profile;
    std::string error;
    try {
        version = loadstone::core_version();
        profile = loadstone::ui_profile(kEmbeddedProfile);
    } catch (const std::exception& e) {
        error = e.what();
    }

    // Headless smoke check.
    if (const char* smokeOut = std::getenv("LOADSTONE_SMOKE_OUT")) {
        std::ofstream out(smokeOut);
        if (!error.empty()) {
            out << "error: " << error << "\n";
        } else {
            out << "version: " << std::string(version) << "\n";
            out << "mode: " << std::string(profile.mode) << "\n";
            out << "title: " << std::string(profile.title) << "\n";
            const char* stateEnv = std::getenv("LOADSTONE_SMOKE_STATE");
            std::string state = stateEnv ? stateEnv : "";
            try {
                out << "profile: " << std::string(loadstone::resolve_profile(kEmbeddedProfile))
                    << "\n";
                out << "installed: " << std::string(loadstone::installed_json(state)) << "\n";
                auto catalog = loadstone::fetch_catalog(kEmbeddedProfile, state);
                out << "catalog: " << catalog.entries.size() << "\n";
                for (const auto& e : catalog.entries)
                    out << "catalog-entry: " << std::string(e.id) << " | "
                        << std::string(e.status) << "\n";
                for (const auto& n : catalog.notes)
                    out << "catalog-note: " << std::string(n) << "\n";
                // Optional deep check: dump one mod's page model.
                if (const char* modId = std::getenv("LOADSTONE_SMOKE_MOD")) {
                    auto page = loadstone::fetch_mod_page(kEmbeddedProfile, state, modId);
                    out << "page: " << std::string(page.name) << " | " << std::string(page.status)
                        << " | latest=" << std::string(page.latest_version)
                        << " | install=" << page.can_install << " update=" << page.can_update
                        << " uninstall=" << page.can_uninstall << "\n";
                    out << "page-game: " << std::string(page.game_name) << " | dir="
                        << std::string(page.game_dir) << "\n";
                    for (const auto& s : page.settings)
                        out << "page-setting: " << std::string(s.id) << " ("
                            << std::string(s.kind) << ") = " << std::string(s.value)
                            << (page.settings_editable ? "" : " [read-only]") << "\n";
                    for (const auto& a : page.actions)
                        out << "page-action: " << std::string(a.id) << "\n";
                    for (const auto& n : page.notes)
                        out << "page-note: " << std::string(n) << "\n";
                }
                // Optional full-path check: run a real install through the
                // bridge with auto-answered callbacks.
                if (const char* installId = std::getenv("LOADSTONE_SMOKE_INSTALL")) {
                    const char* gameDir = std::getenv("LOADSTONE_SMOKE_GAME_DIR");
                    const char* release = std::getenv("LOADSTONE_SMOKE_RELEASE");
                    SmokeUi sui(out);
                    try {
                        auto summary = loadstone::run_install(
                            kEmbeddedProfile, state, installId, "", false,
                            gameDir ? gameDir : "", release ? release : "", sui);
                        out << "op-result: " << std::string(summary) << "\n";
                        out << "installed-after: "
                            << std::string(loadstone::installed_json(state)) << "\n";
                    } catch (const std::exception& e) {
                        out << "op-error: " << e.what() << "\n";
                    }
                }
                // Optional: uninstall driver, value "game:id".
                if (const char* spec = std::getenv("LOADSTONE_SMOKE_UNINSTALL")) {
                    std::string s(spec);
                    auto colon = s.find(':');
                    SmokeUi sui(out);
                    try {
                        if (colon == std::string::npos)
                            throw std::runtime_error("LOADSTONE_SMOKE_UNINSTALL wants game:id");
                        auto summary = loadstone::run_uninstall(
                            state, s.substr(0, colon), s.substr(colon + 1), sui);
                        out << "op-result: " << std::string(summary) << "\n";
                        out << "installed-after: "
                            << std::string(loadstone::installed_json(state)) << "\n";
                    } catch (const std::exception& e) {
                        out << "op-error: " << e.what() << "\n";
                    }
                }
            } catch (const std::exception& e) {
                out << "catalog-error: " << e.what() << "\n";
            }
        }
        return false; // exit without a window
    }

    if (!error.empty()) {
        wxMessageBox(wxString::FromUTF8(error.c_str()), "Loadstone startup error",
                     wxOK | wxICON_ERROR);
        return false;
    }

    auto* frame = new LoadstoneFrame(std::move(profile), FromRust(version));
    frame->Show(true);
    return true;
}
