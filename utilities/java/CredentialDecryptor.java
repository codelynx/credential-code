package com.credentialcode.utility;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;

/**
 * A utility class for decrypting credentials from .creds files
 */
public class CredentialDecryptor {
    private final byte[] key;
    
    /**
     * Initialize with a base64-encoded key string
     */
    public CredentialDecryptor(String keyBase64) {
        this.key = Base64.getDecoder().decode(keyBase64.trim());
    }
    
    /**
     * Initialize with key bytes
     */
    public CredentialDecryptor(byte[] keyBytes) {
        this.key = keyBytes;
    }
    
    /**
     * Initialize by reading key from file
     */
    public CredentialDecryptor(Path keyPath) throws IOException {
        String keyBase64 = Files.readString(keyPath).trim();
        this.key = Base64.getDecoder().decode(keyBase64);
    }
    
    /**
     * Initialize by reading key from file (convenience method)
     */
    public CredentialDecryptor(File keyFile) throws IOException {
        this(keyFile.toPath());
    }
    
    /**
     * Decrypt a single credential
     */
    public String decrypt(JSONObject encryptedData) throws Exception {
        // Decode from base64
        byte[] ciphertext = Base64.getDecoder().decode(encryptedData.getString("data"));
        byte[] nonce = Base64.getDecoder().decode(encryptedData.getString("nonce"));
        byte[] tag = Base64.getDecoder().decode(encryptedData.getString("tag"));
        
        // Create cipher
        SecretKeySpec secretKey = new SecretKeySpec(key, "AES");
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        GCMParameterSpec gcmSpec = new GCMParameterSpec(128, nonce);
        cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec);
        
        // Combine ciphertext and tag for Java's GCM implementation
        byte[] combined = new byte[ciphertext.length + tag.length];
        System.arraycopy(ciphertext, 0, combined, 0, ciphertext.length);
        System.arraycopy(tag, 0, combined, ciphertext.length, tag.length);
        
        // Decrypt
        byte[] decrypted = cipher.doFinal(combined);
        
        return new String(decrypted, StandardCharsets.UTF_8);
    }
    
    /**
     * Load and decrypt all credentials from a .creds file
     */
    public Map<String, String> loadCredentials(String credsPath) throws Exception {
        return loadCredentials(Paths.get(credsPath));
    }
    
    /**
     * Load and decrypt all credentials from a .creds file
     */
    public Map<String, String> loadCredentials(Path credsPath) throws Exception {
        String jsonContent = Files.readString(credsPath);
        return loadCredentialsFromJson(jsonContent);
    }
    
    /**
     * Load and decrypt all credentials from a .creds file
     */
    public Map<String, String> loadCredentials(File credsFile) throws Exception {
        return loadCredentials(credsFile.toPath());
    }
    
    /**
     * Load and decrypt all credentials from JSON string
     */
    public Map<String, String> loadCredentialsFromJson(String jsonString) throws Exception {
        JSONObject credsData = new JSONObject(jsonString);
        JSONObject credentials = credsData.getJSONObject("credentials");
        
        Map<String, String> result = new HashMap<>();
        
        for (String key : credentials.keySet()) {
            JSONObject encryptedData = credentials.getJSONObject(key);
            result.put(key, decrypt(encryptedData));
        }
        
        return result;
    }
    
    /**
     * Load and decrypt all credentials from JSONObject
     */
    public Map<String, String> loadCredentialsFromJson(JSONObject credsData) throws Exception {
        JSONObject credentials = credsData.getJSONObject("credentials");
        
        Map<String, String> result = new HashMap<>();
        
        for (String key : credentials.keySet()) {
            JSONObject encryptedData = credentials.getJSONObject(key);
            result.put(key, decrypt(encryptedData));
        }
        
        return result;
    }
    
    /**
     * Convenience method to load credentials with default key path
     */
    public static Map<String, String> loadCredentials(String credsPath) throws Exception {
        Path keyPath = Paths.get(".credential-code", "encryption-key.txt");
        CredentialDecryptor decryptor = new CredentialDecryptor(keyPath);
        return decryptor.loadCredentials(credsPath);
    }
    
    /**
     * Convenience method to load credentials with custom key path
     */
    public static Map<String, String> loadCredentials(String credsPath, String keyPath) throws Exception {
        CredentialDecryptor decryptor = new CredentialDecryptor(Paths.get(keyPath));
        return decryptor.loadCredentials(credsPath);
    }
}