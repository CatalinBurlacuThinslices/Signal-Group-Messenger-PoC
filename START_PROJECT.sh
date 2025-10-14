#!/bin/bash

echo "========================================="
echo "🚀 Starting Signal PoC Project"
echo "========================================="
echo ""

# Navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Step 1: Start Signal API (Docker)
echo "Step 1: Starting Signal API..."
cd signal-api
docker-compose up -d
cd ..
sleep 3
echo -e "${GREEN}✅ Signal API started${NC}"
echo ""

# Step 2: Start Backend
echo "Step 2: Starting Backend..."
cd signal-poc/backend

# Kill any existing backend
pkill -f "node server.js" 2>/dev/null
pkill -f "demo-mode.js" 2>/dev/null
sleep 1

# Start backend (real mode with your number)
PORT=5001 SIGNAL_NUMBER="+40751770274" SIGNAL_API_URL="http://localhost:8080" node server.js &
BACKEND_PID=$!
cd ../..
sleep 2
echo -e "${GREEN}✅ Backend started (PID: $BACKEND_PID)${NC}"
echo ""

# Step 3: Start Frontend
echo "Step 3: Starting Frontend..."
cd signal-poc/frontend

# Kill any existing frontend
pkill -f "vite" 2>/dev/null
sleep 1

# Start frontend
npm run dev &
FRONTEND_PID=$!
cd ../..
sleep 3
echo -e "${GREEN}✅ Frontend started (PID: $FRONTEND_PID)${NC}"
echo ""

# Summary
echo "========================================="
echo -e "${GREEN}✅ All Services Running!${NC}"
echo "========================================="
echo ""
echo "📱 URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:5001"
echo "   Signal:   http://localhost:8080"
echo ""
echo "📊 Process IDs:"
echo "   Backend:  $BACKEND_PID"
echo "   Frontend: $FRONTEND_PID"
echo ""
echo "🌐 Open your browser to: http://localhost:3000"
echo ""
echo -e "${YELLOW}Note: Your Signal account is linked as a device.${NC}"
echo -e "${YELLOW}      Messages will appear as 'notes to self' in groups.${NC}"
echo -e "${YELLOW}      This is a signal-cli limitation.${NC}"
echo ""
echo "To stop all servers:"
echo "  ./STOP_PROJECT.sh"
echo ""
echo "Or manually:"
echo "  pkill -f 'node server.js'"
echo "  pkill -f 'vite'"
echo "  cd signal-api && docker-compose down"
echo ""

# Open browser (optional)
sleep 2
if command -v open > /dev/null; then
    open http://localhost:3000
fi

echo "✅ Project is running!"

