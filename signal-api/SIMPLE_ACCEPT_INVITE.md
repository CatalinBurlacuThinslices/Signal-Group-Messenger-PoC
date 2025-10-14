# Simple Guide: Accept Group Invitations

## 🎯 **Quick Answer**

When someone invites your number (+40751770274) to a group:

### **Just Sync and Refresh!**

```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api
./sync-groups.sh
```

Then **refresh your web app:** http://localhost:3000

**The group will appear automatically!** ✅

---

## 📋 **That's It!**

**Most invitations are auto-accepted** when you sync. You don't need to do anything special.

---

## 🔍 **If Group Still Doesn't Appear**

**Manually check what groups you have:**

```bash
curl -s http://localhost:8080/v1/groups/+40751770274 | python3 -m json.tool
```

Look for:
- `"isMember": false` - Means you need to accept
- `"pending_invites": [...]` - Shows who's invited

---

## ✅ **Manual Accept (If Needed)**

**If a group shows `"isMember": false`, accept it:**

```bash
# Get the internal_id from the group
# Then run:
docker exec signal-api signal-cli -a +40751770274 \
  joinGroup --group-id INTERNAL_ID_HERE
```

**Example:**
```bash
docker exec signal-api signal-cli -a +40751770274 \
  joinGroup --group-id WvsaevqhZmtVQc3SBXwT6TWZCsYqpQ1iisE7xvFNah0=
```

---

## 🔄 **Complete Workflow**

**1. Someone invites you**
   ```
   "Hey, I added +40751770274 to our group!"
   ```

**2. You sync:**
   ```bash
   cd signal-api
   ./sync-groups.sh
   ```

**3. You refresh web app:**
   - Go to http://localhost:3000
   - Click 🔄 refresh button
   - Group appears!

**4. Send message:**
   - Select the group
   - Type message
   - Send
   - Everyone sees it! ✅

---

## 💡 **Pro Tip**

The 🔄 **Refresh button** in your web app now:
1. Syncs with Signal API automatically
2. Fetches updated groups
3. Shows any new invitations

**So just clicking refresh in the web app is usually enough!**

---

## 🎯 **Summary**

**To accept invitations:**
1. Click 🔄 refresh in web app
2. Group appears
3. Done! ✅

**99% of the time, this is all you need!**

---

**Try it: Have someone invite +40751770274 to a group, then just click refresh in your web app!** 🔄✨

