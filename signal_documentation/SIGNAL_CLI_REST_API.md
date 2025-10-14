# signal-cli-rest-api - Complete Guide

## Overview

signal-cli-rest-api is a REST API wrapper around signal-cli that provides an HTTP interface for Signal messaging operations. This is the **recommended solution** for integrating Signal messaging into applications.

**Repository:** https://github.com/bbernhard/signal-cli-rest-api  
**Swagger Documentation:** https://bbernhard.github.io/signal-cli-rest-api/  
**Docker Hub:** https://hub.docker.com/r/bbernhard/signal-cli-rest-api

---

## Features

### Core Functionality

1. **Account Management**
   - Register a new phone number
   - Verify registration with SMS code
   - Link to existing Signal account
   - Update profile information

2. **Messaging**
   - Send text messages
   - Send attachments (images, files)
   - Send to multiple recipients
   - Send to groups
   - Receive messages

3. **Group Management**
   - Create new groups
   - List existing groups
   - Remove groups
   - Manage group members

4. **Attachment Handling**
   - Upload attachments
   - List attachments
   - Serve/download attachments
   - Delete attachments

5. **Device Management**
   - Link additional devices
   - Manage linked devices
   - Device synchronization

---

## Architecture

```
┌─────────────────┐
│  Your App       │
│  (Python/Node/  │
│   Java/etc.)    │
└────────┬────────┘
         │ HTTP/REST
         │
┌────────▼────────┐
│ signal-cli-     │
│ rest-api        │
│ (Docker)        │
└────────┬────────┘
         │ Wrapper
         │
┌────────▼────────┐
│  signal-cli     │
│  (Java)         │
└────────┬────────┘
         │ Protocol
         │
┌────────▼────────┐
│  Signal Service │
└─────────────────┘
```

---

## Installation

### Using Docker (Recommended)

#### 1. Create Directory Structure

```bash
mkdir -p signal-cli-config
cd signal-cli-config
```

#### 2. Create Docker Compose File

Create `docker-compose.yml`:

```yaml
version: "3"
services:
  signal-cli-rest-api:
    image: bbernhard/signal-cli-rest-api:latest
    environment:
      - MODE=native  # or 'json-rpc' for JSON-RPC mode
    ports:
      - "8080:8080"  # REST API port
    volumes:
      - "./signal-cli-config:/home/.local/share/signal-cli"  # Persist data
    restart: unless-stopped
```

#### 3. Start the Service

```bash
docker-compose up -d
```

#### 4. Verify Installation

```bash
curl http://localhost:8080/v1/health
```

Expected response:
```json
{
  "status": "ok"
}
```

### Using Docker Run

```bash
docker run -d \
  --name signal-api \
  -p 8080:8080 \
  -v $(pwd)/signal-cli-config:/home/.local/share/signal-cli \
  -e MODE=native \
  bbernhard/signal-cli-rest-api:latest
```

---

## Configuration

### Environment Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `MODE` | Operation mode | `native` | `native`, `json-rpc` |
| `PORT` | API port | `8080` | Any valid port |
| `AUTO_RECEIVE_SCHEDULE` | Auto-receive interval | `0 */1 * * *` | Cron expression |
| `SIGNAL_CLI_UID` | User ID for signal-cli | `1000` | Any UID |
| `SIGNAL_CLI_GID` | Group ID for signal-cli | `1000` | Any GID |

### Modes Explained

**Native Mode:**
- Direct REST API interface
- Simpler to use
- Recommended for most use cases

**JSON-RPC Mode:**
- Uses JSON-RPC protocol
- More advanced features
- Better for complex integrations

---

## Getting Started

### Step 1: Register a Phone Number

```bash
curl -X POST \
  http://localhost:8080/v1/register/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{
    "use_voice": false,
    "captcha": ""
  }'
```

**Response:**
```json
{
  "status": "verification_required"
}
```

**Note:** You'll receive an SMS with a verification code.

### Step 2: Verify the Number

```bash
curl -X POST \
  http://localhost:8080/v1/register/+1234567890/verify/123456 \
  -H 'Content-Type: application/json'
```

Where `123456` is the SMS verification code.

**Response:**
```json
{
  "status": "verified"
}
```

### Step 3: Send Your First Message

```bash
curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Hello from signal-cli-rest-api!",
    "number": "+1234567890",
    "recipients": ["+9876543210"]
  }'
```

**Response:**
```json
{
  "timestamp": 1234567890123,
  "results": [
    {
      "recipientNumber": "+9876543210",
      "success": true
    }
  ]
}
```

---

## Common Use Cases

### Send Message to Multiple Recipients

```bash
curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Alert: System maintenance in 1 hour",
    "number": "+1234567890",
    "recipients": [
      "+1111111111",
      "+2222222222",
      "+3333333333"
    ]
  }'
```

### Send Message with Attachment

```bash
# First, upload the attachment
curl -X POST \
  http://localhost:8080/v1/attachments \
  -F "file=@/path/to/image.jpg"

# Response will include attachment path
# Use that path in the send request

curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Check out this image!",
    "number": "+1234567890",
    "recipients": ["+9876543210"],
    "base64_attachments": ["<base64_encoded_image>"]
  }'
```

### Create a Group

```bash
curl -X POST \
  http://localhost:8080/v1/groups/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Team Notifications",
    "members": ["+1111111111", "+2222222222"]
  }'
```

### Send Message to Group

```bash
curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Team meeting at 3 PM",
    "number": "+1234567890",
    "group_id": "group-id-from-create-response"
  }'
```

### Receive Messages

```bash
curl -X GET \
  http://localhost:8080/v1/receive/+1234567890
```

**Response:**
```json
{
  "envelope": [
    {
      "source": "+9876543210",
      "timestamp": 1234567890123,
      "dataMessage": {
        "message": "Hello back!",
        "timestamp": 1234567890123
      }
    }
  ]
}
```

---

## Python Integration Example

### Install Dependencies

```bash
pip install requests
```

### Basic Implementation

```python
import requests
import json

class SignalAPI:
    def __init__(self, base_url, phone_number):
        self.base_url = base_url
        self.phone_number = phone_number
    
    def send_message(self, recipients, message, attachments=None):
        """Send a Signal message to one or more recipients"""
        url = f"{self.base_url}/v2/send"
        
        payload = {
            "message": message,
            "number": self.phone_number,
            "recipients": recipients if isinstance(recipients, list) else [recipients]
        }
        
        if attachments:
            payload["base64_attachments"] = attachments
        
        response = requests.post(url, json=payload)
        return response.json()
    
    def receive_messages(self):
        """Receive pending messages"""
        url = f"{self.base_url}/v1/receive/{self.phone_number}"
        response = requests.get(url)
        return response.json()
    
    def create_group(self, group_name, members):
        """Create a new Signal group"""
        url = f"{self.base_url}/v1/groups/{self.phone_number}"
        
        payload = {
            "name": group_name,
            "members": members
        }
        
        response = requests.post(url, json=payload)
        return response.json()
    
    def send_to_group(self, group_id, message):
        """Send message to a group"""
        url = f"{self.base_url}/v2/send"
        
        payload = {
            "message": message,
            "number": self.phone_number,
            "group_id": group_id
        }
        
        response = requests.post(url, json=payload)
        return response.json()

# Usage
signal = SignalAPI("http://localhost:8080", "+1234567890")

# Send a message
result = signal.send_message(
    recipients=["+9876543210"],
    message="Hello from Python!"
)
print(f"Message sent: {result}")

# Receive messages
messages = signal.receive_messages()
for envelope in messages.get('envelope', []):
    print(f"From: {envelope['source']}")
    print(f"Message: {envelope['dataMessage']['message']}")
```

---

## Node.js Integration Example

### Install Dependencies

```bash
npm install axios
```

### Basic Implementation

```javascript
const axios = require('axios');

class SignalAPI {
  constructor(baseUrl, phoneNumber) {
    this.baseUrl = baseUrl;
    this.phoneNumber = phoneNumber;
  }

  async sendMessage(recipients, message, attachments = null) {
    const url = `${this.baseUrl}/v2/send`;
    
    const payload = {
      message: message,
      number: this.phoneNumber,
      recipients: Array.isArray(recipients) ? recipients : [recipients]
    };
    
    if (attachments) {
      payload.base64_attachments = attachments;
    }
    
    const response = await axios.post(url, payload);
    return response.data;
  }

  async receiveMessages() {
    const url = `${this.baseUrl}/v1/receive/${this.phoneNumber}`;
    const response = await axios.get(url);
    return response.data;
  }

  async createGroup(groupName, members) {
    const url = `${this.baseUrl}/v1/groups/${this.phoneNumber}`;
    
    const payload = {
      name: groupName,
      members: members
    };
    
    const response = await axios.post(url, payload);
    return response.data;
  }

  async sendToGroup(groupId, message) {
    const url = `${this.baseUrl}/v2/send`;
    
    const payload = {
      message: message,
      number: this.phoneNumber,
      group_id: groupId
    };
    
    const response = await axios.post(url, payload);
    return response.data;
  }
}

// Usage
const signal = new SignalAPI('http://localhost:8080', '+1234567890');

(async () => {
  // Send a message
  const result = await signal.sendMessage(
    ['+9876543210'],
    'Hello from Node.js!'
  );
  console.log('Message sent:', result);

  // Receive messages
  const messages = await signal.receiveMessages();
  messages.envelope?.forEach(envelope => {
    console.log(`From: ${envelope.source}`);
    console.log(`Message: ${envelope.dataMessage.message}`);
  });
})();
```

---

## Best Practices

### 1. Error Handling

Always implement proper error handling:

```python
def send_message_safe(signal_api, recipient, message):
    try:
        result = signal_api.send_message(recipient, message)
        if result.get('results', [{}])[0].get('success'):
            return True, "Message sent successfully"
        else:
            return False, "Message failed to send"
    except requests.exceptions.ConnectionError:
        return False, "Cannot connect to Signal API"
    except Exception as e:
        return False, f"Error: {str(e)}"
```

### 2. Rate Limiting

Implement rate limiting to avoid being blocked:

```python
import time
from datetime import datetime, timedelta

class RateLimitedSignalAPI(SignalAPI):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.last_message_time = None
        self.min_delay = 1.0  # Minimum 1 second between messages
    
    def send_message(self, *args, **kwargs):
        if self.last_message_time:
            elapsed = time.time() - self.last_message_time
            if elapsed < self.min_delay:
                time.sleep(self.min_delay - elapsed)
        
        result = super().send_message(*args, **kwargs)
        self.last_message_time = time.time()
        return result
```

### 3. Message Queue

For high-volume applications, use a message queue:

```python
from queue import Queue
from threading import Thread

class QueuedSignalAPI(SignalAPI):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.queue = Queue()
        self.worker = Thread(target=self._process_queue, daemon=True)
        self.worker.start()
    
    def _process_queue(self):
        while True:
            recipients, message = self.queue.get()
            try:
                self.send_message(recipients, message)
            except Exception as e:
                print(f"Error sending message: {e}")
            finally:
                self.queue.task_done()
            time.sleep(1)  # Rate limiting
    
    def queue_message(self, recipients, message):
        self.queue.put((recipients, message))
```

### 4. Persistent Storage

Store message history and configuration:

```python
import sqlite3

class PersistentSignalAPI(SignalAPI):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.db = sqlite3.connect('signal_messages.db')
        self._create_tables()
    
    def _create_tables(self):
        self.db.execute('''
            CREATE TABLE IF NOT EXISTS messages (
                id INTEGER PRIMARY KEY,
                recipient TEXT,
                message TEXT,
                timestamp DATETIME,
                success BOOLEAN
            )
        ''')
        self.db.commit()
    
    def send_message(self, recipients, message):
        result = super().send_message(recipients, message)
        
        # Log to database
        for recipient in (recipients if isinstance(recipients, list) else [recipients]):
            self.db.execute(
                'INSERT INTO messages VALUES (NULL, ?, ?, datetime("now"), ?)',
                (recipient, message, result.get('results', [{}])[0].get('success', False))
            )
        self.db.commit()
        
        return result
```

---

## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues and solutions.

---

## Security Considerations

1. **Network Security**
   - Use HTTPS in production
   - Implement authentication for API access
   - Restrict network access to trusted IPs

2. **Data Storage**
   - Encrypt Signal data at rest
   - Secure backup procedures
   - Regular security audits

3. **Phone Number Management**
   - Use dedicated numbers for notifications
   - Don't share numbers across services
   - Monitor for suspicious activity

---

## Performance Optimization

1. **Batch Messages**
   - Send to multiple recipients at once
   - Use groups for team notifications

2. **Caching**
   - Cache group IDs
   - Store contact information locally

3. **Async Processing**
   - Use background jobs for sending
   - Implement retry logic

---

## Next Steps

- Review [API Reference](./API_REFERENCE.md) for complete endpoint documentation
- Check [Implementation Guide](./IMPLEMENTATION_GUIDE.md) for integration steps
- See [Resources](./RESOURCES.md) for community articles and examples

