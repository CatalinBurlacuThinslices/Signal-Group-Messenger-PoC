# Quick Start Guide - Signal Notifications in 15 Minutes

Get Signal messaging up and running in your application in just 15 minutes.

---

## Prerequisites

- Docker installed
- Phone number for Signal (can receive SMS)
- Terminal/command line access

---

## Step 1: Start Signal API (2 minutes)

Create a directory and start the service:

```bash
# Create directory
mkdir signal-integration && cd signal-integration
mkdir signal-cli-config

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: "3"
services:
  signal-cli-rest-api:
    image: bbernhard/signal-cli-rest-api:latest
    ports:
      - "8080:8080"
    volumes:
      - "./signal-cli-config:/home/.local/share/signal-cli"
    environment:
      - MODE=native
    restart: unless-stopped
EOF

# Start service
docker-compose up -d

# Verify it's running
curl http://localhost:8080/v1/health
# Should return: {"status":"ok"}
```

---

## Step 2: Register Phone Number (3 minutes)

```bash
# Set your phone number (E.164 format: +CountryCode + Number)
export SIGNAL_NUMBER="+12345678900"

# Request verification code
curl -X POST http://localhost:8080/v1/register/${SIGNAL_NUMBER} \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'

# You'll receive an SMS with a 6-digit code
# Verify with the code (replace 123456 with your code)
curl -X POST http://localhost:8080/v1/register/${SIGNAL_NUMBER}/verify/123456
```

---

## Step 3: Send Your First Message (1 minute)

```bash
# Set recipient number
export RECIPIENT="+19876543210"

# Send test message
curl -X POST http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d "{
    \"message\": \"Hello from Signal! 🚀\",
    \"number\": \"${SIGNAL_NUMBER}\",
    \"recipients\": [\"${RECIPIENT}\"]
  }"
```

Check your phone - you should see the message!

---

## Step 4: Python Integration (5 minutes)

Create `signal_notifier.py`:

```python
import requests
import os

class SignalNotifier:
    def __init__(self, api_url, sender_number):
        self.api_url = api_url
        self.sender_number = sender_number
    
    def send(self, recipients, message):
        """Send a Signal message"""
        response = requests.post(
            f"{self.api_url}/v2/send",
            json={
                "message": message,
                "number": self.sender_number,
                "recipients": recipients if isinstance(recipients, list) else [recipients]
            }
        )
        return response.json()

# Usage
signal = SignalNotifier(
    api_url="http://localhost:8080",
    sender_number=os.getenv('SIGNAL_NUMBER', '+12345678900')
)

# Send notification
result = signal.send(
    recipients=["+19876543210"],
    message="Test notification from Python!"
)

print(f"Success: {result.get('results', [{}])[0].get('success')}")
```

Run it:
```bash
pip install requests
python signal_notifier.py
```

---

## Step 5: Safe Wallet Integration (4 minutes)

Create `safe_notifications.py`:

```python
import requests
import os

class SafeSignalNotifier:
    def __init__(self, signal_api_url, signal_number):
        self.api_url = signal_api_url
        self.number = signal_number
    
    def notify_pending_transaction(self, recipients, safe_address, nonce, confirmations):
        """Notify about pending transaction"""
        message = f"""
🔔 Pending Transaction

Safe: {safe_address[:10]}...
Nonce: {nonce}
Confirmations: {confirmations[0]}/{confirmations[1]}

Action: Please review and sign
        """.strip()
        
        return self._send(recipients, message)
    
    def notify_transaction_executed(self, recipients, safe_address, tx_hash):
        """Notify about executed transaction"""
        message = f"""
✅ Transaction Executed

Safe: {safe_address[:10]}...
Tx: {tx_hash[:12]}...

View on Etherscan
        """.strip()
        
        return self._send(recipients, message)
    
    def _send(self, recipients, message):
        response = requests.post(
            f"{self.api_url}/v2/send",
            json={
                "message": message,
                "number": self.number,
                "recipients": recipients
            }
        )
        return response.json()

# Example usage
notifier = SafeSignalNotifier(
    signal_api_url="http://localhost:8080",
    signal_number=os.getenv('SIGNAL_NUMBER', '+12345678900')
)

# Notify about pending transaction
notifier.notify_pending_transaction(
    recipients=["+19876543210"],
    safe_address="0xYourSafeAddress",
    nonce=42,
    confirmations=(1, 3)
)
```

---

## Quick Commands Reference

### Check API Health
```bash
curl http://localhost:8080/v1/health
```

### Send Message
```bash
curl -X POST http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Your message",
    "number": "+12345678900",
    "recipients": ["+19876543210"]
  }'
```

### Receive Messages
```bash
curl http://localhost:8080/v1/receive/+12345678900
```

### Check Docker Logs
```bash
docker logs signal-cli-rest-api --tail 50
```

### Restart Service
```bash
docker-compose restart
```

---

## Troubleshooting

### Problem: Can't connect to API
```bash
# Check if Docker is running
docker ps

# Restart service
docker-compose restart

# Check logs
docker logs signal-cli-rest-api
```

### Problem: Message not received
- Verify recipient has Signal installed
- Check phone number format (must be E.164: +CountryCode + Number)
- Trust the safety number if first time:
  ```bash
  docker exec signal-cli-rest-api signal-cli -a +12345678900 trust +19876543210 -a
  ```

### Problem: "Account not found"
- Re-register your number (see Step 2)

---

## Next Steps

Now that you have Signal working, explore:

1. **[Implementation Guide](./IMPLEMENTATION_GUIDE.md)** - Full integration guide
2. **[API Reference](./API_REFERENCE.md)** - Complete API documentation
3. **[Solutions Comparison](./SOLUTIONS_COMPARISON.md)** - Compare different approaches
4. **[Troubleshooting](./TROUBLESHOOTING.md)** - Solve common issues

---

## Production Checklist

Before deploying to production:

- [ ] Use HTTPS (set up reverse proxy)
- [ ] Implement authentication
- [ ] Set up monitoring
- [ ] Configure backups for signal-cli-config
- [ ] Implement rate limiting
- [ ] Set up error alerting
- [ ] Document phone number and credentials
- [ ] Test failover scenario

---

## Need Help?

- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- Review [RESOURCES.md](./RESOURCES.md)
- Open an issue: https://github.com/bbernhard/signal-cli-rest-api/issues

---

**Congratulations! 🎉**

You now have Signal messaging integrated and ready to send notifications for your Safe wallet transactions!

