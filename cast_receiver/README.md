# Glacier Cast Receiver

This is the custom Google Cast Web Receiver used for low-latency HLS casting.

To use it on devices:

1. Host `index.html` over HTTPS.
2. Register that URL as a Custom Receiver in the Google Cast SDK Developer Console.
3. Put the assigned receiver app ID in `.env`:

```text
CAST_RECEIVER_APP_ID=YOUR_APP_ID
```

If `CAST_RECEIVER_APP_ID` is empty, the Android app falls back to Google's
default media receiver so existing casting still works.
