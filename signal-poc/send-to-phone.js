#!/usr/bin/env node

/**
 * Standalone script to send Signal messages to phone numbers
 * Usage: node send-to-phone.js "+1234567890" "Your message here"
 */

const axios = require('axios');

// Configuration
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:5001';

// Get arguments
const phoneNumber = process.argv[2];
const message = process.argv[3];

// Validation
if (!phoneNumber || !message) {
  console.error('❌ Error: Missing required arguments');
  console.log('\nUsage:');
  console.log('  node send-to-phone.js "+1234567890" "Your message here"');
  console.log('\nExample:');
  console.log('  node send-to-phone.js "+40751770274" "Hello from Signal PoC!"');
  console.log('\nNote: Phone number must include country code (e.g., +1, +40, etc.)');
  process.exit(1);
}

// Send message
async function sendMessage() {
  try {
    console.log('📤 Sending message...');
    console.log(`📞 To: ${phoneNumber}`);
    console.log(`💬 Message: ${message}`);
    console.log('');

    const response = await axios.post(`${BACKEND_URL}/api/send-to-phone`, {
      phoneNumber,
      message
    }, {
      timeout: 30000
    });

    if (response.data.success) {
      console.log('✅ Message sent successfully!');
      console.log(`🕐 Timestamp: ${response.data.timestamp}`);
      console.log(`📱 Recipient: ${response.data.recipient}`);
    } else {
      console.error('❌ Failed to send message:', response.data.error);
      if (response.data.hint) {
        console.log(`💡 Hint: ${response.data.hint}`);
      }
      process.exit(1);
    }

  } catch (error) {
    console.error('❌ Error sending message:');
    
    if (error.response?.data) {
      console.error(`   ${error.response.data.error || error.message}`);
      if (error.response.data.details) {
        console.error(`   Details: ${error.response.data.details}`);
      }
      if (error.response.data.hint) {
        console.log(`💡 Hint: ${error.response.data.hint}`);
      }
    } else if (error.code === 'ECONNREFUSED') {
      console.error('   Cannot connect to backend server');
      console.log(`💡 Hint: Make sure backend is running on ${BACKEND_URL}`);
    } else {
      console.error(`   ${error.message}`);
    }
    
    process.exit(1);
  }
}

sendMessage();

