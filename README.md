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

### ✨ Key Benefits

- 🚫 **No secrets in source code** - Credentials never appear as strings in your binaries
- 🔄 **Build-time encryption** - Each build uses a unique encryption key
- 🌍 **Multi-language support** - Works with Swift, Kotlin, Java, Python, and C++
- 🛡️ **Type-safe access** - No magic strings, just compile-time checked enums
- 📦 **Zero dependencies** - Generated code uses only standard crypto libraries

## 🚀 Quick Start

### 1. Install

```bash
# Build from source
git clone https://github.com/yourusername/credential-code.git
cd credential-code
swift build -c release
sudo cp .build/release/credential-code /usr/local/bin/
```

### 2. Initialize your project

```bash
cd your-project
credential-code init
```

### 3. Add your credentials

Edit `.credential-code/credentials.json`:
```json
{
  "API_KEY": "sk-1234567890abcdef",
  "DATABASE_URL": "postgres://user:pass@localhost/db"
}
```

### 4. Generate encrypted code

```bash
credential-code generate
```

### 5. Use in your app

```swift
if let apiKey = Credentials.decrypt(.API_KEY) {
    // Use your API key securely
}
```

## 📚 Full Documentation

- [**Installation Guide**](#installation) - Detailed setup instructions
- [**Usage Guide**](#usage) - Complete workflow and examples
- [**Security Model**](#security) - How credentials are protected
- [**Language Examples**](#supported-languages) - Code samples for each language
- [**Demo Project**](#demo) - See it in action

## Supported Languages

| Language | File | Required Libraries | Example |
|----------|------|-------------------|---------|
| Swift | `Credentials.swift` | CryptoKit (built-in) | [View](#swift-example) |
| Kotlin | `Credentials.kt` | javax.crypto (built-in) | [View](#kotlin-example) |
| Java | `Credentials.java` | javax.crypto (built-in) | [View](#java-example) |
| Python | `credentials.py` | [cryptography](https://pypi.org/project/cryptography/) | [View](#python-example) |
| C++ | `credentials.cpp` | OpenSSL | [View](#c-example) |

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
# Swift (default)
credential-code generate

# Other languages
credential-code generate --language kotlin
credential-code generate --language java --output src/main/java/Creds.java
```

### Language Examples

#### Swift Example
```swift
import Foundation

// Decrypt a credential
if let apiKey = Credentials.decrypt(.API_KEY) {
    let headers = ["Authorization": "Bearer \(apiKey)"]
    // Make API request...
}

// With caching for frequently used credentials
let dbUrl = Credentials.decryptCached(.DATABASE_URL)
```

#### Kotlin Example
```kotlin
// Decrypt a credential
val apiKey = Credentials.decrypt(CredentialKey.API_KEY)
apiKey?.let { key ->
    val headers = mapOf("Authorization" to "Bearer $key")
    // Make API request...
}

// With caching
val dbUrl = Credentials.decryptCached(CredentialKey.DATABASE_URL)
```

#### Java Example
```java
// Decrypt a credential
String apiKey = Credentials.decrypt(CredentialKey.API_KEY);
if (apiKey != null) {
    Map<String, String> headers = Map.of("Authorization", "Bearer " + apiKey);
    // Make API request...
}
```

#### Python Example
```python
from credentials import Credentials, CredentialKey

# Decrypt a credential
api_key = Credentials.decrypt(CredentialKey.API_KEY)
if api_key:
    headers = {"Authorization": f"Bearer {api_key}"}
    # Make API request...

# With caching
db_url = Credentials.decrypt_cached(CredentialKey.DATABASE_URL)
```

#### C++ Example
```cpp
#include "credentials.h"

// Decrypt a credential
auto apiKey = Credentials::decrypt(CredentialKey::API_KEY);
if (apiKey.has_value()) {
    std::string authHeader = "Bearer " + apiKey.value();
    // Make API request...
}
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

## Security

### How It Works

1. **Development**: Store credentials as plain text in `.credential-code/credentials.json`
2. **Build Time**: Generate code with encrypted credentials using a random key
3. **Runtime**: Credentials are decrypted only in memory when accessed
4. **Version Control**: Only encrypted code is committed, never plain credentials

### Security Features

- **AES-256-GCM encryption** with authenticated encryption
- **Unique key per build** - Each generation uses a new random key
- **Obfuscated key storage** - Keys are split and reconstructed at runtime
- **No string literals** - Credentials never appear as plain text in binaries
- **Memory-only decryption** - Decrypted values exist only during use

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