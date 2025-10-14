#!/bin/bash

echo "========================================="
echo "➕ Add Member to Signal Group"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./add-member-to-group.sh GROUP_ID PHONE_NUMBER_TO_ADD"
    echo ""
    echo "Example:"
    echo "  ./add-member-to-group.sh 'group.ABC123...' '+40757239300'"
    echo ""
    echo "To see your groups and their IDs, run:"
    echo "  curl http://localhost:8080/v1/groups/+40751770274 | python3 -m json.tool"
    echo ""
    exit 1
fi

GROUP_ID="$1"
MEMBER_TO_ADD="$2"

echo "Adding member to group..."
echo "Group ID: $GROUP_ID"
echo "Member: $MEMBER_TO_ADD"
echo ""

# Add member via API
HTTP_CODE=$(curl -s -w "%{http_code}" -o /tmp/signal_response.txt \
  -X POST "http://localhost:8080/v1/groups/$PHONE_NUMBER/$GROUP_ID/members" \
  -H 'Content-Type: application/json' \
  -d "{\"member\": \"$MEMBER_TO_ADD\"}")

RESPONSE=$(cat /tmp/signal_response.txt 2>/dev/null)

echo "HTTP Status: $HTTP_CODE"
[ -n "$RESPONSE" ] && echo "Response: $RESPONSE"
echo ""

# 204 No Content means success
if [ "$HTTP_CODE" = "204" ] || [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Member invitation sent!"
    echo ""
    echo "What happens next:"
    echo "  1. $MEMBER_TO_ADD receives invitation in Signal app"
    echo "  2. They tap to accept"
    echo "  3. They join the group"
    echo "  4. Run ./sync-groups.sh to update"
    echo "  5. Refresh web app to see updated member list"
    echo ""
    echo "To verify:"
    echo "  curl -s http://localhost:8080/v1/groups/$PHONE_NUMBER | python3 -m json.tool | grep -A 5 '$GROUP_ID'"
else
    echo "❌ Failed to add member (HTTP $HTTP_CODE)"
    [ -n "$RESPONSE" ] && echo "$RESPONSE"
fi

rm -f /tmp/signal_response.txt

