# Quick Command Reference

## Send to Single Person

```bash
cd signal-poc

# Using shell script
./send-to-phone.sh "+40751770274" "Hello!"

# Using Node.js
node send-to-phone.js "+40751770274" "Hello!"
```

## Broadcast to Multiple People

```bash
cd signal-poc

# Comma-separated
./broadcast.sh "+40751770274,+12025551234" "Hello everyone!"

# Space-separated  
./broadcast.sh "+40751770274 +12025551234 +447700900123" "Hello!"

# Using Node.js
node broadcast.js "+40751770274,+12025551234" "Hello team!"
```

## Phone Number Format

✅ **Correct**: `+40751770274` (with + and country code)  
❌ **Wrong**: `40751770274` (missing +)  
❌ **Wrong**: `0751770274` (missing country code)

## Common Country Codes

- 🇺🇸 USA: `+1`
- 🇷🇴 Romania: `+40`
- 🇬🇧 UK: `+44`
- 🇩🇪 Germany: `+49`
- 🇫🇷 France: `+33`

## API Endpoints

### Single Message
```bash
POST http://localhost:5001/api/send-to-phone
{
  "phoneNumber": "+40751770274",
  "message": "Hello!"
}
```

### Broadcast
```bash
POST http://localhost:5001/api/broadcast
{
  "phoneNumbers": ["+40751770274", "+12025551234"],
  "message": "Hello everyone!"
}
```

## Quick Test

```bash
# Test single message
./send-to-phone.sh "+YOUR_NUMBER" "Test"

# Test broadcast
./broadcast.sh "+YOUR_NUMBER" "Test broadcast"
```

## Troubleshooting

```bash
# Check if backend is running
curl http://localhost:5001/api/health

# Check if Signal API is running
curl http://localhost:8080/v1/health

# View backend logs
tail -f backend/backend.log

# View Signal API logs
cd ../signal-api && docker-compose logs -f
```

## Start Services

```bash
# Start Signal API
cd signal-api
docker-compose up -d

# Start Backend
cd signal-poc/backend
node server.js
```

---

**Need more details?** See:
- `SEND_TO_PHONE_GUIDE.md` - Single messages
- `BROADCAST_GUIDE.md` - Multiple recipients

