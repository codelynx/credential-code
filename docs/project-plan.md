# Credential Code - Project Plan

## Overview

Credential Code is a Swift-based command-line tool that securely manages sensitive credentials (passwords, API keys, secret keys) for projects in any language by encrypting them at build time rather than storing them as plain text in source code. The CLI is written in Swift but generates secure credential access code for Swift, Kotlin, Java, C/C++, Python, and more.

## Problem Statement

- Hard-coded credentials in source code are a security risk
- Credentials in repositories can be exposed through version control
- Even compiled binaries can be reverse-engineered to extract plain text secrets
- Need a solution that allows secure credential management while maintaining ease of use

## Solution Architecture

### Components

1. **CLI Tool** (`credential-code`) - Written in Swift
   - `init` command: Creates credentials infrastructure
   - `generate` command: Processes credentials and generates code for target language
   - `add` command: Add new credentials
   - `list` command: List existing credentials (keys only, not values)
   - `remove` command: Remove credentials

2. **Credentials Storage**
   - `credentials.json`: Stores encrypted credential data
   - `credentials.key`: Encryption key file (should be in .gitignore)
   - Both files stored in `.credential-code/` directory

3. **Generated Code** (Language-specific)
   - Auto-generated file containing encrypted byte arrays
   - Runtime decryption helper functions
   - Type-safe credential access API
   - Supports: Swift, Kotlin, Java, C/C++, Python, JavaScript/TypeScript, Go, Rust

### Workflow

1. **Initialization**
   ```bash
   credential-code init
   ```
   - Creates `.credential-code/` directory
   - Generates encryption key (`credentials.key`)
   - Creates empty `credentials.json`
   - Adds entries to `.gitignore`

2. **Adding Credentials**
   ```bash
   credential-code add API_KEY "your-secret-key"
   ```
   - Encrypts the value using `credentials.key`
   - Stores encrypted data in `credentials.json`

3. **Code Generation**
   ```bash
   credential-code generate --language kotlin
   credential-code generate --language java --output src/main/java/Credentials.java
   credential-code generate --language swift  # default
   ```
   - Reads `credentials.json` and `credentials.key`
   - Generates language-specific code with encrypted byte arrays
   - Includes runtime decryption logic for the target language

4. **Usage in Client Code**
   ```swift
   // Swift
   let apiKey = Credentials.decrypt(.API_KEY)
   ```
   ```kotlin
   // Kotlin
   val apiKey = Credentials.decrypt(CredentialKey.API_KEY)
   ```
   ```java
   // Java
   String apiKey = Credentials.decrypt(CredentialKey.API_KEY);
   ```

## Technical Design

### Encryption Strategy

- **Algorithm**: AES-256-GCM (authenticated encryption)
- **Key Generation**: Cryptographically secure random key
- **Storage Format**: Base64 encoded encrypted data with metadata

### Generated Code Structure

```swift
// Auto-generated Credentials.swift
enum CredentialKey: String {
    case API_KEY
    case DATABASE_PASSWORD
    // ... other keys
}

struct Credentials {
    private static let encryptedData: [CredentialKey: [UInt8]] = [
        .API_KEY: [0x12, 0x34, 0x56, ...], // Encrypted bytes
        .DATABASE_PASSWORD: [0xAB, 0xCD, 0xEF, ...]
    ]
    
    static func decrypt(_ key: CredentialKey) -> String? {
        // Runtime decryption logic
    }
}
```

### Security Considerations

1. **Key Management**
   - `credentials.key` must never be committed to version control
   - Should be stored securely (environment variable, CI/CD secrets, etc.)
   - Different keys for different environments (dev, staging, prod)

2. **Build-time Security**
   - Credentials are only decrypted during code generation
   - Generated code contains only encrypted data
   - No plain text credentials in source or binary

3. **Runtime Security**
   - Credentials decrypted in memory only when needed
   - Consider implementing credential caching with timeout
   - Clear sensitive data from memory after use

## Implementation Phases

### Phase 1: Core Functionality
- [ ] Basic CLI structure
- [ ] `init` command implementation
- [ ] Simple encryption/decryption
- [ ] Basic code generation

### Phase 2: Credential Management
- [ ] `add`, `list`, `remove` commands
- [ ] Credential validation
- [ ] Update existing credentials
- [ ] Import/export functionality

### Phase 3: Advanced Features
- [ ] Multiple environment support
- [ ] Credential rotation helpers
- [ ] Integration with CI/CD systems
- [ ] Xcode build phase integration

### Phase 4: Security Enhancements
- [ ] Key derivation functions
- [ ] Hardware security module support
- [ ] Audit logging
- [ ] Credential access policies

## Technology Stack

- **Language**: Swift
- **CLI Framework**: Swift Argument Parser
- **Encryption**: CryptoKit (Apple's native crypto framework)
- **JSON Handling**: Foundation's JSONEncoder/Decoder
- **File I/O**: Foundation's FileManager

## Project Structure

```
credential-code/
├── Sources/
│   ├── SwiftCredentials/
│   │   ├── main.swift
│   │   ├── Commands/
│   │   │   ├── InitCommand.swift
│   │   │   ├── GenerateCommand.swift
│   │   │   ├── AddCommand.swift
│   │   │   └── ...
│   │   ├── Crypto/
│   │   │   ├── Encryptor.swift
│   │   │   └── KeyManager.swift
│   │   ├── Generators/
│   │   │   ├── CodeGenerator.swift          // Protocol
│   │   │   ├── SwiftCodeGenerator.swift
│   │   │   ├── KotlinCodeGenerator.swift
│   │   │   ├── JavaCodeGenerator.swift
│   │   │   ├── CCodeGenerator.swift
│   │   │   ├── PythonCodeGenerator.swift
│   │   │   └── ...
│   │   └── Models/
│   │       └── Credential.swift
├── Tests/
├── Package.swift
└── README.md
```

## Success Metrics

- Zero plain text credentials in source code
- Simple integration process (< 5 minutes setup)
- Minimal runtime performance impact
- Support for all major Swift platforms (iOS, macOS, etc.)
- Clear security audit trail

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Key file accidentally committed | Git hooks, clear documentation, .gitignore templates |
| Weak encryption implementation | Use established crypto libraries, security review |
| Complex integration process | Provide clear docs, examples, and automation scripts |
| Runtime decryption overhead | Implement caching, benchmark performance |

## Detailed Example: How Generate Works

### Step-by-Step Process

#### 1. Initial Setup
After running `credential-code init` and adding credentials:

**.credential-code/credentials.json**
```json
{
  "credentials": {
    "API_KEY": "YXNkZmFzZGZhc2RmYXNkZg==",
    "DATABASE_PASSWORD": "cXdlcnR5dWlvcGFzZGZnaGo="
  }
}
```

**.credential-code/credentials.key**
```
sKYw5rJP5LYe6GuUYmKRpF2c7x9TdGwA3fK8hBxCnWQ=
```

**Note on Encryption Format**: The encrypted values in `credentials.json` are actually AES-GCM sealed boxes that contain:
- The encrypted data
- A 12-byte nonce (IV)
- A 16-byte authentication tag

These are concatenated and Base64 encoded as a single value. During the `generate` command, they are parsed and separated for use in the generated code. This keeps the JSON file simple while maintaining cryptographic security.

#### 2. Running Generate Command
```bash
credential-code generate
```

The command performs these steps:
1. Reads the encryption key from `credentials.key`
2. Reads all encrypted credentials from `credentials.json`
3. Re-encrypts each credential with a new runtime key embedded in the code
4. Generates Swift source code with the encrypted data

#### 3. Generated Output

**Generated/Credentials.swift**
```swift
// Auto-generated by credential-code
// DO NOT EDIT - This file will be overwritten

import Foundation
import CryptoKit

public enum CredentialKey: String, CaseIterable {
    case API_KEY = "API_KEY"
    case DATABASE_PASSWORD = "DATABASE_PASSWORD"
}

public struct Credentials {
    // Encrypted credential data as byte arrays
    private static let encryptedData: [CredentialKey: (data: [UInt8], nonce: [UInt8], tag: [UInt8])] = [
        .API_KEY: (
            data: [0x61, 0x73, 0x64, 0x66, 0x61, 0x73, 0x64, 0x66, 0x61, 0x73, 0x64, 0x66, 0x61, 0x73, 0x64, 0x66],
            nonce: [0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32],
            tag: [0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70]
        ),
        .DATABASE_PASSWORD: (
            data: [0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69, 0x6F, 0x70, 0x61, 0x73, 0x64, 0x66, 0x67, 0x68],
            nonce: [0x39, 0x38, 0x37, 0x36, 0x35, 0x34, 0x33, 0x32, 0x31, 0x30, 0x39, 0x38],
            tag: [0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x30]
        )
    ]
    
    // Runtime decryption key (obfuscated)
    private static let keyComponents: [[UInt8]] = [
        [0xB0, 0xA6, 0x30, 0xE6],
        [0xB2, 0x4F, 0xE4, 0xB6],
        [0x1E, 0xE8, 0x6B, 0x94],
        [0x62, 0x62, 0x91, 0xA4],
        [0x5D, 0x9C, 0xEF, 0x1F],
        [0x53, 0x74, 0x6C, 0x00],
        [0xDD, 0xF2, 0xBC, 0x84],
        [0x1C, 0x42, 0x9D, 0x64]
    ]
    
    // Decrypt a credential at runtime
    public static func decrypt(_ key: CredentialKey) -> String? {
        guard let encryptedInfo = encryptedData[key] else { return nil }
        
        // Reconstruct the decryption key
        let keyData = keyComponents.flatMap { $0 }
        let symmetricKey = SymmetricKey(data: keyData)
        
        // Convert arrays to Data
        let encryptedData = Data(encryptedInfo.data)
        let nonce = try? AES.GCM.Nonce(data: Data(encryptedInfo.nonce))
        let tag = Data(encryptedInfo.tag)
        
        guard let nonce = nonce else { return nil }
        
        // Create sealed box for decryption
        let sealedBox = try? AES.GCM.SealedBox(
            nonce: nonce,
            ciphertext: encryptedData,
            tag: tag
        )
        
        guard let sealedBox = sealedBox else { return nil }
        
        // Decrypt
        do {
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    // Optional: Decrypt with caching
    private static var cache: [CredentialKey: String] = [:]
    
    public static func decryptCached(_ key: CredentialKey) -> String? {
        if let cached = cache[key] {
            return cached
        }
        
        guard let decrypted = decrypt(key) else { return nil }
        cache[key] = decrypted
        return decrypted
    }
    
    // Clear cache when needed
    public static func clearCache() {
        cache.removeAll()
    }
}
```

### How Runtime Decryption Works

When you call `Credentials.decrypt(.API_KEY)`:

1. **Lookup Encrypted Data**: The method looks up the encrypted byte array, nonce, and authentication tag for the requested credential key

2. **Reconstruct Decryption Key**: The decryption key is stored as separate components to make it harder to extract via static analysis. These components are combined at runtime

3. **Prepare Decryption Parameters**: The byte arrays are converted to the appropriate CryptoKit types (Data, Nonce, SealedBox)

4. **Perform AES-GCM Decryption**: Using Apple's CryptoKit, the encrypted data is decrypted using authenticated encryption (AES-GCM)

5. **Return Plain Text**: If decryption succeeds, the plain text credential is returned as a String

### Security Benefits

1. **No Plain Text in Binary**: The actual credentials never appear as strings in the compiled binary
2. **Authenticated Encryption**: AES-GCM ensures data integrity - any tampering will cause decryption to fail
3. **Obfuscated Key Storage**: The decryption key is split into components, making it harder to extract
4. **Runtime-Only Access**: Credentials only exist in decrypted form in memory during runtime

### Usage in Your App

```swift
// Simple usage
if let apiKey = Credentials.decrypt(.API_KEY) {
    // Use the API key for your network request
    let headers = ["Authorization": "Bearer \(apiKey)"]
    // Make API call...
}

// With caching (for frequently accessed credentials)
if let dbPassword = Credentials.decryptCached(.DATABASE_PASSWORD) {
    // Connect to database
    let connection = Database.connect(password: dbPassword)
}

// Clear sensitive data when done
Credentials.clearCache()
```

### Build Integration

Add to your Xcode build phases:
```bash
# Run before Compile Sources
credential-code generate --output "${SRCROOT}/Generated/Credentials.swift"
```

This ensures credentials are always up-to-date when building your app.

## Cross-Platform Extension

### Extending to Other Languages

The same concept can be applied to other programming languages. The CLI tool would generate language-specific code while maintaining the same security principles.

#### Kotlin/Android

**Generated Credentials.kt**
```kotlin
// Auto-generated by credential-code
package com.example.app.credentials

import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.util.Base64

enum class CredentialKey {
    API_KEY,
    DATABASE_PASSWORD
}

object Credentials {
    // Encrypted credential data as byte arrays
    private val encryptedData = mapOf(
        CredentialKey.API_KEY to EncryptedData(
            data = byteArrayOf(0x61, 0x73, 0x64, 0x66, 0x61, 0x73, 0x64, 0x66),
            nonce = byteArrayOf(0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38),
            tag = byteArrayOf(0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68)
        ),
        CredentialKey.DATABASE_PASSWORD to EncryptedData(
            data = byteArrayOf(0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69),
            nonce = byteArrayOf(0x39, 0x38, 0x37, 0x36, 0x35, 0x34, 0x33, 0x32),
            tag = byteArrayOf(0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73)
        )
    )
    
    // Runtime decryption key (obfuscated)
    private val keyComponents = arrayOf(
        byteArrayOf(0xB0.toByte(), 0xA6.toByte(), 0x30, 0xE6.toByte()),
        byteArrayOf(0xB2.toByte(), 0x4F, 0xE4.toByte(), 0xB6.toByte()),
        // ... more components
    )
    
    fun decrypt(key: CredentialKey): String? {
        val encrypted = encryptedData[key] ?: return null
        
        try {
            // Reconstruct the decryption key
            val keyData = keyComponents.flatMap { it.toList() }.toByteArray()
            val secretKey = SecretKeySpec(keyData, "AES")
            
            // Setup cipher for AES-GCM
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            val gcmSpec = GCMParameterSpec(128, encrypted.nonce)
            cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec)
            
            // Combine ciphertext and tag for decryption
            val cipherTextWithTag = encrypted.data + encrypted.tag
            val decrypted = cipher.doFinal(cipherTextWithTag)
            
            return String(decrypted, Charsets.UTF_8)
        } catch (e: Exception) {
            return null
        }
    }
    
    // Usage in Kotlin
    // val apiKey = Credentials.decrypt(CredentialKey.API_KEY)
}

private data class EncryptedData(
    val data: ByteArray,
    val nonce: ByteArray,
    val tag: ByteArray
)
```

#### Java

**Generated Credentials.java**
```java
// Auto-generated by credential-code
package com.example.app.credentials;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public final class Credentials {
    public enum CredentialKey {
        API_KEY,
        DATABASE_PASSWORD
    }
    
    private static final Map<CredentialKey, EncryptedData> encryptedData;
    private static final byte[][] keyComponents;
    
    static {
        // Initialize encrypted data
        encryptedData = new HashMap<>();
        encryptedData.put(CredentialKey.API_KEY, new EncryptedData(
            new byte[]{0x61, 0x73, 0x64, 0x66},
            new byte[]{0x31, 0x32, 0x33, 0x34},
            new byte[]{0x61, 0x62, 0x63, 0x64}
        ));
        
        // Initialize key components
        keyComponents = new byte[][]{
            {(byte)0xB0, (byte)0xA6, 0x30, (byte)0xE6},
            {(byte)0xB2, 0x4F, (byte)0xE4, (byte)0xB6}
        };
    }
    
    public static String decrypt(CredentialKey key) {
        EncryptedData encrypted = encryptedData.get(key);
        if (encrypted == null) return null;
        
        try {
            // Reconstruct key
            byte[] keyData = reconstructKey();
            SecretKeySpec secretKey = new SecretKeySpec(keyData, "AES");
            
            // Decrypt
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            GCMParameterSpec gcmSpec = new GCMParameterSpec(128, encrypted.nonce);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec);
            
            byte[] decrypted = cipher.doFinal(
                concatenate(encrypted.data, encrypted.tag)
            );
            
            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            return null;
        }
    }
    
    // Usage in Java
    // String apiKey = Credentials.decrypt(CredentialKey.API_KEY);
}
```

#### C/C++

**Generated credentials.h**
```c
// Auto-generated by credential-code
#ifndef CREDENTIALS_H
#define CREDENTIALS_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    CREDENTIAL_API_KEY,
    CREDENTIAL_DATABASE_PASSWORD
} credential_key_t;

// Decrypt and return credential (caller must free result)
char* credentials_decrypt(credential_key_t key);

// Secure memory cleanup
void credentials_secure_free(char* credential);

#ifdef __cplusplus
}
#endif

#endif // CREDENTIALS_H
```

**Generated credentials.c**
```c
// Auto-generated by credential-code
#include "credentials.h"
#include <string.h>
#include <stdlib.h>
#include <openssl/evp.h>
#include <openssl/aes.h>

typedef struct {
    const unsigned char* data;
    size_t data_len;
    const unsigned char* nonce;
    const unsigned char* tag;
} encrypted_data_t;

// Encrypted data as static arrays
static const unsigned char api_key_data[] = {0x61, 0x73, 0x64, 0x66};
static const unsigned char api_key_nonce[] = {0x31, 0x32, 0x33, 0x34};
static const unsigned char api_key_tag[] = {0x61, 0x62, 0x63, 0x64};

// Key components (obfuscated)
static const unsigned char key_parts[][4] = {
    {0xB0, 0xA6, 0x30, 0xE6},
    {0xB2, 0x4F, 0xE4, 0xB6}
};

static const encrypted_data_t credentials[] = {
    [CREDENTIAL_API_KEY] = {
        .data = api_key_data,
        .data_len = sizeof(api_key_data),
        .nonce = api_key_nonce,
        .tag = api_key_tag
    }
};

char* credentials_decrypt(credential_key_t key) {
    if (key >= sizeof(credentials) / sizeof(credentials[0])) {
        return NULL;
    }
    
    const encrypted_data_t* encrypted = &credentials[key];
    
    // Reconstruct key
    unsigned char full_key[32];
    reconstruct_key(full_key);
    
    // Setup decryption context
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) return NULL;
    
    // Initialize AES-GCM decryption
    if (!EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, full_key, encrypted->nonce)) {
        EVP_CIPHER_CTX_free(ctx);
        return NULL;
    }
    
    // Allocate output buffer
    char* output = malloc(encrypted->data_len + 1);
    if (!output) {
        EVP_CIPHER_CTX_free(ctx);
        return NULL;
    }
    
    // Decrypt
    int len;
    if (!EVP_DecryptUpdate(ctx, (unsigned char*)output, &len, 
                          encrypted->data, encrypted->data_len)) {
        free(output);
        EVP_CIPHER_CTX_free(ctx);
        return NULL;
    }
    
    // Set tag
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, (void*)encrypted->tag);
    
    // Finalize
    int final_len;
    if (!EVP_DecryptFinal_ex(ctx, (unsigned char*)output + len, &final_len)) {
        free(output);
        EVP_CIPHER_CTX_free(ctx);
        return NULL;
    }
    
    output[len + final_len] = '\0';
    EVP_CIPHER_CTX_free(ctx);
    
    // Clear key from memory
    memset(full_key, 0, sizeof(full_key));
    
    return output;
}

void credentials_secure_free(char* credential) {
    if (credential) {
        size_t len = strlen(credential);
        memset(credential, 0, len);
        free(credential);
    }
}

// Usage in C
// char* api_key = credentials_decrypt(CREDENTIAL_API_KEY);
// // Use api_key...
// credentials_secure_free(api_key);
```

### Language-Specific Considerations

#### Kotlin/Java
- Use Java Cryptography Architecture (JCA)
- Consider Android Keystore for additional protection on Android
- Handle checked exceptions appropriately
- Use `char[]` instead of `String` for sensitive data when possible

#### C/C++
- Manual memory management required
- Use secure memory clearing functions
- Consider using libsodium for simpler crypto API
- Platform-specific secure memory allocation (e.g., `mlock()`)

#### Python (Bonus)
```python
# Generated credentials.py
import base64
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from enum import Enum

class CredentialKey(Enum):
    API_KEY = "API_KEY"
    DATABASE_PASSWORD = "DATABASE_PASSWORD"

class Credentials:
    _encrypted_data = {
        CredentialKey.API_KEY: {
            'data': bytes([0x61, 0x73, 0x64, 0x66]),
            'nonce': bytes([0x31, 0x32, 0x33, 0x34]),
            'tag': bytes([0x61, 0x62, 0x63, 0x64])
        }
    }
    
    _key_components = [
        bytes([0xB0, 0xA6, 0x30, 0xE6]),
        bytes([0xB2, 0x4F, 0xE4, 0xB6])
    ]
    
    @staticmethod
    def decrypt(key: CredentialKey) -> str:
        encrypted = Credentials._encrypted_data.get(key)
        if not encrypted:
            return None
            
        # Reconstruct key
        full_key = b''.join(Credentials._key_components)
        
        # Decrypt
        aesgcm = AESGCM(full_key)
        decrypted = aesgcm.decrypt(
            encrypted['nonce'],
            encrypted['data'] + encrypted['tag'],
            None
        )
        
        return decrypted.decode('utf-8')

# Usage: api_key = Credentials.decrypt(CredentialKey.API_KEY)
```

### Swift CLI Architecture

The Swift-based CLI tool includes:

1. **Code Generator Protocol**
   ```swift
   protocol CodeGenerator {
       var language: String { get }
       var defaultFileName: String { get }
       func generate(credentials: [Credential], key: Data) throws -> GeneratedCode
   }
   
   struct GeneratedCode {
       let mainFile: String
       let headerFile: String?  // For C/C++
       let additionalFiles: [String: String]?  // For multi-file outputs
   }
   ```

2. **Language-Specific Generators**
   - Each language has its own generator implementing the protocol
   - Handles language-specific idioms and best practices
   - Generates idiomatic code for each platform

3. **CLI Commands**
   ```bash
   # Generate for different languages
   credential-code generate --language swift
   credential-code generate --language kotlin --package com.example.app
   credential-code generate --language java --output src/main/java/Credentials.java
   credential-code generate --language python --output credentials.py
   credential-code generate --language c --output src/credentials.c --header include/credentials.h
   
   # List supported languages
   credential-code languages
   ```

4. **Build Tool Integration**
   ```bash
   # Xcode Build Phase
   credential-code generate --language swift --output "${SRCROOT}/Generated/Credentials.swift"
   
   # Gradle Task
   credential-code generate --language kotlin --output "${projectDir}/src/main/kotlin/Credentials.kt"
   
   # CMake
   credential-code generate --language c --output "${CMAKE_CURRENT_SOURCE_DIR}/src/credentials.c"
   ```

## Next Steps

1. Set up Swift package structure
2. Implement basic CLI with Swift Argument Parser
3. Create encryption/decryption proof of concept
4. Design JSON schema for credentials storage
5. Implement code generation logic