# Backend Services Usage Guide

This guide explains how to use Credential Code for backend services and runtime-configurable applications.

## Overview

Backend services require credentials that can be:
- Loaded at runtime (not compiled in)
- Updated without redeployment
- Different per environment/tenant
- Managed through configuration systems

Credential Code provides `.creds` files and utility libraries for this use case.

## Quick Start

### 1. Generate .creds File

```bash
# Generate both code and .creds (default)
credential-code generate

# Generate only .creds file for backend
credential-code generate --no-generate-code --creds-output config/prod.creds
```

### 2. Use Utility Libraries

We provide ready-to-use decryption utilities in the `/utilities` directory:

**Node.js/JavaScript**
```javascript
const { CredentialDecryptor } = require('credential-code-utility');

// Initialize with key from environment
const decryptor = new CredentialDecryptor(process.env.CREDENTIAL_KEY);

// Load credentials
const credentials = decryptor.loadCredentials('config/prod.creds');
const dbUrl = credentials.DATABASE_URL;
```

**Python**
```python
from credential_code_utility import CredentialDecryptor

# Initialize with key file
decryptor = CredentialDecryptor('.credential-code/encryption-key.txt')

# Load credentials
credentials = decryptor.load_credentials('config/prod.creds')
api_key = credentials['API_KEY']
```

**Java**
```java
CredentialDecryptor decryptor = new CredentialDecryptor(
    Paths.get(".credential-code/encryption-key.txt")
);
Map<String, String> credentials = decryptor.loadCredentials("config/prod.creds");
```

**Swift (Server-side)**
```swift
let decryptor = try CredentialDecryptor(keyPath: ".credential-code/encryption-key.txt")
let credentials = try decryptor.loadCredentials(from: "config/prod.creds")
```

## Deployment Patterns

### Docker/Containers

```dockerfile
# Dockerfile
FROM node:18

# Copy application
COPY . /app
WORKDIR /app

# Copy credentials (or mount as volume)
COPY config/prod.creds /app/config/

# Key from environment
ENV CREDENTIAL_KEY=${CREDENTIAL_KEY}

CMD ["node", "server.js"]
```

```yaml
# docker-compose.yml
services:
  api:
    image: myapp
    environment:
      - CREDENTIAL_KEY=${CREDENTIAL_KEY}
    volumes:
      - ./config/prod.creds:/app/config/prod.creds:ro
```

### Kubernetes

```yaml
# Secret for encryption key
apiVersion: v1
kind: Secret
metadata:
  name: credential-key
data:
  key: <base64-encoded-key>

---
# ConfigMap for .creds file
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-credentials
data:
  prod.creds: |
    {
      "version": "1.0",
      "algorithm": "AES-256-GCM",
      "credentials": { ... }
    }

---
# Deployment
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: api
        env:
        - name: CREDENTIAL_KEY
          valueFrom:
            secretKeyRef:
              name: credential-key
              key: key
        volumeMounts:
        - name: creds
          mountPath: /config
      volumes:
      - name: creds
        configMap:
          name: app-credentials
```

### AWS/Cloud Deployment

```javascript
// Load key from AWS Secrets Manager
const AWS = require('aws-sdk');
const { CredentialDecryptor } = require('credential-code-utility');

const secretsManager = new AWS.SecretsManager();

async function getCredentials() {
  // Get key from Secrets Manager
  const secret = await secretsManager.getSecretValue({
    SecretId: 'prod/credential-key'
  }).promise();
  
  // Initialize decryptor
  const decryptor = new CredentialDecryptor(secret.SecretString);
  
  // Load credentials from S3 or local file
  return decryptor.loadCredentials('config/prod.creds');
}
```

## Multi-Environment Setup

```bash
# Generate different .creds for each environment
credential-code generate --creds-output config/dev.creds
credential-code generate --creds-output config/staging.creds
credential-code generate --creds-output config/prod.creds
```

```javascript
// Load based on environment
const env = process.env.NODE_ENV || 'dev';
const credentials = decryptor.loadCredentials(`config/${env}.creds`);
```

## Key Management Best Practices

### 1. Environment Variables
```bash
export CREDENTIAL_KEY=$(cat .credential-code/encryption-key.txt)
```

### 2. Secret Management Systems
- AWS Secrets Manager
- HashiCorp Vault
- Azure Key Vault
- Google Secret Manager

### 3. Configuration Services
- Consul
- etcd
- AWS Parameter Store

## Security Considerations

1. **Never commit** the encryption key to version control
2. **Rotate keys** periodically using your secret management system
3. **Use different keys** for different environments
4. **Restrict access** to .creds files and keys
5. **Audit access** to credential files

## Utility Library Installation

See `/utilities/README.md` for detailed installation instructions for each language.

### Quick Install

**Node.js**
```bash
cd utilities/javascript && npm link
```

**Python**
```bash
cd utilities/python && pip install .
```

**Java**
```bash
cd utilities/java && mvn install
```

**Swift**
Add to Package.swift:
```swift
.package(path: "path/to/utilities/swift")
```

## Example: Microservices Architecture

```javascript
// Shared credential service
class CredentialService {
  constructor() {
    this.decryptor = new CredentialDecryptor(process.env.CREDENTIAL_KEY);
    this.cache = new Map();
  }
  
  async getCredentials(service) {
    if (!this.cache.has(service)) {
      const creds = await this.decryptor.loadCredentials(`config/${service}.creds`);
      this.cache.set(service, creds);
    }
    return this.cache.get(service);
  }
}

// In your microservice
const credService = new CredentialService();
const creds = await credService.getCredentials('payment-service');
const stripeKey = creds.STRIPE_KEY;
```

## Troubleshooting

**"Invalid key format" error**
- Ensure key is base64-encoded
- Check for whitespace/newlines in key file

**"Failed to decrypt" error**
- Verify .creds file matches the encryption key
- Ensure .creds file is valid JSON

**Performance issues**
- Use the caching methods in utility libraries
- Load credentials once at startup

## Further Reading

- [Two Use Cases Guide](TWO_USE_CASES.md) - Understand fixed vs configurable deployments
- [Security Best Practices](SECURITY.md) - Detailed security recommendations
- [External Key Guide](EXTERNAL_KEY_GUIDE.md) - Advanced key management options