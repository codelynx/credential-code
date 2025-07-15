# Credential Code Utilities

This directory contains ready-to-use utility libraries for decrypting `.creds` files in various programming languages. These utilities make it easy to integrate credential decryption into your projects without writing boilerplate code.

## Available Languages

- **Swift** - Swift Package Manager compatible
- **Python** - pip installable module
- **JavaScript/TypeScript** - npm compatible with TypeScript definitions
- **Java** - Maven/Gradle compatible

## Quick Start

Each language directory contains:
- Complete utility code for decrypting .creds files
- README with installation and usage instructions
- Package configuration files where applicable

## Common Features

All utilities provide:

1. **Multiple initialization options**:
   - From key file path
   - From base64-encoded key string
   - From raw key bytes

2. **Flexible credential loading**:
   - Load from .creds file path
   - Load from JSON string/object
   - Convenience methods with default paths

3. **Error handling**:
   - Graceful error handling
   - Clear error messages

4. **Consistent API**:
   - Similar method names across languages
   - Predictable behavior

## Usage Examples

### Swift
```swift
let decryptor = try CredentialDecryptor(keyPath: ".credential-code/encryption-key.txt")
let credentials = try decryptor.loadCredentials(from: "Generated/credentials.creds")
```

### Python
```python
decryptor = CredentialDecryptor('.credential-code/encryption-key.txt')
credentials = decryptor.load_credentials('Generated/credentials.creds')
```

### JavaScript
```javascript
const decryptor = new CredentialDecryptor('.credential-code/encryption-key.txt');
const credentials = decryptor.loadCredentials('Generated/credentials.creds');
```

### Java
```java
CredentialDecryptor decryptor = new CredentialDecryptor(Paths.get(".credential-code/encryption-key.txt"));
Map<String, String> credentials = decryptor.loadCredentials("Generated/credentials.creds");
```

## Integration Methods

### Option 1: Package Manager (Recommended where available)

Follow the installation instructions in each language's README for package manager integration.

### Option 2: Manual Integration

Simply copy the utility file(s) to your project:

- **Swift**: Copy `CredentialDecryptor.swift`
- **Python**: Copy `credential_code_utility.py`
- **JavaScript**: Copy `index.js` (and `index.d.ts` for TypeScript)
- **Java**: Copy `CredentialDecryptor.java` and add org.json dependency

### Option 3: Git Submodule

Add the credential-code repository as a submodule and reference the utilities directly:

```bash
git submodule add https://github.com/yourusername/credential-code.git
```

## Security Notes

1. **Key Management**: Always protect your encryption key file. Never commit it to version control.
2. **Caching**: Some utilities offer credential caching. Clear the cache when appropriate.
3. **Error Handling**: Always handle decryption errors gracefully in production code.

## Contributing

To add support for a new language:

1. Create a new directory under `utilities/`
2. Implement the decryption utility following the patterns in existing languages
3. Include a comprehensive README with examples
4. Ensure consistent API design with other languages

## License

These utilities are provided under the same license as the credential-code project.