# Quick Start Guide

Get up and running with Credential Code in 5 minutes.

## Installation

```bash
# Clone and build
git clone https://github.com/yourusername/credential-code.git
cd credential-code
swift build -c release

# Install
sudo cp .build/release/credential-code /usr/local/bin/
```

## Your First Encrypted Credential

### 1. Initialize

```bash
cd your-project
credential-code init
```

### 2. Add a credential

Edit `.credential-code/credentials.json`:

```json
{
  "API_KEY": "sk-my-secret-api-key-123"
}
```

### 3. Generate encrypted code

```bash
credential-code generate
```

### 4. Use in your app

```swift
// Swift
if let apiKey = Credentials.decrypt(.API_KEY) {
    print("Got API key: \(apiKey)")
}
```

## That's it! 🎉

Your credential is now:
- ✅ Encrypted in the generated code
- ✅ Safe to commit to version control
- ✅ Only decrypted at runtime
- ✅ Never visible in your binary as plain text

## Next Steps

- [Add more credentials](#multiple-credentials)
- [Try other languages](#other-languages)
- [Read security best practices](SECURITY.md)

## Multiple Credentials

```json
{
  "API_KEY": "sk-api-key",
  "DATABASE_URL": "postgres://localhost/mydb",
  "JWT_SECRET": "super-secret-jwt-key",
  "STRIPE_KEY": "sk_test_123"
}
```

## Other Languages

### Kotlin/Android
```bash
credential-code generate --language kotlin
```

```kotlin
val apiKey = Credentials.decrypt(CredentialKey.API_KEY)
```

### Python
```bash
credential-code generate --language python
```

```python
from credentials import Credentials, CredentialKey
api_key = Credentials.decrypt(CredentialKey.API_KEY)
```

### Java
```bash
credential-code generate --language java
```

```java
String apiKey = Credentials.decrypt(CredentialKey.API_KEY);
```

## Tips

1. **Always add to .gitignore**: The init command does this automatically
2. **Use UPPER_SNAKE_CASE**: For credential keys (e.g., `API_KEY`, not `apiKey`)
3. **Generate before building**: Add to your build script
4. **Different environments**: Use different credential files for dev/prod

## Common Issues

**"Not initialized" error**
- Run `credential-code init` first

**"Invalid key format" error**  
- Use `API_KEY` not `api-key` or `apiKey`

**Can't find generated file**
- Default location is `Generated/Credentials.{ext}`
- Use `--output` to specify custom path

## Full Demo

See all features in action:

```bash
./demo.sh
```