import Foundation
import CryptoKit

/// A utility class for decrypting credentials from .creds files
public struct CredentialDecryptor {
    private let key: SymmetricKey
    
    /// Initialize with a base64-encoded key string
    public init(keyBase64: String) throws {
        guard let keyData = Data(base64Encoded: keyBase64.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw CredentialError.invalidKey
        }
        self.key = SymmetricKey(data: keyData)
    }
    
    /// Initialize with key data
    public init(keyData: Data) {
        self.key = SymmetricKey(data: keyData)
    }
    
    /// Initialize by reading key from file
    public init(keyPath: String) throws {
        let keyString = try String(contentsOfFile: keyPath, encoding: .utf8)
        try self.init(keyBase64: keyString)
    }
    
    /// Load and decrypt all credentials from a .creds file
    public func loadCredentials(from credsPath: String) throws -> [String: String] {
        let credsData = try Data(contentsOf: URL(fileURLWithPath: credsPath))
        return try loadCredentials(from: credsData)
    }
    
    /// Load and decrypt all credentials from .creds data
    public func loadCredentials(from credsData: Data) throws -> [String: String] {
        guard let credsJSON = try JSONSerialization.jsonObject(with: credsData) as? [String: Any],
              let credentials = credsJSON["credentials"] as? [String: [String: String]] else {
            throw CredentialError.invalidCredsFormat
        }
        
        var decryptedCredentials: [String: String] = [:]
        
        for (key, encryptedData) in credentials {
            decryptedCredentials[key] = try decrypt(encryptedData)
        }
        
        return decryptedCredentials
    }
    
    /// Decrypt a single credential
    public func decrypt(_ encryptedData: [String: String]) throws -> String {
        // Decode from base64
        guard let ciphertext = Data(base64Encoded: encryptedData["data"] ?? ""),
              let nonceData = Data(base64Encoded: encryptedData["nonce"] ?? ""),
              let tagData = Data(base64Encoded: encryptedData["tag"] ?? "") else {
            throw CredentialError.invalidData
        }
        
        // Create nonce and sealed box
        let nonce = try AES.GCM.Nonce(data: nonceData)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tagData)
        
        // Decrypt
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let result = String(data: decryptedData, encoding: .utf8) else {
            throw CredentialError.decryptionFailed
        }
        
        return result
    }
}

/// Errors that can occur during credential operations
public enum CredentialError: LocalizedError {
    case invalidKey
    case invalidData
    case invalidCredsFormat
    case decryptionFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "Invalid encryption key format"
        case .invalidData:
            return "Invalid encrypted data format"
        case .invalidCredsFormat:
            return "Invalid .creds file format"
        case .decryptionFailed:
            return "Failed to decrypt credential"
        }
    }
}