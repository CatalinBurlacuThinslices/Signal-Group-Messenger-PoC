# Message Sending Guide - Signal Linked Device Behavior

## 🔍 Understanding Linked Device Messages

When you link signal-cli as a device (like Signal Desktop), there are some important things to know:

### **How It Works:**

**Your Setup:**
```
Phone (Primary Device)
  ├── Signal Desktop (Linked Device)
  └── signal-cli (Linked Device) ← Your web app
```

### **Message Behavior:**

**Messages sent from linked devices:**
- ✅ Appear in the group for all members
- ✅ Show as coming from your account
- ✅ Sync to your phone
- ⚠️ Might show differently depending on Signal version

---

## 🐛 **"Note to Self" Issue:**

### **Why it happens:**

**Problem 1: Group Only Has You**
- If a group only has 1 member (you), messages appear as notes
- Check group members in Signal app
- Add at least one other person to the group

**Problem 2: Linked Device Sync**
- Linked devices need to fully sync group membership
- Sometimes takes a few messages to complete

**Problem 3: Signal App Version**
- Some versions of Signal show linked device messages differently
- Update Signal app to latest version

---

## ✅ **Solutions:**

### Solution 1: Add More Members to Group

**In Signal mobile app:**
1. Open the group
2. Tap group name at top
3. Tap "Add members"
4. Add at least 1 contact
5. Try sending from web app again

### Solution 2: Force Full Sync

**Run this script:**
```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api
./sync-groups.sh
```

**Or manually:**
```bash
# Receive to sync
curl "http://localhost:8080/v1/receive/+40751770274?timeout=30"

# Wait a bit
sleep 10

# Try sending again from web app
```

### Solution 3: Send Message to Your Phone First

**From web app, send:**
```
"Testing - if you see this, reply with YES"
```

**On your phone:**
- Check if message appears
- Reply from phone in the group
- Try sending from web app again

This "primes" the group for linked device messages.

---

## 📱 **Check Group Membership:**

Your current groups:
- **Signal-test**: Only you (appears as note)
- **signal-test-2**: You + another person (should work properly!)

**Solution:** Try sending to "signal-test-2" instead - it has 2 members!

---

## 🧪 **Testing Steps:**

### Test 1: Send to Group with Multiple Members

1. **In web app:** http://localhost:3000
2. **Select:** "signal-test-2" (has 2 members)
3. **Type:** "Hello everyone!"
4. **Send**
5. **Check on your phone AND ask the other member** if they saw it

### Test 2: Add Member to Signal-test

1. **Open Signal app** on phone
2. **Open "Signal-test" group**
3. **Add a contact** to the group
4. **Try sending from web app**
5. **Check if both people see it**

---

## 🔧 **How Signal Linked Devices Work:**

### What Linked Devices CAN Do:
- ✅ Read all messages
- ✅ Send messages to groups
- ✅ Send messages to individuals
- ✅ See all conversations

### What's Different:
- ⚠️ Messages come from "Your Name (Device Name)"
- ⚠️ Some features limited vs phone
- ⚠️ Need proper group membership sync

### Not Bugs:
- Messages syncing to your phone ✅ (correct behavior)
- Showing your name as sender ✅ (correct)
- Need internet on both devices ✅ (normal)

---

## 🎯 **Quick Fix:**

**Right now in web app:**

1. **Click "signal-test-2"** (the one with 2 members)
2. **Type:** "Test message - can +40757239300 see this?"
3. **Send**
4. **Check:**
   - Your phone (should see it)
   - Ask +40757239300 if they see it

If **signal-test-2** works but **Signal-test** doesn't, it's because Signal-test only has you as member!

---

## 📊 **Group Status:**

```
Signal-test:
  Members: Just you (+40751770274)
  Status: Messages appear as "note to self"
  Fix: Add more members!

signal-test-2:
  Members: You (+40751770274) + Another (+40757239300)
  Status: Should work for everyone!
  Try: Send to this group
```

---

## 🚀 **Try This Now:**

1. **Refresh browser:** http://localhost:3000
2. **Select "signal-test-2"**
3. **Send a message**
4. **Check both phones** - should work!

Then if you want Signal-test to work:
- Add members to it in Signal app
- Try again

---

**This is normal Signal behavior - groups with only 1 member (you) show as notes!** 📝

Try sending to **signal-test-2** now and it should work properly! 🎉

