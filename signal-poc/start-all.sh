#!/bin/bash

echo "========================================="
echo "Signal PoC - Starting Backend & Frontend"
echo "========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}Stopping servers...${NC}"
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    echo -e "${GREEN}Servers stopped${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Step 1: Kill any existing processes
echo "Step 1: Cleaning up existing processes..."
pkill -f "node server.js" 2>/dev/null
pkill -f "node.*vite" 2>/dev/null
sleep 2
echo -e "${GREEN}✅ Cleanup done${NC}"
echo ""

# Step 2: Check if backend .env exists
echo "Step 2: Checking configuration..."
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}Creating backend/.env from example...${NC}"
    cp backend/env.example backend/.env
    echo -e "${GREEN}✅ Created backend/.env${NC}"
    echo -e "${YELLOW}⚠️  Please edit backend/.env and set your SIGNAL_NUMBER${NC}"
else
    echo -e "${GREEN}✅ backend/.env exists${NC}"
fi
echo ""

# Step 3: Install dependencies if needed
echo "Step 3: Checking dependencies..."
if [ ! -d "backend/node_modules" ]; then
    echo "Installing backend dependencies..."
    cd backend && npm install --silent && cd ..
fi

if [ ! -d "frontend/node_modules" ]; then
    echo "Installing frontend dependencies..."
    cd frontend && npm install --silent && cd ..
fi
echo -e "${GREEN}✅ Dependencies ready${NC}"
echo ""

# Step 4: Start backend
echo "Step 4: Starting backend server..."
cd backend
node server.js > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
sleep 2

# Check if backend started
if ps -p $BACKEND_PID > /dev/null; then
    echo -e "${GREEN}✅ Backend started (PID: $BACKEND_PID)${NC}"
    
    # Test backend
    if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend responding on port 5000${NC}"
    else
        echo -e "${YELLOW}⚠️  Backend started but not responding yet${NC}"
    fi
else
    echo -e "${RED}❌ Backend failed to start${NC}"
    echo "Check backend.log for details"
    exit 1
fi
echo ""

# Step 5: Start frontend
echo "Step 5: Starting frontend server..."
cd frontend
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
sleep 3

# Check if frontend started
if ps -p $FRONTEND_PID > /dev/null; then
    echo -e "${GREEN}✅ Frontend started (PID: $FRONTEND_PID)${NC}"
    
    # Extract frontend URL from log
    FRONTEND_URL=$(grep -o "http://localhost:[0-9]*" frontend.log | head -1)
    if [ -n "$FRONTEND_URL" ]; then
        echo -e "${GREEN}✅ Frontend available at: ${BLUE}$FRONTEND_URL${NC}"
    fi
else
    echo -e "${RED}❌ Frontend failed to start${NC}"
    echo "Check frontend.log for details"
    kill $BACKEND_PID
    exit 1
fi
echo ""

# Step 6: Summary
echo "========================================="
echo -e "${GREEN}✅ All servers running!${NC}"
echo "========================================="
echo ""
echo -e "${BLUE}Backend:${NC}  http://localhost:5000"
if [ -n "$FRONTEND_URL" ]; then
    echo -e "${BLUE}Frontend:${NC} $FRONTEND_URL"
else
    echo -e "${BLUE}Frontend:${NC} http://localhost:3000"
fi
echo ""
echo -e "${YELLOW}Signal API Status:${NC}"
if curl -s http://localhost:8080/v1/health > /dev/null 2>&1; then
    echo -e "  ${GREEN}✅ Signal API running${NC}"
else
    echo -e "  ${RED}❌ Signal API not running${NC}"
    echo "     Start it with: cd ~/signal-api && docker-compose up -d"
fi
echo ""
echo "Logs:"
echo "  Backend:  tail -f backend.log"
echo "  Frontend: tail -f frontend.log"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all servers${NC}"
echo ""

# Open browser after a delay
sleep 2
if [ -n "$FRONTEND_URL" ]; then
    OPEN_URL="$FRONTEND_URL"
else
    OPEN_URL="http://localhost:3000"
fi

if command -v open > /dev/null; then
    open "$OPEN_URL" 2>/dev/null
elif command -v xdg-open > /dev/null; then
    xdg-open "$OPEN_URL" 2>/dev/null
fi

# Keep script running
wait

