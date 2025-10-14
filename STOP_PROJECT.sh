#!/bin/bash

echo "========================================="
echo "🛑 Stopping Signal PoC Project"
echo "========================================="
echo ""

# Navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Stop Node processes
echo "Stopping Node.js processes..."
pkill -f "node server.js"
pkill -f "demo-mode.js"
pkill -f "vite"
sleep 2
echo "✅ Node processes stopped"
echo ""

# Stop Docker
echo "Stopping Signal API (Docker)..."
cd signal-api
docker-compose down
cd ..
echo "✅ Docker stopped"
echo ""

echo "========================================="
echo "✅ All services stopped!"
echo "========================================="
echo ""
echo "To restart:"
echo "  ./START_PROJECT.sh"
echo ""

