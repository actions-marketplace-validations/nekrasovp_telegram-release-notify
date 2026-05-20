# Troubleshooting

## Telegram says `chat not found`

Common causes:

- The bot was not added to the group/channel.
- The bot is not an administrator in the target channel.
- `TELEGRAM_CHAT_ID` is wrong.
- A private user has not started a chat with the bot.

## The workflow runs but no Telegram message arrives

Check the workflow logs. The action fails the step when Telegram returns non-2xx HTTP status or when the response does not contain `ok: true`.

## The release workflow did not run

If another GitHub Actions workflow created the release using the default `GITHUB_TOKEN`, a separate workflow listening to `release.published` may not run. Put the Telegram notification step in the same workflow that creates the release, or use a token that is allowed to trigger follow-up workflows.

## The message is truncated

Telegram limits `sendMessage` text to 4096 characters after entity parsing. This action defaults to `max-message-chars: 3900` and `max-body-chars: 1200` to avoid failures with long release notes.

## HTML or Markdown formatting fails

By default the action sends plain text. If you set `parse-mode: HTML` or `parse-mode: MarkdownV2`, you are responsible for escaping custom text and release body according to Telegram rules.

For most release notifications, keep `parse-mode` empty.
