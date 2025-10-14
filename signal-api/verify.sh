#!/bin/bash

# Signal Number Verification Helper Script

echo "========================================="
echo "Signal Number Verification"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

if [ -z "$1" ]; then
    echo "Usage: ./verify.sh YOUR_6_DIGIT_CODE"
    echo ""
    echo "Example: ./verify.sh 123456"
    echo ""
    exit 1
fi

VERIFICATION_CODE="$1"

echo "Phone: $PHONE_NUMBER"
echo "Code:  $VERIFICATION_CODE"
echo ""
echo "Verifying..."
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/v1/register/$PHONE_NUMBER/verify/$VERIFICATION_CODE)

echo "Response: $RESPONSE"
echo ""

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Verification failed"
    echo ""
    echo "Possible issues:"
    echo "  - Wrong code (check SMS again)"
    echo "  - Code expired (request new registration)"
    echo "  - Signal API not running"
    exit 1
fi

echo "✅ Verification successful!"
echo ""
echo "Your Signal number is now registered!"
echo ""
echo "Next steps:"
echo "  1. Create a group in Signal mobile app"
echo "  2. Open http://localhost:3000"
echo "  3. Start sending messages!"

