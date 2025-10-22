#!/usr/bin/env node

/**
 * Broadcast script to send Signal messages to multiple phone numbers
 * Usage: node broadcast.js "+1234567890,+9876543210" "Your message here"
 *   OR:  node broadcast.js "+1234567890 +9876543210" "Your message here"
 */

const axios = require('axios');

// Configuration
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:5001';

// Get arguments
const phoneNumbersArg = process.argv[2];
const message = process.argv[3];

// Validation
if (!phoneNumbersArg || !message) {
  console.error('❌ Error: Missing required arguments');
  console.log('\nUsage:');
  console.log('  node broadcast.js "+1234567890,+9876543210" "Your message here"');
  console.log('  OR');
  console.log('  node broadcast.js "+1234567890 +9876543210" "Your message here"');
  console.log('\nExamples:');
  console.log('  node broadcast.js "+40751770274,+12025551234" "Hello everyone!"');
  console.log('  node broadcast.js "+40751770274 +12025551234 +447700900123" "Meeting at 3pm"');
  console.log('\nNote: Phone numbers must include country code (e.g., +1, +40, etc.)');
  console.log('      Separate numbers with comma or space');
  process.exit(1);
}

// Parse phone numbers (split by comma or space)
const phoneNumbers = phoneNumbersArg
  .split(/[,\s]+/)
  .map(num => num.trim())
  .filter(num => num.length > 0);

if (phoneNumbers.length === 0) {
  console.error('❌ Error: No valid phone numbers provided');
  process.exit(1);
}

// Broadcast message
async function broadcastMessage() {
  try {
    console.log('📤 Broadcasting message...');
    console.log(`📞 To ${phoneNumbers.length} recipients:`);
    phoneNumbers.forEach((num, idx) => {
      console.log(`   ${idx + 1}. ${num}`);
    });
    console.log(`💬 Message: ${message}`);
    console.log('');

    const response = await axios.post(`${BACKEND_URL}/api/broadcast`, {
      phoneNumbers,
      message
    }, {
      timeout: 30000
    });

    if (response.data.success) {
      console.log('✅ Message broadcast successfully!');
      console.log(`📊 Sent to ${response.data.recipientCount} recipients`);
      console.log(`🕐 Timestamp: ${response.data.timestamp}`);
      console.log(`\n📱 Recipients:`);
      response.data.recipients.forEach((num, idx) => {
        console.log(`   ${idx + 1}. ${num}`);
      });
    } else {
      console.error('❌ Failed to broadcast message:', response.data.error);
      if (response.data.hint) {
        console.log(`💡 Hint: ${response.data.hint}`);
      }
      process.exit(1);
    }

  } catch (error) {
    console.error('❌ Error broadcasting message:');
    
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

broadcastMessage();

