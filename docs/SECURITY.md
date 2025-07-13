# Security Model

## Overview

Credential Code implements a build-time encryption model that ensures credentials never appear as plain text in your compiled binaries while maintaining ease of use during development.

### Suitable Use Cases

✅ **Recommended for:**
- Private/proprietary applications
- Internal company tools
- Closed-source mobile apps (iOS/Android)
- Server applications with restricted binary access
- Desktop applications distributed as compiled binaries

❌ **NOT suitable for:**
- Open source projects
- Public GitHub repositories
- Applications where source code is accessible to end users
- Web applications where JavaScript source is visible
- Any scenario where untrusted parties can access the generated code

## Threat Model

### What We Protect Against

1. **Source Code Exposure**
   - Credentials in public repositories
   - Accidental commits of secrets
   - Code sharing with untrusted parties

2. **Binary Analysis**
   - String extraction from compiled binaries
   - Memory dumps containing plain text secrets
   - Reverse engineering attempts

3. **Build Artifact Leakage**
   - CI/CD logs containing secrets
   - Build cache exposure
   - Artifact repository breaches

### What We Don't Protect Against

1. **Open Source Projects**
   - **CRITICAL**: Anyone with access to the generated code can decrypt credentials
   - The encryption key is embedded in the code (even if obfuscated)
   - This tool is NOT suitable for public repositories or open source projects

2. **Compromised Runtime Environment**
   - If an attacker has runtime code execution, they can access decrypted values
   - Memory access attacks on running processes
   - Debugger attachment to production applications

3. **Development Environment Compromise**
   - If `.credential-code/credentials.json` is accessed
   - Developer machine compromise
   - Backup system breaches

## Encryption Details

### Algorithm: AES-256-GCM

- **Encryption**: AES with 256-bit keys
- **Mode**: Galois/Counter Mode (GCM)
- **Authentication**: Built-in authenticated encryption
- **Nonce**: 96-bit (12 bytes) randomly generated per credential
- **Tag**: 128-bit (16 bytes) authentication tag

### Key Management

1. **Key Generation**
   - Cryptographically secure random number generator
   - New key for each `generate` command
   - 256-bit keys (32 bytes)

2. **Key Storage in Generated Code**
   - Split into 4-byte chunks
   - Stored as separate array elements
   - Reconstructed at runtime
   - No single contiguous key in binary

3. **External Key Mode (Recommended for Production)**
   - Keys stored separately from code
   - No embedded keys in binaries
   - Better suited for key rotation
   - Integration with key management systems

### Encryption Process

```
Plain Credential → AES-256-GCM → Ciphertext + Nonce + Tag → Base64 → Generated Code
```

## Runtime Security

### Decryption Flow

1. Key components are combined in memory
2. Encrypted data is decrypted using AES-GCM
3. Plain text exists only in memory during use
4. No persistent storage of decrypted values

### Memory Management

- **Swift**: Automatic memory management with ARC
- **Java/Kotlin**: Garbage collected, consider using `char[]` for sensitive data
- **Python**: Garbage collected, credentials cleared from cache
- **C++**: Manual memory clearing with secure erasure

## Best Practices

### Development

1. **Credential File Security**
   ```bash
   # Set restrictive permissions
   chmod 600 .credential-code/credentials.json
   ```

2. **Git Configuration**
   ```bash
   # Ensure .credential-code is ignored
   echo ".credential-code/" >> .gitignore
   git add .gitignore
   git commit -m "Ignore credential directory"
   ```

3. **Environment Separation**
   - Use different credentials for dev/staging/prod
   - Never use production credentials in development
   - Implement credential rotation policies

### CI/CD Integration

1. **Secure Secret Storage**
   ```yaml
   # Store credentials.json content in CI secrets
   - name: Setup Credentials
     run: |
       mkdir -p .credential-code
       echo "${{ secrets.CREDENTIALS_JSON }}" > .credential-code/credentials.json
       chmod 600 .credential-code/credentials.json
   ```

2. **Build Isolation**
   - Generate credentials in isolated build step
   - Don't log credential values
   - Clean up after build

### Production

1. **Access Control**
   - Limit who can access credential files
   - Use principle of least privilege
   - Audit credential access

2. **Monitoring**
   - Monitor for unusual credential access patterns
   - Set up alerts for failed decryption attempts
   - Track credential usage

## External Key Mode

> 📖 **See the [External Key Usage Guide](EXTERNAL_KEY_GUIDE.md) for comprehensive documentation on this feature.**

### Overview

External key mode separates encryption keys from generated code, providing enhanced security for production environments:

```bash
# Generate with external key
credential-code generate --external-key --key-file prod.key
```

### Security Benefits

1. **Key Isolation**
   - Keys never embedded in binaries
   - Reduced attack surface
   - Better compliance with security standards

2. **Key Rotation**
   - Update keys without rebuilding code
   - Zero-downtime key rotation possible
   - Audit trail for key changes

3. **Access Control**
   - Fine-grained permissions on key files
   - Integration with IAM systems
   - Separation of duties

### Key Features

External key mode provides:
- Separate storage of encryption keys
- Support for both JSON files and source code keys
- Integration with secret management systems
- Simplified key rotation

For detailed implementation guides, deployment strategies, and best practices, see the [External Key Usage Guide](EXTERNAL_KEY_GUIDE.md).

## Comparison with Alternatives

### vs Environment Variables

| Aspect | Credential Code (Embedded) | Credential Code (External Key) | Environment Variables |
|--------|---------------------------|-------------------------------|---------------------|
| Binary Analysis | Encrypted data + obfuscated key | Encrypted data only | May appear in strings |
| Type Safety | Compile-time checked | Compile-time checked | Runtime strings |
| Rotation | Rebuild required | Key update only | Runtime update |
| Cross-platform | Yes | Yes | Shell-dependent |
| Key Management | Built-in | Flexible | Manual |

### vs Key Management Services

| Aspect | Credential Code | KMS (AWS, Azure, etc) |
|--------|----------------|---------------------|
| Network Required | No | Yes |
| Latency | Microseconds | Milliseconds |
| Cost | Free | Per-operation charges |
| Complexity | Low | High |

### vs Config Files

| Aspect | Credential Code | Config Files |
|--------|----------------|---------------------|
| Version Control | Safe (encrypted) | Unsafe (plain text) |
| Runtime Changes | Rebuild required | File reload |
| Type Safety | Yes | Depends on format |
| Security | High | Low |

## Security Audit Checklist

- [ ] `.credential-code/` is in `.gitignore`
- [ ] No credential values in logs
- [ ] Production uses separate credentials
- [ ] Regular credential rotation schedule
- [ ] Access logs for credential files
- [ ] Secure credential distribution process
- [ ] Incident response plan for credential leaks

## Reporting Security Issues

If you discover a security vulnerability, please:

1. **Do NOT** open a public issue
2. Email security@example.com with details
3. Include steps to reproduce if possible
4. Allow time for patch before disclosure

We take security seriously and will respond promptly to valid reports.