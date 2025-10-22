# How to Accept Group Invitations

## 📬 **When Someone Invites You to a Group**

Since your number (+40751770274) is registered in the project (not on your phone), you need to accept invitations via the project.

---

## 🔍 **Check for Pending Invitations**

```bash
cd <project-root>/signal-api
./accept-group-invite.sh
```

This shows:
- All pending group invitations
- Group names and IDs
- Instructions to accept

---

## ✅ **Accept an Invitation**

### **Method 1: Using signal-cli Command**

```bash
# Format:
docker exec signal-api signal-cli -a +40751770274 \
  joinGroup --group-id INTERNAL_ID

# Example:
docker exec signal-api signal-cli -a +40751770274 \
  joinGroup --group-id WvsaevqhZmtVQc3SBXwT6TWZCsYqpQ1iisE7xvFNah0=
```

**Get the INTERNAL_ID from:**
- Running `./accept-group-invite.sh`
- Or from groups list (it's the `internal_id` field, NOT the `id` field)

---

### **Method 2: Auto-Accept (If You Trust the Inviter)**

The invitation is usually auto-accepted when you sync. Just run:

```bash
./sync-groups.sh
```

Then refresh your web app - the group should appear!

---

## 📋 **Complete Workflow**

### **Scenario: Someone Invited You to a Group**

**Step 1: Sync to get the invitation**
```bash
cd signal-api
./sync-groups.sh
```

**Step 2: Check for invitations**
```bash
./accept-group-invite.sh
```

**Step 3: If invitation listed, accept it**
```bash
# Copy the internal_id from the output above
docker exec signal-api signal-cli -a +40751770274 \
  joinGroup --group-id INTERNAL_ID_HERE
```

**Step 4: Sync again**
```bash
./sync-groups.sh
```

**Step 5: Refresh web app**
- Go to http://localhost:3000
- Click refresh (🔄)
- New group appears!

---

## 🎯 **Simpler Approach**

**Most of the time, just syncing is enough:**

```bash
cd signal-api
./sync-groups.sh
```

Then check web app - groups you were invited to should appear automatically!

---

## 📱 **When You Get Invited:**

**Someone adds you to a group → You need to:**

1. **Sync:**
   ```bash
   cd signal-api && ./sync-groups.sh
   ```

2. **Refresh web app:**
   - Click 🔄 button
   - OR refresh browser

3. **Group appears!**
   - Select it
   - Send messages
   - Done! ✅

---

## 🔧 **If Group Doesn't Appear After Sync:**

**Check pending invitations:**
```bash
./accept-group-invite.sh
```

**Then manually accept:**
```bash
docker exec signal-api signal-cli -a +40751770274 \
  joinGroup --group-id INTERNAL_ID
```

---

## ✅ **Quick Reference**

**Check invitations:**
```bash
./accept-group-invite.sh
```

**Accept invitation:**
```bash
docker exec signal-api signal-cli -a +40751770274 \
  joinGroup --group-id INTERNAL_ID
```

**Sync after accepting:**
```bash
./sync-groups.sh
```

**Refresh web app:**
- http://localhost:3000
- Click 🔄

---

**Most of the time, just running `./sync-groups.sh` and refreshing the web app is enough!** 🔄✨

