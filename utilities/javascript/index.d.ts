/// <reference types="node" />

export interface EncryptedData {
    data: string;
    nonce: string;
    tag: string;
}

export interface CredentialsFile {
    credentials: Record<string, EncryptedData>;
}

export class CredentialDecryptor {
    /**
     * Initialize the decryptor with an encryption key
     * @param key - The encryption key. Can be:
     *   - A base64-encoded string
     *   - A file path to a key file
     *   - A Buffer containing the raw key bytes
     */
    constructor(key: string | Buffer);
    
    /**
     * Decrypt a single credential
     * @param encryptedData - Object containing 'data', 'nonce', and 'tag' fields
     * @returns The decrypted credential string
     */
    decrypt(encryptedData: EncryptedData): string;
    
    /**
     * Load and decrypt all credentials from a .creds file
     * @param credsPath - Path to the .creds file
     * @returns Object mapping credential names to their decrypted values
     */
    loadCredentials(credsPath: string): Record<string, string>;
    
    /**
     * Load and decrypt all credentials from JSON data
     * @param credsJson - JSON string or object containing the credentials
     * @returns Object mapping credential names to their decrypted values
     */
    loadCredentialsFromJson(credsJson: string | CredentialsFile): Record<string, string>;
}

export interface LoadCredentialsOptions {
    /**
     * Path to the key file (default: .credential-code/encryption-key.txt)
     */
    keyPath?: string;
    
    /**
     * Base64-encoded key string (alternative to keyPath)
     */
    keyBase64?: string;
}

/**
 * Convenience function to load credentials from a .creds file
 * @param credsPath - Path to the .creds file
 * @param options - Options object
 * @returns Object mapping credential names to their decrypted values
 */
export function loadCredentials(credsPath: string, options?: LoadCredentialsOptions): Record<string, string>;