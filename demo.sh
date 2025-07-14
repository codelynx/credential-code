#!/bin/bash

# Demo script for credential-code
# Shows how to use the tool with different programming languages

set -e  # Exit on error

echo "🚀 Credential Code Demo"
echo "======================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build the tool first
echo -e "${BLUE}Building credential-code...${NC}"
swift build --configuration release
TOOL_PATH="../.build/release/credential-code"

# Create demo directory
DEMO_DIR="demo-projects"
rm -rf $DEMO_DIR
mkdir -p $DEMO_DIR
cd $DEMO_DIR

echo -e "\n${GREEN}✅ Created demo directory${NC}"

# Initialize credential storage
echo -e "\n${BLUE}Step 1: Initializing credential storage...${NC}"
$TOOL_PATH init

# Add some fake credentials
echo -e "\n${BLUE}Step 2: Adding fake credentials...${NC}"
cat > .credential-code/credentials.json << EOF
{
  "API_KEY": "sk-fake-1234567890abcdef",
  "DATABASE_URL": "postgres://demo:pass123@localhost:5432/myapp",
  "JWT_SECRET": "super-secret-jwt-key-for-demo",
  "STRIPE_KEY": "sk_test_fake_stripe_key_123",
  "AWS_SECRET_KEY": "fake-aws-secret-key-abcdef123456"
}
EOF

echo "Added fake credentials:"
cat .credential-code/credentials.json | jq 'keys[]' | sed 's/"//g' | sed 's/^/  - /'

# Create directories for each language
mkdir -p swift kotlin java python cpp

# Generate code for each language
echo -e "\n${BLUE}Step 3: Generating encrypted code for all languages...${NC}"

echo -e "\n${YELLOW}Swift (with external key - default):${NC}"
$TOOL_PATH generate --language swift --output swift/Credentials.swift
echo "  ✅ Generated swift/Credentials.swift"
echo "  ✅ Generated .credential-code/encryption-key.txt (encryption key)"
echo -e "  ${YELLOW}Note: Key is reused across regenerations${NC}"

echo -e "\n${YELLOW}Kotlin (embedded key for demo):${NC}"
$TOOL_PATH generate --language kotlin --output kotlin/Credentials.kt --embedded-key
echo "  ✅ Generated kotlin/Credentials.kt (with embedded key)"

echo -e "\n${YELLOW}Java (embedded key for demo):${NC}"
$TOOL_PATH generate --language java --output java/Credentials.java --embedded-key
echo "  ✅ Generated java/Credentials.java (with embedded key)"

echo -e "\n${YELLOW}Python (embedded key for demo):${NC}"
$TOOL_PATH generate --language python --output python/credentials.py --embedded-key
echo "  ✅ Generated python/credentials.py (with embedded key)"

echo -e "\n${YELLOW}C++ (embedded key for demo):${NC}"
$TOOL_PATH generate --language c++ --output cpp/credentials.cpp --embedded-key
echo "  ✅ Generated cpp/credentials.cpp (with embedded key)"

# Demonstrate external key mode with source code
echo -e "\n${BLUE}Step 3b: Generating with external key source (Swift example)...${NC}"
mkdir -p swift-external
$TOOL_PATH generate --language swift --output swift-external/Credentials.swift --external-key-source --key-source-output swift-external/CredentialKey.swift
echo "  ✅ Generated swift-external/Credentials.swift (without embedded key)"
echo "  ✅ Generated swift-external/CredentialKey.swift (key as source code)"
echo -e "${YELLOW}  ⚠️  Note: Key source file should be stored securely and never committed!${NC}"

# Create test programs for each language
echo -e "\n${BLUE}Step 4: Creating test programs...${NC}"

# Swift test program (external key mode)
cat > swift/test.swift << 'EOF'
import Foundation

@main
struct TestCredentials {
    static func main() {
        print("🔐 Swift Credential Test (External Key Mode)")
        print("============================================")
        
        do {
            // Load the external key
            try Credentials.loadKey(from: "../.credential-code/encryption-key.txt")
            print("✅ Loaded encryption key from file")
            
            // Access credentials
            let apiKey = try Credentials.get(.API_KEY)
            print("✅ API_KEY: \(apiKey)")
            
            let dbUrl = try Credentials.get(.DATABASE_URL)
            print("✅ DATABASE_URL: \(dbUrl)")
            
            let jwtSecret = try Credentials.get(.JWT_SECRET)
            print("✅ JWT_SECRET: \(jwtSecret)")
            
            // Test subscript access
            if let stripe = Credentials[.STRIPE_KEY] {
                print("✅ STRIPE_KEY (subscript): \(stripe)")
            }
            
            print("\n✨ External key mode working correctly!")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
EOF

# Kotlin test program
cat > kotlin/Test.kt << 'EOF'
fun main() {
    println("🔐 Kotlin Credential Test")
    println("========================")
    
    Credentials.decrypt(CredentialKey.API_KEY)?.let {
        println("✅ API_KEY: $it")
    }
    
    Credentials.decrypt(CredentialKey.DATABASE_URL)?.let {
        println("✅ DATABASE_URL: $it")
    }
    
    Credentials.decrypt(CredentialKey.JWT_SECRET)?.let {
        println("✅ JWT_SECRET: $it")
    }
    
    // Test caching
    println("\n📦 Testing cached access...")
    Credentials.decryptCached(CredentialKey.STRIPE_KEY)?.let {
        println("✅ STRIPE_KEY (cached): $it")
    }
    
    Credentials.clearCache()
    println("🧹 Cache cleared")
}
EOF

# Java test program
cat > java/Test.java << 'EOF'
public class Test {
    public static void main(String[] args) {
        System.out.println("🔐 Java Credential Test");
        System.out.println("======================");
        
        String apiKey = Credentials.decrypt(Credentials.CredentialKey.API_KEY);
        if (apiKey != null) {
            System.out.println("✅ API_KEY: " + apiKey);
        }
        
        String dbUrl = Credentials.decrypt(Credentials.CredentialKey.DATABASE_URL);
        if (dbUrl != null) {
            System.out.println("✅ DATABASE_URL: " + dbUrl);
        }
        
        String jwtSecret = Credentials.decrypt(Credentials.CredentialKey.JWT_SECRET);
        if (jwtSecret != null) {
            System.out.println("✅ JWT_SECRET: " + jwtSecret);
        }
        
        // Test caching
        System.out.println("\n📦 Testing cached access...");
        String stripe = Credentials.decryptCached(Credentials.CredentialKey.STRIPE_KEY);
        if (stripe != null) {
            System.out.println("✅ STRIPE_KEY (cached): " + stripe);
        }
        
        Credentials.clearCache();
        System.out.println("🧹 Cache cleared");
    }
}
EOF

# Python test program
cat > python/test.py << 'EOF'
#!/usr/bin/env python3
from credentials import Credentials, CredentialKey

print("🔐 Python Credential Test")
print("========================")

api_key = Credentials.decrypt(CredentialKey.API_KEY)
if api_key:
    print(f"✅ API_KEY: {api_key}")

db_url = Credentials.decrypt(CredentialKey.DATABASE_URL)
if db_url:
    print(f"✅ DATABASE_URL: {db_url}")

jwt_secret = Credentials.decrypt(CredentialKey.JWT_SECRET)
if jwt_secret:
    print(f"✅ JWT_SECRET: {jwt_secret}")

# Test caching
print("\n📦 Testing cached access...")
stripe = Credentials.decrypt_cached(CredentialKey.STRIPE_KEY)
if stripe:
    print(f"✅ STRIPE_KEY (cached): {stripe}")

Credentials.clear_cache()
print("🧹 Cache cleared")
EOF

# C++ test program (header file)
cat > cpp/test.cpp << 'EOF'
#include <iostream>
#include <string>

// Note: In a real project, you would include the generated credentials.h
// For this demo, we're showing the structure

int main() {
    std::cout << "🔐 C++ Credential Test" << std::endl;
    std::cout << "=====================" << std::endl;
    
    std::cout << "Note: C++ implementation requires OpenSSL" << std::endl;
    std::cout << "The generated code is in credentials.cpp" << std::endl;
    
    // Example of how it would be used:
    // auto apiKey = Credentials::decrypt(CredentialKey::API_KEY);
    // if (apiKey) {
    //     std::cout << "✅ API_KEY: " << *apiKey << std::endl;
    // }
    
    return 0;
}
EOF

# Swift external key test program
cat > swift-external/test.swift << 'EOF'
import Foundation

@main
struct TestExternalKeyCredentials {
    static func main() {
        print("🔐 Swift External Key Source Test")
        print("=================================")
        
        do {
            // No need to load key - it's provided by CredentialKeyProvider
            print("✅ Using key from CredentialKeyProvider.swift")
            
            // Access credentials directly
            let apiKey = try Credentials.get(.API_KEY)
            print("✅ API_KEY: \(apiKey)")
            
            let dbUrl = try Credentials.get(.DATABASE_URL)
            print("✅ DATABASE_URL: \(dbUrl)")
            
            // Test subscript access
            if let jwtSecret = Credentials[.JWT_SECRET] {
                print("✅ JWT_SECRET (subscript): \(jwtSecret)")
            }
            
            print("\n✨ External key source mode working correctly!")
            print("   Key is provided as source code.")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
EOF

# Create build scripts for compiled languages
echo -e "\n${BLUE}Step 5: Creating build scripts...${NC}"

# Kotlin build script
cat > kotlin/build.sh << 'EOF'
#!/bin/bash
echo "Building Kotlin..."
# Remove package declaration for simple compilation
sed '1d' Credentials.kt > CredentialsNoPackage.kt
kotlinc CredentialsNoPackage.kt Test.kt -include-runtime -d test.jar
echo "Run with: java -jar test.jar"
EOF
chmod +x kotlin/build.sh

# Java build script
cat > java/build.sh << 'EOF'
#!/bin/bash
echo "Building Java..."
# Remove package declaration for simple compilation
sed '1d' Credentials.java > CredentialsNoPackage.java
javac CredentialsNoPackage.java Test.java
echo "Run with: java Test"
EOF
chmod +x java/build.sh

# Create a summary README
cat > README.md << 'EOF'
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
EOF

echo -e "\n${BLUE}Step 6: Running tests...${NC}"

# Run Swift test
if command -v swiftc &> /dev/null; then
    echo -e "\n${YELLOW}Running Swift test:${NC}"
    cd swift
    swiftc test.swift Credentials.swift -o test 2>/dev/null && ./test
    cd ..
    
    echo -e "\n${YELLOW}Running Swift external key source test:${NC}"
    cd swift-external
    swiftc test.swift Credentials.swift CredentialKey.swift -o test 2>/dev/null && ./test
    cd ..
else
    echo -e "\n${YELLOW}Swift compiler not found, skipping Swift test${NC}"
fi

# Run Python test
if command -v python3 &> /dev/null; then
    echo -e "\n${YELLOW}Running Python test:${NC}"
    cd python
    if python3 -c "import cryptography" 2>/dev/null; then
        python3 test.py
    else
        echo "Note: Python cryptography module not installed"
        echo "Install with: pip install cryptography"
    fi
    cd ..
else
    echo -e "\n${YELLOW}Python 3 not found, skipping Python test${NC}"
fi

echo -e "\n${GREEN}✅ Demo complete!${NC}"
echo -e "\nCheck out the ${YELLOW}demo-projects/${NC} directory to see:"
echo "  • How credentials are stored (plain text JSON)"
echo "  • Generated encrypted code for each language"
echo "  • Example usage in each language"
echo ""
echo "To regenerate with different credentials:"
echo "  1. Edit demo-projects/.credential-code/credentials.json"
echo "  2. Run: credential-code generate --language <language>"