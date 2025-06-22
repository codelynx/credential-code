# Credential Code

A command-line tool that securely manages credentials by storing them as plain text JSON during development and generating encrypted code for production use. Supports Swift, Kotlin, Java, Python, and C++.

## Features

- 🔐 **Secure by Design**: Credentials are encrypted at build time, not stored as plain text in compiled code
- 🌍 **Multi-Language Support**: Generate encrypted credential code for Swift, Kotlin, Java, Python, and C++
- 📝 **Simple Configuration**: Store credentials as plain text JSON during development
- 🚀 **Easy Integration**: Generated code provides type-safe credential access
- 🔄 **Build-Time Encryption**: Each build uses a unique encryption key
- 🛡️ **Runtime Decryption**: Credentials are only decrypted in memory when needed

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/credential-code.git
cd credential-code

# Build the tool
swift build --configuration release

# Add to PATH (optional)
cp .build/release/credential-code /usr/local/bin/
```

### Basic Usage

1. **Initialize** credential storage in your project:
```bash
credential-code init
```

2. **Edit** `.credential-code/credentials.json` with your credentials:
```json
{
  "credentials": {
    "API_KEY": "your-api-key-here",
    "DATABASE_URL": "postgres://user:pass@localhost/db",
    "JWT_SECRET": "your-secret-key"
  }
}
```

3. **Generate** encrypted code for your language:
```bash
# Swift (default)
credential-code generate

# Other languages
credential-code generate --language kotlin
credential-code generate --language java
credential-code generate --language python
credential-code generate --language c++
```

4. **Use** the generated code in your application:

```swift
// Swift
if let apiKey = Credentials.decrypt(.API_KEY) {
    // Use your API key
}
```

```kotlin
// Kotlin
val apiKey = Credentials.decrypt(CredentialKey.API_KEY)
```

```python
# Python
from credentials import Credentials, CredentialKey
api_key = Credentials.decrypt(CredentialKey.API_KEY)
```

## Demo

Run the comprehensive demo to see all supported languages in action:

```bash
./demo.sh
```

This will:
- Create a demo project with fake credentials
- Generate encrypted code for all supported languages
- Run test programs showing decryption working
- Create a complete example project structure

## How It Works

1. **Development**: Store credentials as plain text in `.credential-code/credentials.json`
2. **Build Time**: Run `credential-code generate` to create encrypted code
3. **Runtime**: Generated code contains encrypted data and decryption logic
4. **Security**: Each build uses a unique encryption key, credentials never appear as plain text in compiled code

## Supported Languages

| Language | File Generated | Required Libraries |
|----------|---------------|-------------------|
| Swift | `Credentials.swift` | CryptoKit (built-in) |
| Kotlin | `Credentials.kt` | javax.crypto (built-in) |
| Java | `Credentials.java` | javax.crypto (built-in) |
| Python | `credentials.py` | cryptography |
| C++ | `credentials.cpp` | OpenSSL |

## Commands

### `init`
Initialize credential storage in the current directory.

```bash
credential-code init [--path <path>]
```

- Creates `.credential-code/` directory
- Creates `credentials.json` with example structure
- Updates `.gitignore` to exclude credentials

### `generate`
Generate encrypted code for the specified language.

```bash
credential-code generate [--language <language>] [--output <path>]
```

Options:
- `--language`, `-l`: Target language (swift, kotlin, java, python, c++)
- `--output`, `-o`: Output file path (defaults to language-specific name)

## Security Considerations

1. **Never commit** `.credential-code/` to version control
2. **Generated files are safe** to commit - they contain only encrypted data
3. **Each build is unique** - encryption keys are randomly generated
4. **Runtime-only decryption** - credentials exist in plain text only in memory

## Project Structure

```
your-project/
├── .credential-code/
│   └── credentials.json    # Plain text credentials (git-ignored)
├── Generated/
│   └── Credentials.swift   # Generated encrypted code
└── .gitignore             # Updated to exclude .credential-code/
```

## Requirements

- Swift 5.5 or later
- macOS 12.0 or later (for development)
- Target language runtime requirements:
  - Python: `pip install cryptography`
  - C++: OpenSSL development libraries

## Building from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/credential-code.git
cd credential-code

# Build debug version
swift build

# Build release version
swift build --configuration release

# Run tests
swift test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.