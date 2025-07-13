# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- External key support with `--external-key` flag for enhanced security
- `--key-file` option to specify custom key file path
- External key as source code with `--external-key-source` flag
- `--key-source-output` option to specify custom key source file path
- New methods for Swift: `loadKey()`, `initialize()` for external key management
- Support for separating encryption keys from generated code
- Integration examples for AWS Secrets Manager and other key management systems
- Clear security warnings about not using this tool for open source projects

### Changed
- **BREAKING CHANGE**: Simplified JSON structure for `credentials.json`. The `"credentials"` wrapper object has been removed.
  
  **Before:**
  ```json
  {
    "credentials": {
      "API_KEY": "value",
      "DATABASE_URL": "value"
    }
  }
  ```
  
  **After:**
  ```json
  {
    "API_KEY": "value",
    "DATABASE_URL": "value"
  }
  ```
  
  **Migration:** Users must update their `.credential-code/credentials.json` files by removing the `"credentials"` wrapper and moving all key-value pairs to the root level.

### Initial Release Features
- Swift, Kotlin, Java, Python, and C++ code generation
- AES-256-GCM encryption for credentials
- Type-safe credential access
- In-memory caching support
- Secure credential storage with `.gitignore` integration