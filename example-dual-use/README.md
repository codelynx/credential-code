# Dual Use Example

This example demonstrates two ways to use credential-code with Swift:

1. **Compiled approach** - Using generated code (Credentials.swift)
2. **Runtime approach** - Using .creds file + encryption key

Both examples use Swift to show that the same language can work for both fixed applications and runtime-configurable services.

## Setup

First, generate the credentials:

```bash
credential-code generate
```

This creates:
- `Generated/Credentials.swift` - For compiled approach
- `Generated/credentials.creds` - For runtime approach
- `.credential-code/encryption-key.txt` - Encryption key for both

## Example 1: Compiled Approach (Swift)

The Swift example shows how credentials are compiled into your application:

```bash
# Compile the Swift program with the generated credentials
swiftc print-from-swift.swift Generated/Credentials.swift -o print-from-swift

# Run it
./print-from-swift
```

**Pros:**
- No runtime files needed (after compilation)
- Credentials are obfuscated in the binary
- Type-safe access with enums

**Cons:**
- Need to recompile to change credentials
- Fixed at build time

## Example 2: Runtime Approach (Swift)

The Swift runtime example shows how to load credentials from .creds file:

```bash
# Compile the Swift program
swiftc print-from-creds.swift -o print-from-creds

# Run it
./print-from-creds
```

**Pros:**
- Can change credentials without recompiling the credential logic
- Easy to use different credentials per environment
- Same language (Swift) for both approaches
- Type-safe JSON parsing

**Cons:**
- Need to distribute .creds file and key
- Slightly more complex deployment

## Alternative Runtime Approaches

### Node.js Version

```bash
# Run directly (requires Node.js)
node print-from-creds.js
```

### Python Version

```bash
# Install dependency
pip install cryptography

# Run
python3 print-from-creds.py
```

These show the same .creds file approach works with any language.

## Output

All three programs produce the same output - the decrypted credentials in JSON format:

```json
{
  "API_KEY": "sk-dummy-api-key-123456",
  "DATABASE_URL": "postgresql://user:password@localhost:5432/myapp",
  "JWT_SECRET": "super-secret-jwt-signing-key-for-tokens",
  "AWS_ACCESS_KEY": "AKIAIOSFODNN7EXAMPLE",
  "AWS_SECRET_KEY": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "STRIPE_KEY": "sk_test_DUMMY1234567890EXAMPLE"
}
```

## When to Use Which Swift Approach?

### Use Compiled Approach (Method 1) When:
- Building iOS/macOS apps
- Creating command-line tools with fixed credentials
- Deploying to App Store
- Credentials are the same for all users
- Example: Magazine viewer app with single API key

### Use Runtime Approach (Method 2) When:
- Building server-side Swift applications
- Need different credentials per environment
- Using Docker/Kubernetes deployments
- Credentials change without recompiling
- Example: Multi-tenant backend service

Both approaches use Swift, showing its versatility for both client and server applications!

## Security Notes

1. **Never commit** the `.credential-code/` directory
2. **Never commit** `*.creds` files
3. Store the encryption key securely
4. Use different credentials for dev/staging/production