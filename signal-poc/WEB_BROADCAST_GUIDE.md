# Web Interface - Broadcast to Phone Numbers

## 🎉 New Feature Added!

The web interface now supports sending messages to phone numbers (broadcast) in addition to groups!

## How to Use the Web Interface

### Step 1: Open the Web App

```bash
# Make sure backend is running
cd signal-poc/backend
node server.js &

# Make sure frontend is running  
cd ../frontend
npm run dev
```

Then open: **http://localhost:5173**

### Step 2: Choose Your Mode

You'll see **two tabs** at the top of the "Send Message" section:

1. **👥 Send to Group** - Send to existing Signal groups
2. **📞 Send to Phone Numbers** - Broadcast to phone numbers

### Step 3: Send to Phone Numbers

1. Click the **"📞 Send to Phone Numbers"** tab
2. Enter phone numbers in the text field (one per line or comma-separated):
   ```
   +40751770274
   +12025551234
   +447700900123
   ```
   OR
   ```
   +40751770274, +12025551234, +447700900123
   ```

3. Type your message in the message field (same field as groups)
4. Click **"📤 Broadcast Message"**
5. See success confirmation!

## Phone Number Format

**Important Rules:**
- ✅ Must start with `+`
- ✅ Must include country code (+40, +1, +44, etc.)
- ✅ Can separate with:
  - Comma: `+40751770274, +12025551234`
  - Space: `+40751770274 +12025551234`
  - New line (one per line)
  - Semicolon: `+40751770274; +12025551234`

**Examples:**

✅ **Valid:**
```
+40751770274
+12025551234
+447700900123
```

✅ **Valid (comma-separated):**
```
+40751770274, +12025551234, +447700900123
```

✅ **Valid (space-separated):**
```
+40751770274 +12025551234 +447700900123
```

❌ **Invalid:**
```
40751770274     (missing +)
0751770274      (missing country code)
+40 751 770 274 (spaces in number)
```

## Features

### Real-time Recipient Count
As you type phone numbers, the UI shows how many recipients you have:
```
Recipients: 3 phone number(s)
```

### Helpful Hints
The UI displays helpful hints about:
- Phone number format requirements
- Country code requirements
- Separator options

### Same Message Field
The message textarea is **shared** between both modes:
- Switch between "Group" and "Phone Numbers" tabs
- Same familiar interface
- Same character counter
- Same validation

### Error Messages
Clear error messages if something goes wrong:
- Missing phone numbers
- Invalid format
- Backend connection issues
- Signal API issues

### Success Confirmation
After sending, you'll see:
```
✅ Message broadcast to 3 recipients!
```

## Screenshots/Flow

### 1. Default View (Send to Group)
- Shows your Signal groups
- Select group from list
- Type message
- Send

### 2. Switch to Phone Numbers
- Click "📞 Send to Phone Numbers" tab
- Groups list hidden
- Phone number input appears
- Same message field

### 3. Enter Phone Numbers
```
Phone Numbers:
┌─────────────────────────────────────┐
│ +40751770274                        │
│ +12025551234                        │
│ +447700900123                       │
└─────────────────────────────────────┘
💡 Separate with comma, space, or new line. 
   Must include country code (+40, +1, etc.)
```

### 4. Enter Message (Same as Before)
```
Message:
┌─────────────────────────────────────┐
│ Hello everyone!                     │
│ This is a broadcast message         │
│                                     │
└─────────────────────────────────────┘
21 characters
```

### 5. Send
```
Recipients: 3 phone number(s)

[📤 Broadcast Message]
```

### 6. Success
```
✅ Message broadcast to 3 recipients!
```

## Use Cases

### 1. Quick Team Notification
```
Phone Numbers:
+40751770274, +12025551234

Message:
Meeting in 10 minutes - Room 301
```

### 2. Event Reminder
```
Phone Numbers:
+40751770274
+12025551234
+447700900123

Message:
Reminder: Event tonight at 7pm!
```

### 3. Status Update
```
Phone Numbers:
+40751770274, +12025551234, +33123456789

Message:
Project deployment complete! 🎉
Everything is running smoothly.
```

## Advantages of Web Interface

✅ **Visual Interface** - No need to remember commands  
✅ **Easy Input** - Copy/paste phone numbers  
✅ **Real-time Validation** - See recipient count as you type  
✅ **Error Handling** - Clear error messages  
✅ **Success Feedback** - Immediate confirmation  
✅ **History** - See your groups and previous selections  
✅ **Mode Toggle** - Easy switch between groups and phones  
✅ **Same Familiar UI** - Consistent with group messaging  

## Comparison: Web UI vs Scripts

| Feature | Web Interface | Scripts |
|---------|---------------|---------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ Visual | ⭐⭐⭐ Command line |
| **Phone Input** | Text area | Command argument |
| **Validation** | Real-time | On submit |
| **Error Messages** | Visual alerts | Terminal output |
| **Copy/Paste** | Easy | More steps |
| **Automation** | Good for manual | Best for automation |
| **Learning Curve** | Minimal | Some |

## Tips

1. **Save Frequent Recipients**: Keep a text file with phone numbers, then copy/paste into the web UI

2. **Test First**: Send to yourself first:
   ```
   +YOUR_NUMBER
   
   Test message
   ```

3. **Format Check**: The UI shows recipient count - verify it matches your expectation

4. **Mix Separators**: You can mix separators:
   ```
   +40751770274, +12025551234
   +447700900123
   ```

5. **Clear After Sending**: The form automatically clears after successful send

## Troubleshooting

### Issue: "Please enter at least one phone number"
**Solution**: Make sure you've entered phone numbers in the Phone Numbers field

### Issue: "No valid phone numbers found"
**Solution**: Check format - must have `+` and country code

### Issue: "Failed to broadcast message"
**Solutions:**
1. Check backend is running: `curl http://localhost:5001/api/health`
2. Check Signal API is running: `curl http://localhost:8080/v1/health`
3. Verify phone number format
4. Check backend logs for details

### Issue: Can't see the Phone Numbers tab
**Solution**: Refresh the page. Make sure you're running the latest frontend code.

### Issue: Message sends to group instead of phones
**Solution**: Make sure the "📞 Send to Phone Numbers" tab is selected (should be highlighted)

## Quick Start Checklist

- [ ] Backend running on port 5001
- [ ] Frontend running on port 5173
- [ ] Signal API running on port 8080
- [ ] Open http://localhost:5173 in browser
- [ ] Click "📞 Send to Phone Numbers" tab
- [ ] Enter phone numbers (with + and country code)
- [ ] Type message
- [ ] Click "📤 Broadcast Message"
- [ ] See success message!

## What's Different from Scripts?

### Scripts (broadcast.sh / broadcast.js)
```bash
./broadcast.sh "+40751770274,+12025551234" "Hello"
```

- Good for: Automation, scripting, CI/CD
- Requires: Terminal access
- Input: Command line arguments

### Web Interface
- Open browser → Click tab → Enter numbers → Type message → Send
- Good for: Manual sending, visual interface, easier for non-technical users
- Requires: Browser
- Input: Text fields

**Both use the same backend API endpoint!** Choose what works best for your use case.

## Technical Details

### State Management
- `sendMode`: Toggles between 'group' and 'phone'
- `phoneNumbers`: Stores the phone numbers input
- `message`: Shared between both modes

### API Endpoint
```javascript
POST /api/broadcast
{
  "phoneNumbers": ["+40751770274", "+12025551234"],
  "message": "Your message"
}
```

### Phone Number Parsing
```javascript
phoneNumbers
  .split(/[,\s;]+/)        // Split by comma, space, semicolon
  .map(num => num.trim())   // Remove whitespace
  .filter(num => num.length > 0)  // Remove empty
```

### Success Response
```json
{
  "success": true,
  "message": "Message broadcast to 3 recipients",
  "timestamp": "1761121081823",
  "recipients": ["+40751770274", "+12025551234", "+447700900123"],
  "recipientCount": 3
}
```

## Summary

🎉 **You now have 3 ways to send messages:**

1. **Web UI → Groups**: Select group from list, type message, send
2. **Web UI → Phone Numbers**: Enter phone numbers, type message, broadcast
3. **Scripts**: Use `broadcast.sh` or `broadcast.js` for automation

Choose the method that works best for your needs!

---

**Enjoy your new broadcast feature! 📱💬**

