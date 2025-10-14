const express = require('express');
const cors = require('cors');
const axios = require('axios');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Configuration
const SIGNAL_API_URL = process.env.SIGNAL_API_URL || 'http://localhost:8080';
const SIGNAL_NUMBER = process.env.SIGNAL_NUMBER;

// Logging utility
const logError = (context, error) => {
  const errorInfo = {
    timestamp: new Date().toISOString(),
    context,
    message: error.message,
    response: error.response?.data,
    status: error.response?.status
  };
  console.error('ERROR:', JSON.stringify(errorInfo, null, 2));
  return errorInfo;
};

// Health check endpoint
app.get('/api/health', async (req, res) => {
  try {
    const response = await axios.get(`${SIGNAL_API_URL}/v1/health`, {
      timeout: 5000
    });
    res.json({
      status: 'ok',
      backend: 'running',
      signalApi: response.data
    });
  } catch (error) {
    const errorInfo = logError('Health Check', error);
    res.status(500).json({
      status: 'error',
      backend: 'running',
      signalApi: 'unreachable',
      error: errorInfo
    });
  }
});

// Get all groups
app.get('/api/groups', async (req, res) => {
  try {
    if (!SIGNAL_NUMBER) {
      throw new Error('SIGNAL_NUMBER not configured in .env file');
    }

    console.log(`Fetching groups for number: ${SIGNAL_NUMBER}`);
    
    const response = await axios.get(
      `${SIGNAL_API_URL}/v1/groups/${SIGNAL_NUMBER}`,
      { timeout: 10000 }
    );

    console.log('Groups fetched successfully:', response.data);

    // Parse and format groups
    // Signal API returns array directly, not wrapped in .groups
    const groups = Array.isArray(response.data) ? response.data : (response.data.groups || []);
    const formattedGroups = groups.map(group => ({
      id: group.id, // Use full group ID (includes "group." prefix)
      internalId: group.internal_id, // Keep for reference
      name: group.name || 'Unnamed Group',
      members: group.members || [],
      memberCount: (group.members || []).length,
      isAdmin: group.isAdmin || false,
      isMember: group.isMember || false,
      isBlocked: group.isBlocked || false
    }));

    res.json({
      success: true,
      groups: formattedGroups,
      count: formattedGroups.length
    });

  } catch (error) {
    const errorInfo = logError('Fetch Groups', error);
    res.status(error.response?.status || 500).json({
      success: false,
      error: 'Failed to fetch groups',
      details: errorInfo.message,
      hint: !SIGNAL_NUMBER 
        ? 'Configure SIGNAL_NUMBER in .env file' 
        : 'Ensure Signal API is running and number is registered'
    });
  }
});

// Send message to group
app.post('/api/send', async (req, res) => {
  try {
    const { groupId, message } = req.body;

    // Validation
    if (!groupId) {
      return res.status(400).json({
        success: false,
        error: 'Group ID is required'
      });
    }

    if (!message || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Message cannot be empty'
      });
    }

    if (!SIGNAL_NUMBER) {
      throw new Error('SIGNAL_NUMBER not configured in .env file');
    }

    console.log(`Sending message to group: ${groupId}`);
    console.log(`Message: ${message.substring(0, 50)}...`);

    // Send message via Signal API
    // For groups, use recipients array with full group ID (already includes "group." prefix)
    const response = await axios.post(
      `${SIGNAL_API_URL}/v2/send`,
      {
        message: message.trim(),
        number: SIGNAL_NUMBER,
        recipients: [groupId] // Full group ID (e.g., "group.Base64String...")
      },
      {
        timeout: 30000,
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('Message sent successfully:', response.data);

    res.json({
      success: true,
      message: 'Message sent successfully',
      timestamp: response.data.timestamp,
      data: response.data
    });

  } catch (error) {
    const errorInfo = logError('Send Message', error);
    
    let errorMessage = 'Failed to send message';
    let hint = '';

    if (error.response?.status === 404) {
      errorMessage = 'Signal account not found';
      hint = 'Register your number with Signal first';
    } else if (error.response?.status === 400) {
      errorMessage = 'Invalid request';
      hint = 'Check group ID and message format';
    } else if (error.code === 'ECONNREFUSED') {
      errorMessage = 'Cannot connect to Signal API';
      hint = 'Ensure Signal API Docker container is running';
    }

    res.status(error.response?.status || 500).json({
      success: false,
      error: errorMessage,
      details: errorInfo.message,
      hint
    });
  }
});

// Test endpoint - send to specific recipients (for testing)
app.post('/api/send-test', async (req, res) => {
  try {
    const { recipients, message } = req.body;

    if (!recipients || !Array.isArray(recipients) || recipients.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'At least one recipient is required'
      });
    }

    if (!message || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Message cannot be empty'
      });
    }

    if (!SIGNAL_NUMBER) {
      throw new Error('SIGNAL_NUMBER not configured');
    }

    console.log(`Sending test message to: ${recipients.join(', ')}`);

    const response = await axios.post(
      `${SIGNAL_API_URL}/v2/send`,
      {
        message: message.trim(),
        number: SIGNAL_NUMBER,
        recipients
      },
      { timeout: 30000 }
    );

    res.json({
      success: true,
      message: 'Test message sent successfully',
      data: response.data
    });

  } catch (error) {
    const errorInfo = logError('Send Test Message', error);
    res.status(error.response?.status || 500).json({
      success: false,
      error: 'Failed to send test message',
      details: errorInfo.message
    });
  }
});

// Sync with Signal API (receive messages to update groups)
app.post('/api/sync', async (req, res) => {
  try {
    if (!SIGNAL_NUMBER) {
      throw new Error('SIGNAL_NUMBER not configured');
    }

    console.log('Syncing with Signal API...');

    // Call receive endpoint to sync groups and messages
    await axios.get(
      `${SIGNAL_API_URL}/v1/receive/${SIGNAL_NUMBER}`,
      { 
        params: { timeout: 15 },
        timeout: 20000 
      }
    );

    console.log('Sync completed');

    res.json({
      success: true,
      message: 'Synced successfully'
    });

  } catch (error) {
    const errorInfo = logError('Sync', error);
    res.status(error.response?.status || 500).json({
      success: false,
      error: 'Sync failed',
      details: errorInfo.message
    });
  }
});

// Get configuration info (without exposing full phone number)
app.get('/api/config', (req, res) => {
  res.json({
    signalApiUrl: SIGNAL_API_URL,
    signalNumberConfigured: !!SIGNAL_NUMBER,
    signalNumberMasked: SIGNAL_NUMBER 
      ? `${SIGNAL_NUMBER.substring(0, 4)}...${SIGNAL_NUMBER.substring(SIGNAL_NUMBER.length - 4)}`
      : null
  });
});

// Generate QR code for device linking
app.get('/api/link-device', async (req, res) => {
  try {
    const deviceName = req.query.deviceName || 'SignalPoC';
    
    console.log(`Generating QR code for device linking: ${deviceName}`);
    
    const response = await axios.get(
      `${SIGNAL_API_URL}/v1/qrcodelink`,
      {
        params: { device_name: deviceName },
        responseType: 'arraybuffer',
        timeout: 10000
      }
    );

    // Send the QR code image
    res.set('Content-Type', 'image/png');
    res.send(response.data);

  } catch (error) {
    const errorInfo = logError('Generate QR Code', error);
    res.status(error.response?.status || 500).json({
      success: false,
      error: 'Failed to generate QR code',
      details: errorInfo.message,
      hint: 'Make sure Signal API is running'
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  const errorInfo = logError('Unhandled Error', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    details: errorInfo.message
  });
});

// Start server
app.listen(PORT, () => {
  console.log('=================================');
  console.log('Signal PoC Backend Server');
  console.log('=================================');
  console.log(`Server running on port ${PORT}`);
  console.log(`Signal API URL: ${SIGNAL_API_URL}`);
  console.log(`Signal Number Configured: ${!!SIGNAL_NUMBER}`);
  console.log('=================================');
  
  // Verify Signal API connection on startup
  axios.get(`${SIGNAL_API_URL}/v1/health`, { timeout: 5000 })
    .then(() => {
      console.log('✅ Signal API connection successful');
    })
    .catch(() => {
      console.log('⚠️  Warning: Cannot connect to Signal API');
      console.log('   Make sure signal-cli-rest-api is running');
    });
});

