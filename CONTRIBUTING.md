# Contributing

Thanks for improving this action.

## Design principles

- Keep the action tiny.
- Keep it Bash + curl.
- Do not add Node.js, Python, Rust, Docker, or package-manager runtime dependencies unless there is a strong reason.
- Keep default messages as safe plain text.
- Do not execute release body, custom text, issue text, pull request text, or other user-controlled GitHub context as shell code.

## Local checks

```bash
make test
```

## Pull requests

Before opening a PR:

- Run `make test`.
- Update README/docs if you change inputs or behavior.
- Update `CHANGELOG.md` for user-visible changes.
- Do not commit secrets or real Telegram bot tokens.
