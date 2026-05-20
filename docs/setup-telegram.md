# Telegram setup

## 1. Create a bot

1. Open Telegram.
2. Start a chat with `@BotFather`.
3. Run `/newbot`.
4. Choose a display name and a bot username.
5. Copy the token.

Store the token as a GitHub Actions secret named:

```text
TELEGRAM_BOT_TOKEN
```

Do not paste the real token into repository files, issues, workflow logs, screenshots, or release notes.

## 2. Get the chat id

### Private chat

1. Start a conversation with your bot.
2. Send any message to the bot.
3. Open this URL in your browser, replacing `<TOKEN>`:

```text
https://api.telegram.org/bot<TOKEN>/getUpdates
```

4. Find `message.chat.id` in the JSON response.

### Group or supergroup

1. Add the bot to the group.
2. Send a message in the group.
3. Open:

```text
https://api.telegram.org/bot<TOKEN>/getUpdates
```

4. Find `message.chat.id`. Group and supergroup ids are usually negative numbers.

If the group message does not appear in `getUpdates`, send a slash command to the bot in the group, or adjust the bot privacy setting in BotFather while you discover the id. You can turn privacy back on after you have the id.

### Channel

Use one of these approaches:

- Add the bot as a channel administrator and use the public channel username as `chat-id`, for example `@my_channel`.
- Or post in the channel and use `getUpdates` to discover the numeric channel id if available.

For private channels, the bot must be an administrator and you should use the numeric channel id.

Store the result as a GitHub Actions secret named:

```text
TELEGRAM_CHAT_ID
```

## 3. Test manually

```bash
curl --request POST \
  --data-urlencode "chat_id=<CHAT_ID>" \
  --data-urlencode "text=Telegram release notification test" \
  "https://api.telegram.org/bot<TOKEN>/sendMessage"
```

Do not paste real tokens into issue trackers, logs, README files, or screenshots.
