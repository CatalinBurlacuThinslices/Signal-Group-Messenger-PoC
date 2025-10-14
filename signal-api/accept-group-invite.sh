#!/bin/bash

echo "========================================="
echo "📬 Accept Group Invitations"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

# Sync to get latest invitations
echo "Step 1: Syncing to get latest invitations..."
curl -s "http://localhost:8080/v1/receive/$PHONE_NUMBER?timeout=15" > /dev/null 2>&1
sleep 2
echo "✅ Synced"
echo ""

# Get all groups and find pending invitations
echo "Step 2: Checking for pending invitations..."
GROUPS=$(curl -s "http://localhost:8080/v1/groups/$PHONE_NUMBER")

if [ -z "$GROUPS" ] || [ "$GROUPS" = "[]" ]; then
    echo "❌ No groups found"
    exit 1
fi

echo "$GROUPS" | python3 << 'PYTHON_SCRIPT'
import sys, json

try:
    groups = json.loads(sys.stdin.read())
except:
    print("❌ Could not parse groups")
    sys.exit(1)

pending_count = 0

print("")
print("=" * 60)

for i, group in enumerate(groups, 1):
    name = group.get('name', 'Unknown')
    group_id = group.get('id', '')
    internal_id = group.get('internal_id', '')
    members = group.get('members', [])
    is_member = group.get('isMember', False)
    
    # Check if we're not a member (means we have pending invitation)
    if not is_member or len(members) == 0:
        pending_count += 1
        print(f"\n{pending_count}. Pending Invitation:")
        print(f"   Group: {name}")
        print(f"   ID: {group_id}")
        print(f"   Internal ID: {internal_id}")
        print("")

if pending_count == 0:
    print("\n✅ No pending invitations!")
    print("   You're already in all your groups.")
else:
    print("\n" + "=" * 60)
    print(f"\nFound {pending_count} pending invitation(s)")
    print("\nTo accept an invitation, use signal-cli:")
    print("  docker exec signal-api signal-cli -a +40751770274 \\")
    print("    joinGroup --group-id INTERNAL_ID")

PYTHON_SCRIPT

echo ""
echo "========================================="
echo ""
echo "To accept all invitations automatically:"
echo "  Run this command for each internal_id shown above"
echo ""
echo "Example:"
echo "  docker exec signal-api signal-cli -a +40751770274 \\"
echo "    joinGroup --group-id WvsaevqhZmtVQc3SBXwT6TWZCsYqpQ1iisE7xvFNah0="
echo ""

