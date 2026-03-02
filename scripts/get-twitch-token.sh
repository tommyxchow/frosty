#!/bin/bash
#
# Gets a Twitch OAuth user token for emulator testing.
#
# Usage: ./scripts/get-twitch-token.sh
#
# Reads CLIENT_ID and SECRET from .env, env vars, or prompts interactively.
# Opens the Twitch OAuth page in your browser — after you authorize,
# paste the redirect URL back here and the token is copied to your clipboard.
# Then long-press the Anonymous account tile in the app to log in.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

load_env_var() {
  local name="$1"
  local current="${!name:-}"

  if [ -n "$current" ]; then
    return
  fi

  if [ -f "$ENV_FILE" ] && grep -q "^${name}=" "$ENV_FILE"; then
    eval "$name=$(grep "^${name}=" "$ENV_FILE" | cut -d= -f2-)"
    return
  fi

  read -rp "$name: " "$name"
}

load_env_var CLIENT_ID
load_env_var SECRET

if [ -z "${CLIENT_ID:-}" ] || [ -z "${SECRET:-}" ]; then
  echo "Error: CLIENT_ID and SECRET are both required."
  echo "Add them to .env or export them in your shell."
  exit 1
fi

SCOPES="chat:read+chat:edit+user:read:follows+user:read:blocked_users+user:manage:blocked_users+user:manage:chat_color"
REDIRECT_URI="https://twitch.tv/login"

URL="https://id.twitch.tv/oauth2/authorize?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&response_type=code&scope=${SCOPES}&force_verify=true"

echo "Opening Twitch authorization in your browser..."
open "$URL"

echo ""
echo "After authorizing, copy the full URL from the address bar and paste it here:"
echo "(it will look like https://twitch.tv/login?code=...)"
echo ""
read -rp "> " REDIRECT_URL

# Extract the authorization code from the redirect URL query params
CODE=$(echo "$REDIRECT_URL" | sed -n 's/.*[?&]code=\([^&]*\).*/\1/p')

if [ -z "$CODE" ]; then
  echo ""
  echo "Error: could not extract code from that URL."
  echo "Make sure you pasted the full URL including the ?code=... part."
  exit 1
fi

# Exchange the authorization code for an access token
echo ""
echo "Exchanging code for token..."

RESPONSE=$(curl -s -X POST "https://id.twitch.tv/oauth2/token" \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${SECRET}" \
  -d "code=${CODE}" \
  -d "grant_type=authorization_code" \
  -d "redirect_uri=${REDIRECT_URI}")

# Try to extract access_token from JSON response
TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Error: token exchange failed."
  echo "$RESPONSE"
  exit 1
fi

echo "$TOKEN" | tr -d '\n' | pbcopy

echo "Token copied to clipboard!"
echo ""
echo "Now in the emulator, long-press the Anonymous account tile to log in."
