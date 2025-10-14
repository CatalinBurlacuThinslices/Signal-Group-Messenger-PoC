#!/bin/bash

echo "========================================="
echo "Link Signal Account (Like Signal Desktop)"
echo "========================================="
echo ""

echo "This will generate a QR code to link your existing Signal account"
echo ""

# Generate QR code link
echo "Step 1: Generating QR code..."
echo ""

# Start the linking process
curl -X GET "http://localhost:8080/v1/qrcodelink?device_name=SignalPoC" > qr.png

if [ -f "qr.png" ]; then
    echo "✅ QR code generated: qr.png"
    echo ""
    echo "Step 2: Open the image:"
    echo ""
    
    # Try to open the QR code
    if command -v open > /dev/null; then
        open qr.png
        echo "✅ QR code opened"
    else
        echo "Open the file: $(pwd)/qr.png"
    fi
    
    echo ""
    echo "Step 3: Scan with your phone:"
    echo ""
    echo "  1. Open Signal app on your phone"
    echo "  2. Go to Settings → Linked Devices"
    echo "  3. Tap '+' or 'Link New Device'"
    echo "  4. Scan the QR code on your screen"
    echo ""
    echo "Step 4: Wait for confirmation (this script will wait...)"
    echo ""
    echo "Once linked, you'll be able to:"
    echo "  - See all your groups"
    echo "  - Send messages to groups"
    echo "  - Use the web UI at http://localhost:3000"
    echo ""
else
    echo "❌ Failed to generate QR code"
    echo ""
    echo "Make sure Signal API is running:"
    echo "  docker-compose up -d"
    echo ""
    echo "Check status:"
    echo "  docker ps | grep signal"
    echo "  curl http://localhost:8080/v1/health"
fi

