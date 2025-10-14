#!/bin/bash

echo "========================================="
echo "Signal Device Linking - Complete Process"
echo "========================================="
echo ""

PHONE_NUMBER="+40751770274"

# Function to check if linked
check_linked() {
    docker exec signal-api signal-cli -a "$PHONE_NUMBER" listGroups -d 2>&1 | grep -v "not registered" | grep -q "Id:"
    return $?
}

# Function to wait for linking
wait_for_linking() {
    echo "⏳ Waiting for you to scan QR code and complete linking on your phone..."
    echo ""
    
    for i in {1..60}; do
        if check_linked; then
            echo ""
            echo "✅ Device linked successfully!"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    echo ""
    echo "⏱️ Timeout - linking not completed in 60 seconds"
    return 1
}

# Step 1: Check if already linked
echo "Step 1: Checking current status..."
if check_linked; then
    echo "✅ Already linked!"
    echo ""
    docker exec signal-api signal-cli -a "$PHONE_NUMBER" listGroups -d
    exit 0
fi
echo "Not linked yet - proceeding..."
echo ""

# Step 2: Generate QR code
echo "Step 2: Generating QR code..."
curl -s "http://localhost:8080/v1/qrcodelink?device_name=SignalPoC-$(date +%s)" > qr-link.png

if [ -f "qr-link.png" ]; then
    echo "✅ QR code generated: qr-link.png"
    
    # Open it
    if command -v open > /dev/null; then
        open qr-link.png
        echo "✅ QR code opened"
    else
        echo "Open: $(pwd)/qr-link.png"
    fi
else
    echo "❌ Failed to generate QR code"
    echo "Make sure Signal API is running: docker ps | grep signal"
    exit 1
fi

echo ""
echo "========================================="
echo "📱 NOW DO THIS ON YOUR PHONE:"
echo "========================================="
echo ""
echo "  1. Open Signal app"
echo "  2. Tap Settings (your profile)"
echo "  3. Tap 'Linked devices'"
echo "  4. Tap the '+' button"
echo "  5. Scan the QR code"
echo "  6. Tap 'Link Device'"
echo ""
echo "  ⚠️  IMPORTANT: Keep Signal app open!"
echo "     Wait for 'Syncing...' to complete"
echo "     Don't close the app for 30 seconds"
echo ""
echo "========================================="
echo ""

# Step 3: Wait for linking
if wait_for_linking; then
    echo ""
    echo "Step 3: Verifying account..."
    sleep 5
    
    # Force sync
    echo "Forcing sync..."
    docker exec signal-api signal-cli -a "$PHONE_NUMBER" receive --timeout 5 2>&1 > /dev/null || true
    
    sleep 2
    
    # List groups
    echo ""
    echo "Your Signal groups:"
    docker exec signal-api signal-cli -a "$PHONE_NUMBER" listGroups -d 2>&1
    
    echo ""
    echo "========================================="
    echo "✅ SUCCESS!"
    echo "========================================="
    echo ""
    echo "Now:"
    echo "  1. Refresh your browser: http://localhost:3000"
    echo "  2. Your groups should appear!"
    echo "  3. You can send messages!"
    echo ""
else
    echo ""
    echo "========================================="
    echo "❌ Linking Failed or Timed Out"
    echo "========================================="
    echo ""
    echo "Possible issues:"
    echo "  - QR code expired (they last 60 seconds)"
    echo "  - You closed Signal app too quickly"
    echo "  - Network connection interrupted"
    echo ""
    echo "Try again:"
    echo "  ./link-and-verify.sh"
    echo ""
fi

