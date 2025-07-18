# External Key Usage Guide

This guide explains how to use the external key feature for enhanced security in credential management.

## Overview

While Credential Code uses embedded keys by default for source code generation, all languages support an optional external key mode for enhanced security scenarios where you want to keep the key separate from the code.

**For backend services and runtime configuration**, see the utility libraries in `/utilities` directory which provide ready-to-use decryption code for `.creds` files.

### When to Use External Keys
- When you need to rotate keys without recompiling
- For stricter security requirements
- When the same key needs to be shared across multiple builds

### Key Modes

#### 1. Plain Text Key File (Default)
The default mode stores the key as a base64 string in `.credential-code/encryption-key.txt`:
- Key is automatically created if it doesn't exist
- Key is reused across builds for consistent encryption
- Plain text format for easy copying and manual use
- Key is displayed when first generated

#### 2. Source Code Key (`--external-key-source`)
Generates the key as source code:
- **Generated code file** - Contains only encrypted credentials (safe to commit)  
- **Key source file** - Contains the decryption key as source code (never commit this!)

## Generating with External Key

### External Key Mode
```bash
# Generate code with external key file (all languages)
credential-code generate --external-key
# Creates:
# - Generated/Credentials.swift (requires external key)
# - Generated/credentials.creds (also uses external key)
# - .credential-code/encryption-key.txt

# Generate with custom key file name
credential-code generate --external-key --key-file my-secret-key.txt

# External key without .creds file
credential-code generate --external-key --no-generate-creds
```

### Source Code Key
```bash
# Generate with default key source file name (Generated/CredentialKey.swift)
credential-code generate --external-key-source

# Generate with custom key source file name
credential-code generate --external-key-source --key-source-output Keys/MyKey.swift
```

## Key File Formats

### Plain Text Format (Default)

The default key file `.credential-code/encryption-key.txt` contains just the base64-encoded key:

```
H3bhCcgWg5qhEg21AqIAp17Tt5xiwZJbk7eGHG0K1nU=
```

- Simple base64 string (no JSON wrapper)
- 256-bit encryption key
- Easy to copy and paste
- Compatible with environment variables

### Source Code Format (--external-key-source)

Swift example:
```swift
import Foundation

struct CredentialKeyProvider {
    static let key = Data(base64Encoded: "H3bhCcgWg5qhEg21AqIAp17Tt5xiwZJbk7eGHG0K1nU=")!
}
```

## Using the Key in Your Application

### Swift

#### With Source Code Key (--external-key-source)

When using source code keys, simply compile both files together:

```bash
# Compile your app with both files
swiftc MyApp.swift Generated/Credentials.swift Generated/CredentialKey.swift
```

The key is automatically available:
```swift
// No initialization needed - the key is provided by CredentialKeyProvider
let apiKey = try Credentials.get(.API_KEY)
print("API Key: \(apiKey)")
```

#### With Plain Text Key File (Default)

```swift
import Foundation

// Method 1: Load from default location
do {
    try Credentials.loadKey(from: ".credential-code/encryption-key.txt")
    let apiKey = try Credentials.get(.API_KEY)
    print("API Key: \(apiKey)")
} catch {
    print("Error: \(error)")
}

// Method 2: Initialize with key string
let keyString = try String(contentsOfFile: ".credential-code/encryption-key.txt")
    .trimmingCharacters(in: .whitespacesAndNewlines)
try Credentials.initialize(with: keyString)

// Method 3: From environment variable
if let base64Key = ProcessInfo.processInfo.environment["CREDENTIAL_KEY"] {
    try Credentials.initialize(with: base64Key)
}
```

### Kotlin

```kotlin
// Method 1: Load from default location
try {
    Credentials.loadKey(".credential-code/encryption-key.txt")
    val apiKey = Credentials.get(CredentialKey.API_KEY)
    println("API Key: $apiKey")
} catch (e: Exception) {
    println("Failed to load credentials: ${e.message}")
}

// Method 2: Initialize with base64 key string
val keyString = "H3bhCcgWg5qhEg21AqIAp17Tt5xiwZJbk7eGHG0K1nU="
Credentials.initialize(keyString)

// Method 3: Initialize with raw bytes
val keyData = Base64.getDecoder().decode(keyString)
Credentials.initialize(keyData)
```

Additional dependencies for external key mode:
- `org.json:json` (for JSON key file parsing)

### Java

```java
// Method 1: Load from default location
try {
    Credentials.loadKey(".credential-code/encryption-key.txt");
    String apiKey = Credentials.get(CredentialKey.API_KEY);
    System.out.println("API Key: " + apiKey);
} catch (Exception e) {
    System.err.println("Failed to load credentials: " + e.getMessage());
}

// Method 2: Initialize with base64 key string
String keyString = "H3bhCcgWg5qhEg21AqIAp17Tt5xiwZJbk7eGHG0K1nU=";
Credentials.initialize(keyString);

// Method 3: Initialize with raw bytes
byte[] keyData = Base64.getDecoder().decode(keyString);
Credentials.initialize(keyData);
```

Additional dependencies for external key mode:
- `com.fasterxml.jackson.core:jackson-databind` (for JSON key file parsing)

### Python

```python
# Method 1: Load from default location
try:
    Credentials.load_key(".credential-code/encryption-key.txt")
    api_key = Credentials.get(CredentialKey.API_KEY)
    print(f"API Key: {api_key}")
except CredentialError as e:
    print(f"Failed to load credentials: {e}")

# Method 2: Initialize with base64 key string
key_string = "H3bhCcgWg5qhEg21AqIAp17Tt5xiwZJbk7eGHG0K1nU="
Credentials.initialize_base64(key_string)

# Method 3: Initialize with raw bytes
import base64
key_data = base64.b64decode(key_string)
Credentials.initialize(key_data)

# Method 4: Using convenience functions
from credentials import load_key, get_credential
load_key(".credential-code/encryption-key.txt")
api_key = get_credential(CredentialKey.API_KEY)
```

### C++

```cpp
// Method 1: Load from default location
try {
    Credentials::loadKey(".credential-code/encryption-key.txt");
    std::string apiKey = Credentials::get(CredentialKey::API_KEY);
    std::cout << "API Key: " << apiKey << std::endl;
} catch (const CredentialException& e) {
    std::cerr << "Failed to load credentials: " << e.what() << std::endl;
}

// Method 2: Initialize with base64 key string
std::string keyString = "H3bhCcgWg5qhEg21AqIAp17Tt5xiwZJbk7eGHG0K1nU=";
Credentials::initialize(keyString);

// Method 3: Initialize with raw bytes
std::vector<uint8_t> keyData = base64Decode(keyString);
Credentials::initialize(keyData);
```

Additional dependencies for external key mode:
- `nlohmann/json` (for JSON key file parsing)
- OpenSSL (already required for encryption)

## Source Code Key Benefits

Using source code keys (`--external-key-source`) offers several advantages:

1. **Everything is Code**: No JSON files to manage, everything is source code
2. **Type Safety**: Compiler ensures the key provider exists at compile time
3. **Build Integration**: Easy to generate key files during CI/CD
4. **IDE Support**: Full code completion and type checking
5. **Simple Distribution**: Just include another source file in your build

### Example Workflows

#### Development vs Production Keys
```bash
# Development
cp Keys/dev.swift Generated/CredentialKey.swift

# Production (generated during CI/CD)
echo "struct CredentialKeyProvider {
    static let key = Data(base64Encoded: \"$PROD_KEY\")!
}" > Generated/CredentialKey.swift
```

#### Separate Repository for Keys
```
MainApp/
├── Sources/
│   └── Credentials.swift (from credential-code)
└── Dependencies/
    └── SecureKeys/ (private git submodule)
        └── CredentialKey.swift
```

## Deployment Strategies

### 1. Environment Variables

Store the key in an environment variable:

```bash
# Extract key from file
export CREDENTIAL_KEY=$(cat credential-key.json | jq -r .key)

# Or set directly
export CREDENTIAL_KEY="H3bhCcgWg5qhEg21AqIAp17Tt5xiwZJbk7eGHG0K1nU="
```

In your application:
```swift
if let key = ProcessInfo.processInfo.environment["CREDENTIAL_KEY"] {
    try Credentials.initialize(with: key)
}
```

### 2. Secure File Storage

For applications that can securely store files:

```bash
# Copy key to secure location
cp credential-key.json /secure/path/keys/

# Set appropriate permissions
chmod 600 /secure/path/keys/credential-key.json
```

### 3. AWS Secrets Manager

```bash
# Store the entire key file
aws secretsmanager create-secret \
    --name prod/credential-key \
    --secret-string file://credential-key.json

# Or store just the key value
KEY=$(cat credential-key.json | jq -r .key)
aws secretsmanager create-secret \
    --name prod/credential-key-value \
    --secret-string "$KEY"
```

Retrieve in your application:
```bash
# Get the key
KEY=$(aws secretsmanager get-secret-value \
    --secret-id prod/credential-key-value \
    --query SecretString --output text)
```

### 4. Kubernetes Secrets

Create a Kubernetes secret:
```bash
# From file
kubectl create secret generic credential-key \
    --from-file=key.json=credential-key.json

# From literal value
KEY=$(cat credential-key.json | jq -r .key)
kubectl create secret generic credential-key \
    --from-literal=key="$KEY"
```

Mount in your pod:
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    volumeMounts:
    - name: credential-key
      mountPath: /secrets
      readOnly: true
  volumes:
  - name: credential-key
    secret:
      secretName: credential-key
```

### 5. Docker Secrets

```bash
# Create Docker secret
docker secret create credential_key credential-key.json

# Use in docker-compose.yml
services:
  app:
    image: myapp
    secrets:
      - credential_key
    environment:
      - KEY_FILE=/run/secrets/credential_key

secrets:
  credential_key:
    external: true
```

### 6. HashiCorp Vault

```bash
# Store in Vault
vault kv put secret/credential-key @credential-key.json

# Or just the key
KEY=$(cat credential-key.json | jq -r .key)
vault kv put secret/credential-key value="$KEY"
```

## Security Best Practices

### 1. Never Commit Key Files

Add to `.gitignore`:
```bash
# Credential keys
credential-key.json
*.key.json
*.key
keys/
```

### 2. Use Different Keys Per Environment

```bash
# Development
credential-code generate --external-key --key-file dev.key.json

# Staging
credential-code generate --external-key --key-file staging.key.json

# Production
credential-code generate --external-key --key-file prod.key.json
```

### 3. Implement Key Rotation

1. Generate new credentials with new key:
   ```bash
   credential-code generate --external-key --key-file new-key.json
   ```

2. Deploy new code and key together
3. Verify new deployment works
4. Remove old key from systems

### 4. Limit Key Access

- Use principle of least privilege
- Audit key access
- Monitor for unauthorized access attempts

### 5. Secure Key Transmission

When sharing keys between systems:
- Use encrypted channels (HTTPS, SSH)
- Consider using public key encryption for transmission
- Never send keys via email or chat

## Example: Complete CI/CD Setup

### GitHub Actions Example

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup
        run: |
          # Install credential-code
          # ... installation steps ...
      
      - name: Generate Credentials
        env:
          CREDENTIALS_JSON: ${{ secrets.CREDENTIALS_JSON }}
        run: |
          # Create credentials file from secret
          echo "$CREDENTIALS_JSON" > .credential-code/credentials.json
          
          # Generate with external key
          credential-code generate --external-key --output src/Credentials.swift
          
          # Store key securely (example with AWS)
          aws secretsmanager update-secret \
            --secret-id prod/credential-key \
            --secret-string file://credential-key.json
          
          # Remove key file before building
          rm credential-key.json
      
      - name: Build and Deploy
        run: |
          # Build your application
          # Deploy to production
```

## Troubleshooting

### "Key not initialized" Error

Make sure to initialize the key before accessing credentials:
```swift
// This will fail
let apiKey = try Credentials.get(.API_KEY) // Error: keyNotInitialized

// Initialize first
try Credentials.loadKey(from: "credential-key.json")
let apiKey = try Credentials.get(.API_KEY) // Success
```

### "Invalid key" Error

Check that:
1. The key file exists and is readable
2. The JSON format is correct
3. The base64 key is valid
4. You're using the correct key for the generated code

### Key Mismatch

If you get decryption errors, ensure:
- The key matches the one used during generation
- You haven't mixed keys from different generations
- The key file hasn't been corrupted

## Summary

The external key feature provides better security by separating the encryption key from your code. This allows for:

- ✅ Better key management
- ✅ Easier key rotation
- ✅ Integration with existing secret management systems
- ✅ Compliance with security policies
- ✅ Reduced risk of key exposure

Remember: The key file is as sensitive as your original credentials. Protect it accordingly!