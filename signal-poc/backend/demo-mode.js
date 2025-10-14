const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

console.log('=================================');
console.log('Signal PoC Backend - DEMO MODE');
console.log('=================================');
console.log('Running without Signal API');
console.log('Using mock data for demonstration');
console.log('=================================');
console.log('');

// Mock groups data
const mockGroups = [
  {
    id: 'mock-group-1',
    name: 'Project Team',
    members: ['+40751770274', '+40123456789', '+40987654321'],
    memberCount: 3,
    isAdmin: true,
    isMember: true,
    isBlocked: false
  },
  {
    id: 'mock-group-2',
    name: 'Family',
    members: ['+40751770274', '+40111222333'],
    memberCount: 2,
    isAdmin: false,
    isMember: true,
    isBlocked: false
  },
  {
    id: 'mock-group-3',
    name: 'Safe Wallet Alerts',
    members: ['+40751770274', '+40555666777', '+40888999000'],
    memberCount: 3,
    isAdmin: true,
    isMember: true,
    isBlocked: false
  }
];

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    backend: 'running',
    mode: 'demo',
    signalApi: { status: 'mocked' }
  });
});

// Get groups (mock data)
app.get('/api/groups', (req, res) => {
  console.log('Returning mock groups...');
  res.json({
    success: true,
    groups: mockGroups,
    count: mockGroups.length,
    demo: true
  });
});

// Send message (mock - doesn't actually send)
app.post('/api/send', (req, res) => {
  const { groupId, message } = req.body;

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

  const group = mockGroups.find(g => g.id === groupId);
  
  console.log('=== DEMO MESSAGE ===');
  console.log(`To Group: ${group ? group.name : groupId}`);
  console.log(`Message: ${message}`);
  console.log('===================');

  // Simulate delay
  setTimeout(() => {
    res.json({
      success: true,
      message: 'Message sent successfully (DEMO MODE - not actually sent)',
      timestamp: Date.now(),
      demo: true,
      data: {
        groupId,
        groupName: group ? group.name : 'Unknown',
        message
      }
    });
  }, 500);
});

// Get config
app.get('/api/config', (req, res) => {
  res.json({
    signalApiUrl: 'DEMO MODE',
    signalNumberConfigured: true,
    signalNumberMasked: '+407...0274',
    demo: true
  });
});

// Link device (mock)
app.get('/api/link-device', (req, res) => {
  // Return a placeholder QR code image
  res.json({
    success: false,
    error: 'Not available in demo mode',
    hint: 'Connect real Signal API to use device linking'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Demo server running on port ${PORT}`);
  console.log(`📱 Open: http://localhost:3000`);
  console.log('');
  console.log('⚠️  DEMO MODE - Messages won\'t actually send');
  console.log('   This demonstrates the UI and functionality');
  console.log('');
});

