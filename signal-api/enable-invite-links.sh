#!/bin/bash

echo "========================================="
echo "📎 Enable Invite Links for All Groups"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

# Get all groups
GROUPS=$(curl -s "http://localhost:8080/v1/groups/$PHONE_NUMBER")

if [ -z "$GROUPS" ] || [ "$GROUPS" = "[]" ]; then
    echo "❌ No groups found"
    exit 1
fi

echo "Enabling invite links for all groups..."
echo ""

# Process each group
echo "$GROUPS" | python3 << 'PYTHON_SCRIPT'
import sys, json, subprocess

groups = json.loads(sys.stdin.read())
phone = "+40751770274"

for i, group in enumerate(groups, 1):
    name = group.get('name', 'Unknown')
    group_id = group.get('id', '')
    
    if not group_id:
        continue
    
    print(f"{i}. Enabling link for: {name}")
    
    # Enable invite link
    cmd = [
        'curl', '-s', '-X', 'PUT',
        f'http://localhost:8080/v1/groups/{phone}/{group_id}',
        '-H', 'Content-Type: application/json',
        '-d', '{"resetLink": true}'
    ]
    
    try:
        subprocess.run(cmd, capture_output=True, timeout=10)
        print(f"   ✅ Link enabled")
    except:
        print(f"   ❌ Failed")
    
    print("")

print("=" * 60)
print("\nNow run ./get-invite-links.sh to see all invite links!")
PYTHON_SCRIPT

echo ""
echo "✅ Done! Now get the links:"
echo "   ./get-invite-links.sh"

