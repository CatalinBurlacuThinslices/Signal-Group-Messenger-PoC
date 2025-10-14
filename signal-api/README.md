# Signal API Setup

This directory contains the Docker setup for signal-cli-rest-api.

## Quick Start

```bash
# Start Signal API
docker-compose up -d

# Check if running
curl http://localhost:8080/v1/health

# Stop Signal API
docker-compose down
```

## First Time Setup - Register Your Number

```bash
# 1. Start the API
docker-compose up -d

# 2. Register your phone number (replace with your actual number)
curl -X POST http://localhost:8080/v1/register/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'

# You'll receive an SMS with a 6-digit code

# 3. Verify with the code (replace 123456 with your actual code)
curl -X POST http://localhost:8080/v1/register/+40751770274/verify/123456
```

## Create Groups

You must create groups in the Signal mobile app:
1. Open Signal app
2. Create a new group
3. Add contacts
4. The group will appear in the web UI

## Check Status

```bash
# Health check
curl http://localhost:8080/v1/health

# List groups
curl http://localhost:8080/v1/groups/+40751770274

# View logs
docker logs signal-api
```

## Troubleshooting

### Container not starting
```bash
docker-compose down
docker-compose up -d
docker logs signal-api
```

### Port already in use
```bash
# Check what's using port 8080
lsof -i :8080

# Change port in docker-compose.yml if needed
```

### Re-register number
```bash
# Backup first
cp -r signal-cli-config signal-cli-config.backup

# Remove existing registration
rm -rf signal-cli-config/data/+40751770274

# Register again (follow steps above)
```

## Data Location

All Signal data is stored in: `./signal-cli-config/`

This includes:
- Your registration
- Keys
- Message history
- Group information

**Important:** This directory is in .gitignore - never commit it!

