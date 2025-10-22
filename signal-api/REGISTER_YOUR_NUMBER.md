# Register Your Number - Complete Guide

## ⚠️ **CRITICAL WARNING**

**Registering your number here will UNREGISTER it from your phone!**

Your phone will lose Signal access until you re-register it.

**Recommended:** Use a different/test number instead!

---

## 📱 **Steps to Register +40751770274**

### Step 1: Get Captcha Token

1. **Open:** https://signalcaptchas.org/registration/generate.html
2. **Solve the captcha**
3. **Right-click "Open Signal"** button
4. **Copy the link** (starts with `signalcaptcha://`)

Example: `signalcaptcha://signal-recaptcha-v2.03AGdBq26Abcd...`

### Step 2: Register with Captcha

```bash
cd <project-root>/signal-api

# Use the FULL link you copied
./register.sh 'signalcaptcha://signal-recaptcha-v2.YOUR_TOKEN_HERE'
```

**You'll see:**
```
✅ Registration request sent!
📱 Check your phone for SMS with verification code
```

### Step 3: Verify with SMS Code

Check your SMS for 6-digit code, then:

```bash
./verify.sh 123456
```

Replace `123456` with your actual code.

**You'll see:**
```
✅ Verification successful!
Your Signal number is now registered!
```

### Step 4: Verify It Worked

```bash
curl http://localhost:8080/v1/groups/+40751770274
# Should show your groups!
```

### Step 5: Restart Web App

```bash
cd <project-root>
./STOP_PROJECT.sh
./START_PROJECT.sh
```

### Step 6: Test Sending

1. **Open:** http://localhost:3000
2. **Select a group**
3. **Send message**
4. **✅ Everyone will see it!**

---

## 🔄 **What Happens to Your Phone**

**After registering here:**
- ❌ Your phone loses Signal access
- ❌ Messages won't arrive on phone
- ❌ Can't send from phone

**To fix your phone:**
1. Open Signal app on phone
2. It will ask to re-register
3. Follow the prompts
4. Phone works again ✅

**But then:**
- This web app will stop working
- Because the number is back on your phone
- Can't have same number on two PRIMARY devices

---

## 💡 **Better Alternative: Use Test Number**

**Get a secondary number:**
- Cheap prepaid SIM (~$5-10)
- Google Voice (free, US only)  
- Twilio number ($1/month)
- Any VoIP service

**Then:**
1. Register that number here
2. Keep your main Signal on your phone
3. Both work perfectly! ✅

---

## 🎯 **Recommendation**

**DON'T register your main number +40751770274**

**Instead:**
1. Get a test number
2. Register that number
3. Add it to your Signal groups  
4. Use web app with test number
5. Your main Signal stays on your phone

**OR:**
- Use Demo Mode for showing the PoC
- It demonstrates everything perfectly
- No Signal setup needed

---

## ⚡ **Quick Decision Guide**

**Choose:**

**A) Demo Mode** (Safe, works now)
```bash
cd signal-poc
./switch-mode.sh demo
```
- ✅ No risk to your phone
- ✅ Shows full functionality
- ❌ Messages don't actually send

**B) Test Number** (Best for real usage)
- ✅ Full functionality
- ✅ Your phone keeps working
- ❌ Need to get another number

**C) Register Main Number** (Not recommended!)
- ✅ Full functionality
- ❌ Your phone loses Signal
- ❌ Can't use both simultaneously

---

**What would you like to do?** 🤔

