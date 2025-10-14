@echo off
echo =========================================
echo Signal PoC - Starting Backend ^& Frontend
echo =========================================
echo.

REM Get script directory
cd /d "%~dp0"

REM Step 1: Check if .env exists
if not exist "backend\.env" (
    echo Creating backend\.env from example...
    copy backend\env.example backend\.env
    echo [OK] Created backend\.env
    echo [!] Please edit backend\.env and set your SIGNAL_NUMBER
    echo.
)

REM Step 2: Install dependencies
if not exist "backend\node_modules" (
    echo Installing backend dependencies...
    cd backend
    call npm install
    cd ..
)

if not exist "frontend\node_modules" (
    echo Installing frontend dependencies...
    cd frontend
    call npm install
    cd ..
)

echo.
echo =========================================
echo Starting servers...
echo =========================================
echo.

REM Start backend in new window
echo Starting backend...
start "Signal PoC Backend" cmd /k "cd /d %~dp0backend && node server.js"

REM Wait a bit
timeout /t 3 /nobreak >nul

REM Start frontend in new window
echo Starting frontend...
start "Signal PoC Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"

echo.
echo =========================================
echo Servers started!
echo =========================================
echo.
echo Backend:  http://localhost:5000
echo Frontend: http://localhost:3000
echo.
echo Check the separate windows for server output
echo.
echo Opening browser in 5 seconds...
timeout /t 5 /nobreak >nul

REM Open browser
start http://localhost:3000

echo.
echo To stop servers, close the command windows
echo.
pause

