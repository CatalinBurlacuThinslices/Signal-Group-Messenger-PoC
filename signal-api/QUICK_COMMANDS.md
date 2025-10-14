# Quick Commands Reference - Signal PoC

## 📤 **Send Message to Group**

```bash
curl -X POST http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Your message here",
    "number": "+40751770274",
    "recipients": ["group.YOUR_GROUP_ID_HERE"]
  }'
```

**Example:**
```bash
curl -X POST http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Hello everyone! 👋",
    "number": "+40751770274",
    "recipients": ["group.ekx1bkd6U1lMTVRHcWk1ZzBDQlRHblFqK1A0VklrbTdXRmFMd0lWSGFEQT0="]
  }'
```

---

## ➕ **Create New Group with Members**

```bash
curl -X POST http://localhost:8080/v1/groups/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Your Group Name",
    "members": ["+40PHONE1", "+40PHONE2"],
    "description": "Group description"
  }'
```

**Example:**
```bash
curl -X POST http://localhost:8080/v1/groups/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Team Alerts",
    "members": ["+40757239300", "+40123456789"],
    "description": "Important team notifications"
  }'
```

---

## 🔗 **Generate Invite Link for Existing Group**

```bash
# Get the group's internal ID first
curl -s http://localhost:8080/v1/groups/+40751770274 | python3 -m json.tool | grep -B 2 "YOUR_GROUP_NAME"

# Then enable the invite link
curl -X PUT http://localhost:8080/v1/groups/+40751770274/group.YOUR_GROUP_ID \
  -H 'Content-Type: application/json' \
  -d '{
    "resetLink": true
  }'
```

**Example:**
```bash
# Enable invite link for a specific group
curl -X PUT http://localhost:8080/v1/groups/+40751770274/group.ekx1bkd6U1lMTVRHcWk1ZzBDQlRHblFqK1A0VklrbTdXRmFMd0lWSGFEQT0= \
  -H 'Content-Type: application/json' \
  -d '{
    "resetLink": true
  }'

# Then fetch groups to see the link
curl -s http://localhost:8080/v1/groups/+40751770274 | python3 -m json.tool | grep "invite_link"
```

---

## 🆕 **Create Group WITH Invite Link**

```bash
# Step 1: Create the group
RESPONSE=$(curl -s -X POST http://localhost:8080/v1/groups/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "My New Group",
    "members": ["+40PHONE"],
    "description": "Group with invite link"
  }')

# Step 2: Get the group ID from response
GROUP_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")

# Step 3: Enable invite link
curl -X PUT "http://localhost:8080/v1/groups/+40751770274/$GROUP_ID" \
  -H 'Content-Type: application/json' \
  -d '{
    "resetLink": true
  }'

# Step 4: Get the invite link
curl -s "http://localhost:8080/v1/groups/+40751770274" | \
  python3 -c "import sys, json; groups=json.load(sys.stdin); [print(f'{g[\"name\"]}: {g.get(\"invite_link\", \"none\")}') for g in groups if g['name'] == 'My New Group']"
```

---

## 📋 **Complete Example: Create Group with Link in One Script**

Save this as a script:

```bash
#!/bin/bash

GROUP_NAME="$1"
MEMBER_PHONE="$2"

# Create group
echo "Creating group: $GROUP_NAME"
RESPONSE=$(curl -s -X POST http://localhost:8080/v1/groups/+40751770274 \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"$GROUP_NAME\",
    \"members\": [\"$MEMBER_PHONE\"],
    \"description\": \"Created from PoC\"
  }")

GROUP_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)

if [ -n "$GROUP_ID" ]; then
  echo "✅ Group created: $GROUP_ID"
  
  # Enable invite link
  echo "Generating invite link..."
  curl -s -X PUT "http://localhost:8080/v1/groups/+40751770274/$GROUP_ID" \
    -H 'Content-Type: application/json' \
    -d '{"resetLink": true}' > /dev/null
  
  sleep 2
  
  # Get invite link
  INVITE=$(curl -s "http://localhost:8080/v1/groups/+40751770274" | \
    python3 -c "import sys, json; groups=json.load(sys.stdin); print([g.get('invite_link', '') for g in groups if g['id'] == '$GROUP_ID'][0])")
  
  echo "✅ Group created with invite link:"
  echo "$INVITE"
else
  echo "❌ Failed to create group"
fi
```

---

## 👥 **Add Member to Existing Group**

```bash
curl -X POST http://localhost:8080/v1/groups/+40751770274/GROUP_ID/members \
  -H 'Content-Type: application/json' \
  -d '{
    "member": "+40PHONE_NUMBER"
  }'
```

---

## 📊 **List All Groups with Invite Links**

```bash
curl -s http://localhost:8080/v1/groups/+40751770274 | \
  python3 -c "
import sys, json
groups = json.load(sys.stdin)
for g in groups:
    print(f'\nGroup: {g[\"name\"]}')
    print(f'ID: {g[\"id\"]}')
    print(f'Members: {len(g.get(\"members\", []))}')
    link = g.get('invite_link', '')
    print(f'Invite: {link if link else \"(none - run enable command)\"}')
"
```

---

## 🔄 **Sync Groups (Get Latest)**

```bash
curl -s "http://localhost:8080/v1/receive/+40751770274?timeout=15"
```

Or use the script:
```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api
./sync-groups.sh
```

---

**Save these commands for quick reference!** 📋✨

