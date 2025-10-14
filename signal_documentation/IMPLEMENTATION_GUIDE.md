# Signal Messaging Implementation Guide

Step-by-step guide to implementing Signal messaging in your application for Safe wallet notifications.

---

## Overview

This guide will walk you through:
1. Setting up signal-cli-rest-api
2. Integrating with your Python/Node.js application
3. Implementing notification workflows
4. Testing and deployment

**Estimated Time:** 2-3 hours

---

## Prerequisites

- Docker installed
- Phone number for Signal registration (dedicated for notifications)
- Basic knowledge of REST APIs
- Python 3.7+ or Node.js 14+

---

## Phase 1: Environment Setup

### Step 1: Install Docker

**macOS:**
```bash
brew install --cask docker
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
```

**Windows:**
Download from https://www.docker.com/products/docker-desktop

### Step 2: Create Project Structure

```bash
cd /Users/thinslicesacademy8/projects/safe-poc
mkdir signal-integration
cd signal-integration
mkdir -p signal-cli-config
```

### Step 3: Create Docker Compose File

Create `docker-compose.yml`:

```yaml
version: "3"
services:
  signal-cli-rest-api:
    image: bbernhard/signal-cli-rest-api:latest
    container_name: signal-api
    environment:
      - MODE=native
      - AUTO_RECEIVE_SCHEDULE=0 */1 * * *
    ports:
      - "8080:8080"
    volumes:
      - "./signal-cli-config:/home/.local/share/signal-cli"
    restart: unless-stopped
    networks:
      - signal-network

networks:
  signal-network:
    driver: bridge
```

### Step 4: Start Signal API

```bash
docker-compose up -d
```

Verify it's running:
```bash
docker ps
curl http://localhost:8080/v1/health
```

Expected output: `{"status":"ok"}`

---

## Phase 2: Phone Number Registration

### Step 1: Prepare Your Phone Number

**Important:**
- Use a dedicated phone number for notifications
- Must be able to receive SMS
- Should not be used for personal Signal account
- Format: E.164 (e.g., +12345678900)

### Step 2: Register the Number

```bash
# Replace with your actual phone number
export SIGNAL_NUMBER="+12345678900"

curl -X POST \
  http://localhost:8080/v1/register/${SIGNAL_NUMBER} \
  -H 'Content-Type: application/json' \
  -d '{
    "use_voice": false
  }'
```

**Expected response:**
```json
{"status":"verification_required"}
```

### Step 3: Verify with SMS Code

You'll receive an SMS with a 6-digit code. Verify:

```bash
# Replace 123456 with your actual code
export VERIFICATION_CODE="123456"

curl -X POST \
  http://localhost:8080/v1/register/${SIGNAL_NUMBER}/verify/${VERIFICATION_CODE}
```

**Expected response:**
```json
{"status":"verified"}
```

### Step 4: Test Message Sending

Send a test message to your personal phone:

```bash
export RECIPIENT_NUMBER="+19876543210"  # Your personal number

curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d "{
    \"message\": \"Test message from Signal API setup\",
    \"number\": \"${SIGNAL_NUMBER}\",
    \"recipients\": [\"${RECIPIENT_NUMBER}\"]
  }"
```

Check your phone for the message!

---

## Phase 3: Python Integration

### Step 1: Create Python Module

Create `signal_notifier.py`:

```python
import requests
import logging
from typing import List, Dict, Optional
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class SignalNotifier:
    """Signal notification client for Safe wallet alerts"""
    
    def __init__(self, api_url: str, sender_number: str):
        """
        Initialize Signal notifier
        
        Args:
            api_url: Base URL of signal-cli-rest-api (e.g., http://localhost:8080)
            sender_number: Your Signal phone number in E.164 format
        """
        self.api_url = api_url.rstrip('/')
        self.sender_number = sender_number
        self.session = requests.Session()
        
    def send_notification(
        self, 
        recipients: List[str], 
        message: str,
        attachment_paths: Optional[List[str]] = None
    ) -> Dict:
        """
        Send a Signal notification
        
        Args:
            recipients: List of recipient phone numbers
            message: Message text
            attachment_paths: Optional list of file paths to attach
            
        Returns:
            Dict with send results
        """
        try:
            url = f"{self.api_url}/v2/send"
            
            payload = {
                "message": message,
                "number": self.sender_number,
                "recipients": recipients
            }
            
            # Handle attachments if provided
            if attachment_paths:
                base64_attachments = []
                for path in attachment_paths:
                    base64_attachments.append(self._encode_file(path))
                payload["base64_attachments"] = base64_attachments
            
            response = self.session.post(url, json=payload, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            logger.info(f"Message sent successfully to {len(recipients)} recipient(s)")
            return result
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to send notification: {e}")
            return {"error": str(e), "success": False}
    
    def send_safe_transaction_alert(
        self,
        recipients: List[str],
        safe_address: str,
        transaction_hash: str,
        transaction_type: str,
        amount: Optional[str] = None,
        token: Optional[str] = None
    ) -> Dict:
        """
        Send Safe transaction alert
        
        Args:
            recipients: List of recipient phone numbers
            safe_address: Safe wallet address
            transaction_hash: Transaction hash
            transaction_type: Type of transaction (e.g., "Transfer", "Contract Call")
            amount: Amount (optional)
            token: Token symbol (optional)
        """
        message = self._format_transaction_message(
            safe_address, transaction_hash, transaction_type, amount, token
        )
        return self.send_notification(recipients, message)
    
    def send_pending_transaction_alert(
        self,
        recipients: List[str],
        safe_address: str,
        nonce: int,
        confirmations_required: int,
        confirmations_current: int
    ) -> Dict:
        """
        Send pending transaction alert
        
        Args:
            recipients: List of recipient phone numbers
            safe_address: Safe wallet address
            nonce: Transaction nonce
            confirmations_required: Required confirmations
            confirmations_current: Current confirmations
        """
        message = f"""
🔔 Pending Transaction Alert

Safe: {safe_address[:8]}...{safe_address[-6:]}
Nonce: {nonce}
Status: {confirmations_current}/{confirmations_required} confirmations

Action Required: Please review and sign if appropriate.
        """.strip()
        
        return self.send_notification(recipients, message)
    
    def _format_transaction_message(
        self,
        safe_address: str,
        tx_hash: str,
        tx_type: str,
        amount: Optional[str],
        token: Optional[str]
    ) -> str:
        """Format transaction notification message"""
        short_address = f"{safe_address[:8]}...{safe_address[-6:]}"
        short_hash = f"{tx_hash[:8]}...{tx_hash[-6:]}"
        
        message = f"""
✅ Transaction Executed

Safe: {short_address}
Type: {tx_type}
"""
        
        if amount and token:
            message += f"Amount: {amount} {token}\n"
        
        message += f"Tx: {short_hash}\n"
        message += f"\nTime: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        
        return message.strip()
    
    def _encode_file(self, file_path: str) -> str:
        """Encode file to base64"""
        import base64
        with open(file_path, 'rb') as f:
            return base64.b64encode(f.read()).decode('utf-8')
    
    def test_connection(self) -> bool:
        """Test connection to Signal API"""
        try:
            response = self.session.get(f"{self.api_url}/v1/health", timeout=5)
            return response.status_code == 200
        except:
            return False


# Usage example
if __name__ == "__main__":
    # Initialize
    notifier = SignalNotifier(
        api_url="http://localhost:8080",
        sender_number="+12345678900"
    )
    
    # Test connection
    if not notifier.test_connection():
        print("❌ Cannot connect to Signal API")
        exit(1)
    
    print("✅ Connected to Signal API")
    
    # Send test notification
    result = notifier.send_notification(
        recipients=["+19876543210"],
        message="Test notification from Safe wallet integration"
    )
    
    print(f"Result: {result}")
```

### Step 2: Create Requirements File

Create `requirements.txt`:

```txt
requests>=2.28.0
python-dotenv>=0.19.0
```

Install:
```bash
pip install -r requirements.txt
```

### Step 3: Create Configuration

Create `.env`:

```env
SIGNAL_API_URL=http://localhost:8080
SIGNAL_SENDER_NUMBER=+12345678900
SIGNAL_RECIPIENTS=+19876543210,+11234567890
```

### Step 4: Test the Integration

Create `test_signal.py`:

```python
import os
from dotenv import load_dotenv
from signal_notifier import SignalNotifier

load_dotenv()

def main():
    # Initialize notifier
    notifier = SignalNotifier(
        api_url=os.getenv('SIGNAL_API_URL'),
        sender_number=os.getenv('SIGNAL_SENDER_NUMBER')
    )
    
    # Test connection
    print("Testing connection...")
    if not notifier.test_connection():
        print("❌ Connection failed")
        return
    
    print("✅ Connection successful")
    
    # Get recipients
    recipients = os.getenv('SIGNAL_RECIPIENTS').split(',')
    
    # Send test message
    print(f"Sending test message to {recipients}...")
    result = notifier.send_notification(
        recipients=recipients,
        message="🚀 Signal integration test successful!"
    )
    
    if result.get('results', [{}])[0].get('success'):
        print("✅ Message sent successfully")
    else:
        print("❌ Message failed")
        print(result)

if __name__ == "__main__":
    main()
```

Run:
```bash
python test_signal.py
```

---

## Phase 4: Safe Wallet Integration

### Step 1: Integrate with Existing Safe Code

Update your Safe transaction monitoring code:

```python
from signal_notifier import SignalNotifier
import os

# Initialize Signal notifier
signal = SignalNotifier(
    api_url=os.getenv('SIGNAL_API_URL'),
    sender_number=os.getenv('SIGNAL_SENDER_NUMBER')
)

recipients = os.getenv('SIGNAL_RECIPIENTS').split(',')

# In your transaction monitoring function
def on_transaction_executed(safe_address, tx_hash, tx_type, amount, token):
    """Called when a transaction is executed"""
    # Send Signal notification
    signal.send_safe_transaction_alert(
        recipients=recipients,
        safe_address=safe_address,
        transaction_hash=tx_hash,
        transaction_type=tx_type,
        amount=amount,
        token=token
    )

# In your pending transaction checker
def on_pending_transaction(safe_address, nonce, required, current):
    """Called when a transaction is pending signatures"""
    signal.send_pending_transaction_alert(
        recipients=recipients,
        safe_address=safe_address,
        nonce=nonce,
        confirmations_required=required,
        confirmations_current=current
    )
```

### Step 2: Add to Existing Scripts

Update `get_pending_transactions.py`:

```python
# Add at the top
from signal_notifier import SignalNotifier
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize
signal = SignalNotifier(
    api_url=os.getenv('SIGNAL_API_URL'),
    sender_number=os.getenv('SIGNAL_SENDER_NUMBER')
)
recipients = os.getenv('SIGNAL_RECIPIENTS').split(',')

# After fetching pending transactions
if pending_count > 0:
    message = f"""
🔔 Pending Transactions Alert

Safe: {safe_address[:10]}...
Network: {network}
Pending: {pending_count} transaction(s)

Please review and sign.
    """.strip()
    
    signal.send_notification(recipients, message)
```

---

## Phase 5: Advanced Features

### Feature 1: Rate Limiting

```python
import time
from functools import wraps

def rate_limit(min_interval=1.0):
    """Decorator to rate limit function calls"""
    def decorator(func):
        last_called = [0.0]
        
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

# Apply to send method
SignalNotifier.send_notification = rate_limit(1.0)(
    SignalNotifier.send_notification
)
```

### Feature 2: Message Queue

```python
from queue import Queue
from threading import Thread
import atexit

class QueuedSignalNotifier(SignalNotifier):
    """Signal notifier with message queue"""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.queue = Queue()
        self.worker = Thread(target=self._process_queue, daemon=True)
        self.worker.start()
        atexit.register(self.shutdown)
    
    def _process_queue(self):
        """Process queued messages"""
        while True:
            try:
                recipients, message = self.queue.get()
                super().send_notification(recipients, message)
                time.sleep(1)  # Rate limiting
            except Exception as e:
                logger.error(f"Error processing queue: {e}")
            finally:
                self.queue.task_done()
    
    def send_notification(self, recipients, message, **kwargs):
        """Queue a notification"""
        self.queue.put((recipients, message))
        logger.info(f"Queued message for {len(recipients)} recipient(s)")
    
    def shutdown(self):
        """Wait for queue to empty"""
        self.queue.join()
```

### Feature 3: Notification Templates

```python
class TemplatedSignalNotifier(SignalNotifier):
    """Signal notifier with message templates"""
    
    TEMPLATES = {
        'transaction_executed': """
✅ Transaction Executed

Safe: {safe_short}
Type: {tx_type}
Amount: {amount} {token}
Tx: {tx_short}

Time: {timestamp}
""",
        'pending_signature': """
⏳ Signature Required

Safe: {safe_short}
Nonce: {nonce}
Confirmations: {current}/{required}

Action: Review and sign if appropriate
Link: {link}
""",
        'threshold_reached': """
✅ Threshold Reached

Safe: {safe_short}
Nonce: {nonce}
Status: Ready to execute

All required signatures collected.
""",
        'error_alert': """
⚠️ Error Alert

Safe: {safe_short}
Error: {error_message}

Time: {timestamp}
"""
    }
    
    def send_templated(self, template_name, recipients, **kwargs):
        """Send notification using template"""
        template = self.TEMPLATES.get(template_name)
        if not template:
            raise ValueError(f"Unknown template: {template_name}")
        
        message = template.format(**kwargs).strip()
        return self.send_notification(recipients, message)
```

---

## Phase 6: Testing

### Test 1: Unit Tests

Create `test_notifier.py`:

```python
import unittest
from unittest.mock import Mock, patch
from signal_notifier import SignalNotifier

class TestSignalNotifier(unittest.TestCase):
    
    def setUp(self):
        self.notifier = SignalNotifier(
            api_url="http://localhost:8080",
            sender_number="+12345678900"
        )
    
    @patch('requests.Session.post')
    def test_send_notification_success(self, mock_post):
        # Mock successful response
        mock_post.return_value.status_code = 201
        mock_post.return_value.json.return_value = {
            'results': [{'success': True}]
        }
        
        result = self.notifier.send_notification(
            recipients=['+19876543210'],
            message='Test'
        )
        
        self.assertTrue(result['results'][0]['success'])
    
    @patch('requests.Session.get')
    def test_connection(self, mock_get):
        mock_get.return_value.status_code = 200
        self.assertTrue(self.notifier.test_connection())

if __name__ == '__main__':
    unittest.main()
```

Run:
```bash
python -m pytest test_notifier.py
```

### Test 2: Integration Test

```bash
# Send test to yourself
python test_signal.py

# Check your phone for the message
```

### Test 3: Load Test

Create `load_test.py`:

```python
import time
from signal_notifier import SignalNotifier

notifier = SignalNotifier(
    api_url="http://localhost:8080",
    sender_number="+12345678900"
)

recipients = ["+19876543210"]

# Send 10 messages
for i in range(10):
    print(f"Sending message {i+1}/10...")
    result = notifier.send_notification(
        recipients=recipients,
        message=f"Load test message #{i+1}"
    )
    print(f"Result: {result.get('results', [{}])[0].get('success')}")
    time.sleep(2)  # Rate limiting
```

---

## Phase 7: Deployment

### Production Checklist

- [ ] Use HTTPS for Signal API
- [ ] Implement authentication
- [ ] Set up monitoring
- [ ] Configure backups
- [ ] Document phone number
- [ ] Test failover
- [ ] Set up logging
- [ ] Configure alerts

### Docker Production Setup

Update `docker-compose.yml`:

```yaml
version: "3"
services:
  signal-cli-rest-api:
    image: bbernhard/signal-cli-rest-api:latest
    container_name: signal-api-prod
    environment:
      - MODE=native
      - AUTO_RECEIVE_SCHEDULE=0 */5 * * *
    ports:
      - "127.0.0.1:8080:8080"  # Bind to localhost only
    volumes:
      - "./signal-cli-config:/home/.local/share/signal-cli"
      - "./backups:/backups"
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - internal

  nginx:
    image: nginx:alpine
    container_name: nginx-reverse-proxy
    ports:
      - "443:443"
    volumes:
      - "./nginx.conf:/etc/nginx/nginx.conf:ro"
      - "./ssl:/etc/ssl:ro"
    depends_on:
      - signal-cli-rest-api
    networks:
      - internal

networks:
  internal:
    driver: bridge
```

### Backup Strategy

Create backup script `backup.sh`:

```bash
#!/bin/bash
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup signal-cli config
tar -czf "${BACKUP_DIR}/signal-cli-${TIMESTAMP}.tar.gz" \
    ./signal-cli-config

# Keep only last 7 backups
ls -t "${BACKUP_DIR}"/signal-cli-*.tar.gz | tail -n +8 | xargs rm -f

echo "Backup completed: signal-cli-${TIMESTAMP}.tar.gz"
```

---

## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues.

---

## Next Steps

1. Review [API_REFERENCE.md](./API_REFERENCE.md) for complete API documentation
2. Check [RESOURCES.md](./RESOURCES.md) for additional examples
3. Implement monitoring and alerting
4. Set up automated backups

---

## Support

- GitHub Issues: https://github.com/bbernhard/signal-cli-rest-api/issues
- Community: Signal-CLI discussions
- Documentation: https://bbernhard.github.io/signal-cli-rest-api/

