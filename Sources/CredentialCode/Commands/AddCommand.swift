import ArgumentParser
import Foundation
import CryptoKit

struct AddCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a new credential"
    )
    
    @Argument(help: "The credential key (e.g., API_KEY)")
    var key: String
    
    @Argument(help: "The credential value")
    var value: String
    
    @Flag(name: .shortAndLong, help: "Force overwrite if key already exists")
    var force = false
    
    mutating func run() throws {
        let credentialDir = URL(fileURLWithPath: ".credential-code")
        
        // Check if initialized
        guard FileManager.default.fileExists(atPath: credentialDir.path) else {
            print("Error: Not initialized. Run 'credential-code init' first.")
            throw ExitCode.failure
        }
        
        // Validate key format
        guard isValidKey(key) else {
            print("Error: Invalid key format. Use uppercase letters, numbers, and underscores only.")
            throw ExitCode.failure
        }
        
        // Load existing credentials
        let credentialsFile = credentialDir.appendingPathComponent("credentials.json")
        let credentialsData = try Data(contentsOf: credentialsFile)
        var credentialsJson = try JSONSerialization.jsonObject(with: credentialsData) as? [String: Any] ?? [:]
        var credentials = credentialsJson["credentials"] as? [String: String] ?? [:]
        
        // Check if key exists
        if credentials[key] != nil && !force {
            print("Error: Key '\(key)' already exists. Use --force to overwrite.")
            throw ExitCode.failure
        }
        
        // Load encryption key
        let keyFile = credentialDir.appendingPathComponent("credentials.key")
        let keyData = try Data(contentsOf: keyFile)
        let key64 = String(data: keyData, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let keyBytes = Data(base64Encoded: key64) else {
            print("Error: Invalid encryption key")
            throw ExitCode.failure
        }
        
        // Encrypt the value
        let encryptedValue = try encrypt(value, using: keyBytes)
        credentials[self.key] = encryptedValue
        
        // Save updated credentials
        credentialsJson["credentials"] = credentials
        let updatedData = try JSONSerialization.data(withJSONObject: credentialsJson, options: .prettyPrinted)
        try updatedData.write(to: credentialsFile)
        
        print("✅ Added credential '\(self.key)'")
    }
    
    private func isValidKey(_ key: String) -> Bool {
        let pattern = "^[A-Z0-9_]+$"
        return key.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func encrypt(_ plaintext: String, using keyData: Data) throws -> String {
        let key = SymmetricKey(data: keyData)
        let plaintextData = plaintext.data(using: .utf8)!
        
        let sealedBox = try AES.GCM.seal(plaintextData, using: key)
        
        // Combine nonce + ciphertext + tag into a single value
        var combined = Data()
        combined.append(sealedBox.nonce.withUnsafeBytes { Data($0) })
        combined.append(sealedBox.ciphertext)
        combined.append(sealedBox.tag)
        
        return combined.base64EncodedString()
    }
}