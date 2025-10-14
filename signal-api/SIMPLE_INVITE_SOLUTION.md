# Simple Solution: Invite People to Your Groups

## 🎯 **The Situation**

You registered your number **+40751770274** in the project, so:
- ❌ Can't use your phone Signal app anymore
- ❌ Can't get invite links from phone
- ✅ But you CAN add members directly via the project!

---

## ✅ **Solution: Add Members via Project**

### **Step 1: See Your Groups**

```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api

# List groups
curl -s http://localhost:8080/v1/groups/+40751770274 | python3 -m json.tool
```

You'll see:
- Group names
- Group IDs (like `group.ABC123...`)
- Current members

---

### **Step 2: Add Someone to a Group**

```bash
# Format:
./add-member-to-group.sh 'GROUP_ID' '+PHONE_NUMBER'

# Example - Add +40757239300 to first group:
./add-member-to-group.sh 'group.V3ZzYWV2cWhabXRWUWMzU0JYd1Q2VFdaQ3NZcXBRMWlpc0U3eHZGTmFoMD0=' '+40757239300'
```

---

### **Step 3: They Receive Invite**

The person will:
1. Get notified in Signal app
2. See group invitation
3. Accept it
4. Join the group!

---

### **Step 4: Send Messages**

Once they join:
1. **Go to:** http://localhost:3000
2. **Click refresh** (🔄)
3. **Select the group**
4. **Send message**
5. **Everyone sees it!** ✅

---

## 📋 **Your Current Groups:**

From the data I see:

**1. "Test Group From Web"**
- ID: `group.V3ZzYWV2cWhabXRWUWMzU0JYd1Q2VFdaQ3NZcXBRMWlpc0U3eHZGTmFoMD0=`
- Has pending request from: +40757239300

**2. "Web App Test Group"**
- ID: `group.UkhXTjVrZG1HTk13RDRGamszM3FJeVVEdFBlR00zTXBIY3haV2tmUndBbz0=`
- No pending requests

---

## 💡 **Quick Example:**

**To invite +40757239300 to "Web App Test Group":**

```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api

./add-member-to-group.sh \
  'group.UkhXTjVrZG1HTk13RDRGamszM3FJeVVEdFBlR00zTXBIY3haV2tmUndBbz0=' \
  '+40757239300'
```

They'll get an invitation in their Signal app!

---

## 🔄 **Alternative: Create Group with Members**

Create a NEW group and add members immediately:

```bash
curl -X POST http://localhost:8080/v1/groups/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "My New Group",
    "members": ["+40757239300", "+40123456789"],
    "description": "Group with members added"
  }'
```

Everyone gets invited automatically!

---

## 📊 **Complete Workflow:**

**1. Create group with members:**
```bash
curl -X POST http://localhost:8080/v1/groups/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Safe Alerts Group",
    "members": ["+40757239300"]
  }'
```

**2. They accept on their phone**

**3. You send messages from web app:**
- http://localhost:3000
- Select "Safe Alerts Group"
- Send message
- **Everyone sees it!** ✅

---

## 🎯 **Try This Now:**

**Add someone to "Web App Test Group":**

```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api

# Replace with actual phone number to invite
./add-member-to-group.sh \
  'group.UkhXTjVrZG1HTk13RDRGamszM3FJeVVEdFBlR00zTXBIY3haV2tmUndBbz0=' \
  '+40757239300'
```

**OR create a brand new group with members:**

```bash
curl -X POST http://localhost:8080/v1/groups/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "PoC Demo Group",
    "members": ["+40757239300"]
  }'
```

Then refresh your web app - the group appears with members already added!

---

**This way you can invite people WITHOUT needing your phone!** 🎉
