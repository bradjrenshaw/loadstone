//! Tester access (SPEC 2.3): a registry's testers.json, and a mod's own
//! password in its package file, gate tester-only links and beta versions,
//! through both resolution and the mod list.

use std::path::Path;

use loadstone_core::registry::{HttpFetcher, Resolver, TesterAccess};
use loadstone_core::testers::{PasswordHash, TestersFile};

fn write(path: &Path, value: serde_json::Value) {
    std::fs::create_dir_all(path.parent().unwrap()).unwrap();
    std::fs::write(path, serde_json::to_string_pretty(&value).unwrap()).unwrap();
}

/// The passwords a tester has saved.
fn pw(list: &[&str]) -> Vec<String> {
    list.iter().map(|p| p.to_string()).collect()
}

fn mod_file(id: &str) -> serde_json::Value {
    serde_json::json!({ "manifestVersion": 1, "id": id, "name": id, "game": "g", "install": [] })
}

/// A mod's package file carrying the mod's own tester password.
fn mod_file_with_password(id: &str, password: &str) -> serde_json::Value {
    let mut file = mod_file(id);
    file["testers"] = serde_json::to_value(PasswordHash::new(password)).unwrap();
    file
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
    assert!(!resolver.unlock_testers(&pw(&["wrong"])));
    assert_eq!(ids(&mut resolver), vec!["public"]);
    assert!(resolver.resolve_project("secret").is_err());

    // Unlocked: both, and the secret one says it came through a tester link.
    assert!(resolver.unlock_testers(&pw(&["swordfish"])));
    let mut found = ids(&mut resolver);
    found.sort();
    assert_eq!(found, vec!["public", "secret"]);
    assert!(resolver.resolve_project("secret").unwrap().testers);
    assert!(!resolver.resolve_project("public").unwrap().testers);

    assert!(loadstone_core::testers::check_password(&sources, "swordfish").unwrap().registry_wide);
    assert!(!loadstone_core::testers::check_password(&sources, "nope").unwrap().any());
    let bare = tmp.path().join("bare");
    std::fs::create_dir_all(&bare).unwrap();
    assert!(!loadstone_core::testers::check_password(&[bare.to_string_lossy().into_owned()], "x").unwrap().any());

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
        assert!(resolver.unlock_testers(&pw(&[password])), "{password} is accepted somewhere");
        assert!(ids(&mut resolver).is_empty(), "{password} must not list B's tester mods");
        assert!(resolver.resolve_project("secret-b").is_err(), "{password} must not resolve B's tester mods");
    }
    assert!(resolver.unlock_testers(&pw(&["bravo"])));
    assert_eq!(ids(&mut resolver), vec!["secret-b"]);
}

#[test]
fn beta_versions_follow_the_registry_that_lists_the_mod() {
    let tmp = tempfile::tempdir().unwrap();
    // Three registries: one without a testers file, two with their own
    // passwords. The gated one also lists a mod through an ordinary link.
    let open = tmp.path().join("open");
    let gated = tmp.path().join("gated");
    let other = tmp.path().join("other");
    let linked = tmp.path().join("linked-mod");
    write(&open.join("open-mod.json"), mod_file("open-mod"));
    write(&gated.join("gated-mod.json"), mod_file("gated-mod"));
    write(&linked.join("linked-mod.json"), mod_file("linked-mod"));
    write(&gated.join("linked.json"), serde_json::json!({ "kind": "link", "source": linked, "packages": ["linked-mod"] }));
    write(&other.join("other-mod.json"), mod_file("other-mod"));
    std::fs::write(gated.join("testers.json"), serde_json::to_string(&TestersFile::new("swordfish")).unwrap()).unwrap();
    std::fs::write(other.join("testers.json"), serde_json::to_string(&TestersFile::new("marlin")).unwrap()).unwrap();

    let sources: Vec<String> = [&open, &gated, &other].iter().map(|p| p.to_string_lossy().into_owned()).collect();
    let mut fetcher = HttpFetcher::new(Some(tmp.path().join("cache")), Box::new(|_| {})).unwrap();
    let mut resolver = Resolver::from_sources(&sources, &mut fetcher).unwrap();
    let access = |r: &mut Resolver, id: &str| r.resolve_project(id).unwrap().access;

    // No password: a registry without a testers file gates nothing, so its
    // mods' prereleases stay public whatever the other registries do.
    assert!(!resolver.unlock_testers(&[]));
    assert_eq!(access(&mut resolver, "open-mod"), TesterAccess::Open);
    assert!(TesterAccess::Open.shows_prereleases() && !TesterAccess::Open.betas());
    for id in ["gated-mod", "linked-mod", "other-mod"] {
        assert_eq!(access(&mut resolver, id), TesterAccess::Locked, "{id}");
    }
    assert!(!TesterAccess::Locked.shows_prereleases() && !TesterAccess::Locked.betas());

    // One registry's password: its own mods get beta versions, including
    // the one it lists through a link. The other registry stays locked,
    // and the open one is unchanged.
    assert!(resolver.unlock_testers(&pw(&["swordfish"])));
    assert_eq!(access(&mut resolver, "gated-mod"), TesterAccess::Unlocked);
    assert_eq!(access(&mut resolver, "linked-mod"), TesterAccess::Unlocked);
    assert_eq!(access(&mut resolver, "other-mod"), TesterAccess::Locked);
    assert_eq!(access(&mut resolver, "open-mod"), TesterAccess::Open);
    assert!(TesterAccess::Unlocked.shows_prereleases() && TesterAccess::Unlocked.betas());

    // The mod list says the same as resolving by id.
    for m in resolver.list_mods().unwrap() {
        let expected = match m.manifest.id.as_str() {
            "open-mod" => TesterAccess::Open,
            "other-mod" => TesterAccess::Locked,
            _ => TesterAccess::Unlocked,
        };
        assert_eq!(m.access, expected, "{}", m.manifest.id);
    }
}

#[test]
fn a_mod_can_carry_its_own_password_in_its_package_file() {
    let tmp = tempfile::tempdir().unwrap();
    // A registry with a password for the mods it lists. Each mod lives in
    // its own repo, where its package file may carry the mod's own
    // password, which then replaces the registry's for that mod.
    let registry = tmp.path().join("registry");
    let gated = tmp.path().join("beta-gated-mod");
    let special = tmp.path().join("special-mod");
    let hidden = tmp.path().join("hidden-mod");
    write(&registry.join("ordinary.json"), mod_file("ordinary"));
    write(&gated.join("beta-gated.json"), mod_file_with_password("beta-gated", "betas"));
    write(&special.join("special.json"), mod_file_with_password("special", "few"));
    write(&hidden.join("hidden.json"), mod_file("hidden"));
    let link = |source: &Path, id: &str, testers: bool| {
        serde_json::json!({ "kind": "link", "source": source, "packages": [id], "testers": testers })
    };
    write(&registry.join("beta-gated.json"), link(&gated, "beta-gated", false));
    write(&registry.join("special.json"), link(&special, "special", true));
    write(&registry.join("hidden.json"), link(&hidden, "hidden", true));
    std::fs::write(registry.join("testers.json"), serde_json::to_string(&TestersFile::new("everyone")).unwrap()).unwrap();
    // A second registry with no password of its own: only the mod that
    // carries one is gated.
    let small = tmp.path().join("small");
    write(&small.join("solo.json"), mod_file_with_password("solo", "solo-pw"));
    write(&small.join("neighbour.json"), mod_file("neighbour"));

    // The validator knows the field, and checks the hash.
    let validate = |doc: &serde_json::Value| loadstone_core::validate::validate_value(doc, &Default::default());
    let plain = validate(&mod_file("solo")).diagnostics.len();
    assert_eq!(validate(&mod_file_with_password("solo", "solo-pw")).diagnostics.len(), plain);
    let mut bad = mod_file("solo");
    bad["testers"] = serde_json::json!({ "salt": "", "passwordSha256": "solo-pw" });
    assert_eq!(validate(&bad).diagnostics.len(), plain + 2, "an empty salt and a hash that isn't one");

    let sources: Vec<String> = [&registry, &small].iter().map(|p| p.to_string_lossy().into_owned()).collect();
    let mut fetcher = HttpFetcher::new(Some(tmp.path().join("cache")), Box::new(|_| {})).unwrap();
    let mut resolver = Resolver::from_sources(&sources, &mut fetcher).unwrap();
    let listed = |r: &mut Resolver| {
        let mut all: Vec<(String, TesterAccess)> =
            r.list_mods().unwrap().into_iter().map(|m| (m.manifest.id, m.access)).collect();
        all.sort_by(|a, b| a.0.cmp(&b.0));
        all
    };
    let entry = |id: &str, access: TesterAccess| (id.to_string(), access);
    use TesterAccess::{Locked, Open, Unlocked};

    // Nothing entered: the tester-only mods are hidden, and the listed ones
    // are locked where a password covers them and open where none does.
    assert!(!resolver.unlock_testers(&[]));
    assert_eq!(
        listed(&mut resolver),
        vec![entry("beta-gated", Locked), entry("neighbour", Open), entry("ordinary", Locked), entry("solo", Locked)]
    );
    assert!(resolver.resolve_project("special").is_err());
    assert!(resolver.resolve_project("hidden").is_err());

    // The registry's password opens its mods, but not those with their own.
    assert!(resolver.unlock_testers(&pw(&["everyone"])));
    assert_eq!(
        listed(&mut resolver),
        vec![
            entry("beta-gated", Locked),
            entry("hidden", Unlocked),
            entry("neighbour", Open),
            entry("ordinary", Unlocked),
            entry("solo", Locked)
        ]
    );
    assert!(resolver.resolve_project("special").is_err(), "the registry's password is not special's");

    // A mod's password opens that mod and nothing else.
    assert!(!resolver.unlock_testers(&pw(&["few"])), "it is no registry's password");
    assert_eq!(
        listed(&mut resolver),
        vec![
            entry("beta-gated", Locked),
            entry("neighbour", Open),
            entry("ordinary", Locked),
            entry("solo", Locked),
            entry("special", Unlocked)
        ]
    );
    assert!(resolver.resolve_project("hidden").is_err());
    assert_eq!(resolver.resolve_project("special").unwrap().access, Unlocked);
    assert_eq!(resolver.resolve_project("beta-gated").unwrap().access, Locked);

    // Several saved passwords each open their own part.
    resolver.unlock_testers(&pw(&["everyone", "few", "solo-pw", "betas"]));
    assert_eq!(
        listed(&mut resolver),
        vec![
            entry("beta-gated", Unlocked),
            entry("hidden", Unlocked),
            entry("neighbour", Open),
            entry("ordinary", Unlocked),
            entry("solo", Unlocked),
            entry("special", Unlocked)
        ]
    );

    // Checking a password says what it is for.
    let check = |p: &str| loadstone_core::testers::check_password(&sources, p).unwrap();
    assert!(check("everyone").registry_wide && check("everyone").packages.is_empty());
    assert_eq!(check("few").packages, vec!["special"]);
    assert!(!check("few").registry_wide);
    assert_eq!(check("betas").packages, vec!["beta-gated"]);
    assert_eq!(check("solo-pw").packages, vec!["solo"]);
    assert!(!check("nope").any());

    // A registry with no testers file still offers tester access when a
    // mod it lists carries a password; one with nothing gated does not.
    let offers = |dir: &Path| {
        let mut fetcher = HttpFetcher::new(Some(tmp.path().join("cache")), Box::new(|_| {})).unwrap();
        Resolver::from_sources(&[dir.to_string_lossy().into_owned()], &mut fetcher).unwrap().offers_testers()
    };
    assert!(offers(&small));
    let bare = tmp.path().join("bare");
    write(&bare.join("plain.json"), mod_file("plain"));
    assert!(!offers(&bare));
}
