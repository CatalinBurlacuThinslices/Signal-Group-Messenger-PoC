# Send Messages to Phone Numbers

This guide explains how to send Signal messages directly to phone numbers using the new endpoint.

## Overview

The `/api/send-to-phone` endpoint allows you to send Signal messages to individual phone numbers without modifying the existing group messaging functionality.

## Prerequisites

1. Signal API must be running (Docker container)
2. Your Signal number must be registered in the system
3. Backend server must be running
4. Recipient must have Signal installed and registered

## Phone Number Format

**Important:** Phone numbers must include the country code and start with `+`

Examples:
- ✅ `+40751770274` (Romania)
- ✅ `+12025551234` (USA)
- ✅ `+447700900123` (UK)
- ❌ `40751770274` (Missing +)
- ❌ `0751770274` (Missing country code)

## Usage Methods

### Method 1: Using Node.js Script

```bash
cd signal-poc
node send-to-phone.js "+40751770274" "Hello from Signal PoC!"
```

### Method 2: Using Shell Script

```bash
cd signal-poc
./send-to-phone.sh "+40751770274" "Hello from Signal PoC!"
```

### Method 3: Using cURL (Direct API Call)

```bash
curl -X POST http://localhost:5001/api/send-to-phone \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+40751770274",
    "message": "Hello from Signal PoC!"
  }'
```

### Method 4: Using JavaScript/Node.js Code

```javascript
const axios = require('axios');

async function sendMessageToPhone(phoneNumber, message) {
  try {
    const response = await axios.post('http://localhost:5001/api/send-to-phone', {
      phoneNumber,
      message
    });

    if (response.data.success) {
      console.log('✅ Message sent successfully!');
      console.log('Timestamp:', response.data.timestamp);
      console.log('Recipient:', response.data.recipient);
    }
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

// Example usage
sendMessageToPhone('+40751770274', 'Hello from Signal PoC!');
```

### Method 5: Using Python

```python
import requests

def send_message_to_phone(phone_number, message):
    url = 'http://localhost:5001/api/send-to-phone'
    payload = {
        'phoneNumber': phone_number,
        'message': message
    }
    
    try:
        response = requests.post(url, json=payload)
        data = response.json()
        
        if data.get('success'):
            print('✅ Message sent successfully!')
            print(f"Timestamp: {data.get('timestamp')}")
            print(f"Recipient: {data.get('recipient')}")
        else:
            print(f"❌ Error: {data.get('error')}")
    except Exception as e:
        print(f'❌ Error: {str(e)}')

# Example usage
send_message_to_phone('+40751770274', 'Hello from Signal PoC!')
```

## API Endpoint Details

### Endpoint
```
POST /api/send-to-phone
```

### Request Body
```json
{
  "phoneNumber": "+40751770274",
  "message": "Your message text here"
}
```

### Success Response
```json
{
  "success": true,
  "message": "Message sent successfully to phone number",
  "timestamp": 1234567890123,
  "recipient": "+40751770274",
  "data": {
    // Additional Signal API response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Failed to send message to phone number",
  "details": "Error details here",
  "hint": "Helpful hint for fixing the issue"
}
```

## Common Errors and Solutions

### Error: "Phone number is required"
- **Cause:** Missing `phoneNumber` field in request
- **Solution:** Include the phone number in your request

### Error: "Signal account not found"
- **Cause:** Your Signal number is not registered or recipient doesn't have Signal
- **Solution:** 
  - Make sure your number is registered: `cd signal-api && ./register.sh`
  - Verify recipient has Signal installed

### Error: "Invalid request - Check phone number format"
- **Cause:** Phone number format is incorrect
- **Solution:** Use format: `+[country code][number]`, e.g., `+40751770274`

### Error: "Cannot connect to Signal API"
- **Cause:** Signal API Docker container is not running
- **Solution:** Start Signal API: `cd signal-api && docker-compose up -d`

### Error: "SIGNAL_NUMBER not configured"
- **Cause:** Backend `.env` file is missing `SIGNAL_NUMBER`
- **Solution:** Add your registered number to `signal-poc/backend/.env`:
  ```
  SIGNAL_NUMBER=+40751770274
  ```

## Testing

### Quick Test
```bash
# Test sending a message to yourself
cd signal-poc
node send-to-phone.js "+YOUR_NUMBER" "Test message from Signal PoC"
```

### Verify Backend is Running
```bash
curl http://localhost:5001/api/health
```

### Verify Signal API is Running
```bash
curl http://localhost:8080/v1/health
```

## Integration Examples

### Express.js Route
```javascript
app.post('/send-signal-message', async (req, res) => {
  const { recipient, text } = req.body;
  
  try {
    const response = await axios.post('http://localhost:5001/api/send-to-phone', {
      phoneNumber: recipient,
      message: text
    });
    
    res.json({ success: true, data: response.data });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.response?.data || error.message 
    });
  }
});
```

### React Component
```jsx
import { useState } from 'react';
import axios from 'axios';

function SendToPhone() {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [message, setMessage] = useState('');
  const [status, setStatus] = useState('');

  const handleSend = async (e) => {
    e.preventDefault();
    setStatus('Sending...');
    
    try {
      const response = await axios.post('/api/send-to-phone', {
        phoneNumber,
        message
      });
      
      if (response.data.success) {
        setStatus('✅ Message sent successfully!');
        setMessage(''); // Clear message
      }
    } catch (error) {
      setStatus(`❌ Error: ${error.response?.data?.error || error.message}`);
    }
  };

  return (
    <div>
      <h2>Send Message to Phone</h2>
      <form onSubmit={handleSend}>
        <input
          type="tel"
          placeholder="+40751770274"
          value={phoneNumber}
          onChange={(e) => setPhoneNumber(e.target.value)}
          required
        />
        <textarea
          placeholder="Your message..."
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          required
        />
        <button type="submit">Send</button>
      </form>
      {status && <p>{status}</p>}
    </div>
  );
}
```

## Differences from Group Messaging

| Feature | Group Messages (`/api/send`) | Phone Messages (`/api/send-to-phone`) |
|---------|------------------------------|---------------------------------------|
| Recipient Type | Group ID | Phone number |
| Format | `group.Base64String...` | `+[country][number]` |
| Multiple Recipients | Yes (group members) | Single recipient per call |
| Requires Group | Yes | No |

## Notes

1. **Both endpoints work independently** - The existing `/api/send` endpoint for groups remains unchanged
2. **Rate Limiting** - Signal may impose rate limits on message sending
3. **Delivery** - Messages require both sender and recipient to have Signal
4. **Privacy** - Signal uses end-to-end encryption for all messages
5. **Auto-formatting** - The endpoint automatically adds `+` if missing (but country code still required)

## Troubleshooting

If messages aren't sending:

1. **Check Backend Logs**
   ```bash
   tail -f signal-poc/backend/backend.log
   ```

2. **Check Signal API Logs**
   ```bash
   cd signal-api
   docker-compose logs -f
   ```

3. **Test Direct API Call**
   ```bash
   curl -X POST http://localhost:8080/v2/send \
     -H "Content-Type: application/json" \
     -d '{
       "message": "Test",
       "number": "+YOUR_NUMBER",
       "recipients": ["+RECIPIENT_NUMBER"]
     }'
   ```

4. **Verify Registration**
   ```bash
   curl http://localhost:8080/v1/accounts
   ```

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Signal API logs
3. Verify phone number format
4. Ensure both sender and recipient have Signal installed

