# Manual Decryption Examples (Archived)

**Note: This document is archived. For production use, please use the utility libraries provided in `/utilities/` directory.**

This document shows the manual implementation of .creds file decryption for educational purposes. These examples demonstrate how the decryption works under the hood.

## Node.js Manual Implementation

```javascript
const crypto = require('crypto');
const fs = require('fs');

function decrypt(credentialKey) {
    const keyBase64 = fs.readFileSync('.credential-code/encryption-key.txt', 'utf8').trim();
    const key = Buffer.from(keyBase64, 'base64');
    const credsData = JSON.parse(fs.readFileSync('credentials.creds', 'utf8'));
    
    const encrypted = credsData.credentials[credentialKey];
    const data = Buffer.from(encrypted.data, 'base64');
    const nonce = Buffer.from(encrypted.nonce, 'base64');
    const tag = Buffer.from(encrypted.tag, 'base64');
    
    const decipher = crypto.createDecipheriv('aes-256-gcm', key, nonce);
    decipher.setAuthTag(tag);
    
    const decrypted = Buffer.concat([
        decipher.update(data),
        decipher.final()
    ]);
    
    return decrypted.toString('utf8');
}
```

## Python Manual Implementation

```python
import json
import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

def decrypt_credential(key_bytes, encrypted_data):
    ciphertext = base64.b64decode(encrypted_data['data'])
    nonce = base64.b64decode(encrypted_data['nonce'])
    tag = base64.b64decode(encrypted_data['tag'])
    
    cipher = Cipher(
        algorithms.AES(key_bytes),
        modes.GCM(nonce, tag),
        backend=default_backend()
    )
    
    decryptor = cipher.decryptor()
    plaintext = decryptor.update(ciphertext) + decryptor.finalize()
    
    return plaintext.decode('utf-8')
```

## Production Use

Instead of implementing decryption manually, use the provided utility libraries:

- **Node.js**: `const { CredentialDecryptor } = require('credential-code-utility');`
- **Python**: `from credential_code_utility import CredentialDecryptor`
- **Java**: `import com.credentialcode.utility.CredentialDecryptor;`
- **Swift**: `import CredentialCodeUtility`

See `/utilities/README.md` for installation and usage instructions.