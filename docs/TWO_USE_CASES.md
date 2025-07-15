# Two Use Cases for Credential Code

Credential Code supports two distinct use cases that share the same source of truth:

## Source of Truth

The source of truth consists of two files:
1. **`.credential-code/credentials.json`** - Plain text credentials
2. **`.credential-code/encryption-key.txt`** - Encryption key (created if doesn't exist, reused if exists)

## Use Case 1: Fixed Applications (Viewers)

For applications where credentials are fixed at compile time (mobile apps, desktop viewers, etc.):

```bash
# Generate encrypted code only (no .creds file)
credential-code generate --language swift --no-generate-creds

# Creates: Generated/Credentials.swift
```

**Example: iOS Magazine Viewer**
```swift
// Credentials are compiled into the app
try Credentials.loadKey(from: "encryption-key.txt")
let apiKey = try Credentials.get(.API_KEY)
```

**Benefits:**
- Credentials are encrypted in the binary
- No configuration files needed at runtime
- Simple deployment

## Use Case 2: Backend/Configurable Systems

For backend services that need runtime configuration:

```bash
# Generate .creds file (default behavior includes both code and .creds)
credential-code generate

# Or generate only .creds file
credential-code generate --no-generate-code --creds-output backend/prod.creds

# Creates: 
# - Generated/credentials.creds (encrypted credentials)
# - Uses existing .credential-code/encryption-key.txt
```

**Example: Multi-tenant Backend Service**

Using the provided utility libraries (see `/utilities` directory):

```javascript
// Node.js backend with utility library
const { CredentialDecryptor } = require('credential-code-utility');

// Initialize decryptor with key from environment or file
const decryptor = new CredentialDecryptor(
  process.env.CREDENTIAL_KEY || '.credential-code/encryption-key.txt'
);

// Load credentials for specific client/environment
const credentials = decryptor.loadCredentials('client1.creds');
const apiKey = credentials.API_KEY;
```

Or for Python backends:

```python
# Python backend with utility library
from credential_code_utility import CredentialDecryptor

# Key from environment variable (common in containers)
decryptor = CredentialDecryptor(os.environ['CREDENTIAL_KEY'])

# Load credentials at runtime
credentials = decryptor.load_credentials('prod.creds')
database_url = credentials['DATABASE_URL']
```

**Benefits:**
- Different credentials per environment/client
- Easy to update without recompiling
- Key and credentials can be stored separately
- Utility libraries handle all decryption complexity

## Generating Both Formats

Since both use cases often exist in the same ecosystem, generating both is now the default:

```bash
# Default: generates both code and .creds file
credential-code generate --language swift

# Creates:
# - Generated/Credentials.swift (for app)
# - Generated/credentials.creds (for backend)
# - Uses same encryption key for both
```

## Example Workflow

### 1. Initialize with credentials
```bash
credential-code init

# Edit .credential-code/credentials.json
{
  "API_KEY": "sk-production-key-123",
  "DATABASE_URL": "postgres://prod-server/db"
}
```

### 2. Generate for viewer app
```bash
credential-code generate --language swift --output iOS/Credentials.swift --no-generate-creds
```

### 3. Generate for backend
```bash
credential-code generate --creds-output backend/prod.creds --no-generate-code
```

### 4. Deploy
- **App**: Include `Credentials.swift` in build, embed key or load from bundle
- **Backend**: Deploy `prod.creds` + `encryption-key.txt` via secure configuration
  - Use provided utility libraries from `/utilities` directory for easy decryption
  - Store key in environment variables or secret managers
  - Mount `.creds` files as config volumes in containers

## Security Considerations

### Key Management
- The encryption key (`encryption-key.txt`) is reused across generations
- Store the key securely (environment variables, secrets manager, etc.)
- Never commit the key to version control

### Deployment Patterns

**Pattern 1: Embedded Key (Default for Code)**
```bash
# Self-contained code with embedded key
credential-code generate
```

**Pattern 2: External Key File (Swift Only)**
```bash
# Swift code with separate key file
credential-code generate --external-key
```

**Pattern 3: External Key Source (Swift Only)**
```bash
# Key as source code (compiled separately)
credential-code generate --external-key-source
```

## File Formats

### credentials.creds
```json
{
  "version": "1.0",
  "algorithm": "AES-256-GCM",
  "credentials": {
    "API_KEY": {
      "data": "base64-encrypted-data",
      "nonce": "base64-nonce",
      "tag": "base64-tag"
    }
  }
}
```

### encryption-key.txt
```
qAplK3wRHndckPrgKLqn/ai+fzj5CBhL/l+xPJpgETA=
```

Plain base64-encoded 256-bit key.