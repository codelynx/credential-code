#!/bin/bash

echo "=== Credential Code Dual Use Demo ==="
echo
echo "This demo shows two Swift approaches to access the same credentials:"
echo "1. Compiled into the application (using Credentials.swift)"
echo "2. Loaded at runtime from .creds file"
echo

# Check if credentials exist
if [ ! -f "Generated/Credentials.swift" ] || [ ! -f "Generated/credentials.creds" ] || [ ! -f ".credential-code/encryption-key.txt" ]; then
    echo "Generating credentials first..."
    if [ -f "../.build/release/credential-code" ]; then
        ../.build/release/credential-code generate
    elif command -v credential-code &> /dev/null; then
        credential-code generate
    else
        echo "Error: credential-code not found. Please install it first."
        exit 1
    fi
    echo
fi

# Compile and run Swift example
echo "=== Method 1: Compiled Approach (Swift) ==="
echo "Compiling Swift program with credentials..."
if swiftc print-from-swift.swift Generated/Credentials.swift -o print-from-swift; then
    echo "Running..."
    ./print-from-swift
else
    echo "Error: Swift compilation failed. Make sure Swift is installed."
    echo "Try: swift --version"
fi

echo
echo "=== Method 2: Runtime Approach (Swift) ==="
echo "Compiling Swift program that loads .creds file..."
if swiftc print-from-creds.swift -parse-as-library -o print-from-creds; then
    echo "Running..."
    ./print-from-creds
else
    echo "Error: Swift compilation failed. Make sure Swift is installed."
    echo "Try: swift --version"
fi

# Also show Node.js version if available
if command -v node &> /dev/null; then
    echo
    echo "=== Alternative: Runtime Approach (Node.js) ==="
    node print-from-creds.js
fi

echo
echo "=== Summary ==="
echo "The two methods use different approaches:"
echo "- Method 1: Self-contained binary with embedded key (Credentials.swift)"
echo "- Method 2: Runtime configuration with external key (.creds + encryption-key.txt)"
echo
echo "Method 1 generates a new key each build (embedded in code)"
echo "Method 2 uses a persistent key for consistent decryption across deployments"
echo
echo "This shows the flexibility of credential-code for different deployment scenarios!"