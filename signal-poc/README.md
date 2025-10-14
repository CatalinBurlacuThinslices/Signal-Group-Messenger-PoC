# Signal Group Messenger - PoC

A simple web application to send messages to Signal groups using Node.js backend and React frontend.

![Signal PoC](https://img.shields.io/badge/Status-PoC-yellow)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🎯 Features

- ✅ View all your Signal groups
- ✅ Select a group from the list
- ✅ Send messages to selected group
- ✅ Real-time error messages (in console and UI)
- ✅ Simple, clean interface
- ✅ Health status indicators
- ✅ Refresh groups functionality

## 📋 Prerequisites

Before you begin, ensure you have:

1. **Docker** installed and running
2. **Node.js** (v16 or higher) and npm
3. **signal-cli-rest-api** running (see setup below)
4. A **registered Signal phone number**

## 🚀 Quick Start

### Step 1: Start Signal API

First, you need to have signal-cli-rest-api running. If you haven't set it up yet:

```bash
# Create signal-api directory
mkdir signal-api && cd signal-api
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
```

### Step 2: Register Your Phone Number (If Not Already Registered)

```bash
# Request verification code
curl -X POST http://localhost:8080/v1/register/+12345678900 \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'

# Verify with SMS code (replace 123456 with your code)
curl -X POST http://localhost:8080/v1/register/+12345678900/verify/123456
```

### Step 3: Create a Group in Signal App

Open your Signal mobile app and create at least one group. This PoC will display all your groups.

### Step 4: Setup Backend

```bash
cd signal-poc/backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env

# Edit .env file with your Signal number
nano .env
# Set: SIGNAL_NUMBER=+12345678900

# Start backend server
npm start
```

Backend will run on **http://localhost:5000**

### Step 5: Setup Frontend

Open a new terminal:

```bash
cd signal-poc/frontend

# Install dependencies
npm install

# Start frontend development server
npm run dev
```

Frontend will run on **http://localhost:3000**

### Step 6: Use the Application

1. Open your browser to **http://localhost:3000**
2. You should see your Signal groups listed
3. Click on a group to select it
4. Type your message in the text box
5. Click "Send Message"
6. Check your Signal app - the message should appear in the group!

## 📁 Project Structure

```
signal-poc/
├── backend/
│   ├── server.js          # Express server with API endpoints
│   ├── package.json       # Backend dependencies
│   └── .env.example       # Environment variables template
├── frontend/
│   ├── src/
│   │   ├── App.jsx        # Main React component
│   │   ├── App.css        # Styles
│   │   ├── main.jsx       # React entry point
│   │   └── index.css      # Global styles
│   ├── index.html         # HTML template
│   ├── package.json       # Frontend dependencies
│   └── vite.config.js     # Vite configuration
├── README.md              # This file
├── USAGE.md               # Detailed usage guide
└── TROUBLESHOOTING.md     # Common issues and solutions
```

## 🔧 Configuration

### Backend (.env)

```env
PORT=5000
SIGNAL_API_URL=http://localhost:8080
SIGNAL_NUMBER=+12345678900
```

### Frontend

Frontend uses Vite proxy to connect to backend. No configuration needed.

## 📡 API Endpoints

### Backend API

- `GET /api/health` - Check backend and Signal API health
- `GET /api/groups` - Fetch all Signal groups
- `POST /api/send` - Send message to a group
- `GET /api/config` - Get configuration info

### Example API Calls

**Fetch Groups:**
```bash
curl http://localhost:5000/api/groups
```

**Send Message:**
```bash
curl -X POST http://localhost:5000/api/send \
  -H 'Content-Type: application/json' \
  -d '{
    "groupId": "your-group-id-here",
    "message": "Hello from API!"
  }'
```

## 🐛 Error Handling

All errors are logged in:
1. **Browser Console** (F12 → Console tab)
2. **Backend Terminal** (JSON formatted logs)
3. **UI Alert Box** (red error message box)

Error messages include:
- Error description
- Details about what went wrong
- Hints on how to fix it

## 🧪 Testing

### Test Backend

```bash
# Health check
curl http://localhost:5000/api/health

# Get groups
curl http://localhost:5000/api/groups

# Check configuration
curl http://localhost:5000/api/config
```

### Test Frontend

1. Open browser console (F12)
2. Watch for error messages
3. Try sending a test message
4. Check backend terminal for logs

## 📚 Additional Documentation

- **[USAGE.md](./USAGE.md)** - Detailed usage instructions
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Common issues and fixes
- **[../output/signal_documentation/](../output/signal_documentation/)** - Complete Signal integration docs

## 🔐 Security Notes

⚠️ **This is a PoC - NOT production ready!**

For production use:
- Add authentication
- Use HTTPS
- Implement rate limiting
- Add input validation
- Secure environment variables
- Add logging
- Implement proper error handling

## 🤔 Do You Need a Database?

**No database is required** for this PoC. Here's why:

- Groups are fetched from Signal API in real-time
- No persistent storage needed
- Signal API maintains all data
- This app is stateless

If you want to add features like:
- Message history
- User authentication
- Analytics
- Scheduled messages

Then you would need a database.

## 🛠️ Tech Stack

- **Backend:** Node.js + Express
- **Frontend:** React + Vite
- **Signal Integration:** signal-cli-rest-api (Docker)
- **HTTP Client:** Axios
- **Styling:** Vanilla CSS

## 📝 License

MIT License - feel free to use and modify!

## 🙋 Support

If you encounter issues:

1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Verify Signal API is running: `docker ps`
3. Check backend logs for errors
4. Check browser console for errors
5. Ensure phone number is registered

## 🎉 Credits

Built using:
- [signal-cli-rest-api](https://github.com/bbernhard/signal-cli-rest-api) by bbernhard
- [signal-cli](https://github.com/AsamK/signal-cli) by AsamK
- React, Node.js, and Express

---

**Happy Messaging! 📱✨**

