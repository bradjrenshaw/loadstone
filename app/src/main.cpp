// Loadstone Mod Manager — wxWidgets shell over the Rust core.
//
// Two views, both built from typed models the cxx bridge returns:
//   - the catalog: every mod visible through the profile's registries,
//     merged with installed state;
//   - the mod page: status, install/update/uninstall buttons, a live
//     settings form, and declared actions.
// Network fetches run on worker threads; results hop back to the GUI
// thread via wxTheApp->CallAfter (thread-safe), guarded by an alive flag
// the frame clears on destruction. Install operations land in the next
// phase — their buttons explain that for now.
//
// Everything is native wx controls with real labels, so screen readers see
// a proper list, checkboxes, and buttons.
//
// Smoke mode: when the LOADSTONE_SMOKE_OUT environment variable names a
// file, the app writes what it got from the bridge there and exits without
// showing a window — CI and terminal sessions verify the stack headlessly.

#include <wx/wx.h>
#include <wx/choice.h>
#include <wx/listbox.h>
#include <wx/scrolwin.h>
#include <wx/statline.h>

#include <atomic>
#include <cstdlib>
#include <fstream>
#include <memory>
#include <string>
#include <thread>
#include <vector>

#include "rust/cxx.h"
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

std::string ToStd(const wxString& s) {
    return std::string(s.utf8_str());
}

} // namespace

// ---------------------------------------------------------------------------

class LoadstoneFrame : public wxFrame {
public:
    LoadstoneFrame(loadstone::UiProfile profile, wxString coreVersion);
    ~LoadstoneFrame() override { alive_->store(false); }

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

    // The settings form writes through the bridge as controls change.
    // Returns false (and shows the error) when the value was rejected.
    bool ApplySetting(const wxString& settingId, const wxString& rawValue);

    void ShowNotYet(const wxString& what);
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

    bool fetchInFlight_ = false;
    std::shared_ptr<std::atomic<bool>> alive_ = std::make_shared<std::atomic<bool>>(true);
};

LoadstoneFrame::LoadstoneFrame(loadstone::UiProfile profile, wxString coreVersion)
    : wxFrame(nullptr, wxID_ANY, FromRust(profile.title), wxDefaultPosition,
              wxSize(720, 560)),
      profile_(std::move(profile)),
      coreVersion_(std::move(coreVersion)),
      singleMod_(std::string(profile_.mode) == "single-mod") {
    CreateStatusBar();
    Bind(wxEVT_CHAR_HOOK, &LoadstoneFrame::OnCharHook, this);

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
    modList_->SetFocus();
}

// ---------------------------------------------------------------------------
// Mod page view.

void LoadstoneFrame::OpenMod(const wxString& id) {
    if (fetchInFlight_) return;
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
    if (!pagePanel_ || singleMod_) return;
    pagePanel_->Destroy();
    pagePanel_ = nullptr;
    catalogPanel_->Show();
    Layout();
    SetStatusText("");
    modList_->SetFocus();
    // Installed status may have changed once operations land; harmless now,
    // and keeps the list honest later.
    StartCatalogFetch();
}

void LoadstoneFrame::BuildModPage(const loadstone::ModPage& page) {
    if (pagePanel_) {
        pagePanel_->Destroy();
        pagePanel_ = nullptr;
    }
    pageModId_ = FromRust(page.id);
    pageGame_ = FromRust(page.installed_game);

    pagePanel_ = new wxScrolledWindow(this);
    pagePanel_->SetScrollRate(0, 12);
    auto* sizer = new wxBoxSizer(wxVERTICAL);

    if (!singleMod_) {
        auto* back = new wxButton(pagePanel_, wxID_ANY, "&Back to mod list");
        back->Bind(wxEVT_BUTTON, [this](wxCommandEvent&) { GoBack(); });
        sizer->Add(back, 0, wxALL, 8);
    }

    wxString headingText = FromRust(page.name);
    wxString authors = FromRust(page.authors);
    if (!authors.empty()) headingText += " by " + authors;
    auto* heading = new wxStaticText(pagePanel_, wxID_ANY, headingText);
    heading->SetFont(heading->GetFont().MakeBold().Scaled(1.2f));
    sizer->Add(heading, 0, wxALL, 8);

    wxString statusText = FromRust(page.status);
    wxString latest = FromRust(page.latest_version);
    if (!latest.empty()) statusText += ". Latest release: " + latest;
    auto* status = new wxStaticText(pagePanel_, wxID_ANY, statusText);
    sizer->Add(status, 0, wxLEFT | wxRIGHT | wxBOTTOM, 8);

    wxString description = FromRust(page.description);
    if (!description.empty()) {
        auto* descLabel = new wxStaticText(pagePanel_, wxID_ANY, "Description:");
        sizer->Add(descLabel, 0, wxLEFT | wxRIGHT, 8);
        auto* desc = new wxTextCtrl(pagePanel_, wxID_ANY, description,
                                    wxDefaultPosition, wxSize(-1, 90),
                                    wxTE_MULTILINE | wxTE_READONLY | wxTE_BESTWRAP);
        sizer->Add(desc, 0, wxEXPAND | wxALL, 8);
    }

    // Install / Update / Uninstall — wired to the engine in the next build.
    auto* ops = new wxBoxSizer(wxHORIZONTAL);
    auto addOp = [&](const wxString& label, bool enabled, const wxString& what) {
        auto* b = new wxButton(pagePanel_, wxID_ANY, label);
        b->Enable(enabled);
        b->Bind(wxEVT_BUTTON, [this, what](wxCommandEvent&) { ShowNotYet(what); });
        ops->Add(b, 0, wxRIGHT, 8);
        return b;
    };
    addOp("&Install", page.can_install, "Installing");
    addOp("&Update", page.can_update, "Updating");
    addOp("U&ninstall", page.can_uninstall, "Uninstalling");
    sizer->Add(ops, 0, wxALL, 8);

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

    if (!page.actions.empty()) {
        auto* box = new wxStaticBoxSizer(wxVERTICAL, pagePanel_, "Actions");
        wxWindow* parent = box->GetStaticBox();
        for (const auto& a : page.actions) {
            auto* b = new wxButton(parent, wxID_ANY, FromRust(a.label));
            b->Enable(page.actions_available);
            wxString describe = FromRust(a.description);
            if (!describe.empty()) b->SetToolTip(describe);
            wxString label = FromRust(a.label);
            b->Bind(wxEVT_BUTTON, [this, label](wxCommandEvent&) { ShowNotYet(label); });
            box->Add(b, 0, wxALL, 6);
        }
        sizer->Add(box, 0, wxEXPAND | wxALL, 8);
    }

    for (const auto& n : page.notes) {
        auto* note = new wxStaticText(pagePanel_, wxID_ANY, FromRust(n));
        note->Wrap(640);
        sizer->Add(note, 0, wxLEFT | wxRIGHT | wxBOTTOM, 8);
    }

    pagePanel_->SetSizer(sizer);
    pagePanel_->FitInside();
}

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

void LoadstoneFrame::ShowNotYet(const wxString& what) {
    wxMessageBox(
        wxString::Format(
            "%s from this app arrives in the next build.\n\n"
            "Until then, the loadstone command-line tool can do it, for "
            "example: loadstone install %s",
            what, pageModId_),
        "Coming soon", wxOK | wxICON_INFORMATION, this);
}

void LoadstoneFrame::OnCharHook(wxKeyEvent& event) {
    // Escape returns from a mod page to the list (manager mode only).
    if (event.GetKeyCode() == WXK_ESCAPE && pagePanel_ && !singleMod_) {
        GoBack();
        return;
    }
    event.Skip();
}

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
            try {
                out << "profile: " << std::string(loadstone::resolve_profile(kEmbeddedProfile))
                    << "\n";
                out << "installed: " << std::string(loadstone::installed_json("")) << "\n";
                auto catalog = loadstone::fetch_catalog(kEmbeddedProfile, "");
                out << "catalog: " << catalog.entries.size() << "\n";
                for (const auto& e : catalog.entries)
                    out << "catalog-entry: " << std::string(e.id) << " | "
                        << std::string(e.status) << "\n";
                for (const auto& n : catalog.notes)
                    out << "catalog-note: " << std::string(n) << "\n";
                // Optional deep check: dump one mod's page model.
                if (const char* modId = std::getenv("LOADSTONE_SMOKE_MOD")) {
                    auto page = loadstone::fetch_mod_page(kEmbeddedProfile, "", modId);
                    out << "page: " << std::string(page.name) << " | " << std::string(page.status)
                        << " | latest=" << std::string(page.latest_version)
                        << " | install=" << page.can_install << " update=" << page.can_update
                        << " uninstall=" << page.can_uninstall << "\n";
                    for (const auto& s : page.settings)
                        out << "page-setting: " << std::string(s.id) << " ("
                            << std::string(s.kind) << ") = " << std::string(s.value)
                            << (page.settings_editable ? "" : " [read-only]") << "\n";
                    for (const auto& a : page.actions)
                        out << "page-action: " << std::string(a.id) << "\n";
                    for (const auto& n : page.notes)
                        out << "page-note: " << std::string(n) << "\n";
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
