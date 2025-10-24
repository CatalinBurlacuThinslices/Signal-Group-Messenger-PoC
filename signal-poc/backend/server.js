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

// Send message to phone number(s)
app.post('/api/send-to-phone', async (req, res) => {
  try {
    const { phoneNumber, message } = req.body;

    // Validation
    if (!phoneNumber) {
      return res.status(400).json({
        success: false,
        error: 'Phone number is required'
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

    // Format phone number if needed (ensure it starts with +)
    const formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`;

    console.log(`Sending message to phone: ${formattedPhone}`);
    console.log(`Message: ${message.substring(0, 50)}...`);

    // Send message via Signal API
    const response = await axios.post(
      `${SIGNAL_API_URL}/v2/send`,
      {
        message: message.trim(),
        number: SIGNAL_NUMBER,
        recipients: [formattedPhone]
      },
      {
        timeout: 30000,
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('Message sent successfully to phone:', response.data);

    res.json({
      success: true,
      message: 'Message sent successfully to phone number',
      timestamp: response.data.timestamp,
      recipient: formattedPhone,
      data: response.data
    });

  } catch (error) {
    const errorInfo = logError('Send Message to Phone', error);
    
    let errorMessage = 'Failed to send message to phone number';
    let hint = '';

    if (error.response?.status === 404) {
      errorMessage = 'Signal account not found';
      hint = 'Make sure your number is registered and the recipient has Signal';
    } else if (error.response?.status === 400) {
      errorMessage = 'Invalid request';
      hint = 'Check phone number format (should include country code, e.g., +1234567890)';
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

// Broadcast message to multiple phone numbers
app.post('/api/broadcast', async (req, res) => {
  try {
    const { phoneNumbers, message } = req.body;

    // Validation
    if (!phoneNumbers || !Array.isArray(phoneNumbers) || phoneNumbers.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'At least one phone number is required (phoneNumbers array)'
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

    // Format all phone numbers (ensure they start with +)
    const formattedPhones = phoneNumbers.map(phone => 
      phone.startsWith('+') ? phone : `+${phone}`
    );

    console.log(`Broadcasting message to ${formattedPhones.length} recipients`);
    console.log(`Recipients: ${formattedPhones.join(', ')}`);
    console.log(`Message: ${message.substring(0, 50)}...`);

    // Send message via Signal API to all recipients
    const response = await axios.post(
      `${SIGNAL_API_URL}/v2/send`,
      {
        message: message.trim(),
        number: SIGNAL_NUMBER,
        recipients: formattedPhones
      },
      {
        timeout: 30000,
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('Broadcast message sent successfully:', response.data);

    res.json({
      success: true,
      message: `Message broadcast to ${formattedPhones.length} recipients`,
      timestamp: response.data.timestamp,
      recipients: formattedPhones,
      recipientCount: formattedPhones.length,
      data: response.data
    });

  } catch (error) {
    const errorInfo = logError('Broadcast Message', error);
    
    let errorMessage = 'Failed to broadcast message';
    let hint = '';

    if (error.response?.status === 404) {
      errorMessage = 'Signal account not found';
      hint = 'Make sure your number is registered and recipients have Signal';
    } else if (error.response?.status === 400) {
      errorMessage = 'Invalid request';
      hint = 'Check phone number formats (should include country code, e.g., +1234567890)';
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

// Update Signal profile (name, about, emoji)
app.put('/api/profile', async (req, res) => {
  try {
    const { name, about, emoji, avatar } = req.body;

    // Validation
    if (!name || name.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Profile name is required'
      });
    }

    if (!SIGNAL_NUMBER) {
      throw new Error('SIGNAL_NUMBER not configured in .env file');
    }

    console.log(`Updating profile for: ${SIGNAL_NUMBER}`);
    console.log(`New name: ${name}`);

    // Build profile update request
    const profileData = {
      name: name.trim()
    };

    if (about) profileData.about = about.trim();
    if (emoji) profileData.emoji = emoji.trim();
    if (avatar) profileData.avatar = avatar;

    // Update profile via Signal API
    const response = await axios.put(
      `${SIGNAL_API_URL}/v1/profiles/${SIGNAL_NUMBER}`,
      profileData,
      {
        timeout: 10000,
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('Profile updated successfully');

    res.json({
      success: true,
      message: 'Profile updated successfully',
      profile: profileData
    });

  } catch (error) {
    const errorInfo = logError('Update Profile', error);
    
    let errorMessage = 'Failed to update profile';
    let hint = '';

    if (error.response?.status === 404) {
      errorMessage = 'Signal account not found';
      hint = 'Make sure your number is registered or linked';
    } else if (error.response?.status === 400) {
      errorMessage = 'Invalid request';
      hint = 'Check profile data format';
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

