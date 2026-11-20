//! Translations, in two halves:
//!
//! - **Loadstone's own text** — every message the manager shows lives in a
//!   Fluent catalog per language (`locales/<tag>.ftl`), compiled into the
//!   binary. Code asks for a message by id with [`t!`]; a message missing
//!   from the current language falls back to English.
//! - **Package text** — labels, descriptions and messages a mod author
//!   writes in a manifest are [`LocalizedText`]: a plain string, or an
//!   object of language tag to string (SPEC 18). The best match for the
//!   user's languages is picked when the text is shown.
//!
//! One language setting drives both. Until a frontend calls
//! [`set_language`], everything is English, so the developer CLI and the
//! tests are stable whatever the machine's locale.

use std::sync::{LazyLock, OnceLock, RwLock};

use fluent_bundle::concurrent::FluentBundle;
use fluent_bundle::FluentResource;
use fluent_langneg::{negotiate_languages, NegotiationStrategy};
use serde::de::{self, MapAccess, Visitor};
use serde::ser::SerializeMap;
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use unic_langid::LanguageIdentifier;

pub use fluent_bundle::{FluentArgs, FluentValue};

/// A language Loadstone's own interface is translated into.
pub struct Language {
    /// BCP 47 tag, also the catalog's file name.
    pub tag: &'static str,
    /// The language's name in that language, for the language picker.
    pub name: &'static str,
    /// Written right to left (the frontend mirrors its layout).
    pub rtl: bool,
    source: &'static str,
}

macro_rules! language {
    ($tag:literal, $name:literal) => {
        language!($tag, $name, false)
    };
    ($tag:literal, $name:literal, $rtl:literal) => {
        Language {
            tag: $tag,
            name: $name,
            rtl: $rtl,
            source: include_str!(concat!("../locales/", $tag, ".ftl")),
        }
    };
}

/// Every interface language, English first (the fallback for anything a
/// catalog lacks). The rest are in tag order.
pub static LANGUAGES: &[Language] = &[
    language!("en", "English"),
    language!("ar", "العربية", true),
    language!("cs", "Čeština"),
    language!("de", "Deutsch"),
    language!("es", "Español"),
    language!("fr", "Français"),
    language!("hu", "Magyar"),
    language!("it", "Italiano"),
    language!("ja", "日本語"),
    language!("ko", "한국어"),
    language!("pl", "Polski"),
    language!("pt-BR", "Português (Brasil)"),
    language!("ru", "Русский"),
    language!("tr", "Türkçe"),
    language!("uk", "Українська"),
    language!("zh-Hans", "简体中文"),
    language!("zh-Hant", "繁體中文"),
];

struct State {
    /// The user's languages, most preferred first.
    requested: Vec<LanguageIdentifier>,
    /// Index into [`LANGUAGES`] of the interface language.
    ui: usize,
}

static STATE: RwLock<State> = RwLock::new(State { requested: Vec::new(), ui: 0 });

thread_local! {
    /// A per-thread language for tests ([`with_language`]), so tests
    /// running in parallel never see each other's choice.
    static OVERRIDE: std::cell::RefCell<Option<State>> = const { std::cell::RefCell::new(None) };
}

/// Run `f` against the current language state.
fn with_state<R>(f: impl FnOnce(&State) -> R) -> R {
    let mut f = Some(f);
    if let Some(r) = OVERRIDE.with(|o| o.borrow().as_ref().map(|s| (f.take().unwrap())(s))) {
        return r;
    }
    let state = STATE.read().unwrap_or_else(|e| e.into_inner());
    (f.take().unwrap())(&state)
}

fn resolve(choice: &str) -> State {
    let requested: Vec<LanguageIdentifier> = if choice.trim().is_empty() {
        sys_locale::get_locales().filter_map(|l| parse_tag(&l)).collect()
    } else {
        parse_tag(choice).into_iter().collect()
    };
    let ui = best_match(&requested, LANGUAGES.iter().map(|l| l.tag)).unwrap_or(0);
    State { requested, ui }
}

/// Choose the language. `choice` is a tag from [`LANGUAGES`] (or any BCP 47
/// tag, matched to the closest one), or empty for the system's languages.
/// Package text is matched against the same choice, so a mod translated
/// into a language Loadstone isn't still shows in it.
pub fn set_language(choice: &str) {
    let resolved = resolve(choice);
    *STATE.write().unwrap_or_else(|e| e.into_inner()) = resolved;
}

/// The interface language currently in use.
pub fn current() -> &'static Language {
    &LANGUAGES[with_state(|s| s.ui)]
}

/// Whether `tag` names one of the interface languages exactly.
pub fn is_supported(tag: &str) -> bool {
    LANGUAGES.iter().any(|l| l.tag == tag)
}

/// Parse a language tag, accepting the `_` separators some systems use.
fn parse_tag(tag: &str) -> Option<LanguageIdentifier> {
    tag.trim().replace('_', "-").parse().ok()
}

/// A well-formed BCP 47 tag with a two- or three-letter language, as
/// manifests must use (`fr`, `pt-BR`, `zh-Hans`; not `french` or `pt_BR`).
pub fn is_valid_tag(tag: &str) -> bool {
    !tag.contains('_')
        && tag.parse::<LanguageIdentifier>().is_ok_and(|id| {
            let language = id.language.as_str();
            (2..=3).contains(&language.len()) && language != "und"
        })
}

/// Index of the best of `available` for the user's languages; `None` when
/// none of them match. Chinese scripts and regions are matched through
/// likely subtags (`zh-TW` picks `zh-Hant`, `zh-CN` picks `zh-Hans`).
fn best_match<'a>(
    requested: &[LanguageIdentifier],
    available: impl IntoIterator<Item = &'a str>,
) -> Option<usize> {
    let available: Vec<(usize, LanguageIdentifier)> = available
        .into_iter()
        .enumerate()
        .filter_map(|(i, tag)| parse_tag(tag).map(|id| (i, id)))
        .collect();
    let ids: Vec<LanguageIdentifier> = available.iter().map(|(_, id)| id.clone()).collect();
    let best = negotiate_languages(requested, &ids, None, NegotiationStrategy::Filtering)
        .into_iter()
        .next()?;
    available.iter().find(|(_, id)| id == best).map(|(i, _)| *i)
}

// ---------------------------------------------------------------------------
// Loadstone's own messages

/// Each language's parsed catalog, built the first time it is used.
static BUNDLES: LazyLock<Vec<OnceLock<Option<FluentBundle<FluentResource>>>>> =
    LazyLock::new(|| LANGUAGES.iter().map(|_| OnceLock::new()).collect());

fn bundle(index: usize) -> Option<&'static FluentBundle<FluentResource>> {
    BUNDLES[index]
        .get_or_init(|| {
            let lang = &LANGUAGES[index];
            let resource = FluentResource::try_new(lang.source.to_string()).ok()?;
            let mut bundle = FluentBundle::new_concurrent(vec![parse_tag(lang.tag)?]);
            // Isolation marks would end up inside paths the user copies
            // and be read out by some screen readers.
            bundle.set_use_isolating(false);
            bundle.add_resource(resource).ok()?;
            Some(bundle)
        })
        .as_ref()
}

/// The message `id` in the interface language, else in English, else the
/// id itself (a test checks every id the code uses exists in English).
pub fn message(id: &str, args: Option<&FluentArgs>) -> String {
    let ui = with_state(|s| s.ui);
    for index in [ui, 0] {
        let Some(bundle) = bundle(index) else { continue };
        let Some(pattern) = bundle.get_message(id).and_then(|m| m.value()) else { continue };
        let mut errors = Vec::new();
        let text = bundle.format_pattern(pattern, args, &mut errors);
        if errors.is_empty() || index == 0 {
            return text.into_owned();
        }
    }
    id.to_string()
}

/// A value for a [`t!`] argument. Text arguments take `&str`, `String` or
/// `&String`; numbers stay numbers so plural forms can select on them.
pub trait Arg {
    fn into_value(self) -> FluentValue<'static>;
}

impl Arg for &str {
    fn into_value(self) -> FluentValue<'static> {
        FluentValue::from(self.to_string())
    }
}

impl Arg for String {
    fn into_value(self) -> FluentValue<'static> {
        FluentValue::from(self)
    }
}

impl Arg for &String {
    fn into_value(self) -> FluentValue<'static> {
        FluentValue::from(self.clone())
    }
}

impl Arg for &LocalizedText {
    fn into_value(self) -> FluentValue<'static> {
        FluentValue::from(self.get().to_string())
    }
}

macro_rules! numeric_arg {
    ($($ty:ty),*) => {$(
        impl Arg for $ty {
            fn into_value(self) -> FluentValue<'static> {
                FluentValue::from(self)
            }
        }
    )*};
}
numeric_arg!(u8, u16, u32, u64, usize, i32, i64, f64);

/// Loadstone's message `id` in the user's language, with optional named
/// arguments: `t!("installed-version", version = &v)`.
#[macro_export]
macro_rules! t {
    ($id:literal) => {
        $crate::i18n::message($id, None)
    };
    ($id:literal, $($name:ident = $value:expr),+ $(,)?) => {{
        let mut args = $crate::i18n::FluentArgs::new();
        $( args.set(stringify!($name), $crate::i18n::Arg::into_value($value)); )+
        $crate::i18n::message($id, Some(&args))
    }};
}

// ---------------------------------------------------------------------------
// Package text

/// Text a package author writes: one string for everyone, or translations
/// keyed by BCP 47 language tag. The first translation is the fallback
/// when neither the user's languages nor English are present.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LocalizedText {
    Plain(String),
    Translated(Vec<(String, String)>),
}

impl Default for LocalizedText {
    fn default() -> Self {
        LocalizedText::Plain(String::new())
    }
}

impl From<&str> for LocalizedText {
    fn from(s: &str) -> Self {
        LocalizedText::Plain(s.to_string())
    }
}

impl From<String> for LocalizedText {
    fn from(s: String) -> Self {
        LocalizedText::Plain(s)
    }
}

impl std::fmt::Display for LocalizedText {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.get())
    }
}

impl LocalizedText {
    /// The text for the user's languages: the best-matching translation,
    /// else English, else the first one.
    pub fn get(&self) -> &str {
        match self {
            LocalizedText::Plain(s) => s,
            LocalizedText::Translated(variants) => {
                if variants.is_empty() {
                    return "";
                }
                let tags = || variants.iter().map(|(tag, _)| tag.as_str());
                let index = with_state(|s| best_match(&s.requested, tags()))
                    .or_else(|| tags().position(|t| t.eq_ignore_ascii_case("en")))
                    .unwrap_or(0);
                &variants[index].1
            }
        }
    }

    pub fn is_translated(&self) -> bool {
        matches!(self, LocalizedText::Translated(_))
    }

    /// Every variant's text (one for plain text).
    pub fn texts(&self) -> Vec<&str> {
        match self {
            LocalizedText::Plain(s) => vec![s.as_str()],
            LocalizedText::Translated(v) => v.iter().map(|(_, s)| s.as_str()).collect(),
        }
    }

    /// True when there is no text, or any translation is blank.
    pub fn is_blank(&self) -> bool {
        match self {
            LocalizedText::Plain(s) => s.trim().is_empty(),
            LocalizedText::Translated(v) => {
                v.is_empty() || v.iter().any(|(_, s)| s.trim().is_empty())
            }
        }
    }

    /// The same text with `f` applied to every variant (token
    /// substitution).
    pub fn try_map<E>(
        &self,
        mut f: impl FnMut(&str) -> Result<String, E>,
    ) -> Result<LocalizedText, E> {
        Ok(match self {
            LocalizedText::Plain(s) => LocalizedText::Plain(f(s)?),
            LocalizedText::Translated(v) => LocalizedText::Translated(
                v.iter().map(|(t, s)| Ok((t.clone(), f(s)?))).collect::<Result<_, E>>()?,
            ),
        })
    }
}

impl Serialize for LocalizedText {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        match self {
            LocalizedText::Plain(s) => serializer.serialize_str(s),
            LocalizedText::Translated(variants) => {
                let mut map = serializer.serialize_map(Some(variants.len()))?;
                for (tag, text) in variants {
                    map.serialize_entry(tag, text)?;
                }
                map.end()
            }
        }
    }
}

impl<'de> Deserialize<'de> for LocalizedText {
    fn deserialize<D: Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        struct TextVisitor;

        impl<'de> Visitor<'de> for TextVisitor {
            type Value = LocalizedText;

            fn expecting(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                f.write_str("a string, or an object of language tag to string")
            }

            fn visit_str<E: de::Error>(self, s: &str) -> Result<Self::Value, E> {
                Ok(LocalizedText::Plain(s.to_string()))
            }

            fn visit_string<E: de::Error>(self, s: String) -> Result<Self::Value, E> {
                Ok(LocalizedText::Plain(s))
            }

            fn visit_map<A: MapAccess<'de>>(self, mut map: A) -> Result<Self::Value, A::Error> {
                let mut variants: Vec<(String, String)> = Vec::new();
                while let Some((tag, text)) = map.next_entry::<String, String>()? {
                    if variants.iter().any(|(t, _)| *t == tag) {
                        return Err(de::Error::custom(format!("language \"{tag}\" appears twice")));
                    }
                    variants.push((tag, text));
                }
                Ok(LocalizedText::Translated(variants))
            }
        }

        deserializer.deserialize_any(TextVisitor)
    }
}

/// Run `f` with this thread's language set to `choice` (tests).
#[doc(hidden)]
pub fn with_language<R>(choice: &str, f: impl FnOnce() -> R) -> R {
    let previous = OVERRIDE.with(|o| o.replace(Some(resolve(choice))));
    struct Restore(Option<State>);
    impl Drop for Restore {
        fn drop(&mut self) {
            let previous = self.0.take();
            OVERRIDE.with(|o| *o.borrow_mut() = previous);
        }
    }
    let _restore = Restore(previous);
    f()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn translated(pairs: &[(&str, &str)]) -> LocalizedText {
        LocalizedText::Translated(
            pairs.iter().map(|(t, s)| (t.to_string(), s.to_string())).collect(),
        )
    }

    #[test]
    fn picks_the_closest_translation() {
        let text = translated(&[("en", "Blind"), ("fr", "Aveugle"), ("zh-Hant", "盲人")]);
        with_language("fr-CA", || assert_eq!(text.get(), "Aveugle"));
        with_language("zh-TW", || assert_eq!(text.get(), "盲人"));
        with_language("de", || assert_eq!(text.get(), "Blind"));
    }

    #[test]
    fn falls_back_to_the_first_translation_without_english() {
        let text = translated(&[("ru", "Слепой"), ("fr", "Aveugle")]);
        with_language("de", || assert_eq!(text.get(), "Слепой"));
    }

    #[test]
    fn plain_text_round_trips_as_a_string() {
        let plain: LocalizedText = serde_json::from_str("\"Hi\"").unwrap();
        assert_eq!(plain, LocalizedText::from("Hi"));
        assert_eq!(serde_json::to_string(&plain).unwrap(), "\"Hi\"");
        let map: LocalizedText = serde_json::from_str(r#"{"en":"Hi","fr":"Salut"}"#).unwrap();
        assert_eq!(serde_json::to_string(&map).unwrap(), r#"{"en":"Hi","fr":"Salut"}"#);
        assert!(serde_json::from_str::<LocalizedText>(r#"{"en":1}"#).is_err());
    }

    #[test]
    fn interface_language_follows_the_choice() {
        with_language("pt-PT", || assert_eq!(current().tag, "pt-BR"));
        with_language("zh-CN", || assert_eq!(current().tag, "zh-Hans"));
        with_language("nl", || assert_eq!(current().tag, "en"));
    }

    #[test]
    fn every_catalog_parses() {
        for lang in LANGUAGES {
            if let Err((_, errors)) = FluentResource::try_new(lang.source.to_string()) {
                panic!("{}.ftl has syntax errors: {errors:?}", lang.tag);
            }
        }
    }
}
