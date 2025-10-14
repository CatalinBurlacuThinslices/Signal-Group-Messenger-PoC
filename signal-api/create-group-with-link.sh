#!/bin/bash

echo "========================================="
echo "Create Signal Group with Invite Link"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

if [ -z "$1" ]; then
    echo "Usage: ./create-group-with-link.sh \"Group Name\""
    echo ""
    echo "Example:"
    echo "  ./create-group-with-link.sh \"My Test Group\""
    echo ""
    exit 1
fi

GROUP_NAME="$1"

echo "Creating group: $GROUP_NAME"
echo "Phone: $PHONE_NUMBER"
echo ""

# Create group
RESPONSE=$(curl -s -X POST http://localhost:8080/v1/groups/$PHONE_NUMBER \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"$GROUP_NAME\",
    \"members\": [],
    \"description\": \"Created from Signal PoC\"
  }")

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>&1

echo ""

# Extract invite link if present
INVITE_LINK=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('invite_link', 'No link'))" 2>/dev/null)

if [ "$INVITE_LINK" != "No link" ] && [ -n "$INVITE_LINK" ]; then
    echo "========================================="
    echo "✅ Group Created Successfully!"
    echo "========================================="
    echo ""
    echo "Group Name: $GROUP_NAME"
    echo ""
    echo "📱 Invite Link:"
    echo "$INVITE_LINK"
    echo ""
    echo "Share this link to invite people to the group!"
    echo ""
else
    echo "Group created but no invite link available."
    echo "Check if registration completed successfully."
fi

