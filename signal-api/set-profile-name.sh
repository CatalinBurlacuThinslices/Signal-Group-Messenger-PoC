#!/bin/bash

# Set your Signal profile name
# This name will appear when you send messages

SIGNAL_NUMBER="+40751770274"
SIGNAL_API_URL="http://localhost:8080"

# Default name if not provided as argument
PROFILE_NAME="${1:-Amatsu}"

echo "========================================="
echo "Setting Signal Profile Name"
echo "========================================="
echo ""
echo "Phone Number: $SIGNAL_NUMBER"
echo "Profile Name: $PROFILE_NAME"
echo ""

# Set profile name
response=$(curl -s -X PUT \
  "$SIGNAL_API_URL/v1/profiles/$SIGNAL_NUMBER" \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"$PROFILE_NAME\"
  }")

if [ $? -eq 0 ]; then
    echo "✅ Profile name set successfully!"
    echo ""
    echo "Your messages will now appear as coming from: $PROFILE_NAME"
    echo ""
    echo "Note: It may take a few moments for recipients to see the updated name."
else
    echo "❌ Failed to set profile name"
    echo "Response: $response"
    echo ""
    echo "Make sure:"
    echo "  - Signal API is running (docker ps | grep signal)"
    echo "  - Your number is registered or linked"
fi

echo ""
echo "========================================="

