# Broadcast Messages to Multiple People

Send the same Signal message to multiple phone numbers at once!

## Quick Start Commands

### Method 1: Using Shell Script (Easiest)

```bash
cd signal-poc

# Comma-separated numbers
./broadcast.sh "+40751770274,+12025551234,+447700900123" "Hello everyone!"

# Space-separated numbers
./broadcast.sh "+40751770274 +12025551234 +447700900123" "Meeting at 3pm"
```

### Method 2: Using Node.js Script

```bash
cd signal-poc

# Comma-separated numbers
node broadcast.js "+40751770274,+12025551234" "Hello team!"

# Space-separated numbers
node broadcast.js "+40751770274 +12025551234 +447700900123" "Important update"
```

### Method 3: Using cURL (Direct API)

```bash
curl -X POST http://localhost:5001/api/broadcast \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumbers": ["+40751770274", "+12025551234", "+447700900123"],
    "message": "Hello everyone!"
  }'
```

## Detailed Examples

### Example 1: Send to 2 people
```bash
./broadcast.sh "+40751770274,+12025551234" "Hi there!"
```

### Example 2: Send to 3 people
```bash
./broadcast.sh "+40751770274 +12025551234 +447700900123" "Meeting reminder: 3pm today"
```

### Example 3: Send to 5 people
```bash
node broadcast.js "+40751770274,+12025551234,+447700900123,+33123456789,+491234567890" "Project deadline tomorrow!"
```

### Example 4: Long message to multiple people
```bash
./broadcast.sh "+40751770274,+12025551234" "This is a longer message that will be sent to everyone on the list. All recipients will receive the exact same message."
```

## Phone Number Format

**Important Rules:**
- ✅ Must start with `+` followed by country code
- ✅ No spaces within individual numbers
- ✅ Separate multiple numbers with comma or space
- ✅ All numbers must have country codes

**Valid Examples:**
- `+40751770274,+12025551234`
- `+40751770274 +12025551234`
- `"+40751770274" "+12025551234"` (quoted)

**Invalid Examples:**
- ❌ `40751770274,12025551234` (missing +)
- ❌ `0751770274,2025551234` (missing country code)
- ❌ `+40 751 770 274` (spaces within number)

## Country Codes Reference

| Country | Code | Example |
|---------|------|---------|
| USA | +1 | +12025551234 |
| Romania | +40 | +40751770274 |
| UK | +44 | +447700900123 |
| Germany | +49 | +491234567890 |
| France | +33 | +33123456789 |
| Italy | +39 | +390123456789 |
| Spain | +34 | +34612345678 |
| Canada | +1 | +14165551234 |

## Using in Code

### JavaScript/Node.js

```javascript
const axios = require('axios');

async function broadcastToMultiple(phoneNumbers, message) {
  try {
    const response = await axios.post('http://localhost:5001/api/broadcast', {
      phoneNumbers: phoneNumbers,
      message: message
    });

    if (response.data.success) {
      console.log(`✅ Sent to ${response.data.recipientCount} people`);
      console.log('Recipients:', response.data.recipients);
    }
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Usage
broadcastToMultiple(
  ['+40751770274', '+12025551234', '+447700900123'],
  'Hello everyone!'
);
```

### Python

```python
import requests

def broadcast_message(phone_numbers, message):
    url = 'http://localhost:5001/api/broadcast'
    payload = {
        'phoneNumbers': phone_numbers,
        'message': message
    }
    
    try:
        response = requests.post(url, json=payload)
        data = response.json()
        
        if data.get('success'):
            print(f"✅ Sent to {data.get('recipientCount')} people")
            print(f"Recipients: {data.get('recipients')}")
        else:
            print(f"❌ Error: {data.get('error')}")
    except Exception as e:
        print(f'❌ Error: {str(e)}')

# Usage
broadcast_message(
    ['+40751770274', '+12025551234', '+447700900123'],
    'Hello everyone!'
)
```

### PHP

```php
<?php
function broadcastMessage($phoneNumbers, $message) {
    $url = 'http://localhost:5001/api/broadcast';
    $data = [
        'phoneNumbers' => $phoneNumbers,
        'message' => $message
    ];
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    
    $response = curl_exec($ch);
    curl_close($ch);
    
    $result = json_decode($response, true);
    
    if ($result['success']) {
        echo "✅ Sent to " . $result['recipientCount'] . " people\n";
        print_r($result['recipients']);
    } else {
        echo "❌ Error: " . $result['error'] . "\n";
    }
}

// Usage
broadcastMessage(
    ['+40751770274', '+12025551234', '+447700900123'],
    'Hello everyone!'
);
?>
```

## API Endpoint Details

### Endpoint
```
POST /api/broadcast
```

### Request Body
```json
{
  "phoneNumbers": ["+40751770274", "+12025551234", "+447700900123"],
  "message": "Your message text"
}
```

### Success Response
```json
{
  "success": true,
  "message": "Message broadcast to 3 recipients",
  "timestamp": 1234567890123,
  "recipients": ["+40751770274", "+12025551234", "+447700900123"],
  "recipientCount": 3,
  "data": {
    // Additional Signal API response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Failed to broadcast message",
  "details": "Error details",
  "hint": "Helpful hint"
}
```

## Comparison: Single vs Broadcast

| Feature | Single (`send-to-phone`) | Broadcast (`broadcast`) |
|---------|-------------------------|------------------------|
| Command | `./send-to-phone.sh "+NUM" "MSG"` | `./broadcast.sh "+NUM1,+NUM2" "MSG"` |
| API | `/api/send-to-phone` | `/api/broadcast` |
| Recipients | 1 phone number | Multiple phone numbers |
| Input Format | String | Array |
| Use Case | One person | Multiple people |

## Practical Use Cases

### 1. Team Notifications
```bash
# Notify team about meeting
./broadcast.sh "+40751770274,+12025551234,+447700900123" "Team meeting in 10 minutes in Room 301"
```

### 2. Event Reminders
```bash
# Remind people about event
./broadcast.sh "+40751770274 +12025551234" "Event starts at 7pm. See you there!"
```

### 3. Emergency Alerts
```bash
# Send urgent message
./broadcast.sh "+40751770274,+12025551234,+447700900123,+491234567890" "URGENT: Server down. Working on fix."
```

### 4. Status Updates
```bash
# Update on project
./broadcast.sh "+40751770274,+12025551234" "Project completed successfully! Thanks everyone."
```

### 5. Announcements
```bash
# General announcement
node broadcast.js "+40751770274,+12025551234,+447700900123,+33123456789" "Office closed tomorrow for holiday"
```

## Tips & Best Practices

1. **Test First**: Send to yourself first to verify it works
   ```bash
   ./broadcast.sh "+YOUR_NUMBER" "Test message"
   ```

2. **Check Format**: Ensure all numbers have country codes and start with `+`

3. **Keep Messages Clear**: Make messages concise and clear

4. **Verify Recipients**: Double-check phone numbers before sending

5. **Rate Limiting**: Signal may limit how many messages you can send in a short time

6. **Batch Large Lists**: If sending to many people, consider splitting into smaller batches

7. **Error Handling**: Always check the response to ensure messages were sent

## Troubleshooting

### Error: "At least one phone number is required"
**Solution**: Make sure you're providing phone numbers in an array format
```bash
# Correct
./broadcast.sh "+40751770274,+12025551234" "Message"

# Wrong
./broadcast.sh "" "Message"
```

### Error: "Invalid phone number format"
**Solution**: Check that all numbers start with `+` and include country code
```bash
# Correct
./broadcast.sh "+40751770274,+12025551234" "Message"

# Wrong
./broadcast.sh "40751770274,12025551234" "Message"
```

### Error: "Cannot connect to backend"
**Solution**: Make sure backend is running
```bash
cd signal-poc/backend
node server.js
```

### Error: "Signal account not found"
**Solution**: 
1. Ensure Signal API is running
2. Verify your number is registered
3. Make sure recipients have Signal

### Messages sent but not received
**Possible Causes:**
1. Recipient doesn't have Signal installed
2. Recipient's number is incorrect
3. Signal service issues

**Solutions:**
1. Verify recipient has Signal
2. Double-check phone numbers
3. Try sending a test message to yourself first

## Limitations

1. **Signal Rate Limits**: Signal may throttle if you send too many messages too quickly
2. **Recipient Must Have Signal**: All recipients must have Signal installed and registered
3. **No Delivery Confirmation**: The API doesn't provide per-recipient delivery status
4. **Same Message Only**: All recipients receive the identical message (no personalization)

## Advanced Usage

### Read Recipients from File

```bash
# Create a file with phone numbers (one per line)
cat > recipients.txt <<EOF
+40751770274
+12025551234
+447700900123
EOF

# Convert to comma-separated and broadcast
NUMBERS=$(cat recipients.txt | tr '\n' ',' | sed 's/,$//')
./broadcast.sh "$NUMBERS" "Hello everyone!"
```

### Broadcast with Environment Variables

```bash
# Set recipients as environment variable
export RECIPIENTS="+40751770274,+12025551234,+447700900123"
./broadcast.sh "$RECIPIENTS" "Message from script"
```

### Schedule Broadcasts (Cron)

```bash
# Add to crontab for daily reminder at 9am
0 9 * * * cd /path/to/signal-poc && ./broadcast.sh "+40751770274,+12025551234" "Daily standup in 30 minutes"
```

## Prerequisites

✅ Signal API Docker container running  
✅ Backend server running on port 5001  
✅ Your Signal number registered  
✅ Recipients have Signal installed  

## Quick Setup Checklist

```bash
# 1. Start Signal API
cd signal-api
docker-compose up -d

# 2. Start Backend
cd ../signal-poc/backend
node server.js &

# 3. Test broadcast
cd ..
./broadcast.sh "+YOUR_NUMBER" "Test broadcast"

# 4. Send to multiple people
./broadcast.sh "+NUM1,+NUM2,+NUM3" "Your message"
```

## Support

Having issues? Check:
1. Backend logs: `tail -f signal-poc/backend/backend.log`
2. Signal API logs: `cd signal-api && docker-compose logs -f`
3. Phone number format (must have + and country code)
4. All services are running

---

**Ready to broadcast?** Try this command:

```bash
cd signal-poc
./broadcast.sh "+40751770274,+12025551234" "Hello from Signal PoC!"
```

