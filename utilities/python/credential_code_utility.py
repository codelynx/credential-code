#!/usr/bin/env python3
"""
credential_code_utility - A utility library for decrypting .creds files
"""

import json
import base64
from pathlib import Path
from typing import Dict, Optional, Union
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend


class CredentialDecryptor:
    """A utility class for decrypting credentials from .creds files"""
    
    def __init__(self, key: Union[str, bytes, Path]):
        """
        Initialize the decryptor with an encryption key.
        
        Args:
            key: The encryption key. Can be:
                - A base64-encoded string
                - Raw key bytes
                - A Path object pointing to a key file
        """
        if isinstance(key, Path) or (isinstance(key, str) and '/' in key or '\\' in key):
            # It's a file path
            key_path = Path(key)
            key_base64 = key_path.read_text().strip()
            self.key_bytes = base64.b64decode(key_base64)
        elif isinstance(key, str):
            # It's a base64-encoded string
            self.key_bytes = base64.b64decode(key.strip())
        elif isinstance(key, bytes):
            # It's raw bytes
            self.key_bytes = key
        else:
            raise ValueError("Key must be a string, bytes, or Path object")
    
    def decrypt(self, encrypted_data: Dict[str, str]) -> str:
        """
        Decrypt a single credential.
        
        Args:
            encrypted_data: Dictionary containing 'data', 'nonce', and 'tag' fields
        
        Returns:
            The decrypted credential string
        """
        # Decode components
        ciphertext = base64.b64decode(encrypted_data['data'])
        nonce = base64.b64decode(encrypted_data['nonce'])
        tag = base64.b64decode(encrypted_data['tag'])
        
        # Create cipher
        cipher = Cipher(
            algorithms.AES(self.key_bytes),
            modes.GCM(nonce, tag),
            backend=default_backend()
        )
        
        # Decrypt
        decryptor = cipher.decryptor()
        plaintext = decryptor.update(ciphertext) + decryptor.finalize()
        
        return plaintext.decode('utf-8')
    
    def load_credentials(self, creds_path: Union[str, Path]) -> Dict[str, str]:
        """
        Load and decrypt all credentials from a .creds file.
        
        Args:
            creds_path: Path to the .creds file
        
        Returns:
            Dictionary mapping credential names to their decrypted values
        """
        creds_path = Path(creds_path)
        creds_data = json.loads(creds_path.read_text())
        
        result = {}
        for cred_name, encrypted_data in creds_data['credentials'].items():
            result[cred_name] = self.decrypt(encrypted_data)
        
        return result
    
    def load_credentials_from_json(self, creds_json: Union[str, dict]) -> Dict[str, str]:
        """
        Load and decrypt all credentials from JSON data.
        
        Args:
            creds_json: JSON string or dictionary containing the credentials
        
        Returns:
            Dictionary mapping credential names to their decrypted values
        """
        if isinstance(creds_json, str):
            creds_data = json.loads(creds_json)
        else:
            creds_data = creds_json
        
        result = {}
        for cred_name, encrypted_data in creds_data['credentials'].items():
            result[cred_name] = self.decrypt(encrypted_data)
        
        return result


def load_credentials(creds_path: Union[str, Path], 
                    key_path: Optional[Union[str, Path]] = None,
                    key_base64: Optional[str] = None) -> Dict[str, str]:
    """
    Convenience function to load credentials from a .creds file.
    
    Args:
        creds_path: Path to the .creds file
        key_path: Path to the key file (default: .credential-code/encryption-key.txt)
        key_base64: Base64-encoded key string (alternative to key_path)
    
    Returns:
        Dictionary mapping credential names to their decrypted values
    """
    if key_base64:
        decryptor = CredentialDecryptor(key_base64)
    elif key_path:
        decryptor = CredentialDecryptor(Path(key_path))
    else:
        # Default key path
        decryptor = CredentialDecryptor(Path('.credential-code/encryption-key.txt'))
    
    return decryptor.load_credentials(creds_path)