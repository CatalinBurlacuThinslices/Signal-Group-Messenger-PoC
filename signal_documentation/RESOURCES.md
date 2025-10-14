# Signal Integration Resources

Curated list of resources, articles, examples, and tools for Signal messaging integration.

---

## Official Documentation

### signal-cli-rest-api

- **GitHub Repository:** https://github.com/bbernhard/signal-cli-rest-api
- **Swagger API Documentation:** https://bbernhard.github.io/signal-cli-rest-api/
- **Docker Hub:** https://hub.docker.com/r/bbernhard/signal-cli-rest-api
- **Getting Started Guide:** https://github.com/bbernhard/signal-cli-rest-api#getting-started
- **Environment Variables:** https://github.com/bbernhard/signal-cli-rest-api#environment-variables

### signal-cli

- **GitHub Repository:** https://github.com/AsamK/signal-cli
- **Wiki Documentation:** https://github.com/AsamK/signal-cli/wiki
- **Usage Guide:** https://github.com/AsamK/signal-cli#usage
- **Man Page:** https://github.com/AsamK/signal-cli/blob/master/man/signal-cli.1.adoc
- **FAQ:** https://github.com/AsamK/signal-cli/wiki/FAQ

### Signal Protocol / libsignal

- **libsignal Repository:** https://github.com/signalapp/libsignal
- **Signal Protocol Docs:** https://signal.org/docs/
- **Specifications:** https://signal.org/docs/specifications/
- **Double Ratchet Algorithm:** https://signal.org/docs/specifications/doubleratchet/
- **X3DH Key Agreement:** https://signal.org/docs/specifications/x3dh/

---

## Community Articles & Tutorials

### signal-cli-rest-api Implementations

#### "Signal REST API - A Practical Guide" by Aanand Awadia
**URL:** https://blog.aawadia.dev/2023/04/24/signal-api/

**Key Takeaways:**
- Real-world implementation experience
- Common pitfalls and solutions
- Rate limiting considerations
- Number registration tips
- Production deployment insights

**Relevant Quote:**
> "Of course, there are some challenges. Rate limiting is one of them. Signal has strict rate limits to prevent spam..."

#### "Running Signal REST API in Azure App Service" by Stefan Stranger
**URL:** https://stefanstranger.github.io/2021/06/01/RunningSignalRESTAPIinAppService/

**Key Takeaways:**
- Azure deployment guide
- Docker container configuration
- Environment setup
- Persistent storage setup
- Security considerations

**Topics Covered:**
- Creating Azure resources
- Configuring App Service
- Setting up persistent storage
- Environment variables
- Testing the deployment

### General Signal Integration

#### "Building a Signal Bot"
Various community implementations show:
- Automated responses
- Command handling
- Message parsing
- Event-driven architecture

#### "Signal for Notifications"
Real-world use cases:
- Server monitoring alerts
- Application notifications
- CI/CD pipeline alerts
- Security alerts

---

## Code Examples

### Python Examples

#### Basic Sender
```python
import requests

def send_signal_message(api_url, sender, recipients, message):
    """Simple Signal message sender"""
    response = requests.post(
        f"{api_url}/v2/send",
        json={
            "message": message,
            "number": sender,
            "recipients": recipients
        }
    )
    return response.json()

# Usage
send_signal_message(
    "http://localhost:8080",
    "+12345678900",
    ["+19876543210"],
    "Hello from Python!"
)
```

#### Message Queue Implementation
```python
from queue import Queue
from threading import Thread
import requests
import time

class SignalQueue:
    def __init__(self, api_url, sender):
        self.api_url = api_url
        self.sender = sender
        self.queue = Queue()
        self.worker = Thread(target=self._process, daemon=True)
        self.worker.start()
    
    def _process(self):
        while True:
            recipients, message = self.queue.get()
            try:
                requests.post(
                    f"{self.api_url}/v2/send",
                    json={
                        "message": message,
                        "number": self.sender,
                        "recipients": recipients
                    }
                )
                time.sleep(1)  # Rate limiting
            finally:
                self.queue.task_done()
    
    def send(self, recipients, message):
        self.queue.put((recipients, message))
```

### Node.js Examples

#### Express Webhook Handler
```javascript
const express = require('express');
const axios = require('axios');

const app = express();
app.use(express.json());

const SIGNAL_API = 'http://localhost:8080';
const SIGNAL_NUMBER = '+12345678900';

// Receive Signal messages
app.post('/webhook', async (req, res) => {
  const { envelope, account } = req.body;
  
  const sender = envelope.source;
  const message = envelope.dataMessage?.message;
  
  console.log(`From ${sender}: ${message}`);
  
  // Auto-reply
  if (message?.toLowerCase() === 'ping') {
    await axios.post(`${SIGNAL_API}/v2/send`, {
      message: 'Pong!',
      number: account,
      recipients: [sender]
    });
  }
  
  res.json({ status: 'received' });
});

app.listen(3000, () => {
  console.log('Webhook server running on port 3000');
});
```

#### Async Batch Sender
```javascript
const axios = require('axios');

async function sendBatchMessages(recipients, message) {
  const SIGNAL_API = 'http://localhost:8080';
  const SIGNAL_NUMBER = '+12345678900';
  
  // Send to all recipients at once
  const response = await axios.post(`${SIGNAL_API}/v2/send`, {
    message,
    number: SIGNAL_NUMBER,
    recipients
  });
  
  return response.data;
}

// Usage
sendBatchMessages(
  ['+1111111111', '+2222222222', '+3333333333'],
  'System update: All services operational'
).then(result => console.log(result));
```

### Shell Script Examples

#### Simple Monitor Script
```bash
#!/bin/bash

SIGNAL_NUMBER="+12345678900"
ALERT_NUMBER="+19876543210"
SERVICE_URL="https://api.yourservice.com/health"

while true; do
  if ! curl -f -s "$SERVICE_URL" > /dev/null; then
    signal-cli -a "$SIGNAL_NUMBER" send \
      -m "⚠️ Service is DOWN!" \
      "$ALERT_NUMBER"
  fi
  sleep 60
done
```

#### Backup Alert Script
```bash
#!/bin/bash

SIGNAL_NUMBER="+12345678900"
ADMIN_NUMBER="+19876543210"

# Run backup
if /usr/local/bin/backup.sh; then
  MESSAGE="✅ Backup completed successfully"
else
  MESSAGE="❌ Backup FAILED - Please investigate"
fi

# Send Signal notification
signal-cli -a "$SIGNAL_NUMBER" send \
  -m "$MESSAGE" \
  "$ADMIN_NUMBER"
```

---

## Docker Configurations

### Basic Setup
```yaml
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
```

### Production Setup with Nginx
```yaml
version: "3"
services:
  signal-api:
    image: bbernhard/signal-cli-rest-api:latest
    container_name: signal-api
    environment:
      - MODE=native
      - AUTO_RECEIVE_SCHEDULE=0 */5 * * *
    volumes:
      - "./signal-cli-config:/home/.local/share/signal-cli"
      - "./backups:/backups"
    networks:
      - internal
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - "./nginx.conf:/etc/nginx/nginx.conf:ro"
      - "./ssl:/etc/ssl/certs:ro"
    depends_on:
      - signal-api
    networks:
      - internal
    restart: always

networks:
  internal:
    driver: bridge
```

### Nginx Configuration
```nginx
server {
    listen 443 ssl;
    server_name signal-api.yourdomain.com;

    ssl_certificate /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/certs/key.pem;

    location / {
        proxy_pass http://signal-api:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Basic auth (optional)
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

---

## Integration Examples

### Safe Wallet Transaction Notifications

```python
import requests
from datetime import datetime

class SafeSignalNotifier:
    def __init__(self, signal_api_url, signal_number):
        self.api_url = signal_api_url
        self.number = signal_number
    
    def notify_transaction_executed(
        self,
        recipients,
        safe_address,
        tx_hash,
        amount,
        token,
        network
    ):
        """Notify when a Safe transaction is executed"""
        message = f"""
✅ Transaction Executed

Safe: {safe_address[:8]}...{safe_address[-6:]}
Network: {network.upper()}
Amount: {amount} {token}
Tx: {tx_hash[:10]}...

Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Explorer: https://etherscan.io/tx/{tx_hash}
        """.strip()
        
        return self._send(recipients, message)
    
    def notify_pending_signatures(
        self,
        recipients,
        safe_address,
        nonce,
        required,
        current,
        safe_url
    ):
        """Notify when signatures are needed"""
        message = f"""
⏳ Signatures Required

Safe: {safe_address[:8]}...{safe_address[-6:]}
Nonce: {nonce}
Status: {current}/{required} signatures

Action: Please review and sign
Link: {safe_url}
        """.strip()
        
        return self._send(recipients, message)
    
    def notify_threshold_reached(
        self,
        recipients,
        safe_address,
        nonce
    ):
        """Notify when threshold is reached"""
        message = f"""
✅ Ready to Execute

Safe: {safe_address[:8]}...{safe_address[-6:]}
Nonce: {nonce}

All required signatures collected.
Transaction can now be executed.
        """.strip()
        
        return self._send(recipients, message)
    
    def _send(self, recipients, message):
        """Internal send method"""
        response = requests.post(
            f"{self.api_url}/v2/send",
            json={
                "message": message,
                "number": self.number,
                "recipients": recipients
            }
        )
        return response.json()


# Usage
notifier = SafeSignalNotifier(
    "http://localhost:8080",
    "+12345678900"
)

# Notify on transaction
notifier.notify_transaction_executed(
    recipients=["+19876543210", "+11234567890"],
    safe_address="0xYourSafeAddress",
    tx_hash="0xTransactionHash",
    amount="1.5",
    token="ETH",
    network="eth"
)
```

### Flask Webhook Receiver

```python
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

SIGNAL_API = "http://localhost:8080"
SIGNAL_NUMBER = "+12345678900"

@app.route('/signal-webhook', methods=['POST'])
def signal_webhook():
    """Handle incoming Signal messages"""
    data = request.json
    envelope = data.get('envelope', {})
    
    sender = envelope.get('source')
    message = envelope.get('dataMessage', {}).get('message', '')
    
    print(f"Received from {sender}: {message}")
    
    # Command handling
    if message.lower().startswith('/status'):
        reply = "✅ All systems operational"
        send_reply(sender, reply)
    
    elif message.lower().startswith('/help'):
        reply = """
Available commands:
/status - Check system status
/pending - Check pending transactions
/help - Show this help
        """.strip()
        send_reply(sender, reply)
    
    return jsonify({'status': 'ok'}), 200

def send_reply(recipient, message):
    """Send a reply message"""
    requests.post(
        f"{SIGNAL_API}/v2/send",
        json={
            "message": message,
            "number": SIGNAL_NUMBER,
            "recipients": [recipient]
        }
    )

if __name__ == '__main__':
    app.run(port=5000)
```

---

## Tools & Utilities

### Testing Tools

#### Postman Collection
Import this to Postman for easy API testing:

```json
{
  "info": {
    "name": "Signal CLI REST API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "{{baseUrl}}/v1/health"
      }
    },
    {
      "name": "Send Message",
      "request": {
        "method": "POST",
        "url": "{{baseUrl}}/v2/send",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"message\": \"Test message\",\n  \"number\": \"{{senderNumber}}\",\n  \"recipients\": [\"{{recipientNumber}}\"]\n}"
        }
      }
    },
    {
      "name": "Receive Messages",
      "request": {
        "method": "GET",
        "url": "{{baseUrl}}/v1/receive/{{senderNumber}}"
      }
    }
  ],
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:8080"
    },
    {
      "key": "senderNumber",
      "value": "+12345678900"
    },
    {
      "key": "recipientNumber",
      "value": "+19876543210"
    }
  ]
}
```

### Monitoring Script

```python
import requests
import time
from datetime import datetime

def monitor_signal_api(api_url, check_interval=60):
    """Monitor Signal API health"""
    while True:
        try:
            response = requests.get(
                f"{api_url}/v1/health",
                timeout=5
            )
            
            if response.status_code == 200:
                print(f"[{datetime.now()}] ✅ API healthy")
            else:
                print(f"[{datetime.now()}] ⚠️ API unhealthy: {response.status_code}")
                # Send alert here
                
        except Exception as e:
            print(f"[{datetime.now()}] ❌ API unreachable: {e}")
            # Send alert here
        
        time.sleep(check_interval)

if __name__ == "__main__":
    monitor_signal_api("http://localhost:8080")
```

---

## Best Practices

### Rate Limiting
- Max ~30-60 messages per minute
- Use exponential backoff for retries
- Batch recipients when possible
- Use groups for multiple recipients

### Error Handling
- Always check response status
- Implement retry logic
- Log all errors
- Monitor success rates

### Security
- Use HTTPS in production
- Implement authentication
- Restrict network access
- Rotate phone numbers periodically

### Performance
- Use async/parallel requests
- Implement message queues
- Cache group IDs
- Monitor latency

---

## Community Projects

### Signal Bots
- **signal-bot-framework:** Bot building framework
- **signal-cli-rest-bot:** Bot using REST API
- **signal-automation:** Automation tools

### Integrations
- **Grafana Signal Alerts:** Monitoring integration
- **GitHub Actions Signal:** CI/CD notifications
- **Prometheus Alertmanager:** Metric alerts

---

## Related Technologies

### Alternatives to Signal
- **Telegram Bot API:** Easier API, less privacy
- **WhatsApp Business API:** Paid, business-focused
- **Discord Webhooks:** Gaming/community focused
- **Slack API:** Team collaboration

### Complementary Tools
- **Redis:** Message queue/caching
- **RabbitMQ:** Message broker
- **Prometheus:** Monitoring
- **Grafana:** Dashboards

---

## Learning Resources

### Cryptography
- "The Signal Protocol" - Signal Blog
- "Applied Cryptography" - Bruce Schneier
- "Cryptography Engineering" - Ferguson, Schneier, Kohno

### APIs & Integration
- RESTful API Design
- Microservices Patterns
- Event-Driven Architecture

### Python
- Requests library documentation
- AsyncIO tutorial
- Flask/FastAPI guides

---

## Video Tutorials

### Setup Guides
Search YouTube for:
- "signal-cli-rest-api setup"
- "signal-cli tutorial"
- "Signal bot Python"

### Docker Tutorials
- "Docker Compose tutorial"
- "Container networking"
- "Docker volumes explained"

---

## Support Channels

### Official
- **GitHub Issues:** Primary support channel
- **GitHub Discussions:** Community Q&A
- **Signal Community Forum:** General Signal questions

### Unofficial
- **Stack Overflow:** Tag `signal-protocol`
- **Reddit:** r/signal, r/selfhosted
- **Discord:** Various DevOps communities

---

## Contributing

### signal-cli-rest-api
- Report bugs: https://github.com/bbernhard/signal-cli-rest-api/issues
- Submit PRs: https://github.com/bbernhard/signal-cli-rest-api/pulls
- Documentation: Help improve docs

### This Documentation
- Found an error? Let us know
- Have a better example? Share it
- Additional resources? Add them

---

## Quick Links Summary

**Essential Links:**
- [signal-cli-rest-api GitHub](https://github.com/bbernhard/signal-cli-rest-api)
- [Swagger Docs](https://bbernhard.github.io/signal-cli-rest-api/)
- [signal-cli GitHub](https://github.com/AsamK/signal-cli)

**Community Articles:**
- [Aanand Awadia's Guide](https://blog.aawadia.dev/2023/04/24/signal-api/)
- [Azure Deployment](https://stefanstranger.github.io/2021/06/01/RunningSignalRESTAPIinAppService/)

**Internal Docs:**
- [Solutions Comparison](./SOLUTIONS_COMPARISON.md)
- [Implementation Guide](./IMPLEMENTATION_GUIDE.md)
- [API Reference](./API_REFERENCE.md)
- [Troubleshooting](./TROUBLESHOOTING.md)

---

## Stay Updated

- ⭐ Star repositories on GitHub
- 👀 Watch for releases
- 📧 Subscribe to release notifications
- 🐦 Follow maintainers on social media

---

*Last Updated: 2025-10-10*
*Contributions welcome!*

