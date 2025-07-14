#!/usr/bin/env node

// Example 2: Print credentials from .creds file
// This demonstrates the runtime approach where credentials are loaded from files

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Load the encryption key
const keyPath = path.join('.credential-code', 'encryption-key.txt');
const keyBase64 = fs.readFileSync(keyPath, 'utf8').trim();
const key = Buffer.from(keyBase64, 'base64');

// Load the .creds file
const credsPath = path.join('Generated', 'credentials.creds');
const credsData = JSON.parse(fs.readFileSync(credsPath, 'utf8'));

// Function to decrypt a credential
function decrypt(credentialKey) {
    const encrypted = credsData.credentials[credentialKey];
    if (!encrypted) {
        throw new Error(`Credential ${credentialKey} not found`);
    }
    
    // Decode from base64
    const data = Buffer.from(encrypted.data, 'base64');
    const nonce = Buffer.from(encrypted.nonce, 'base64');
    const tag = Buffer.from(encrypted.tag, 'base64');
    
    // Create decipher
    const decipher = crypto.createDecipheriv('aes-256-gcm', key, nonce);
    decipher.setAuthTag(tag);
    
    // Decrypt
    const decrypted = Buffer.concat([
        decipher.update(data),
        decipher.final()
    ]);
    
    return decrypted.toString('utf8');
}

// Print all credentials
console.log('=== Credentials from .creds file ===');
const result = {};

try {
    // Get all credential keys
    const keys = Object.keys(credsData.credentials);
    
    // Decrypt each one
    for (const key of keys) {
        result[key] = decrypt(key);
    }
    
    // Print as JSON
    console.log(JSON.stringify(result, null, 2));
    
} catch (error) {
    console.error('Error:', error.message);
    console.error('Make sure you have generated credentials with: credential-code generate');
}