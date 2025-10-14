#!/bin/bash

echo "========================================="
echo "🆕 Create Group with Invite Link"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

if [ -z "$1" ]; then
    echo "Usage: ./create-group-with-invite.sh \"Group Name\" \"+40PHONE\" ..."
    echo ""
    echo "Examples:"
    echo "  ./create-group-with-invite.sh \"My Team\" \"+40757239300\""
    echo "  ./create-group-with-invite.sh \"Project Group\" \"+40111\" \"+40222\""
    echo ""
    exit 1
fi

GROUP_NAME="$1"
shift

# Collect all members
MEMBERS=""
for member in "$@"; do
    if [ -z "$MEMBERS" ]; then
        MEMBERS="\"$member\""
    else
        MEMBERS="$MEMBERS, \"$member\""
    fi
done

echo "Creating group: $GROUP_NAME"
[ -n "$MEMBERS" ] && echo "With members: $MEMBERS"
echo ""

# Create group
echo "Step 1: Creating group..."
RESPONSE=$(curl -s -X POST http://localhost:8080/v1/groups/$PHONE_NUMBER \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"$GROUP_NAME\",
    \"members\": [$MEMBERS],
    \"description\": \"Created from Signal PoC\"
  }")

echo "$RESPONSE" | python3 -m json.tool 2>&1

# Extract group ID
GROUP_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('id', ''))" 2>/dev/null)

if [ -z "$GROUP_ID" ]; then
    echo "❌ Failed to create group"
    exit 1
fi

echo ""
echo "✅ Group created: $GROUP_ID"
echo ""

# Enable invite link
echo "Step 2: Generating invite link..."
curl -s -X PUT "http://localhost:8080/v1/groups/$PHONE_NUMBER/$GROUP_ID" \
  -H 'Content-Type: application/json' \
  -d '{"resetLink": true}' > /dev/null

sleep 3

# Get the invite link
echo "Step 3: Fetching invite link..."
INVITE_LINK=$(curl -s "http://localhost:8080/v1/groups/$PHONE_NUMBER" | \
  python3 -c "
import sys, json
groups = json.load(sys.stdin)
for g in groups:
    if g['id'] == '$GROUP_ID':
        print(g.get('invite_link', ''))
        break
" 2>/dev/null)

echo ""
echo "========================================="
echo "✅ SUCCESS!"
echo "========================================="
echo ""
echo "Group Name: $GROUP_NAME"
echo "Group ID: $GROUP_ID"
echo ""

if [ -n "$INVITE_LINK" ] && [ "$INVITE_LINK" != "" ]; then
    echo "📱 Invite Link:"
    echo "$INVITE_LINK"
    echo ""
    echo "Share this link to invite people!"
    echo "They click it → Signal opens → They join!"
else
    echo "⚠️  Invite link not generated yet"
    echo "   Try running: ./get-invite-links.sh"
    echo "   Or check Signal app on phone"
fi

echo ""
echo "Members will receive invitation in their Signal app."
echo "Refresh web app to see the new group: http://localhost:3000"

