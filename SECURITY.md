# Security Policy

## Supported versions

Security fixes are provided for the latest major tag:

```text
v1
```

## Reporting a vulnerability

Please report security issues privately to the repository owner. Do not open public issues containing secrets, tokens, exploit details, or sensitive logs.

## Secret handling

This action expects the Telegram bot token to be passed through GitHub Actions secrets:

```yaml
bot-token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
```

The script masks the token in logs with GitHub Actions `add-mask`, but users should still avoid enabling shell tracing or printing secrets manually.

## Scope

This action sends text to Telegram via the Bot API. It does not store credentials, persist data, receive Telegram updates, or run a webhook server.
