#!/bin/bash

echo "========================================="
echo "📱 Signal Group Invite Links"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

# Fetch groups
GROUPS=$(curl -s "http://localhost:8080/v1/groups/$PHONE_NUMBER")

if [ -z "$GROUPS" ] || [ "$GROUPS" = "[]" ]; then
    echo "❌ No groups found or Signal API not running"
    echo ""
    echo "Make sure:"
    echo "  1. Docker is running"
    echo "  2. Signal API is up: docker ps | grep signal"
    echo "  3. Number is registered"
    exit 1
fi

echo "$GROUPS" | python3 << 'EOF'
import sys, json

data = sys.stdin.read().strip()
if not data:
    print("❌ No data received from Signal API")
    print("   Make sure Signal API is running and number is registered")
    sys.exit(1)

try:
    groups = json.loads(data)
except json.JSONDecodeError as e:
    print(f"❌ Invalid response from API: {e}")
    print(f"   Response: {data[:100]}")
    sys.exit(1)

if not groups:
    print("No groups found")
    sys.exit(1)

print(f"Found {len(groups)} group(s):\n")

for i, group in enumerate(groups, 1):
    name = group.get('name', 'Unknown')
    members = group.get('members', [])
    invite_link = group.get('invite_link', '')
    
    print(f"{i}. {name}")
    print(f"   Members: {len(members)}")
    
    if invite_link:
        print(f"   📎 Invite Link:")
        print(f"   {invite_link}")
        print(f"\n   Share this link to invite people!")
    else:
        print(f"   ⚠️  No invite link available")
        print(f"      Group might need to be updated to enable links")
    
    print("")

print("=" * 60)
print("\n💡 To share an invite link:")
print("   1. Copy the link above")
print("   2. Send it via SMS, email, or any messaging app")
print("   3. Recipients tap the link")
print("   4. They join the group automatically!\n")
EOF

