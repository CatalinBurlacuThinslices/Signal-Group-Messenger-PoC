#!/bin/bash

echo "========================================="
echo "🔗 Enable Invite Link for Group"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

if [ -z "$1" ]; then
    echo "Usage: ./enable-group-invite-link.sh GROUP_ID"
    echo ""
    echo "Example:"
    echo "  ./enable-group-invite-link.sh 'group.ekx1bkd6U1lMTVRHcWk1ZzBDQlRHblFqK1A0VklrbTdXRmFMd0lWSGFEQT0='"
    echo ""
    echo "To see your groups and their IDs:"
    echo "  curl http://localhost:8080/v1/groups/+40751770274 | python3 -m json.tool | grep -E 'name|id'"
    echo ""
    exit 1
fi

GROUP_ID="$1"

echo "Enabling invite link for group..."
echo "Group ID: $GROUP_ID"
echo ""

# Enable invite link
RESPONSE=$(curl -s -X PUT "http://localhost:8080/v1/groups/$PHONE_NUMBER/$GROUP_ID" \
  -H 'Content-Type: application/json' \
  -d '{
    "resetLink": true
  }')

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Failed to enable invite link"
    echo "$RESPONSE"
    exit 1
fi

echo "✅ Invite link enabled!"
echo ""

# Wait a bit for it to process
sleep 3

# Fetch the link
echo "Fetching invite link..."
GROUPS=$(curl -s "http://localhost:8080/v1/groups/$PHONE_NUMBER")

if [ -z "$GROUPS" ] || [ "$GROUPS" = "[]" ]; then
    echo "⚠️  Could not fetch groups"
    echo "   Invite link was enabled, but can't verify it yet"
    echo ""
    echo "To check manually:"
    echo "  curl http://localhost:8080/v1/groups/$PHONE_NUMBER | python3 -m json.tool"
    exit 0
fi

echo "$GROUPS" | python3 << PYTHON_SCRIPT
import sys, json

try:
    data = sys.stdin.read().strip()
    groups = json.loads(data)
except:
    print("⚠️  Could not parse response")
    print("   Invite link enabled, check manually")
    sys.exit(0)

target_id = "$GROUP_ID"

for g in groups:
    if g['id'] == target_id:
        name = g.get('name', 'Unknown')
        invite_link = g.get('invite_link', '')
        
        print("=" * 60)
        print(f"Group: {name}")
        print(f"ID: {target_id}")
        print("")
        
        if invite_link:
            print("📱 Invite Link:")
            print(invite_link)
            print("")
            print("✅ Share this link to invite people!")
            print("   They click → Signal opens → Join group!")
        else:
            print("⚠️  Invite link not generated")
            print("   This might be a signal-cli limitation")
            print("   Try creating link via Signal mobile app instead")
        
        print("=" * 60)
        break
PYTHON_SCRIPT

echo ""
echo "To share the link:"
echo "  - Copy the https://signal.group/# URL above"
echo "  - Send via SMS, email, WhatsApp, etc."
echo "  - Anyone can click to join!"

