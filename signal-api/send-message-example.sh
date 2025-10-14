#!/bin/bash

# Example: How to send a message to a Signal group

GROUP_ID="group.ekx1bkd6U1lMTVRHcWk1ZzBDQlRHblFqK1A0VklrbTdXRmFMd0lWSGFEQT0="
PHONE_NUMBER="+40751770274"
MESSAGE="Test message from command line!"

echo "Sending message to group..."
echo "Group ID: $GROUP_ID"
echo "Message: $MESSAGE"
echo ""

curl -X POST http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d "{
    \"message\": \"$MESSAGE\",
    \"number\": \"$PHONE_NUMBER\",
    \"recipients\": [\"$GROUP_ID\"]
  }"

echo ""
echo ""
echo "✅ Message sent!"
echo ""
echo "To send your own message, edit this script and change:"
echo "  MESSAGE=\"Your message here\""

