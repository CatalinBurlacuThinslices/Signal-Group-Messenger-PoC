@echo off
echo =========================================
echo Signal Group Messenger PoC - Startup
echo =========================================
echo.

REM Check Node.js
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [X] Node.js not found
    echo    Install from: https://nodejs.org/
    pause
    exit /b 1
)
echo [OK] Node.js found

REM Check npm
where npm >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [X] npm not found
    pause
    exit /b 1
)
echo [OK] npm found

echo.

REM Check if .env exists
if not exist "backend\.env" (
    echo [!] Backend .env not found
    echo    Creating from example...
    copy backend\env.example backend\.env
    echo    Please edit backend\.env and set your SIGNAL_NUMBER
    echo.
)

REM Install backend dependencies
if not exist "backend\node_modules" (
    echo Installing backend dependencies...
    cd backend
    call npm install
    cd ..
)

REM Install frontend dependencies
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

REM Start backend
echo Starting backend...
start "Signal PoC Backend" cmd /k "cd backend && npm start"

REM Wait a bit
timeout /t 3 >nul

REM Start frontend
echo Starting frontend...
start "Signal PoC Frontend" cmd /k "cd frontend && npm run dev"

echo.
echo =========================================
echo Servers started!
echo =========================================
echo.
echo Backend:  http://localhost:5000
echo Frontend: http://localhost:3000
echo.
echo Opening browser in 5 seconds...
timeout /t 5 >nul

REM Open browser
start http://localhost:3000

echo.
echo To stop servers, close the command windows
echo or press Ctrl+C in each window
echo.
pause

