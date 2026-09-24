//! Parsing and validation of `${...}` path tokens (SPEC §3).

/// OS/context tokens available everywhere.
pub const BUILTIN_TOKENS: &[&str] = &[
    "gameDir",
    "userData",
    "appData",
    "localAppData",
    "localLow",
    "documents",
    "home",
    "distribution",
    "platform",
    "arch",
    "steam.appId",
];

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Token {
    Builtin(String),
    /// `${game.<name>}` — a named path from the game package.
    GamePath(String),
    /// `${var.<id>}` — a value bound by an earlier step.
    Var(String),
    /// Anything else — invalid.
    Unknown(String),
}

/// Extract every `${...}` token from a path string. Returns an error message
/// for an unterminated `${`.
pub fn extract(input: &str) -> Result<Vec<Token>, String> {
    let mut tokens = Vec::new();
    let mut rest = input;
    while let Some(start) = rest.find("${") {
        let after = &rest[start + 2..];
        let Some(end) = after.find('}') else {
            return Err(format!("unterminated token in \"{input}\""));
        };
        let name = &after[..end];
        tokens.push(classify(name));
        rest = &after[end + 1..];
    }
    Ok(tokens)
}

fn classify(name: &str) -> Token {
    if BUILTIN_TOKENS.contains(&name) {
        Token::Builtin(name.to_string())
    } else if let Some(rest) = name.strip_prefix("game.") {
        Token::GamePath(rest.to_string())
    } else if let Some(rest) = name.strip_prefix("var.") {
        Token::Var(rest.to_string())
    } else {
        Token::Unknown(name.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extracts_builtin_and_namespaced() {
        let tokens = extract("${game.mods}/Blindfold/${var.x}/${gameDir}").unwrap();
        assert_eq!(
            tokens,
            vec![
                Token::GamePath("mods".into()),
                Token::Var("x".into()),
                Token::Builtin("gameDir".into()),
            ]
        );
    }

    #[test]
    fn plain_path_has_no_tokens() {
        assert!(extract("mods/SayTheSpire2.dll").unwrap().is_empty());
    }

    #[test]
    fn unknown_token_is_flagged() {
        let tokens = extract("${bogus}/x").unwrap();
        assert_eq!(tokens, vec![Token::Unknown("bogus".into())]);
    }

    #[test]
    fn unterminated_token_is_an_error() {
        assert!(extract("${gameDir/x").is_err());
    }
}
