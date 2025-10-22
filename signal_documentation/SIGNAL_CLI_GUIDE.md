# Signal-CLI Direct Usage Guide

Guide for using signal-cli directly without the REST API wrapper.

---

## Overview

signal-cli is a command-line interface for Signal that provides direct access to Signal's messaging service. This approach is lighter weight than the REST API but requires more integration work.

**Repository:** https://github.com/AsamK/signal-cli

---

## When to Use signal-cli

### ✅ Good For:
- Shell scripts and automation
- Single-server deployments
- Resource-constrained environments
- Quick prototyping
- System administrators comfortable with CLI

### ❌ Not Ideal For:
- Web applications (use REST API instead)
- Microservices architectures
- Multiple programming languages
- Complex integrations

---

## Installation

### Option 1: Download Pre-built Binary

**Linux/macOS:**
```bash
cd /tmp
wget https://github.com/AsamK/signal-cli/releases/download/v0.11.5/signal-cli-0.11.5.tar.gz
tar -xzf signal-cli-0.11.5.tar.gz
sudo mv signal-cli-0.11.5 /opt/signal-cli
sudo ln -s /opt/signal-cli/bin/signal-cli /usr/local/bin/signal-cli
```

Verify installation:
```bash
signal-cli --version
```

### Option 2: Using Homebrew (macOS)

```bash
brew install signal-cli
```

### Option 3: Using Package Manager (Debian/Ubuntu)

```bash
# Add repository
echo "deb [signed-by=/usr/share/keyrings/signal-cli.gpg] https://updates.signal.org/linux/apt xenial main" | \
  sudo tee /etc/apt/sources.list.d/signal-cli.list

# Import key
wget -O- https://updates.signal.org/desktop/apt/keys.asc | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/signal-cli.gpg > /dev/null

# Install
sudo apt update
sudo apt install signal-cli
```

---

## Setup and Registration

### Step 1: Register a Phone Number

```bash
signal-cli -a +12345678900 register
```

**Output:**
```
Verification code sent to +12345678900
```

### Step 2: Verify with SMS Code

```bash
signal-cli -a +12345678900 verify 123456
```

Where `123456` is the code received via SMS.

**Output:**
```
Registration successful
```

### Step 3: Trust the Safety Number (First Time)

When messaging a new contact:
```bash
signal-cli -a +12345678900 send -m "Test message" +19876543210
```

You may need to trust the safety number:
```bash
signal-cli -a +12345678900 trust +19876543210 -a
```

---

## Basic Usage

### Send a Text Message

```bash
signal-cli -a +12345678900 send -m "Hello from signal-cli!" +19876543210
```

### Send to Multiple Recipients

```bash
signal-cli -a +12345678900 send -m "Group announcement" +19876543210 +11234567890
```

### Send with Attachment

```bash
signal-cli -a +12345678900 send \
  -m "Check out this file" \
  -a /path/to/document.pdf \
  +19876543210
```

### Receive Messages

```bash
signal-cli -a +12345678900 receive
```

**Output:**
```json
{
  "envelope": {
    "source": "+19876543210",
    "timestamp": 1234567890123,
    "dataMessage": {
      "timestamp": 1234567890123,
      "message": "Hello back!"
    }
  }
}
```

### Receive Messages (Continuous)

```bash
signal-cli -a +12345678900 daemon --receive-mode on-connection
```

---

## Group Management

### Create a Group

```bash
signal-cli -a +12345678900 updateGroup \
  -n "Project Team" \
  -m +11111111111 +12222222222
```

### List Groups

```bash
signal-cli -a +12345678900 listGroups -d
```

### Send Message to Group

```bash
signal-cli -a +12345678900 send \
  -m "Team meeting at 3 PM" \
  -g "group-id-from-list-command"
```

---

## Python Wrapper

### Basic Wrapper Implementation

Create `signal_cli_wrapper.py`:

```python
import subprocess
import json
import logging
from typing import List, Optional, Dict

logger = logging.getLogger(__name__)


class SignalCLI:
    """Python wrapper for signal-cli"""
    
    def __init__(self, sender_number: str, signal_cli_path: str = "signal-cli"):
        """
        Initialize Signal CLI wrapper
        
        Args:
            sender_number: Your Signal phone number
            signal_cli_path: Path to signal-cli binary
        """
        self.sender_number = sender_number
        self.signal_cli_path = signal_cli_path
    
    def _run_command(self, args: List[str]) -> Dict:
        """Run signal-cli command and return result"""
        cmd = [self.signal_cli_path, "-a", self.sender_number] + args
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode != 0:
                logger.error(f"Command failed: {result.stderr}")
                return {"success": False, "error": result.stderr}
            
            # Try to parse JSON output
            try:
                return json.loads(result.stdout) if result.stdout else {"success": True}
            except json.JSONDecodeError:
                return {"success": True, "output": result.stdout}
                
        except subprocess.TimeoutExpired:
            logger.error("Command timed out")
            return {"success": False, "error": "Command timed out"}
        except Exception as e:
            logger.error(f"Command error: {e}")
            return {"success": False, "error": str(e)}
    
    def send_message(
        self,
        recipients: List[str],
        message: str,
        attachments: Optional[List[str]] = None
    ) -> Dict:
        """
        Send a Signal message
        
        Args:
            recipients: List of recipient phone numbers
            message: Message text
            attachments: Optional list of file paths to attach
            
        Returns:
            Dict with success status
        """
        args = ["send", "-m", message] + recipients
        
        if attachments:
            for attachment in attachments:
                args.extend(["-a", attachment])
        
        return self._run_command(args)
    
    def receive_messages(self, timeout: int = 5) -> List[Dict]:
        """
        Receive pending messages
        
        Args:
            timeout: Receive timeout in seconds
            
        Returns:
            List of message envelopes
        """
        args = ["receive", "--timeout", str(timeout), "--json"]
        result = self._run_command(args)
        
        if isinstance(result, dict) and result.get("success"):
            return []
        
        # Parse JSON lines
        messages = []
        if isinstance(result, dict) and "output" in result:
            for line in result["output"].strip().split('\n'):
                if line:
                    try:
                        messages.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass
        
        return messages
    
    def create_group(self, name: str, members: List[str]) -> Dict:
        """
        Create a Signal group
        
        Args:
            name: Group name
            members: List of member phone numbers
            
        Returns:
            Dict with group info
        """
        args = ["updateGroup", "-n", name, "-m"] + members
        return self._run_command(args)
    
    def send_to_group(self, group_id: str, message: str) -> Dict:
        """
        Send message to a group
        
        Args:
            group_id: Group ID
            message: Message text
            
        Returns:
            Dict with success status
        """
        args = ["send", "-m", message, "-g", group_id]
        return self._run_command(args)
    
    def list_groups(self) -> List[Dict]:
        """List all groups"""
        args = ["listGroups", "-d"]
        result = self._run_command(args)
        
        # Parse group list from output
        groups = []
        if isinstance(result, dict) and "output" in result:
            # Parse group information from text output
            # Format varies, this is a simplified parser
            for line in result["output"].strip().split('\n'):
                if line and "Id:" in line:
                    groups.append({"raw": line})
        
        return groups


# Usage example
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    
    # Initialize
    signal = SignalCLI(sender_number="+12345678900")
    
    # Send message
    print("Sending message...")
    result = signal.send_message(
        recipients=["+19876543210"],
        message="Test from Python wrapper"
    )
    print(f"Result: {result}")
    
    # Receive messages
    print("\nReceiving messages...")
    messages = signal.receive_messages(timeout=5)
    for msg in messages:
        print(f"From: {msg.get('envelope', {}).get('source')}")
        print(f"Message: {msg.get('envelope', {}).get('dataMessage', {}).get('message')}")
```

### Advanced Wrapper with Error Handling

```python
import subprocess
import json
from typing import List, Optional, Dict
from functools import wraps
import time

def retry(max_attempts=3, delay=1):
    """Retry decorator"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    time.sleep(delay * (attempt + 1))
            return None
        return wrapper
    return decorator


class RobustSignalCLI(SignalCLI):
    """Signal CLI wrapper with retry and error handling"""
    
    @retry(max_attempts=3, delay=2)
    def send_message(self, recipients, message, attachments=None):
        """Send message with retry"""
        result = super().send_message(recipients, message, attachments)
        
        if not result.get("success"):
            raise Exception(f"Send failed: {result.get('error')}")
        
        return result
    
    def send_safe_transaction_alert(
        self,
        recipients: List[str],
        safe_address: str,
        tx_hash: str,
        tx_type: str
    ) -> Dict:
        """Send Safe transaction alert"""
        message = f"""
✅ Transaction Executed

Safe: {safe_address[:10]}...
Type: {tx_type}
Tx: {tx_hash[:10]}...
        """.strip()
        
        return self.send_message(recipients, message)
```

---

## Shell Script Example

### Safe Transaction Monitor

Create `monitor_safe_transactions.sh`:

```bash
#!/bin/bash

# Configuration
SIGNAL_NUMBER="+12345678900"
ALERT_RECIPIENTS="+19876543210 +11234567890"
SAFE_ADDRESS="0xYourSafeAddress"
NETWORK="eth"

# Function to send Signal alert
send_alert() {
    local message="$1"
    signal-cli -a "${SIGNAL_NUMBER}" send -m "${message}" ${ALERT_RECIPIENTS}
}

# Check pending transactions
check_pending() {
    # Use your existing Safe API call here
    # This is a placeholder
    PENDING_COUNT=$(curl -s "https://safe-transaction-${NETWORK}.safe.global/api/v1/safes/${SAFE_ADDRESS}/multisig-transactions/?executed=false" | jq '.count')
    
    if [ "${PENDING_COUNT}" -gt 0 ]; then
        send_alert "🔔 ${PENDING_COUNT} pending transaction(s) for Safe ${SAFE_ADDRESS}"
    fi
}

# Main loop
while true; do
    echo "[$(date)] Checking pending transactions..."
    check_pending
    sleep 300  # Check every 5 minutes
done
```

Make executable:
```bash
chmod +x monitor_safe_transactions.sh
```

Run in background:
```bash
nohup ./monitor_safe_transactions.sh > monitor.log 2>&1 &
```

---

## Systemd Service (Linux)

### Create Service File

Create `/etc/systemd/system/signal-monitor.service`:

```ini
[Unit]
Description=Signal Safe Transaction Monitor
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/home/youruser/<project-folder>
ExecStart=/home/youruser/<project-folder>/monitor_safe_transactions.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Enable and Start

```bash
sudo systemctl daemon-reload
sudo systemctl enable signal-monitor
sudo systemctl start signal-monitor
sudo systemctl status signal-monitor
```

---

## Cron Job Integration

### Add to Crontab

```bash
crontab -e
```

Add:
```cron
# Check for pending Safe transactions every 15 minutes
*/15 * * * * /home/youruser/<project-folder>/check_and_alert.sh >> /var/log/signal-alerts.log 2>&1
```

### Check Script Example

Create `check_and_alert.sh`:

```bash
#!/bin/bash

SIGNAL_NUMBER="+12345678900"
RECIPIENT="+19876543210"

# Your check logic here
NEEDS_ALERT=$(python3 /home/youruser/<project-folder>/get_pending_transactions.py --count-only)

if [ "${NEEDS_ALERT}" -gt 0 ]; then
    signal-cli -a "${SIGNAL_NUMBER}" send \
        -m "⚠️ ${NEEDS_ALERT} pending transactions require attention" \
        "${RECIPIENT}"
fi
```

---

## Pros and Cons

### ✅ Advantages

1. **Lightweight**
   - No web server needed
   - Lower resource usage
   - Simple deployment

2. **Direct Control**
   - Full access to all Signal features
   - No API abstraction layer
   - Fine-grained options

3. **Shell Integration**
   - Easy to use in bash scripts
   - Works with cron jobs
   - Standard Unix tools

### ❌ Disadvantages

1. **Integration Complexity**
   - Need to wrap CLI commands
   - Parse text/JSON output
   - Handle process execution

2. **Error Handling**
   - Less structured errors
   - Need to parse stderr
   - More boilerplate code

3. **Maintenance**
   - CLI interface may change
   - Protocol updates needed
   - Less stable than REST API

4. **Development Experience**
   - Harder to debug
   - More verbose code
   - Less intuitive for web developers

---

## Best Practices

### 1. Always Use JSON Output

```bash
signal-cli -a +12345678900 receive --json
```

Easier to parse than text output.

### 2. Set Timeouts

```python
subprocess.run(cmd, timeout=30)
```

Prevent hanging processes.

### 3. Log All Commands

```python
logger.info(f"Running: {' '.join(cmd)}")
```

Essential for debugging.

### 4. Handle Exit Codes

```python
if result.returncode != 0:
    # Handle error
    pass
```

Don't assume success.

### 5. Use Absolute Paths

```python
signal_cli_path = "/usr/local/bin/signal-cli"
```

Avoid PATH issues.

---

## Comparison: CLI vs REST API

| Feature | signal-cli | signal-cli-rest-api |
|---------|-----------|---------------------|
| **Ease of Use** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Resource Usage** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Web Integration** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Error Handling** | ⭐⭐ | ⭐⭐⭐⭐ |
| **Documentation** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Shell Scripts** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Production Ready** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## Troubleshooting

### Issue: Command Not Found

```bash
which signal-cli
# If empty, add to PATH or use absolute path
```

### Issue: Permission Denied

```bash
chmod +x /path/to/signal-cli
```

### Issue: Config Not Found

```bash
# Check config directory
ls ~/.local/share/signal-cli/

# Verify registration
signal-cli -a +12345678900 listAccounts
```

### Issue: Trust Required

```bash
signal-cli -a +12345678900 trust +19876543210 -a
```

---

## Next Steps

- For web applications, consider [signal-cli-rest-api](./SIGNAL_CLI_REST_API.md)
- Review [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) for full integration
- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues

---

## Resources

- signal-cli GitHub: https://github.com/AsamK/signal-cli
- signal-cli Wiki: https://github.com/AsamK/signal-cli/wiki
- Man page: `signal-cli --help`

