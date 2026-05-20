# Repository start commands

```bash
git status --short
make test

git add --chmod=+x scripts/send-telegram.sh test/smoke.sh
git add .
git commit -m "Prepare v1.0.0 release"
git branch -M main
gh repo create nekrasovp/telegram-release-notify --public --source=. --remote=origin --push
```

If `origin` already exists, use `git push -u origin main` instead of `gh repo create`.

Then follow `docs/publish-to-marketplace.md`.
