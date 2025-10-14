#!/bin/bash

echo "========================================="
echo "Syncing Signal Groups"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

echo "Forcing sync for: $PHONE_NUMBER"
echo ""

# Call receive to sync
echo "Step 1: Receiving messages (this syncs groups)..."
curl -s "http://localhost:8080/v1/receive/$PHONE_NUMBER?timeout=15" > /dev/null

echo "✅ Sync complete"
echo ""

# List groups
echo "Step 2: Fetching groups..."
GROUPS=$(curl -s "http://localhost:8080/v1/groups/$PHONE_NUMBER")

echo "$GROUPS" | python3 -m json.tool 2>&1 | grep -E "name|members" | head -20

echo ""
echo "✅ Done! Refresh your browser to see updated groups."
echo "   http://localhost:3000"

