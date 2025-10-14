# Quick Registration (Alternative to Linking)

If device linking isn't working due to network issues, you can register your number directly.

## Steps:

### 1. Get Captcha Token

Visit: https://signalcaptchas.org/registration/generate.html

- Solve the captcha
- Right-click "Open Signal" button
- Copy the link (starts with `signalcaptcha://`)

### 2. Register

```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api

# Run the register script with your captcha token
./register.sh 'YOUR_CAPTCHA_TOKEN_HERE'
```

### 3. Verify with SMS Code

```bash
# Once you receive SMS code
./verify.sh YOUR_6_DIGIT_CODE
```

### 4. Done!

After verification:
- Update backend/.env with your number
- Refresh http://localhost:3000
- You'll see all your groups!

## Note

**Warning:** This will register your phone number with Signal on this computer. If you already use Signal on your phone, you'll need to re-register your phone afterwards, OR better yet, use a different number for this PoC.

**Better:** Use Option B (Phone's Hotspot) for linking instead!

