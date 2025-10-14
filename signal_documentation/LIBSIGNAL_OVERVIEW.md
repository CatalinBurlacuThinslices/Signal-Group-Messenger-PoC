# Libsignal Protocol Library Overview

Comprehensive guide to the Signal Protocol library for building custom secure messaging systems.

---

## Overview

libsignal is the cryptographic protocol library that powers Signal. It provides end-to-end encryption for messaging applications but requires significant implementation effort.

**Repository:** https://github.com/signalapp/libsignal

---

## What is libsignal?

libsignal implements the Signal Protocol (formerly known as TextSecure Protocol), which provides:

- **End-to-end encryption** - Messages encrypted on sender, decrypted only by recipient
- **Forward secrecy** - Compromised keys don't decrypt past messages
- **Deniable authentication** - Cryptographically sound but recipients can't prove authorship
- **Asynchronous messaging** - Send messages to offline recipients

---

## Key Concepts

### 1. Signal Protocol Components

```
┌─────────────────────────────────────────┐
│         Signal Protocol                 │
├─────────────────────────────────────────┤
│  X3DH (Extended Triple Diffie-Hellman) │
│  - Initial key agreement                │
│  - Identity keys                        │
│  - Signed pre-keys                      │
│  - One-time pre-keys                    │
├─────────────────────────────────────────┤
│  Double Ratchet Algorithm               │
│  - Key derivation                       │
│  - Message encryption                   │
│  - Forward secrecy                      │
├─────────────────────────────────────────┤
│  Sesame Algorithm (optional)            │
│  - Sealed sender                        │
│  - Metadata protection                  │
└─────────────────────────────────────────┘
```

### 2. Key Types

**Identity Key Pair**
- Long-term key pair
- Identifies the user
- Used for authentication

**Signed Pre-Key**
- Medium-term key pair
- Rotated periodically
- Signed by identity key

**One-Time Pre-Keys**
- Single-use key pairs
- Provide forward secrecy
- Replenished regularly

**Ephemeral Keys**
- Session-specific keys
- Generated per message
- Deleted after use

---

## When to Use libsignal

### ✅ Good Use Cases

1. **Building a Custom Messaging Platform**
   - Your own messaging infrastructure
   - Custom client applications
   - Proprietary messaging system

2. **Research and Education**
   - Studying cryptographic protocols
   - Academic projects
   - Security research

3. **Embedded Systems**
   - IoT device communication
   - Specialized hardware
   - Proprietary networks

4. **High-Security Applications**
   - Government communications
   - Healthcare systems
   - Financial services

### ❌ NOT Suitable For

1. **Messaging Real Signal Users**
   - Cannot communicate with Signal app users
   - Requires separate infrastructure
   - Different network entirely

2. **Quick Prototypes**
   - Weeks/months of development
   - Complex implementation
   - Steep learning curve

3. **Standard Notifications**
   - Overkill for simple alerts
   - Use signal-cli-rest-api instead
   - Much simpler alternatives exist

4. **Small Teams**
   - Requires cryptography expertise
   - Ongoing maintenance burden
   - Security audit needs

---

## Architecture

### Complete System Requirements

To build a messaging system with libsignal, you need:

```
┌─────────────────────────────────────────┐
│           Client Application            │
│  - UI/UX                                │
│  - Message composition                  │
│  - libsignal integration               │
└──────────────┬──────────────────────────┘
               │
               │ HTTPS/WebSocket
               │
┌──────────────▼──────────────────────────┐
│           Server Infrastructure         │
│  - User registration                    │
│  - Key distribution                     │
│  - Message relay                        │
│  - Pre-key storage                      │
│  - Push notifications                   │
└──────────────┬──────────────────────────┘
               │
               │ Database
               │
┌──────────────▼──────────────────────────┐
│           Data Storage                  │
│  - User accounts                        │
│  - Pre-keys                             │
│  - Metadata                             │
└─────────────────────────────────────────┘
```

---

## Implementation Overview

### Language Support

libsignal is available for:
- **Rust** (primary implementation)
- **Java** (Android)
- **Swift** (iOS)
- **TypeScript** (Node.js)
- **Python** (via FFI bindings)

### Basic Flow

#### 1. Account Creation

```python
# Pseudo-code - not actual API
from signal_protocol import IdentityKeyPair, PreKeyBundle

# Generate identity key pair
identity_key_pair = IdentityKeyPair.generate()

# Generate signed pre-key
signed_pre_key = SignedPreKeyPair.generate(identity_key_pair)

# Generate one-time pre-keys
one_time_keys = [OneTimePreKey.generate() for _ in range(100)]

# Upload to server
server.register_user(
    user_id="alice@example.com",
    identity_key=identity_key_pair.public_key,
    signed_pre_key=signed_pre_key,
    one_time_keys=one_time_keys
)
```

#### 2. Starting a Conversation

```python
# Alice wants to message Bob
# Fetch Bob's pre-key bundle from server
bob_bundle = server.get_pre_key_bundle("bob@example.com")

# Create session
session = SessionBuilder(alice_store, bob_address)
session.process_pre_key_bundle(bob_bundle)

# Send first message
ciphertext = session_cipher.encrypt("Hello Bob!")
server.send_message(
    to="bob@example.com",
    from="alice@example.com",
    message=ciphertext
)
```

#### 3. Receiving a Message

```python
# Bob receives message from Alice
encrypted_message = server.receive_message("bob@example.com")

# Decrypt
session_cipher = SessionCipher(bob_store, alice_address)
plaintext = session_cipher.decrypt(encrypted_message)
print(plaintext)  # "Hello Bob!"
```

---

## Key Storage

### Required Storage Interface

You must implement secure storage for:

```python
class SignalProtocolStore:
    """Interface for storing Signal Protocol data"""
    
    def get_identity_key_pair(self):
        """Get local identity key pair"""
        pass
    
    def get_local_registration_id(self):
        """Get local registration ID"""
        pass
    
    def save_identity(self, address, identity_key):
        """Save identity key for address"""
        pass
    
    def is_trusted_identity(self, address, identity_key):
        """Check if identity key is trusted"""
        pass
    
    def load_session(self, address):
        """Load session for address"""
        pass
    
    def store_session(self, address, record):
        """Store session record"""
        pass
    
    def load_pre_key(self, pre_key_id):
        """Load pre-key by ID"""
        pass
    
    def store_pre_key(self, pre_key_id, record):
        """Store pre-key"""
        pass
    
    def load_signed_pre_key(self, signed_pre_key_id):
        """Load signed pre-key"""
        pass
    
    def store_signed_pre_key(self, signed_pre_key_id, record):
        """Store signed pre-key"""
        pass
```

---

## Server Requirements

### Minimal Server Features

Your server must provide:

1. **User Registration**
   ```
   POST /register
   {
     "user_id": "alice@example.com",
     "identity_key": "base64_encoded",
     "device_id": 1
   }
   ```

2. **Pre-Key Upload**
   ```
   POST /keys
   {
     "user_id": "alice@example.com",
     "signed_pre_key": {...},
     "one_time_keys": [{...}, ...]
   }
   ```

3. **Pre-Key Retrieval**
   ```
   GET /keys/bob@example.com/device/1
   Response:
   {
     "identity_key": "...",
     "signed_pre_key": {...},
     "one_time_key": {...}
   }
   ```

4. **Message Relay**
   ```
   POST /messages
   {
     "to": "bob@example.com",
     "from": "alice@example.com",
     "message": "encrypted_content"
   }
   ```

5. **Message Retrieval**
   ```
   GET /messages/bob@example.com
   Response:
   [
     {"from": "alice@example.com", "message": "..."},
     ...
   ]
   ```

---

## Security Considerations

### Critical Security Requirements

1. **Key Storage**
   - Encrypt keys at rest
   - Use secure key derivation (PBKDF2, Argon2)
   - Hardware security modules for production

2. **Transport Security**
   - TLS 1.3 for all communications
   - Certificate pinning
   - Perfect forward secrecy

3. **Server Trust**
   - Server cannot read messages
   - Server can see metadata (who talks to whom)
   - Use sealed sender to hide metadata

4. **Key Rotation**
   - Rotate signed pre-keys regularly
   - Replenish one-time pre-keys
   - Handle key exhaustion

5. **Device Verification**
   - Implement safety numbers
   - Allow user verification
   - Warn on key changes

---

## Example: Minimal Implementation

### Python Example (Conceptual)

```python
from signal_protocol import (
    IdentityKeyPair,
    SessionBuilder,
    SessionCipher,
    PreKeyBundle
)

class SimpleSignalClient:
    """Minimal Signal Protocol client"""
    
    def __init__(self, user_id, storage):
        self.user_id = user_id
        self.storage = storage
        
        # Generate or load identity
        if not storage.has_identity():
            identity = IdentityKeyPair.generate()
            storage.save_identity(identity)
        else:
            identity = storage.load_identity()
        
        self.identity = identity
    
    def send_message(self, recipient_id, message_text):
        """Send encrypted message"""
        # Get recipient's pre-key bundle
        bundle = self._fetch_pre_key_bundle(recipient_id)
        
        # Build session
        session = SessionBuilder(
            self.storage,
            recipient_id
        )
        session.process_pre_key_bundle(bundle)
        
        # Encrypt message
        cipher = SessionCipher(self.storage, recipient_id)
        ciphertext = cipher.encrypt(message_text.encode())
        
        # Send to server
        self._send_to_server(recipient_id, ciphertext)
    
    def receive_message(self, sender_id, ciphertext):
        """Decrypt received message"""
        cipher = SessionCipher(self.storage, sender_id)
        plaintext = cipher.decrypt(ciphertext)
        return plaintext.decode()
    
    def _fetch_pre_key_bundle(self, user_id):
        """Fetch pre-key bundle from server"""
        # Implementation depends on your server
        pass
    
    def _send_to_server(self, recipient_id, ciphertext):
        """Send message via server"""
        # Implementation depends on your server
        pass


# Usage
storage = MySignalProtocolStore()
client = SimpleSignalClient("alice@example.com", storage)

# Send message
client.send_message("bob@example.com", "Hello Bob!")

# Receive message
plaintext = client.receive_message("bob@example.com", encrypted_data)
```

---

## Development Timeline

### Realistic Estimates

**Minimal Viable Product:**
- Research and planning: 1-2 weeks
- Core protocol integration: 2-4 weeks
- Server implementation: 2-3 weeks
- Client application: 4-6 weeks
- Testing and security review: 2-4 weeks
- **Total: 3-5 months**

**Production-Ready System:**
- MVP timeline: 3-5 months
- Multi-device support: 1-2 months
- Group messaging: 2-3 months
- Media attachments: 1-2 months
- Security hardening: 2-3 months
- **Total: 9-15 months**

---

## Cost Considerations

### Development Costs

- **Engineering Team:** 2-3 experienced developers
- **Security Expertise:** Cryptography specialist
- **Infrastructure:** Servers, databases, CDN
- **Security Audit:** $50,000-$200,000+
- **Ongoing Maintenance:** 1-2 developers full-time

### Operational Costs

- **Servers:** $500-$5,000+/month
- **Database:** $200-$2,000+/month
- **CDN:** $100-$1,000+/month
- **Monitoring:** $100-$500+/month
- **Security:** Ongoing audits and updates

---

## Comparison to Alternatives

| Aspect | libsignal | signal-cli-rest-api | signal-cli |
|--------|-----------|---------------------|-----------|
| **Development Time** | Months | Hours | Days |
| **Real Signal Users** | ❌ No | ✅ Yes | ✅ Yes |
| **Cryptography Expertise** | Required | Not needed | Not needed |
| **Custom Network** | ✅ Yes | ❌ No | ❌ No |
| **Server Infrastructure** | Build yourself | Provided | Provided |
| **Security Audits** | Required | Not needed | Not needed |
| **Cost** | $$$$ | $ | $ |

---

## Recommendations

### For Safe Wallet Notifications

**DO NOT use libsignal** because:
1. ❌ Cannot message real Signal users
2. ❌ Months of development time
3. ❌ Requires cryptography expertise
4. ❌ Ongoing maintenance burden
5. ❌ Overkill for notifications

**INSTEAD, use signal-cli-rest-api:**
1. ✅ Works with real Signal
2. ✅ Setup in hours, not months
3. ✅ No cryptography expertise needed
4. ✅ Minimal maintenance
5. ✅ Perfect for notifications

### When libsignal Makes Sense

Use libsignal ONLY if:
- Building your own messaging platform
- Need custom crypto implementation
- Cannot use Signal's network
- Have cryptography expertise in-house
- Have 6-12+ months for development
- Budget for security audits

---

## Learning Resources

### Official Documentation
- libsignal Repository: https://github.com/signalapp/libsignal
- Signal Protocol Specs: https://signal.org/docs/
- Cryptographic Protocols: https://signal.org/blog/signal-protocol/

### Educational Resources
- "The Signal Protocol": https://signal.org/docs/specifications/doubleratchet/
- "X3DH Key Agreement": https://signal.org/docs/specifications/x3dh/
- "XEdDSA Signatures": https://signal.org/docs/specifications/xeddsa/

### Implementation Examples
- Signal Android: https://github.com/signalapp/Signal-Android
- Signal iOS: https://github.com/signalapp/Signal-iOS
- Signal Desktop: https://github.com/signalapp/Signal-Desktop

---

## Conclusion

While libsignal is powerful and provides state-of-the-art encryption, it's **not recommended** for typical notification use cases like Safe wallet alerts.

**For 99% of use cases, use [signal-cli-rest-api](./SIGNAL_CLI_REST_API.md) instead.**

Only consider libsignal if you're building a complete messaging platform from scratch and have the expertise, time, and budget to do so properly.

---

## Next Steps

If you're still interested in libsignal:
1. Read the official documentation
2. Study the Signal protocol specifications
3. Review existing implementations
4. Plan for 6-12 month timeline
5. Budget for security audits

If you want to implement notifications:
1. Use [signal-cli-rest-api](./SIGNAL_CLI_REST_API.md)
2. Follow the [Implementation Guide](./IMPLEMENTATION_GUIDE.md)
3. Start sending notifications today

