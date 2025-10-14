# Troubleshooting Guide - Signal Group Messenger PoC

Common issues and their solutions.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Backend Problems](#backend-problems)
3. [Frontend Problems](#frontend-problems)
4. [Signal API Issues](#signal-api-issues)
5. [Message Sending Failures](#message-sending-failures)
6. [Common Error Messages](#common-error-messages)

---

## Installation Issues

### Problem: npm install fails

**Symptoms:**
```
npm ERR! code ENOENT
```

**Solution:**
```bash
# Make sure you're in the right directory
cd signal-poc/backend  # or frontend

# Clear npm cache
npm cache clean --force

# Try again
npm install
```

### Problem: Node version too old

**Symptoms:**
```
error: Unsupported engine
```

**Solution:**
```bash
# Check Node version
node --version

# Need v16 or higher
# Install/update Node.js from nodejs.org

# Or use nvm
nvm install 18
nvm use 18
```

---

## Backend Problems

### Problem: Backend won't start

**Symptoms:**
```
Error: Cannot find module 'express'
```

**Solution:**
```bash
cd signal-poc/backend
npm install
npm start
```

### Problem: Port already in use

**Symptoms:**
```
Error: listen EADDRINUSE: address already in use :::5000
```

**Solution:**
```bash
# Find and kill process using port 5000
lsof -i :5000
kill -9 <PID>

# Or change port in .env
echo "PORT=5001" >> .env
npm start
```

### Problem: SIGNAL_NUMBER not configured

**Symptoms:**
```json
{
  "error": "SIGNAL_NUMBER not configured in .env file"
}
```

**Solution:**
```bash
cd signal-poc/backend

# Create .env from example
cp env.example .env

# Edit .env
nano .env

# Add your Signal number:
# SIGNAL_NUMBER=+12345678900

# Restart backend
npm start
```

### Problem: Cannot connect to Signal API

**Symptoms:**
```
⚠️  Warning: Cannot connect to Signal API
```

**Solution:**
```bash
# Check if Signal API is running
docker ps | grep signal

# If not running, start it
cd signal-api  # or wherever you have it
docker-compose up -d

# Verify
curl http://localhost:8080/v1/health

# Should return: {"status":"ok"}
```

---

## Frontend Problems

### Problem: Frontend won't start

**Symptoms:**
```
npm ERR! missing script: dev
```

**Solution:**
```bash
# Make sure you're in frontend directory
cd signal-poc/frontend

# Install dependencies
npm install

# Start
npm run dev
```

### Problem: Port 3000 already in use

**Symptoms:**
```
Port 3000 is in use
```

**Solution:**
```bash
# Kill process on port 3000
lsof -i :3000
kill -9 <PID>

# Or Vite will suggest an alternative port
# Just press 'y' to use it
```

### Problem: Blank white page

**Symptoms:**
- Browser shows white page
- No errors visible

**Solution:**
```bash
# Check browser console (F12)
# Look for errors

# Common fix: Clear browser cache
# Chrome: Ctrl+Shift+R (or Cmd+Shift+R on Mac)

# Or try incognito mode

# Restart frontend
cd signal-poc/frontend
npm run dev
```

### Problem: Cannot connect to backend

**Symptoms:**
```
Network Error
```

**Solution:**
```bash
# Make sure backend is running
cd signal-poc/backend
npm start

# Check backend health
curl http://localhost:5000/api/health

# Check frontend proxy configuration
cat frontend/vite.config.js
# Should have proxy setup for /api
```

---

## Signal API Issues

### Problem: Docker not running

**Symptoms:**
```
Cannot connect to the Docker daemon
```

**Solution:**
```bash
# Start Docker Desktop (macOS/Windows)
# Or start Docker service (Linux):
sudo systemctl start docker

# Verify
docker ps
```

### Problem: signal-cli-rest-api container not found

**Symptoms:**
```
Error: No such container: signal-cli-rest-api
```

**Solution:**
```bash
# Start Signal API
cd signal-api  # your signal-api directory
docker-compose up -d

# Verify it's running
docker ps
curl http://localhost:8080/v1/health
```

### Problem: Phone number not registered

**Symptoms:**
```json
{
  "error": "Account not found",
  "status": 404
}
```

**Solution:**
```bash
# Register your number
curl -X POST http://localhost:8080/v1/register/+12345678900 \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'

# You'll receive SMS with code
# Verify (replace 123456 with your code)
curl -X POST http://localhost:8080/v1/register/+12345678900/verify/123456
```

---

## Message Sending Failures

### Problem: No groups found

**Symptoms:**
UI shows "No groups found"

**Solution:**
1. Open Signal mobile app
2. Create a group
3. Add at least one contact
4. Refresh groups in the web UI

### Problem: Group selected but can't send

**Symptoms:**
Send button is disabled

**Solution:**
- Make sure you've typed a message
- Message cannot be empty or just spaces
- Check if group is still selected (should be purple)

### Problem: Message not appearing in group

**Symptoms:**
- "Message sent successfully" shown
- But message doesn't appear in Signal app

**Solution:**
```bash
# Trust the safety number
docker exec -it signal-cli-rest-api \
  signal-cli -a +12345678900 trust <group-member-number> -a

# Or check if you're actually a member of the group
# Open Signal app and verify
```

### Problem: "Unregistered failure"

**Symptoms:**
```json
{
  "unregisteredFailure": true
}
```

**Solution:**
- Some group members might not be on Signal
- Your account might need re-registration
- Check your Signal app is working

---

## Common Error Messages

### Error: "Failed to fetch groups"

**Possible Causes:**
1. Signal API not running
2. Phone number not registered
3. Network issues

**Solutions:**
```bash
# 1. Check Signal API
curl http://localhost:8080/v1/health

# 2. Check backend
curl http://localhost:5000/api/health

# 3. Verify phone number
curl http://localhost:8080/v1/groups/+12345678900
```

### Error: "Invalid request"

**Possible Causes:**
1. Malformed group ID
2. Empty message
3. Missing required fields

**Solutions:**
- Check group ID is correct (base64 encoded string)
- Ensure message is not empty
- Verify JSON format

### Error: "Network failure"

**Possible Causes:**
1. No internet connection
2. Signal servers down
3. Docker network issues

**Solutions:**
```bash
# Test internet
ping google.com

# Check Signal API
docker logs signal-cli-rest-api --tail 50

# Restart Signal API
docker restart signal-cli-rest-api
```

### Error: "Cannot connect to Signal API"

**Full Error:**
```
Failed to fetch groups. Ensure Signal API is running and number is registered
```

**Solutions:**
```bash
# 1. Is Docker running?
docker ps

# 2. Is Signal API container running?
docker ps | grep signal

# If not, start it:
cd signal-api
docker-compose up -d

# 3. Check logs
docker logs signal-cli-rest-api

# 4. Verify URL in backend .env
cat backend/.env
# Should have: SIGNAL_API_URL=http://localhost:8080
```

---

## Debugging Tips

### Enable Verbose Logging

**Backend:**
```javascript
// In server.js, add:
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`, req.body);
  next();
});
```

**Frontend:**
Open browser console (F12) and watch for:
- Network requests (Network tab)
- Console errors (Console tab)
- React errors

### Check All Services

```bash
# Quick health check script
echo "=== Docker ==="
docker ps | grep signal

echo "=== Signal API ==="
curl -s http://localhost:8080/v1/health | jq

echo "=== Backend ==="
curl -s http://localhost:5000/api/health | jq

echo "=== Frontend ==="
curl -s http://localhost:3000
```

### View All Logs

```bash
# Backend logs
cd signal-poc/backend
npm start 2>&1 | tee backend.log

# Signal API logs
docker logs -f signal-cli-rest-api

# Frontend logs (in browser console)
# Press F12 → Console tab
```

---

## Quick Fixes

### Complete Restart

```bash
# Stop everything
docker-compose down  # in signal-api directory
pkill -f "node server.js"
pkill -f vite

# Start fresh
docker-compose up -d  # in signal-api directory
cd signal-poc/backend && npm start &
cd signal-poc/frontend && npm run dev &
```

### Clear Everything and Start Over

```bash
# Backend
cd signal-poc/backend
rm -rf node_modules package-lock.json
npm install

# Frontend
cd signal-poc/frontend
rm -rf node_modules package-lock.json
npm install

# Clear browser cache
# Chrome: Settings → Clear browsing data
```

---

## Still Having Issues?

### Collect Debug Information

```bash
# System info
node --version
npm --version
docker --version

# Service status
docker ps
lsof -i :5000
lsof -i :3000
lsof -i :8080

# Test endpoints
curl http://localhost:8080/v1/health
curl http://localhost:5000/api/health
curl http://localhost:5000/api/config
```

### Check Logs

1. **Backend logs:** Check terminal where `npm start` is running
2. **Frontend logs:** Browser console (F12)
3. **Signal API logs:** `docker logs signal-cli-rest-api`

### Common Log Patterns

**Looking for errors:**
```bash
# Backend
grep -i error backend.log

# Signal API
docker logs signal-cli-rest-api 2>&1 | grep -i error
```

---

## Environment Variables Checklist

### Backend (.env)

```env
✅ PORT=5000
✅ SIGNAL_API_URL=http://localhost:8080
✅ SIGNAL_NUMBER=+12345678900  # Your actual number
```

### Verify Configuration

```bash
cd signal-poc/backend
cat .env

# Should see all three variables
# SIGNAL_NUMBER should be YOUR number in E.164 format
```

---

## Network Diagram

```
Browser (localhost:3000)
    ↓ HTTP
Frontend (Vite Dev Server)
    ↓ Proxy /api → localhost:5000
Backend (Express on port 5000)
    ↓ HTTP
Signal API (Docker on port 8080)
    ↓ Signal Protocol
Signal Servers
```

If any link is broken, things won't work!

---

## Getting Help

If you're still stuck:

1. Check backend terminal for errors
2. Check browser console (F12) for errors
3. Check Docker logs: `docker logs signal-cli-rest-api`
4. Review [USAGE.md](./USAGE.md) for correct usage
5. Verify all prerequisites from [README.md](./README.md)

---

## Known Limitations

This is a PoC with limitations:

- ❌ No authentication (anyone with access can send)
- ❌ No rate limiting (can hit Signal limits)
- ❌ No message history (stateless)
- ❌ No typing indicators
- ❌ No read receipts
- ❌ No attachments support (yet)

For production, you'd need to add these features!

---

**Happy Debugging! 🔧**

