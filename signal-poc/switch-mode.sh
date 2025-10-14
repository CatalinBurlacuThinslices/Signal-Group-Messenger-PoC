#!/bin/bash

echo "========================================="
echo "Switch Between Demo and Real Mode"
echo "========================================="
echo ""

if [ "$1" = "demo" ]; then
    echo "Switching to DEMO mode..."
    pkill -f "node server.js"
    sleep 1
    cd backend
    node demo-mode.js &
    echo "✅ Demo mode started"
    echo "   Mock groups will appear"
    echo "   Messages won't actually send"
    
elif [ "$1" = "real" ]; then
    echo "Switching to REAL mode..."
    pkill -f "demo-mode.js"
    sleep 1
    cd backend
    PORT=5001 node server.js &
    echo "✅ Real mode started"
    echo "   Connects to Signal API"
    echo "   Requires device linking or registration"
    
else
    echo "Usage:"
    echo "  ./switch-mode.sh demo   # Switch to demo mode (mock data)"
    echo "  ./switch-mode.sh real   # Switch to real Signal mode"
    echo ""
    echo "Current status:"
    ps aux | grep -E "demo-mode|node server" | grep -v grep || echo "  No backend running"
fi

