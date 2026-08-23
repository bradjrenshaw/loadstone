// Loadstone Mod Manager — walking-skeleton shell.
//
// Proves the full stack: this C++ wxWidgets window shows data obtained from
// the Rust core through the cxx bridge. Real pages replace this frame next.
//
// Smoke mode: when the LOADSTONE_SMOKE_OUT environment variable names a
// file, the app writes what it got from the bridge there and exits without
// showing a window — CI and terminal sessions verify the stack headlessly.

#include <wx/wx.h>
#include <wx/listbox.h>

#include <cstdlib>
#include <fstream>
#include <string>

#include "rust/cxx.h"
#include "loadstone-bridge/src/lib.rs.h"

// The compile-time distribution profile. "null" = resolve at runtime
// (loadstone.json sidecar, else the default manager profile). Branded
// installer builds will inject real JSON here.
static const char* kEmbeddedProfile = "null";

namespace {

wxString FromRust(const rust::String& s) {
    return wxString::FromUTF8(s.data(), s.size());
}

} // namespace

class LoadstoneApp : public wxApp {
public:
    bool OnInit() override;
};

wxIMPLEMENT_APP(LoadstoneApp);

bool LoadstoneApp::OnInit() {
    rust::String version;
    rust::String title;
    rust::String profileJson;
    rust::String installedJson;
    std::string error;
    try {
        version = loadstone::core_version();
        title = loadstone::profile_title(kEmbeddedProfile);
        profileJson = loadstone::resolve_profile(kEmbeddedProfile);
        installedJson = loadstone::installed_json("");
    } catch (const rust::Error& e) {
        error = e.what();
    }

    // Headless smoke check.
    if (const char* smokeOut = std::getenv("LOADSTONE_SMOKE_OUT")) {
        std::ofstream out(smokeOut);
        if (!error.empty()) {
            out << "error: " << error << "\n";
        } else {
            out << "version: " << std::string(version) << "\n";
            out << "title: " << std::string(title) << "\n";
            out << "profile: " << std::string(profileJson) << "\n";
            out << "installed: " << std::string(installedJson) << "\n";
        }
        return false; // exit without a window
    }

    if (!error.empty()) {
        wxMessageBox(wxString::FromUTF8(error.c_str()), "Loadstone startup error",
                     wxOK | wxICON_ERROR);
        return false;
    }

    auto* frame = new wxFrame(nullptr, wxID_ANY, FromRust(title),
                              wxDefaultPosition, wxSize(600, 400));
    auto* panel = new wxPanel(frame);
    auto* sizer = new wxBoxSizer(wxVERTICAL);

    auto* heading = new wxStaticText(
        panel, wxID_ANY,
        wxString::Format("%s — core %s", FromRust(title), FromRust(version)));
    sizer->Add(heading, 0, wxALL, 8);

    auto* listLabel = new wxStaticText(panel, wxID_ANY, "Installed mods:");
    sizer->Add(listLabel, 0, wxLEFT | wxRIGHT, 8);

    // Placeholder listing: raw entries until the real mod page lands. The
    // wxListBox is a native control, so screen readers see a proper list.
    auto* list = new wxListBox(panel, wxID_ANY);
    wxString installed = FromRust(installedJson);
    if (installed == "[]") {
        list->Append("Nothing installed yet.");
    } else {
        list->Append(installed);
    }
    sizer->Add(list, 1, wxEXPAND | wxALL, 8);

    panel->SetSizer(sizer);
    frame->CreateStatusBar();
    frame->SetStatusText("Ready.");
    frame->Show(true);
    return true;
}
