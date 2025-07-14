# Makefile for credential-code dual use examples

.PHONY: all clean generate swift node python

# Default target
all: generate swift

# Generate credentials
generate:
	@echo "=== Generating credentials ==="
	@credential-code generate

# Build and run Swift compiled example
swift-compiled: generate
	@echo "\n=== Building Swift compiled example ==="
	@swiftc print-from-swift.swift Generated/Credentials.swift -o print-from-swift
	@echo "\n=== Running Swift compiled example ==="
	@./print-from-swift

# Build and run Swift runtime example
swift-runtime: generate
	@echo "\n=== Building Swift runtime example ==="
	@swiftc print-from-creds.swift -parse-as-library -o print-from-creds
	@echo "\n=== Running Swift runtime example ==="
	@./print-from-creds

# Run both Swift examples
swift: swift-compiled swift-runtime

# Run Node.js example
node: generate
	@echo "\n=== Running Node.js example ==="
	@node print-from-creds.js

# Run Python example
python: generate
	@echo "\n=== Running Python example ==="
	@python3 print-from-creds.py

# Compare outputs
compare: swift node
	@echo "\n=== Both approaches produce the same credentials ==="

# Clean generated files
clean:
	@echo "=== Cleaning generated files ==="
	@rm -rf Generated/
	@rm -f print-from-swift print-from-creds
	@rm -f .credential-code/encryption-key.txt
	@echo "✅ Cleaned (keeping .credential-code/credentials.json)"