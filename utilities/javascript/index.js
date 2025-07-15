const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/**
 * A utility class for decrypting credentials from .creds files
 */
class CredentialDecryptor {
    /**
     * Initialize the decryptor with an encryption key
     * @param {string|Buffer} key - The encryption key. Can be:
     *   - A base64-encoded string
     *   - A file path to a key file
     *   - A Buffer containing the raw key bytes
     */
    constructor(key) {
        if (Buffer.isBuffer(key)) {
            this.key = key;
        } else if (typeof key === 'string') {
            // Check if it's a file path
            if (key.includes('/') || key.includes('\\') || fs.existsSync(key)) {
                const keyBase64 = fs.readFileSync(key, 'utf8').trim();
                this.key = Buffer.from(keyBase64, 'base64');
            } else {
                // Assume it's a base64-encoded string
                this.key = Buffer.from(key.trim(), 'base64');
            }
        } else {
            throw new Error('Key must be a string or Buffer');
        }
    }
    
    /**
     * Decrypt a single credential
     * @param {Object} encryptedData - Object containing 'data', 'nonce', and 'tag' fields
     * @returns {string} The decrypted credential string
     */
    decrypt(encryptedData) {
        // Decode from base64
        const data = Buffer.from(encryptedData.data, 'base64');
        const nonce = Buffer.from(encryptedData.nonce, 'base64');
        const tag = Buffer.from(encryptedData.tag, 'base64');
        
        // Create decipher
        const decipher = crypto.createDecipheriv('aes-256-gcm', this.key, nonce);
        decipher.setAuthTag(tag);
        
        // Decrypt
        const decrypted = Buffer.concat([
            decipher.update(data),
            decipher.final()
        ]);
        
        return decrypted.toString('utf8');
    }
    
    /**
     * Load and decrypt all credentials from a .creds file
     * @param {string} credsPath - Path to the .creds file
     * @returns {Object} Object mapping credential names to their decrypted values
     */
    loadCredentials(credsPath) {
        const credsData = JSON.parse(fs.readFileSync(credsPath, 'utf8'));
        const result = {};
        
        for (const [credName, encryptedData] of Object.entries(credsData.credentials)) {
            result[credName] = this.decrypt(encryptedData);
        }
        
        return result;
    }
    
    /**
     * Load and decrypt all credentials from JSON data
     * @param {string|Object} credsJson - JSON string or object containing the credentials
     * @returns {Object} Object mapping credential names to their decrypted values
     */
    loadCredentialsFromJson(credsJson) {
        const credsData = typeof credsJson === 'string' ? JSON.parse(credsJson) : credsJson;
        const result = {};
        
        for (const [credName, encryptedData] of Object.entries(credsData.credentials)) {
            result[credName] = this.decrypt(encryptedData);
        }
        
        return result;
    }
}

/**
 * Convenience function to load credentials from a .creds file
 * @param {string} credsPath - Path to the .creds file
 * @param {Object} options - Options object
 * @param {string} options.keyPath - Path to the key file (default: .credential-code/encryption-key.txt)
 * @param {string} options.keyBase64 - Base64-encoded key string (alternative to keyPath)
 * @returns {Object} Object mapping credential names to their decrypted values
 */
function loadCredentials(credsPath, options = {}) {
    let key;
    
    if (options.keyBase64) {
        key = options.keyBase64;
    } else if (options.keyPath) {
        key = options.keyPath;
    } else {
        // Default key path
        key = path.join('.credential-code', 'encryption-key.txt');
    }
    
    const decryptor = new CredentialDecryptor(key);
    return decryptor.loadCredentials(credsPath);
}

module.exports = {
    CredentialDecryptor,
    loadCredentials
};