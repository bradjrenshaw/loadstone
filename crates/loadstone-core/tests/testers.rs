//! Tester access (SPEC 2.3): a registry's testers.json gates tester-only
//! links, through both resolution and the mod list.

use std::path::Path;

use loadstone_core::registry::{HttpFetcher, Resolver};
use loadstone_core::testers::TestersFile;

fn write(path: &Path, value: serde_json::Value) {
    std::fs::create_dir_all(path.parent().unwrap()).unwrap();
    std::fs::write(path, serde_json::to_string_pretty(&value).unwrap()).unwrap();
}

fn mod_file(id: &str) -> serde_json::Value {
    serde_json::json!({ "manifestVersion": 1, "id": id, "name": id, "game": "g", "install": [] })
}

#[test]
fn tester_links_appear_only_with_the_password() {
    let tmp = tempfile::tempdir().unwrap();
    let registry = tmp.path().join("registry");
    let public = tmp.path().join("public-mod");
    let secret = tmp.path().join("secret-mod");
    write(&public.join("public.json"), mod_file("public"));
    write(&secret.join("secret.json"), mod_file("secret"));
    write(&registry.join("public.json"), serde_json::json!({ "kind": "link", "source": public, "packages": ["public"] }));
    write(&registry.join("secret.json"), serde_json::json!({ "kind": "link", "source": secret, "packages": ["secret"], "testers": true }));
    std::fs::write(registry.join("testers.json"), serde_json::to_string(&TestersFile::new("swordfish")).unwrap()).unwrap();

    let sources = vec![registry.to_string_lossy().into_owned()];
    let mut fetcher = HttpFetcher::new(Some(tmp.path().join("cache")), Box::new(|_| {})).unwrap();
    let mut resolver = Resolver::from_sources(&sources, &mut fetcher).unwrap();
    assert!(resolver.offers_testers());

    // Locked: the tester-only mod is neither listed nor installable by id.
    let ids = |r: &mut Resolver| r.list_mods().unwrap().into_iter().map(|m| m.manifest.id).collect::<Vec<_>>();
    assert!(!resolver.unlock_testers(Some("wrong")));
    assert_eq!(ids(&mut resolver), vec!["public"]);
    assert!(resolver.resolve_project("secret").is_err());

    // Unlocked: both, and the secret one says it came through a tester link.
    assert!(resolver.unlock_testers(Some("swordfish")));
    let mut found = ids(&mut resolver);
    found.sort();
    assert_eq!(found, vec!["public", "secret"]);
    assert!(resolver.resolve_project("secret").unwrap().testers);
    assert!(!resolver.resolve_project("public").unwrap().testers);

    assert!(loadstone_core::testers::check_password(&sources, "swordfish").unwrap());
    assert!(!loadstone_core::testers::check_password(&sources, "nope").unwrap());
    let bare = tmp.path().join("bare");
    std::fs::create_dir_all(&bare).unwrap();
    assert!(loadstone_core::testers::check_password(&[bare.to_string_lossy().into_owned()], "x").is_err());

    // The validator knows the file and the link flag.
    let result = loadstone_core::validate::validate_value(
        &serde_json::from_str(&std::fs::read_to_string(registry.join("testers.json")).unwrap()).unwrap(),
        &Default::default(),
    );
    assert!(!result.has_errors() && result.diagnostics.is_empty(), "{:?}", result.diagnostics);
    let bad = loadstone_core::validate::validate_value(
        &serde_json::json!({ "kind": "testers", "salt": "", "passwordSha256": "swordfish" }),
        &Default::default(),
    );
    assert!(bad.has_errors());
}

#[test]
fn a_registrys_password_unlocks_only_its_own_listings() {
    let tmp = tempfile::tempdir().unwrap();
    let a = tmp.path().join("registry-a");
    let b = tmp.path().join("registry-b");
    let mine = tmp.path().join("my-registry");
    let secret_b = tmp.path().join("secret-b");
    write(&secret_b.join("secret-b.json"), mod_file("secret-b"));
    write(&b.join("secret-b.json"), serde_json::json!({ "kind": "link", "source": secret_b, "packages": ["secret-b"], "testers": true }));
    std::fs::create_dir_all(&a).unwrap();
    std::fs::write(a.join("testers.json"), serde_json::to_string(&TestersFile::new("alpha")).unwrap()).unwrap();
    std::fs::write(b.join("testers.json"), serde_json::to_string(&TestersFile::new("bravo")).unwrap()).unwrap();
    // A registry the user added themselves, with a password they chose.
    std::fs::create_dir_all(&mine).unwrap();
    std::fs::write(mine.join("testers.json"), serde_json::to_string(&TestersFile::new("mine")).unwrap()).unwrap();

    let sources: Vec<String> = [&mine, &a, &b].iter().map(|p| p.to_string_lossy().into_owned()).collect();
    let mut fetcher = HttpFetcher::new(Some(tmp.path().join("cache")), Box::new(|_| {})).unwrap();
    let mut resolver = Resolver::from_sources(&sources, &mut fetcher).unwrap();
    let ids = |r: &mut Resolver| r.list_mods().unwrap().into_iter().map(|m| m.manifest.id).collect::<Vec<_>>();

    for password in ["alpha", "mine"] {
        assert!(resolver.unlock_testers(Some(password)), "{password} is accepted somewhere");
        assert!(ids(&mut resolver).is_empty(), "{password} must not list B's tester mods");
        assert!(resolver.resolve_project("secret-b").is_err(), "{password} must not resolve B's tester mods");
    }
    assert!(resolver.unlock_testers(Some("bravo")));
    assert_eq!(ids(&mut resolver), vec!["secret-b"]);
}

#[test]
fn prereleases_are_public_unless_a_registry_gates_them() {
    let tmp = tempfile::tempdir().unwrap();
    let open = tmp.path().join("open");
    std::fs::create_dir_all(&open).unwrap();
    let mut fetcher = HttpFetcher::new(Some(tmp.path().join("cache")), Box::new(|_| {})).unwrap();
    let mut resolver = Resolver::from_sources(&[open.to_string_lossy().into_owned()], &mut fetcher).unwrap();
    assert!(!resolver.unlock_testers(None));
    assert!(resolver.shows_prereleases(), "no testers.json: prereleases are public");

    let gated = tmp.path().join("gated");
    std::fs::create_dir_all(&gated).unwrap();
    std::fs::write(gated.join("testers.json"), serde_json::to_string(&TestersFile::new("swordfish")).unwrap()).unwrap();
    let mut fetcher = HttpFetcher::new(Some(tmp.path().join("cache")), Box::new(|_| {})).unwrap();
    let sources: Vec<String> = [&open, &gated].iter().map(|p| p.to_string_lossy().into_owned()).collect();
    let mut resolver = Resolver::from_sources(&sources, &mut fetcher).unwrap();
    assert!(!resolver.unlock_testers(Some("wrong")));
    assert!(!resolver.shows_prereleases());
    assert!(resolver.unlock_testers(Some("swordfish")));
    assert!(resolver.shows_prereleases());
}
