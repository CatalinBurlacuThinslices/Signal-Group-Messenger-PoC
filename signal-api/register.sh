#!/bin/bash

# Signal Number Registration Helper Script
# This script helps you register your Signal number with captcha support

echo "========================================="
echo "Signal Number Registration"
echo "========================================="
echo ""

# Your phone number
PHONE_NUMBER="+40751770274"

echo "Phone number: $PHONE_NUMBER"
echo ""

# Check if captcha token is provided
if [ -z "$1" ]; then
    echo "📋 Step 1: Get Captcha Token"
    echo ""
    echo "1. Open: https://signalcaptchas.org/registration/generate.html"
    echo "2. Solve the captcha"
    echo "3. Right-click 'Open Signal' button"
    echo "4. Copy the link"
    echo "5. Run this script again with the token:"
    echo ""
    echo "   ./register.sh 'signal-recaptcha-v2.YOUR_TOKEN_HERE'"
    echo ""
    exit 0
fi

CAPTCHA_TOKEN="$1"

echo "🔄 Registering with captcha..."
echo ""

# Register with captcha
RESPONSE=$(curl -s -X POST http://localhost:8080/v1/register/$PHONE_NUMBER \
  -H 'Content-Type: application/json' \
  -d "{\"use_voice\": false, \"captcha\": \"$CAPTCHA_TOKEN\"}")

echo "Response: $RESPONSE"
echo ""

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Registration failed"
    echo ""
    echo "Possible issues:"
    echo "  - Captcha token expired (get a new one)"
    echo "  - Signal API not running (docker-compose up -d)"
    echo "  - Token format incorrect"
    exit 1
fi

echo "✅ Registration request sent!"
echo ""
echo "📱 Check your phone for SMS with verification code"
echo ""
echo "Once you receive the code, verify with:"
echo ""
echo "  curl -X POST http://localhost:8080/v1/register/$PHONE_NUMBER/verify/YOUR_CODE"
echo ""
echo "Or use the verify script:"
echo "  ./verify.sh YOUR_CODE"

