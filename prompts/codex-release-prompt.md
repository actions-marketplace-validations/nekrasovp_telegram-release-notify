# Codex prompt: finish, release, publish, and use the action

Paste this prompt into the VS Code Codex extension after opening this repository folder.

```text
You are a senior GitHub Actions maintainer and release engineer. This repository is a public GitHub Marketplace action implemented as a Bash/curl composite action. The goal is to publish a stable v1 release and make it easy to use from other projects.

Important constraints:
- Do not convert this project to Node.js, Python, Rust, Docker, C, or C++.
- Do not add runtime dependencies.
- Keep it a composite action using Bash and curl.
- Do not create or commit .github/workflows files in this action repository unless I explicitly ask; Marketplace docs require a focused action repo and this starter keeps workflow templates under examples/.
- Never print or commit Telegram bot tokens.
- Keep default messages as plain text. If adding parse-mode features, document escaping risks clearly.

Tasks:
1. Inspect the repository end to end: action.yml, scripts/send-telegram.sh, tests, README.md, docs, examples, SECURITY.md, CONTRIBUTING.md, CHANGELOG.md, and LICENSE.
2. Replace placeholders with the real repository owner/repo when inferable from git remote. If not inferable, leave a clear TODO and tell me exactly what to replace.
3. Verify action.yml metadata:
   - root action.yml exists;
   - action name, description, author, branding are present;
   - inputs are documented and match the script;
   - outputs are wired correctly;
   - the action name should be unique enough for GitHub Marketplace.
4. Verify the script:
   - bot token is masked;
   - required inputs fail fast;
   - curl errors and Telegram API errors fail the step;
   - custom text works;
   - release.published context works;
   - same-workflow explicit release inputs work;
   - message-thread-id, disable-notification, disable-link-preview, and protect-content work;
   - no untrusted GitHub event text is executed as shell code.
5. Run `make test`. Fix all failures.
6. Improve documentation where needed, especially:
   - how to create the Telegram bot;
   - how to find chat id;
   - how to install the action in another repository;
   - how to publish to GitHub Marketplace;
   - why there is no Docker/Node/server deployment.
7. Prepare release notes for v1.0.0 in CHANGELOG.md.
8. Produce a final release checklist with exact commands:
   - git status;
   - make test;
   - git add/commit;
   - create public repo if needed;
   - push main;
   - create annotated tag v1.0.0;
   - publish GitHub Release and check “Publish this Action to the GitHub Marketplace” in the GitHub UI;
   - create or move major tag v1;
   - test `uses: nekrasovp/telegram-release-notify@v1` in a separate repository.

Before changing files, summarize any risky or ambiguous decisions. Then make the smallest correct changes necessary and show a changed-files summary at the end.
```

## Follow-up prompt after Codex finishes fixes

```text
Now act as the final release reviewer. Run `make test`, inspect `git diff`, and check the repository against GitHub Marketplace publication requirements. Do not make broad rewrites. Give me a concise go/no-go decision for v1.0.0, a list of blocking issues if any, and the exact commands/UI steps to publish and then use the action in another repository.
```

## Prompt for generating usage workflow in another project

```text
Create a `.github/workflows/telegram-release.yml` workflow in this project that uses nekrasovp/telegram-release-notify@v1. The workflow must run on `release.published`, require only `contents: read`, and read `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` from repository secrets. Keep it minimal and explain where I must add the two secrets.
```
