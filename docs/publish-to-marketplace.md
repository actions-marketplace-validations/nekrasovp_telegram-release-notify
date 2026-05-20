# Publish to GitHub Marketplace

This repository is designed as a GitHub Marketplace action.

The repository identity inferred from `origin` is:

```text
nekrasovp/telegram-release-notify
```

## Marketplace requirements checklist

Before publishing, verify:

- [ ] The repository is public.
- [ ] `action.yml` exists in the repository root.
- [ ] There is only one root action metadata file: `action.yml` or `action.yaml`.
- [ ] The metadata `name` is unique in GitHub Marketplace.
- [ ] The repository is focused on this one action.
- [ ] There are no workflow files committed under `.github/workflows`.
- [ ] The repository owner has accepted the GitHub Marketplace Developer Agreement.
- [ ] You have two-factor authentication enabled for publishing.

## 1. Verify locally

```bash
git status --short
make test
```

## 2. Commit release-ready files

```bash
git add action.yml README.md CHANGELOG.md CONTRIBUTING.md LICENSE Makefile REPOSITORY_START.md SECURITY.md docs examples prompts scripts test .gitignore
git commit -m "Prepare v1.0.0 release"
```

## 3. Create the public repository if needed

If `origin` already points to `git@github.com:nekrasovp/telegram-release-notify.git`, skip the `gh repo create` command.

```bash
git branch -M main
gh repo create nekrasovp/telegram-release-notify --public --source=. --remote=origin --push
```

If the public repository already exists, push `main` directly:

```bash
git push -u origin main
```

## 4. Create an annotated semver tag

```bash
git tag -a v1.0.0 -m "v1.0.0"
git push origin v1.0.0
```

## 5. Publish through GitHub UI

1. Open the repository on GitHub.
2. Open `action.yml`.
3. Use the marketplace publishing banner and click **Draft a release**.
4. Check **Publish this Action to the GitHub Marketplace**.
5. Choose categories. `Utilities` is usually a good primary category.
6. Use tag `v1.0.0`.
7. Title: `v1.0.0`.
8. Add release notes from `CHANGELOG.md`.
9. Confirm the metadata validation says everything looks good.
10. Publish the release.

## 6. Add a moving major tag

After the semver release exists, create or update the `v1` tag:

```bash
git tag -f v1 v1.0.0
git push origin v1 --force
```

Users can now reference:

```yaml
uses: nekrasovp/telegram-release-notify@v1
```

For maximum reproducibility, users can reference the exact tag:

```yaml
uses: nekrasovp/telegram-release-notify@v1.0.0
```

## 7. First usage test in another project

Add this workflow to another repository:

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

Publish a test release and confirm that Telegram receives the message.
