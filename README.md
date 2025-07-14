# 🔐 Credential Code

> Transform plain text credentials into encrypted code at build time. Never commit secrets again.

[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Languages](https://img.shields.io/badge/Languages-Swift%20%7C%20Kotlin%20%7C%20Java%20%7C%20Python%20%7C%20C++-brightgreen.svg)](#supported-languages)

## Why Credential Code?

**Stop hardcoding secrets.** Credential Code encrypts your credentials at build time, generating source code with encrypted data that's safe to commit. Your secrets are only decrypted in memory at runtime.

```mermaid
graph LR
    A[credentials.json<br/>plain text] -->|credential-code<br/>generate| B[Encrypted Code<br/>safe to commit]
    B -->|Your App<br/>runtime| C[Decrypted<br/>in memory]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
```

### ⚠️ IMPORTANT: Security Limitations

**This tool is NOT suitable for open source projects.** The encryption key is embedded in the generated code (even in obfuscated form), which means anyone with access to the code can decrypt the credentials. Use this tool only for:
- Private/proprietary applications
- Internal company projects
- Closed-source mobile apps
- Server applications with restricted access

### ✨ Key Benefits

- 🚫 **No secrets in source code** - Credentials never appear as strings in your binaries
- 🔄 **Build-time encryption** - Source code uses embedded keys, no external dependencies
- 🌍 **Multi-language support** - Works with Swift, Kotlin, Java, Python, and C++
- 🛡️ **Type-safe access** - No magic strings, just compile-time checked enums
- 📦 **Zero dependencies** - Generated code uses only standard crypto libraries
- 🔀 **Dual output formats** - Self-contained code for apps, .creds files for runtime config

## 📚 Documentation

See the [Documentation Index](docs/README.md) for comprehensive guides and resources.

## 🚀 Quick Start

### 1. Install

```bash
# Build from source
git clone https://github.com/yourusername/credential-code.git
cd credential-code
swift build -c release
sudo cp .build/release/credential-code /usr/local/bin/
```

### 2. Initialize Your Project

```bash
cd your-project
credential-code init
```

### 3. Add Your Credentials

Edit `.credential-code/credentials.json`:
```json
{
  "API_KEY": "sk-1234567890abcdef",
  "DATABASE_URL": "postgres://user:pass@localhost/db"
}
```

### 4. Generate Encrypted Code

```bash
credential-code generate
# This creates:
# - Generated/Credentials.swift (self-contained with embedded key)
# - Generated/credentials.creds (requires external key file)
# - .credential-code/encryption-key.txt (key for .creds file only)
```

### 5. Use in Your App

```swift
// Direct usage - no key loading needed!
if let apiKey = Credentials.decrypt(.API_KEY) {
    // Use your API key
}
```

## 📚 Full Documentation

- [**Installation Guide**](#installation) - Detailed setup instructions
- [**Usage Guide**](#usage) - Complete workflow and examples
- [**Security Model**](#security) - How credentials are protected
- [**Language Examples**](#supported-languages) - Code samples for each language
- [**Demo Project**](#demo) - See it in action

## Supported Languages

| Language | File | Required Libraries | Key Mode |
|----------|------|-------------------|----------|
| Swift | `Credentials.swift` | CryptoKit (built-in) | Embedded by default, external available |
| Kotlin | `Credentials.kt` | javax.crypto (built-in) | Embedded by default, external available |
| Java | `Credentials.java` | javax.crypto (built-in) | Embedded by default, external available |
| Python | `credentials.py` | [cryptography](https://pypi.org/project/cryptography/) | Embedded by default, external available |
| C++ | `credentials.cpp` | OpenSSL | Embedded by default, external available |

> **Note:** All languages generate self-contained code with embedded keys by default. All languages support external key mode with the `--external-key` flag for enhanced security.

## Usage

### Initialize

Create the credential storage structure in your project:

```bash
credential-code init
```

This creates:
- `.credential-code/` directory
- `credentials.json` with example structure  
- Updates `.gitignore` to exclude credentials

### Add Credentials

Edit `.credential-code/credentials.json`:

```json
{
  "STRIPE_KEY": "sk_test_...",
  "AWS_SECRET": "aws_secret_key_...",
  "JWT_SECRET": "your-256-bit-secret"
}
```

**Naming Convention**: Use UPPER_SNAKE_CASE for credential keys.

### Generate Code

Generate encrypted code for your target language:

```bash
# Default: Swift with external key + .creds file
credential-code generate
# Creates: 
# - Generated/Credentials.swift
# - Generated/credentials.creds
# - .credential-code/encryption-key.txt

# Other languages (also generate .creds by default)
credential-code generate --language kotlin
credential-code generate --language java --output src/main/java/Creds.java

# Without .creds file
credential-code generate --no-generate-creds
```

By default, credential-code now generates:
- **Code file**: Language-specific encrypted credentials (e.g., Generated/Credentials.swift)
- **.creds file**: JSON format for backend/runtime use (Generated/credentials.creds)
- **External key**: Stored in `.credential-code/encryption-key.txt` (base64 format)
- **Key reuse**: If the key file exists, it's reused (consistent encryption across builds)
- **Easy copying**: Key is displayed when first generated for manual backup

#### Key Management Options

**Default: External Key File**
```bash
# Generate with external key (default)
credential-code generate

# Specify custom key file path
credential-code generate --key-file path/to/key.txt
```

**Option 1: Embedded Key (Legacy)**
```bash
# Generate with embedded key (old behavior)
credential-code generate --embedded-key
```

**Option 2: Source Code Key**
```bash
# Generate with external key as source code
credential-code generate --external-key-source

# Specify custom output path
credential-code generate --external-key-source --key-source-output Keys/MyKey.swift
```

📖 **[See the complete External Key Usage Guide](docs/EXTERNAL_KEY_GUIDE.md)** for detailed instructions

### Backend/Runtime Configuration (.creds files)

`.creds` files are now generated by default alongside code files:

```bash
# Default: generates both code and .creds
credential-code generate

# Custom .creds output path
credential-code generate --creds-output backend/prod.creds

# Disable .creds generation (code only)
credential-code generate --no-generate-creds
```

The `.creds` file can be loaded at runtime by any backend service:
```javascript
// Node.js example
const key = fs.readFileSync('encryption-key.txt', 'utf8');
const creds = JSON.parse(fs.readFileSync('credentials.creds'));
const apiKey = decrypt(creds, key, 'API_KEY');
```

📖 **[See the Two Use Cases Guide](docs/TWO_USE_CASES.md)** for detailed examples

### Language Examples

#### Swift Example
```swift
import Foundation

// Default mode (embedded key) - no setup needed!
if let apiKey = Credentials.decrypt(.API_KEY) {
    let headers = ["Authorization": "Bearer \(apiKey)"]
    // Make API request...
}

// Use cached decryption for frequently accessed credentials
let dbUrl = Credentials.decryptCached(.DATABASE_URL)

// External key mode (requires --external-key flag during generation)
// First, load the key
try Credentials.loadKey(from: ".credential-code/encryption-key.txt")
// Then access credentials
let apiKey = try Credentials.get(.API_KEY)
```

#### Kotlin Example
```kotlin
// Default mode (embedded key) - no setup needed!
val apiKey = Credentials.decrypt(CredentialKey.API_KEY)
apiKey?.let { key ->
    val headers = mapOf("Authorization" to "Bearer $key")
    // Make API request...
}

// With caching
val dbUrl = Credentials.decryptCached(CredentialKey.DATABASE_URL)

// External key mode (requires --external-key flag during generation)
// First, load the key
Credentials.loadKey(".credential-code/encryption-key.txt")
// Then access credentials
val apiKey = Credentials.get(CredentialKey.API_KEY)
```

#### Java Example
```java
// Default mode (embedded key) - no setup needed!
String apiKey = Credentials.decrypt(CredentialKey.API_KEY);
if (apiKey != null) {
    Map<String, String> headers = Map.of("Authorization", "Bearer " + apiKey);
    // Make API request...
}

// External key mode (requires --external-key flag during generation)
// First, load the key
Credentials.loadKey(".credential-code/encryption-key.txt");
// Then access credentials
String apiKey = Credentials.get(CredentialKey.API_KEY);
```

#### Python Example
```python
from credentials import Credentials, CredentialKey

# Default mode (embedded key) - no setup needed!
api_key = Credentials.decrypt(CredentialKey.API_KEY)
if api_key:
    headers = {"Authorization": f"Bearer {api_key}"}
    # Make API request...

# With caching
db_url = Credentials.decrypt_cached(CredentialKey.DATABASE_URL)

# External key mode (requires --external-key flag during generation)
# First, load the key
Credentials.load_key(".credential-code/encryption-key.txt")
# Then access credentials
api_key = Credentials.get(CredentialKey.API_KEY)
```

#### C++ Example
```cpp
#include "credentials.h"

// Default mode (embedded key) - no setup needed!
auto apiKey = Credentials::decrypt(CredentialKey::API_KEY);
if (apiKey.has_value()) {
    std::string authHeader = "Bearer " + apiKey.value();
    // Make API request...
}

// External key mode (requires --external-key flag during generation)
// First, load the key
Credentials::loadKey(".credential-code/encryption-key.txt");
// Then access credentials
std::string apiKey = Credentials::get(CredentialKey::API_KEY);
```

## Demo

Run the comprehensive demo to see all languages in action:

```bash
./demo.sh
```

The demo:
- Creates a sample project with test credentials
- Generates encrypted code for all languages
- Runs working examples
- Shows the complete workflow

### Dual Use Example

See the `example-dual-use/` directory for a complete example showing both approaches:

```bash
cd example-dual-use
./demo.sh
```

This demonstrates:
- **Compiled approach**: Credentials embedded in Swift binary
- **Runtime approach**: Credentials loaded from .creds file in Node.js
- Both methods decrypt the same credentials using the same key

## Security

### How It Works

1. **Development**: Store credentials as plain text in `.credential-code/credentials.json`
2. **Build Time**: Generate code with encrypted credentials using a random key
3. **Runtime**: Credentials are decrypted only in memory when accessed
4. **Version Control**: Only encrypted code is committed, never plain credentials

### Security Features

- **AES-256-GCM encryption** with authenticated encryption
- **External keys by default** - Keys stored separately from code
- **Key persistence** - Same key reused across builds (when file exists)
- **No string literals** - Credentials never appear as plain text in binaries
- **Memory-only decryption** - Decrypted values exist only during use
- **Multiple key formats** - Plain text, JSON, or source code

### Best Practices

✅ **DO:**
- Add `.credential-code/` to `.gitignore`
- Generate fresh code for production builds
- Use different credentials for each environment
- Rotate credentials regularly

❌ **DON'T:**
- Commit `.credential-code/` directory
- Share credential files between developers
- Log decrypted credential values
- Store decrypted values longer than necessary
- **Use this for open source projects** - Anyone with access to the code can decrypt credentials

## Installation

### Requirements

- **Development**: macOS 12.0+, Swift 5.5+
- **Runtime**: Depends on target language
  - Swift: macOS 11.0+, iOS 14.0+
  - Python: Python 3.7+, `cryptography` package
  - Java/Kotlin: Java 8+
  - C++: C++17, OpenSSL

### Build from Source

```bash
# Clone repository
git clone https://github.com/yourusername/credential-code.git
cd credential-code

# Build release version
swift build -c release

# Install to /usr/local/bin
sudo cp .build/release/credential-code /usr/local/bin/

# Verify installation
credential-code --version
```

## Advanced Usage

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Generate Credentials
  run: |
    echo '${{ secrets.CREDENTIALS_JSON }}' > .credential-code/credentials.json
    credential-code generate --language swift
```

### Multiple Environments

```bash
# Development
credential-code generate --output Generated/Credentials.dev.swift

# Production  
credential-code generate --output Generated/Credentials.prod.swift
```

### Custom Output Paths

```bash
# Specify custom output location
credential-code generate \
  --language python \
  --output src/config/secure_credentials.py
```

### External Key Management

External keys are now the default for better security:

```bash
# Generate with default external key
credential-code generate
# Key saved to: .credential-code/encryption-key.txt

# Use custom key location
credential-code generate --key-file keys/prod.key

# Store key in environment variable (CI/CD)
export CREDENTIAL_KEY=$(cat .credential-code/encryption-key.txt)
```

**Key Storage Options:**
- **Environment Variables**: Best for CI/CD and containerized deployments
- **Secret Management Systems**: AWS Secrets Manager, HashiCorp Vault, etc.
- **Secure File Storage**: Encrypted volumes, HSMs
- **Configuration Management**: Kubernetes Secrets, Docker Secrets

**Example: AWS Secrets Manager Integration**
```bash
# Store key in AWS Secrets Manager
aws secretsmanager create-secret \
  --name prod/credential-key \
  --secret-string file://keys/prod.key

# Retrieve at runtime
KEY=$(aws secretsmanager get-secret-value \
  --secret-id prod/credential-key \
  --query SecretString --output text)
```

## Troubleshooting

### Common Issues

**"Not initialized" error**
```bash
# Run init in your project root
credential-code init
```

**"Invalid key format" error**
- Use UPPER_SNAKE_CASE for keys
- Only letters, numbers, and underscores

**Python "No module named 'cryptography'"**
```bash
pip install cryptography
```

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Clone repo
git clone https://github.com/yourusername/credential-code.git
cd credential-code

# Open in Xcode
open Package.swift

# Run tests
swift test
```

## Roadmap

- [ ] Package manager support (Homebrew, apt, etc.)
- [ ] GUI application
- [ ] VS Code extension
- [ ] Additional languages (Go, Rust, Ruby)
- [ ] Cloud key management integration
- [ ] Credential rotation automation

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built with [Swift Argument Parser](https://github.com/apple/swift-argument-parser) and love for secure coding practices.

---

<p align="center">
  Made with ❤️ by developers who forgot to remove their API keys one too many times
</p>