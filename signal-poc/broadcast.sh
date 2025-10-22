#!/bin/bash

# Script to broadcast Signal messages to multiple phone numbers
# Usage: ./broadcast.sh "+1234567890,+9876543210" "Your message here"

BACKEND_URL="http://localhost:5001"
PHONE_NUMBERS_ARG="$1"
MESSAGE="$2"

# Check arguments
if [ -z "$PHONE_NUMBERS_ARG" ] || [ -z "$MESSAGE" ]; then
  echo "❌ Error: Missing required arguments"
  echo ""
  echo "Usage:"
  echo "  ./broadcast.sh \"+1234567890,+9876543210\" \"Your message here\""
  echo "  OR"
  echo "  ./broadcast.sh \"+1234567890 +9876543210\" \"Your message here\""
  echo ""
  echo "Examples:"
  echo "  ./broadcast.sh \"+40751770274,+12025551234\" \"Hello everyone!\""
  echo "  ./broadcast.sh \"+40751770274 +12025551234\" \"Meeting at 3pm\""
  echo ""
  echo "Note: Phone numbers must include country code (e.g., +1, +40, etc.)"
  echo "      Separate numbers with comma or space"
  exit 1
fi

# Convert phone numbers to JSON array
# Replace spaces and commas with proper JSON format
PHONE_ARRAY=$(echo "$PHONE_NUMBERS_ARG" | sed 's/[, ]\+/","/g' | sed 's/^/["/' | sed 's/$/"]/')

echo "📤 Broadcasting message..."
echo "📞 Recipients: $PHONE_NUMBERS_ARG"
echo "💬 Message: $MESSAGE"
echo ""

# Send request
RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/broadcast" \
  -H "Content-Type: application/json" \
  -d "{
    \"phoneNumbers\": $PHONE_ARRAY,
    \"message\": \"$MESSAGE\"
  }")

# Check if successful
if echo "$RESPONSE" | grep -q '"success":true'; then
  echo "✅ Message broadcast successfully!"
  
  # Extract and display recipient count
  RECIPIENT_COUNT=$(echo "$RESPONSE" | grep -o '"recipientCount":[0-9]*' | cut -d':' -f2)
  echo "📊 Sent to $RECIPIENT_COUNT recipients"
  
  # Extract and display timestamp
  echo "$RESPONSE" | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4 | sed 's/^/🕐 Timestamp: /'
  
  echo ""
  echo "📱 Recipients:"
  echo "$RESPONSE" | grep -o '"recipients":\[[^]]*\]' | sed 's/"recipients":\[//;s/\]//;s/","/\n/g;s/"//g' | nl -w2 -s'. '
else
  echo "❌ Failed to broadcast message"
  echo "$RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4
  echo ""
  echo "Full response:"
  echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
  exit 1
fi

