#!/bin/bash

# Script to send Signal messages to phone numbers
# Usage: ./send-to-phone.sh "+1234567890" "Your message here"

BACKEND_URL="http://localhost:5001"
PHONE_NUMBER="$1"
MESSAGE="$2"

# Check arguments
if [ -z "$PHONE_NUMBER" ] || [ -z "$MESSAGE" ]; then
  echo "❌ Error: Missing required arguments"
  echo ""
  echo "Usage:"
  echo "  ./send-to-phone.sh \"+1234567890\" \"Your message here\""
  echo ""
  echo "Example:"
  echo "  ./send-to-phone.sh \"+40751770274\" \"Hello from Signal PoC!\""
  echo ""
  echo "Note: Phone number must include country code (e.g., +1, +40, etc.)"
  exit 1
fi

echo "📤 Sending message..."
echo "📞 To: $PHONE_NUMBER"
echo "💬 Message: $MESSAGE"
echo ""

# Send request
RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/send-to-phone" \
  -H "Content-Type: application/json" \
  -d "{
    \"phoneNumber\": \"$PHONE_NUMBER\",
    \"message\": \"$MESSAGE\"
  }")

# Check if successful
if echo "$RESPONSE" | grep -q '"success":true'; then
  echo "✅ Message sent successfully!"
  echo "$RESPONSE" | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4 | sed 's/^/🕐 Timestamp: /'
  echo "$RESPONSE" | grep -o '"recipient":"[^"]*"' | cut -d'"' -f4 | sed 's/^/📱 Recipient: /'
else
  echo "❌ Failed to send message"
  echo "$RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4
  echo ""
  echo "Full response:"
  echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
  exit 1
fi

