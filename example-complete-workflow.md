# Complete Workflow Example

This example shows the complete workflow for both use cases using the same source of truth.

## 1. Setup Source of Truth

```bash
# Initialize
credential-code init

# Edit credentials
cat > .credential-code/credentials.json << EOF
{
  "API_KEY": "sk-production-api-key-123",
  "DATABASE_URL": "postgres://prod@db.example.com:5432/myapp",
  "JWT_SECRET": "super-secret-jwt-signing-key",
  "STRIPE_KEY": "sk_live_abcdef123456"
}
EOF
```

## 2. Generate for Fixed App (iOS Viewer)

```bash
# Generate Swift code for iOS app (default includes .creds)
credential-code generate --language swift --output iOS/Sources/Credentials.swift --no-generate-creds

# This creates:
# - iOS/Sources/Credentials.swift (encrypted credentials)
# - .credential-code/encryption-key.txt (if not exists)
```

### iOS App Usage
```swift
// AppDelegate.swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Load encryption key from bundle
        if let keyPath = Bundle.main.path(forResource: "encryption-key", ofType: "txt") {
            try? Credentials.loadKey(from: keyPath)
        }
        
        return true
    }
}

// ApiService.swift
class ApiService {
    func makeRequest() {
        guard let apiKey = try? Credentials.get(.API_KEY) else { return }
        
        var request = URLRequest(url: URL(string: "https://api.example.com/data")!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        // Make request...
    }
}
```

## 3. Generate for Backend Service

```bash
# Generate .creds file for backend (default behavior)
credential-code generate --creds-output backend/prod.creds --no-generate-code

# Or generate both code and .creds (default)
credential-code generate --creds-output backend/prod.creds

# This creates:
# - backend/prod.creds (encrypted credentials in JSON format)
# - Uses existing .credential-code/encryption-key.txt
```

### Backend Usage (Node.js)
```javascript
// credentialService.js
const crypto = require('crypto');
const fs = require('fs');

class CredentialService {
    constructor(keyPath, credsPath) {
        this.key = Buffer.from(
            fs.readFileSync(keyPath, 'utf8').trim(), 
            'base64'
        );
        this.creds = JSON.parse(fs.readFileSync(credsPath, 'utf8'));
    }
    
    decrypt(credentialKey) {
        const encrypted = this.creds.credentials[credentialKey];
        if (!encrypted) throw new Error(`Unknown credential: ${credentialKey}`);
        
        const decipher = crypto.createDecipheriv(
            'aes-256-gcm', 
            this.key, 
            Buffer.from(encrypted.nonce, 'base64')
        );
        decipher.setAuthTag(Buffer.from(encrypted.tag, 'base64'));
        
        const decrypted = Buffer.concat([
            decipher.update(Buffer.from(encrypted.data, 'base64')),
            decipher.final()
        ]);
        
        return decrypted.toString('utf8');
    }
}

// Usage
const creds = new CredentialService(
    process.env.KEY_PATH || '/secure/encryption-key.txt',
    process.env.CREDS_PATH || '/app/config/prod.creds'
);

const apiKey = creds.decrypt('API_KEY');
const dbUrl = creds.decrypt('DATABASE_URL');
```

## 4. Generate Both Together

For ecosystems where both apps and backends need the same credentials:

```bash
# Generate both formats in one command (default behavior)
credential-code generate --language swift \
  --output mobile/Credentials.swift \
  --creds-output backend/credentials.creds

# Creates:
# - mobile/Credentials.swift (for iOS/macOS apps)
# - backend/credentials.creds (for backend services)
# - Both use the same encryption key
```

## 5. Deployment

### iOS App Deployment
1. Include `Credentials.swift` in Xcode project
2. Add `encryption-key.txt` to app bundle (never in source control)
3. Build and distribute through App Store

### Backend Deployment
1. Deploy `credentials.creds` with your application
2. Store `encryption-key.txt` in secure location:
   - Environment variable
   - AWS Secrets Manager
   - Kubernetes Secret
   - Docker secret

### Example: Docker Deployment
```dockerfile
# Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Mount secrets at runtime, don't bake into image
# docker run -v /secure/keys:/keys -v /secure/creds:/creds myapp
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: .
    secrets:
      - encryption_key
      - credentials
    environment:
      KEY_PATH: /run/secrets/encryption_key
      CREDS_PATH: /run/secrets/credentials

secrets:
  encryption_key:
    file: ./secrets/encryption-key.txt
  credentials:
    file: ./backend/prod.creds
```

## 6. Key Rotation

When you need to rotate credentials:

```bash
# 1. Update credentials
vim .credential-code/credentials.json

# 2. Regenerate all formats (uses same encryption key)
credential-code generate --language swift --output iOS/Sources/Credentials.swift --no-generate-creds
credential-code generate --creds-output backend/prod.creds

# 3. Deploy updates to both app and backend
```

## Security Notes

1. **Never commit** `.credential-code/` directory
2. **Never commit** `encryption-key.txt`
3. **Never commit** `*.creds` files
4. Store encryption key securely and separately from credentials
5. Use different credentials for dev/staging/production
6. Rotate credentials regularly
7. Monitor credential usage for anomalies