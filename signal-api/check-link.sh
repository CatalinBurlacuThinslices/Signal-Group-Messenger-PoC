#!/bin/bash

echo "========================================="
echo "Checking if device is linked..."
echo "========================================="
echo ""

# Check if linked
docker exec signal-api signal-cli -u +40751770274 listDevices 2>&1 | grep -v "not registered" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ SUCCESS! Device is linked!"
    echo ""
    echo "Your linked devices:"
    docker exec signal-api signal-cli -u +40751770274 listDevices
    echo ""
    echo "🎉 Now refresh your browser at http://localhost:3000"
    echo "   You should see all your groups!"
else
    echo "❌ Not linked yet"
    echo ""
    echo "Make sure you:"
    echo "  1. Scanned the QR code with Signal app"
    echo "  2. Tapped 'Link Device' on your phone"
    echo "  3. Waited for confirmation"
    echo ""
    echo "Try running this script again after linking."
fi

