#!/usr/bin/env python3

# Example 2b: Print credentials from .creds file (Python version)
# This demonstrates the runtime approach in Python
#
# NOTE: This example shows manual decryption for educational purposes.
# For production use, see the utility library at /utilities/python/

import json
import base64
from pathlib import Path
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

def decrypt_credential(key_bytes, encrypted_data):
    """Decrypt a single credential using AES-256-GCM"""
    # Decode components
    ciphertext = base64.b64decode(encrypted_data['data'])
    nonce = base64.b64decode(encrypted_data['nonce'])
    tag = base64.b64decode(encrypted_data['tag'])
    
    # Create cipher
    cipher = Cipher(
        algorithms.AES(key_bytes),
        modes.GCM(nonce, tag),
        backend=default_backend()
    )
    
    # Decrypt
    decryptor = cipher.decryptor()
    plaintext = decryptor.update(ciphertext) + decryptor.finalize()
    
    return plaintext.decode('utf-8')

def main():
    try:
        # Load encryption key
        key_path = Path('.credential-code/encryption-key.txt')
        key_base64 = key_path.read_text().strip()
        key_bytes = base64.b64decode(key_base64)
        
        # Load .creds file
        creds_path = Path('Generated/credentials.creds')
        creds_data = json.loads(creds_path.read_text())
        
        print('=== Credentials from .creds file (Python) ===')
        
        # Decrypt all credentials
        result = {}
        for cred_name, encrypted_data in creds_data['credentials'].items():
            result[cred_name] = decrypt_credential(key_bytes, encrypted_data)
        
        # Print as JSON
        print(json.dumps(result, indent=2))
        
    except FileNotFoundError as e:
        print(f"Error: File not found - {e}")
        print("Make sure you have generated credentials with: credential-code generate")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()