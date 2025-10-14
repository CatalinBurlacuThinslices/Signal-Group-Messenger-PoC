#!/bin/bash

echo "========================================="
echo "Signal Group Messenger PoC - Startup"
echo "========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is in use
port_in_use() {
    lsof -i :"$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Node.js
if ! command_exists node; then
    echo -e "${RED}❌ Node.js not found${NC}"
    echo "   Install from: https://nodejs.org/"
    exit 1
fi
echo -e "${GREEN}✅ Node.js found:${NC} $(node --version)"

# Check npm
if ! command_exists npm; then
    echo -e "${RED}❌ npm not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm found:${NC} $(npm --version)"

# Check Docker
if ! command_exists docker; then
    echo -e "${YELLOW}⚠️  Docker not found${NC}"
    echo "   Install from: https://www.docker.com/"
    echo "   Signal API won't be available"
else
    echo -e "${GREEN}✅ Docker found${NC}"
fi

echo ""

# Check Signal API
echo "Checking Signal API..."
if curl -s http://localhost:8080/v1/health >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Signal API is running${NC}"
else
    echo -e "${YELLOW}⚠️  Signal API not running${NC}"
    echo "   Start it with:"
    echo "   cd signal-api && docker-compose up -d"
fi

echo ""

# Check if backend .env exists
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}⚠️  Backend .env not found${NC}"
    echo "   Creating from example..."
    cp backend/env.example backend/.env
    echo -e "${YELLOW}   Please edit backend/.env and set your SIGNAL_NUMBER${NC}"
    echo ""
fi

# Install dependencies
echo "Installing dependencies..."
echo ""

# Backend
if [ ! -d "backend/node_modules" ]; then
    echo "Installing backend dependencies..."
    cd backend
    npm install
    cd ..
    echo -e "${GREEN}✅ Backend dependencies installed${NC}"
else
    echo -e "${GREEN}✅ Backend dependencies already installed${NC}"
fi

# Frontend
if [ ! -d "frontend/node_modules" ]; then
    echo "Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
    echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
else
    echo -e "${GREEN}✅ Frontend dependencies already installed${NC}"
fi

echo ""

# Check ports
echo "Checking ports..."
if port_in_use 5000; then
    echo -e "${RED}❌ Port 5000 already in use${NC}"
    echo "   Kill the process or change PORT in backend/.env"
    exit 1
fi
echo -e "${GREEN}✅ Port 5000 available${NC}"

if port_in_use 3000; then
    echo -e "${YELLOW}⚠️  Port 3000 in use (Vite will suggest alternative)${NC}"
else
    echo -e "${GREEN}✅ Port 3000 available${NC}"
fi

echo ""
echo "========================================="
echo "Starting servers..."
echo "========================================="
echo ""

# Start backend
echo "Starting backend on port 5000..."
cd backend
npm start &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 2

# Start frontend
echo "Starting frontend on port 3000..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "========================================="
echo -e "${GREEN}✅ Servers started!${NC}"
echo "========================================="
echo ""
echo "Backend:  http://localhost:5000"
echo "Frontend: http://localhost:3000"
echo ""
echo "Backend PID:  $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "To stop servers:"
echo "  kill $BACKEND_PID $FRONTEND_PID"
echo ""
echo "Or press Ctrl+C and run:"
echo "  pkill -f 'node server.js'"
echo "  pkill -f vite"
echo ""
echo -e "${YELLOW}Opening browser in 5 seconds...${NC}"
sleep 5

# Open browser
if command_exists open; then
    open http://localhost:3000
elif command_exists xdg-open; then
    xdg-open http://localhost:3000
else
    echo "Please open http://localhost:3000 in your browser"
fi

# Wait for user
echo ""
echo "Press Ctrl+C to stop servers"
wait

