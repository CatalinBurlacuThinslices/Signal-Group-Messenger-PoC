# Signal Integration Troubleshooting Guide

Common issues and solutions when implementing Signal messaging.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Registration Problems](#registration-problems)
3. [Message Sending Failures](#message-sending-failures)
4. [Connection Issues](#connection-issues)
5. [Docker Problems](#docker-problems)
6. [Rate Limiting](#rate-limiting)
7. [Authentication Errors](#authentication-errors)
8. [Message Receiving Issues](#message-receiving-issues)
9. [Group Management](#group-management)
10. [Performance Issues](#performance-issues)

---

## Installation Issues

### Problem: Docker Container Won't Start

**Symptoms:**
```bash
docker-compose up -d
# Container immediately stops
```

**Solution 1: Check Logs**
```bash
docker logs signal-api
```

**Solution 2: Verify Volume Permissions**
```bash
# Ensure config directory is writable
chmod 777 ./signal-cli-config

# Restart container
docker-compose restart
```

**Solution 3: Check Port Availability**
```bash
# Check if port 8080 is already in use
lsof -i :8080

# Kill process or change port in docker-compose.yml
```

### Problem: signal-cli Command Not Found

**Symptoms:**
```bash
signal-cli --version
# command not found
```

**Solution:**
```bash
# Add to PATH
export PATH=$PATH:/opt/signal-cli/bin

# Or use absolute path
/opt/signal-cli/bin/signal-cli --version

# Permanently add to PATH (Linux/macOS)
echo 'export PATH=$PATH:/opt/signal-cli/bin' >> ~/.bashrc
source ~/.bashrc
```

---

## Registration Problems

### Problem: Phone Number Already Registered

**Symptoms:**
```json
{
  "error": "Account already exists",
  "status": 409
}
```

**Solution 1: Use Existing Account**
```bash
# List registered accounts
signal-cli listAccounts

# Use existing account (skip registration)
```

**Solution 2: Re-register (Will Lose Messages)**
```bash
# Backup data first!
cp -r ~/.local/share/signal-cli ~/.local/share/signal-cli.backup

# Remove existing registration
rm -rf ~/.local/share/signal-cli/data/+1234567890

# Register again
curl -X POST http://localhost:8080/v1/register/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'
```

### Problem: SMS Verification Code Not Received

**Symptoms:**
- No SMS received after registration
- Waiting more than 5 minutes

**Solution 1: Request Voice Call**
```bash
curl -X POST http://localhost:8080/v1/register/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": true}'
```

**Solution 2: Check Phone Number Format**
```bash
# Must be E.164 format
# ✅ Correct: +12345678900
# ❌ Wrong: 2345678900
# ❌ Wrong: (234) 567-8900
# ❌ Wrong: +1 234 567 8900
```

**Solution 3: Check for Blocks**
```bash
# Try from a different number
# Signal may have temporarily blocked the number
```

### Problem: Verification Code Invalid

**Symptoms:**
```json
{
  "error": "Invalid verification code",
  "status": 403
}
```

**Solution:**
```bash
# Check code carefully (6 digits, no spaces)
# Code expires after 10-15 minutes
# Request new code if expired

curl -X POST http://localhost:8080/v1/register/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'
```

### Problem: Captcha Required

**Symptoms:**
```json
{
  "error": "Captcha required",
  "status": 402
}
```

**Solution:**
```bash
# 1. Get captcha token from Signal
# Visit: https://signalcaptchas.org/registration/generate.html
# Complete captcha and get token

# 2. Register with captcha
curl -X POST http://localhost:8080/v1/register/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{
    "use_voice": false,
    "captcha": "signal-recaptcha-v2.YOUR_TOKEN_HERE"
  }'
```

---

## Message Sending Failures

### Problem: "Unregistered User" Error

**Symptoms:**
```json
{
  "results": [{
    "recipientNumber": "+9876543210",
    "unregisteredFailure": true,
    "success": false
  }]
}
```

**Solution:**
```bash
# Recipient is not on Signal
# Verify the number is correct
# Ask recipient to install Signal
```

### Problem: "Network Failure"

**Symptoms:**
```json
{
  "results": [{
    "networkFailure": true,
    "success": false
  }]
}
```

**Solution 1: Check Internet Connection**
```bash
# Verify connectivity
ping -c 3 google.com

# Check Docker network
docker network inspect signal-network
```

**Solution 2: Retry with Backoff**
```python
import time

def send_with_retry(signal_api, recipients, message, max_retries=3):
    for attempt in range(max_retries):
        result = signal_api.send_message(recipients, message)
        
        if result.get('results', [{}])[0].get('success'):
            return result
        
        if attempt < max_retries - 1:
            wait_time = 2 ** attempt  # Exponential backoff
            print(f"Retry in {wait_time}s...")
            time.sleep(wait_time)
    
    return {"error": "Failed after retries"}
```

### Problem: Messages Not Delivered

**Symptoms:**
- API returns success
- Recipient doesn't receive message

**Solution 1: Check Recipient's Signal**
```bash
# Ask recipient to:
# 1. Open Signal app
# 2. Check if registered
# 3. Verify phone number
```

**Solution 2: Verify Trust**
```bash
# Trust recipient's safety number
signal-cli -a +1234567890 trust +9876543210 -a
```

**Solution 3: Check Blocked Status**
```bash
# Ensure recipient hasn't blocked you
# No API to check this - ask recipient
```

### Problem: Attachment Too Large

**Symptoms:**
```json
{
  "error": "Attachment too large",
  "status": 413
}
```

**Solution:**
```python
import base64

def resize_if_needed(file_path, max_size_mb=50):
    """Ensure file is under size limit"""
    import os
    
    size_mb = os.path.getsize(file_path) / (1024 * 1024)
    
    if size_mb > max_size_mb:
        # For images, resize
        if file_path.endswith(('.jpg', '.png')):
            from PIL import Image
            img = Image.open(file_path)
            img.thumbnail((1920, 1920))
            img.save(file_path, optimize=True, quality=85)
        else:
            raise ValueError(f"File too large: {size_mb:.1f}MB")
```

---

## Connection Issues

### Problem: Cannot Connect to API

**Symptoms:**
```python
requests.exceptions.ConnectionError: Connection refused
```

**Solution 1: Verify Service is Running**
```bash
# Check Docker container
docker ps | grep signal

# Check logs
docker logs signal-api

# Restart if needed
docker-compose restart
```

**Solution 2: Check URL**
```python
# ✅ Correct
api_url = "http://localhost:8080"

# ❌ Wrong (missing http://)
api_url = "localhost:8080"

# ❌ Wrong (extra slash)
api_url = "http://localhost:8080/"
```

**Solution 3: Check Firewall**
```bash
# Linux: Allow port 8080
sudo ufw allow 8080

# macOS: Check System Preferences > Security
```

### Problem: Timeout Errors

**Symptoms:**
```python
requests.exceptions.Timeout: Request timed out
```

**Solution 1: Increase Timeout**
```python
response = requests.post(
    url,
    json=payload,
    timeout=60  # Increase from default 30s
)
```

**Solution 2: Check Signal Service Status**
```bash
# Signal services may be slow/down
# Check status: https://status.signal.org/

# Implement retry logic
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

session = requests.Session()
retry = Retry(total=3, backoff_factor=1)
adapter = HTTPAdapter(max_retries=retry)
session.mount('http://', adapter)
```

---

## Docker Problems

### Problem: "No Space Left on Device"

**Solution:**
```bash
# Clean Docker
docker system prune -a

# Check disk space
df -h

# Free up space
docker volume prune
```

### Problem: Permission Denied

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
# Or run with sudo (not recommended)
sudo docker-compose up -d
```

### Problem: Container Keeps Restarting

**Solution:**
```bash
# Check logs
docker logs signal-api --tail 50

# Common causes:
# 1. Volume permission issues
sudo chown -R 1000:1000 ./signal-cli-config

# 2. Port already in use
lsof -i :8080
# Change port in docker-compose.yml if needed
```

---

## Rate Limiting

### Problem: "Too Many Requests" (429)

**Symptoms:**
```json
{
  "error": "Rate limit exceeded",
  "status": 429
}
```

**Solution 1: Implement Rate Limiting**
```python
import time
from functools import wraps

def rate_limit(calls_per_minute=30):
    min_interval = 60.0 / calls_per_minute
    last_called = [0.0]
    
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time.time() - last_called[0]
            if elapsed < min_interval:
                time.sleep(min_interval - elapsed)
            result = func(*args, **kwargs)
            last_called[0] = time.time()
            return result
        return wrapper
    return decorator

@rate_limit(calls_per_minute=30)
def send_message(recipients, message):
    # Send message
    pass
```

**Solution 2: Use Message Queue**
```python
from queue import Queue
from threading import Thread

class RateLimitedSender:
    def __init__(self, signal_api, messages_per_minute=30):
        self.api = signal_api
        self.queue = Queue()
        self.delay = 60.0 / messages_per_minute
        self.worker = Thread(target=self._process, daemon=True)
        self.worker.start()
    
    def _process(self):
        while True:
            recipients, message = self.queue.get()
            try:
                self.api.send_message(recipients, message)
                time.sleep(self.delay)
            finally:
                self.queue.task_done()
    
    def queue_message(self, recipients, message):
        self.queue.put((recipients, message))
```

**Solution 3: Use Groups**
```bash
# Instead of sending to multiple individuals
# Create a group and send once

curl -X POST http://localhost:8080/v1/groups/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Alert Recipients",
    "members": ["+1111111111", "+2222222222", "+3333333333"]
  }'
```

---

## Authentication Errors

### Problem: "Account Not Found" (404)

**Symptoms:**
```json
{
  "error": "Account not found",
  "status": 404
}
```

**Solution:**
```bash
# Verify registration
signal-cli -a +1234567890 listAccounts

# If not listed, register:
curl -X POST http://localhost:8080/v1/register/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'
```

### Problem: Invalid Phone Number Format

**Solution:**
```python
import re

def validate_e164(phone):
    """Validate E.164 format"""
    pattern = r'^\+[1-9]\d{1,14}$'
    if not re.match(pattern, phone):
        raise ValueError(f"Invalid phone number: {phone}")
    return phone

# Usage
try:
    phone = validate_e164("+12345678900")
except ValueError as e:
    print(f"Error: {e}")
```

---

## Message Receiving Issues

### Problem: No Messages Received

**Solution 1: Manual Receive**
```bash
curl http://localhost:8080/v1/receive/+1234567890
```

**Solution 2: Check Daemon Mode**
```bash
# Ensure receiving is enabled
docker logs signal-api | grep receive

# Configure auto-receive in docker-compose.yml
environment:
  - AUTO_RECEIVE_SCHEDULE=0 */1 * * *
```

**Solution 3: Use Webhooks**
```yaml
# docker-compose.yml
environment:
  - WEBHOOK_URL=https://your-app.com/webhook
```

---

## Group Management

### Problem: Cannot Create Group

**Solution:**
```bash
# Ensure all members are registered on Signal
# Minimum 1 member required (plus yourself)
# Maximum ~1000 members per group
```

### Problem: Group ID Not Working

**Solution:**
```bash
# List groups to get correct ID
curl http://localhost:8080/v1/groups/+1234567890

# Use exact ID from response (base64 encoded)
```

---

## Performance Issues

### Problem: Slow Message Sending

**Solution 1: Use Async**
```python
import asyncio
import aiohttp

async def send_async(recipients, message):
    async with aiohttp.ClientSession() as session:
        async with session.post(url, json=payload) as response:
            return await response.json()

# Send multiple messages in parallel
await asyncio.gather(*[
    send_async([r], msg) for r, msg in messages
])
```

**Solution 2: Batch Recipients**
```python
# Instead of 10 individual sends
for recipient in recipients:
    send_message([recipient], message)  # ❌ Slow

# Send to all at once
send_message(recipients, message)  # ✅ Fast
```

---

## Debug Mode

### Enable Verbose Logging

**Docker:**
```yaml
# docker-compose.yml
environment:
  - LOG_LEVEL=debug
```

**Python:**
```python
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

**signal-cli:**
```bash
signal-cli -v -a +1234567890 send -m "test" +9876543210
```

---

## Getting Help

### Check Logs First

```bash
# Docker logs
docker logs signal-api --tail 100 --follow

# Application logs
tail -f /var/log/your-app.log
```

### Community Resources

- **GitHub Issues:** https://github.com/bbernhard/signal-cli-rest-api/issues
- **signal-cli Issues:** https://github.com/AsamK/signal-cli/issues
- **Stack Overflow:** Tag `signal-protocol`

### Create Good Bug Reports

Include:
1. **Environment:** OS, Docker version, signal-cli-rest-api version
2. **Steps to reproduce**
3. **Expected vs actual behavior**
4. **Logs** (with sensitive data removed)
5. **Code samples** (minimal reproducible example)

Example:
```markdown
## Environment
- OS: Ubuntu 22.04
- Docker: 20.10.21
- signal-cli-rest-api: latest

## Steps
1. Start Docker container
2. Register number +1234567890
3. Send message to +9876543210
4. Error occurs

## Expected
Message should send successfully

## Actual
Error: "Network failure"

## Logs
```
[logs here]
```

## Code
```python
[minimal code here]
```
```

---

## Quick Reference

### Health Check
```bash
curl http://localhost:8080/v1/health
```

### Test Send
```bash
curl -X POST http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Test",
    "number": "+1234567890",
    "recipients": ["+9876543210"]
  }'
```

### Check Registration
```bash
signal-cli -a +1234567890 listAccounts
```

### Restart Service
```bash
docker-compose restart
```

---

## Still Having Issues?

1. Review [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
2. Check [API_REFERENCE.md](./API_REFERENCE.md)
3. Visit [RESOURCES.md](./RESOURCES.md) for community articles
4. Open an issue on GitHub with details
