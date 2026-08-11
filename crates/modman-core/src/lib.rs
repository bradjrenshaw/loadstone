//! Core library for the accessible mod manager package format (SPEC.md).
//!
//! This crate is shared by the developer CLI (`modman`) and, later, the
//! end-user manager application. It contains the manifest types, semantic
//! validation, and release-manifest building — no UI and no network access.

pub mod release;
pub mod tokens;
pub mod types;
pub mod validate;
