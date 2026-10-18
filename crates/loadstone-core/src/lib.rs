//! Loadstone Mod Manager core library (see SPEC.md for the package format).
//!
//! This crate is shared by the developer CLI (`loadstone`) and the end-user
//! manager application (a C++ wxWidgets GUI linking this crate as a static
//! library over a `cxx` bridge). It contains the manifest types, semantic
//! validation, and release-manifest building — no UI. All untrusted-input
//! handling (parsing, extraction, verification) belongs here, not in the GUI.

pub mod archive;
pub mod auth;
pub mod context;
pub mod detect;
pub mod engine;
pub mod fetch;
pub mod jsonedit;
pub mod macho;
pub mod ops;
pub mod prefs;
pub mod process;
pub mod profile;
pub mod registry;
pub mod release;
pub mod secrets;
pub mod selfupdate;
pub mod settings;
pub mod source;
pub mod tokens;
pub mod track;
pub mod types;
pub mod validate;
