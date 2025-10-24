#!/bin/bash

# Set your complete Signal profile (name, about, emoji, and avatar)
# Usage: ./set-full-profile.sh "Name" "About" "Emoji" path/to/avatar.jpg

SIGNAL_NUMBER="+40751770274"
SIGNAL_API_URL="http://localhost:8080"

# Parse arguments
PROFILE_NAME="$1"
PROFILE_ABOUT="$2"
PROFILE_EMOJI="$3"
AVATAR_FILE="$4"

echo "========================================="
echo "Setting Complete Signal Profile"
echo "========================================="
echo ""

# Check if at least name is provided
if [ -z "$PROFILE_NAME" ]; then
    echo "❌ Error: Profile name is required"
    echo ""
    echo "Usage: ./set-full-profile.sh \"Name\" [\"About\"] [\"Emoji\"] [avatar.jpg]"
    echo ""
    echo "Examples:"
    echo "  ./set-full-profile.sh \"Amatsu\""
    echo "  ./set-full-profile.sh \"Amatsu\" \"Available 24/7\""
    echo "  ./set-full-profile.sh \"Amatsu\" \"Gamer\" \"🎮\""
    echo "  ./set-full-profile.sh \"Amatsu\" \"Gamer\" \"🎮\" ~/Pictures/avatar.jpg"
    echo ""
    exit 1
fi

echo "Phone Number: $SIGNAL_NUMBER"
echo "Profile Name: $PROFILE_NAME"
[ -n "$PROFILE_ABOUT" ] && echo "About: $PROFILE_ABOUT"
[ -n "$PROFILE_EMOJI" ] && echo "Emoji: $PROFILE_EMOJI"
[ -n "$AVATAR_FILE" ] && echo "Avatar: $AVATAR_FILE"
echo ""

# Build JSON payload
JSON_PAYLOAD="{\"name\": \"$PROFILE_NAME\""

# Add optional fields
if [ -n "$PROFILE_ABOUT" ]; then
    JSON_PAYLOAD="$JSON_PAYLOAD, \"about\": \"$PROFILE_ABOUT\""
fi

if [ -n "$PROFILE_EMOJI" ]; then
    JSON_PAYLOAD="$JSON_PAYLOAD, \"emoji\": \"$PROFILE_EMOJI\""
fi

# Handle avatar if provided
if [ -n "$AVATAR_FILE" ]; then
    if [ ! -f "$AVATAR_FILE" ]; then
        echo "⚠️  Warning: Avatar file not found: $AVATAR_FILE"
        echo "   Continuing without avatar..."
        echo ""
    else
        echo "Converting avatar to base64..."
        BASE64_IMAGE=$(base64 -i "$AVATAR_FILE" | tr -d '\n')
        JSON_PAYLOAD="$JSON_PAYLOAD, \"avatar\": \"$BASE64_IMAGE\""
        echo "✅ Avatar converted"
        echo ""
    fi
fi

JSON_PAYLOAD="$JSON_PAYLOAD}"

echo "Updating profile..."

# Set profile
response=$(curl -s -w "\n%{http_code}" -X PUT \
  "$SIGNAL_API_URL/v1/profiles/$SIGNAL_NUMBER" \
  -H 'Content-Type: application/json' \
  -d "$JSON_PAYLOAD")

# Get HTTP status code (last line)
http_code=$(echo "$response" | tail -n1)
# Get response body (everything except last line)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 204 ]; then
    echo "✅ Profile updated successfully!"
    echo ""
    echo "Your profile is now:"
    echo "  Name: $PROFILE_NAME"
    [ -n "$PROFILE_ABOUT" ] && echo "  About: $PROFILE_ABOUT"
    [ -n "$PROFILE_EMOJI" ] && echo "  Emoji: $PROFILE_EMOJI"
    [ -n "$AVATAR_FILE" ] && [ -f "$AVATAR_FILE" ] && echo "  Avatar: ✅ Set"
    echo ""
    echo "Recipients will see your updated profile in messages."
else
    echo "❌ Failed to update profile"
    echo "HTTP Status: $http_code"
    echo "Response: $body"
    echo ""
    echo "Make sure:"
    echo "  - Signal API is running (docker ps | grep signal)"
    echo "  - Your number is registered or linked"
fi

echo ""
echo "========================================="

