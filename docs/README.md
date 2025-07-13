# Documentation Index

Welcome to the credential-code documentation. This index helps you find the right documentation for your needs.

## Getting Started
- [Quick Start Guide](QUICK_START.md) - Get up and running in 5 minutes
- [Main README](../README.md) - Project overview and installation
- [日本語 README](../README-ja.md) - Japanese documentation

## Core Documentation
- [Security Model](SECURITY.md) - Understand the security architecture and threat model
- [External Key Usage Guide](EXTERNAL_KEY_GUIDE.md) - Complete guide for external key features
- [Changelog](../CHANGELOG.md) - Version history and breaking changes

## Examples and Demos
- [Demo Script](../demo.sh) - Comprehensive demonstration of all features
- Demo Projects README - Generated after running demo.sh

## Developer Resources
- Source code in `Sources/CredentialCode/`
- Tests in `Tests/`

## Archived Documentation
- [Original Project Plan](archive/project-plan.md) - Initial project planning document
- [README Structure Plan](archive/readme-structure.md) - README planning document

## Feature Support Matrix

| Feature | Swift | Kotlin | Java | Python | C++ |
|---------|-------|--------|------|--------|-----|
| Basic Generation | ✅ | ✅ | ✅ | ✅ | ✅ |
| External Key (JSON) | ✅ | ❌ | ❌ | ❌ | ❌ |
| External Key (Source) | ✅ | ❌ | ❌ | ❌ | ❌ |

## Security Warning

⚠️ **This tool is NOT suitable for open source projects.** The encryption key is embedded in the generated code, which means anyone with access to the code can decrypt the credentials. Use only for closed-source applications.