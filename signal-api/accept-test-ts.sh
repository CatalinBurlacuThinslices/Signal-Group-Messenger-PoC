#!/bin/bash

echo "========================================="
echo "✅ Accept Invitation to 'Test TS' Group"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"
GROUP_INTERNAL_ID="2zOz9Zp+W3bQE8cNDDnld2PPzH3Yv8jZ0AI7opV0X0Q="

echo "Accepting invitation to 'Test TS' group..."
echo ""

# Method 1: Try updating the group (syncs membership)
echo "Method 1: Syncing group membership..."
docker exec signal-api signal-cli -a $PHONE_NUMBER updateGroup -g $GROUP_INTERNAL_ID 2>&1

# Method 2: Sync account
echo ""
echo "Method 2: Syncing account..."
curl -s "http://localhost:8080/v1/receive/$PHONE_NUMBER?timeout=15" > /dev/null 2>&1
sleep 2

# Method 3: Try via API
echo ""
echo "Method 3: Updating via API..."
curl -s -X PUT "http://localhost:8080/v1/groups/$PHONE_NUMBER/group.MnpPejlacCtXM2JRRThjTkREbmxkMlBQekgzWXY4alowQUk3b3BWMFgwUT0=" \
  -H 'Content-Type: application/json' \
  -d '{}' > /dev/null 2>&1

sleep 3

# Check if now a member
echo ""
echo "Checking membership status..."
RESULT=$(curl -s "http://localhost:8080/v1/groups/$PHONE_NUMBER" | \
  python3 -c "
import sys, json
try:
    groups = json.load(sys.stdin)
    ts = [g for g in groups if 'Test TS' in g['name']]
    if ts:
        g = ts[0]
        members = g.get('members', [])
        pending = g.get('pending_requests', [])
        
        if '+40751770274' in members:
            print('✅ SUCCESS! You are now a member!')
            print(f'   Members: {members}')
        elif '+40751770274' in pending:
            print('⏳ Still pending - admin needs to approve you')
            print('   Ask the admin (+40748478455) to approve your request')
        else:
            print('⚠️  Status unclear')
    else:
        print('❌ Group not found')
except Exception as e:
    print(f'❌ Error: {e}')
" 2>&1)

echo "$RESULT"
echo ""
echo "========================================="
echo ""

if echo "$RESULT" | grep -q "SUCCESS"; then
    echo "🎉 You can now send messages to 'Test TS'!"
    echo ""
    echo "Next steps:"
    echo "  1. Refresh web app: http://localhost:3000"
    echo "  2. Click 🔄 refresh button"
    echo "  3. Select 'Test TS'"
    echo "  4. Send a message!"
else
    echo "The admin (+40748478455) needs to approve you first."
    echo ""
    echo "Ask them to:"
    echo "  1. Open Signal app"
    echo "  2. Go to 'Test TS' group"
    echo "  3. See your join request"
    echo "  4. Tap 'Approve'"
    echo ""
    echo "Then run this script again!"
fi

