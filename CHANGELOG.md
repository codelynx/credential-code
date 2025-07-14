# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Non-Swift languages now automatically fall back to embedded key mode with a warning message instead of throwing an error
- Added clear documentation about external key support being Swift-only currently

### Added
- External key support with `--external-key` flag for enhanced security
- `--key-file` option to specify custom key file path
- External key as source code with `--external-key-source` flag
- `--key-source-output` option to specify custom key source file path
- New methods for Swift: `loadKey()`, `initialize()` for external key management
- Support for separating encryption keys from generated code
- Integration examples for AWS Secrets Manager and other key management systems
- Clear security warnings about not using this tool for open source projects
- Key persistence: encryption key is saved to `.credential-code/encryption-key.txt` and reused across builds
- Plain text base64 key format for easy copying and manual use
- `.creds` file generation with `--generate-creds` flag for backend/runtime use
- `--creds-output` option to specify custom .creds file path
- Support for generating both code and .creds files in single command

### Changed
- **BREAKING CHANGE**: External key mode is now the default behavior
  - `credential-code generate` now creates an external key file by default
  - Key is stored in `.credential-code/encryption-key.txt` as base64 string
  - Use `--embedded-key` flag to restore old behavior with embedded keys
  - Key is displayed when first generated for manual backup
- **BREAKING CHANGE**: .creds file generation is now default
  - `credential-code generate` now creates both code and .creds files by default
  - Use `--no-generate-creds` flag to disable .creds generation
  - Both files use the same encryption key for consistency
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