# Release checklist

Use this checklist for every release.

## Before release

- [ ] `make test` passes.
- [ ] README examples point to the correct owner/repository.
- [ ] `action.yml` metadata name is still unique and accurate.
- [ ] `CHANGELOG.md` contains release notes.
- [ ] No secrets are present in commits.
- [ ] No `.github/workflows` files are committed to this Marketplace action repository.

## Release commands

```bash
VERSION=v1.0.0

git status --short
make test

git add action.yml README.md CHANGELOG.md CONTRIBUTING.md LICENSE Makefile REPOSITORY_START.md SECURITY.md docs examples prompts scripts test .gitignore
git commit -m "Prepare ${VERSION} release"

git branch -M main
gh repo create nekrasovp/telegram-release-notify --public --source=. --remote=origin --push
```

If `origin` already exists and points to the public repository, push `main` instead of creating the repository:

```bash
git push -u origin main
```

Then create the annotated version tag:

```bash
git tag -a "$VERSION" -m "$VERSION"
git push origin "$VERSION"
```

Publish the release in the GitHub UI:

1. Open `https://github.com/nekrasovp/telegram-release-notify`.
2. Open `action.yml`.
3. Click **Draft a release** from the Marketplace banner.
4. Check **Publish this Action to the GitHub Marketplace**.
5. Pick a primary category such as `Utilities`.
6. Use tag `v1.0.0`, title `v1.0.0`, and the `CHANGELOG.md` notes.
7. Confirm GitHub reports the action metadata looks good.
8. Click **Publish release**.

Then move the major tag:

```bash
git tag -f v1 "$VERSION"
git push origin v1 --force
```

Test the major tag in a separate repository:

```yaml
name: Telegram release notification

on:
  release:
    types: [published]

permissions:
  contents: read

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - uses: nekrasovp/telegram-release-notify@v1
        with:
          bot-token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
          chat-id: ${{ secrets.TELEGRAM_CHAT_ID }}
```

## After release

- [ ] Marketplace listing is visible.
- [ ] `uses: nekrasovp/telegram-release-notify@v1` works in a separate test repository.
- [ ] Exact tag usage works: `uses: nekrasovp/telegram-release-notify@v1.0.0`.
- [ ] Telegram receives a release notification.
