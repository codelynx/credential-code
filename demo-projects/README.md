# Credential Code Demo Projects

This directory contains example projects showing how to use `credential-code` with different programming languages.

## Structure

```
demo-projects/
├── .credential-code/
│   └── credentials.json       # Plain text credentials (git-ignored)
├── swift/
│   ├── Credentials.swift      # Generated encrypted code
│   └── test.swift            # Example usage
├── swift-external/           # External key source example
│   ├── Credentials.swift     # Generated code (no embedded key)
│   ├── CredentialKey.swift  # Key as source code
│   └── test.swift           # Example usage with external key source
├── kotlin/
│   ├── Credentials.kt        # Generated encrypted code
│   └── Test.kt              # Example usage
├── java/
│   ├── Credentials.java      # Generated encrypted code
│   └── Test.java            # Example usage
├── python/
│   ├── credentials.py        # Generated encrypted code
│   └── test.py              # Example usage
└── cpp/
    ├── credentials.cpp       # Generated encrypted code
    └── test.cpp             # Example structure
```

## Running the Examples

### Swift
```bash
cd swift
swiftc test.swift Credentials.swift -o test
./test
```

### Swift with External Key Source
```bash
cd swift-external
swiftc test.swift Credentials.swift CredentialKey.swift -o test
./test
```

### Python
```bash
cd python
# Install cryptography if needed: pip install cryptography
python3 test.py
```

### Kotlin
```bash
cd kotlin
./build.sh
java -jar test.jar
```

### Java
```bash
cd java
./build.sh
java Test
```

### C++
The C++ code requires OpenSSL and proper build configuration.

## How It Works

1. Credentials are stored in plain text in `.credential-code/credentials.json`
2. Running `credential-code generate` creates encrypted code for each language
3. Each generated file contains:
   - Encrypted credential data as byte arrays
   - Runtime decryption logic
   - Type-safe credential access
4. The encryption key is randomly generated for each build
5. No plain text credentials appear in the generated code

## Security Notes

- Never commit `.credential-code/` to version control
- The generated code files are safe to commit
- Each build uses a different encryption key
- Credentials are only decrypted in memory at runtime
