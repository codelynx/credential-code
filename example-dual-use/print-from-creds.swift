// Example: Print credentials from .creds file (Swift version)
// This demonstrates the runtime approach in Swift
//
// NOTE: This example shows manual decryption for educational purposes.
// For production use, see the utility library at /utilities/swift/

import Foundation
import CryptoKit

@main
struct PrintFromCreds {
    static func main() {
        do {
            // Load the encryption key
            let keyPath = ".credential-code/encryption-key.txt"
            let keyString = try String(contentsOfFile: keyPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let keyData = Data(base64Encoded: keyString) else {
                throw RuntimeError.invalidKey
            }
            let key = SymmetricKey(data: keyData)
            
            // Load the .creds file
            let credsPath = "Generated/credentials.creds"
            let credsData = try Data(contentsOf: URL(fileURLWithPath: credsPath))
            let credsJSON = try JSONSerialization.jsonObject(with: credsData) as! [String: Any]
            let credentials = credsJSON["credentials"] as! [String: [String: String]]
            
            print("=== Credentials from .creds file (Swift) ===")
            print("{")
            
            // Decrypt each credential
            let sortedKeys = credentials.keys.sorted()
            for (index, credName) in sortedKeys.enumerated() {
                if let encryptedData = credentials[credName] {
                    let decrypted = try decrypt(encryptedData, using: key)
                    let comma = index < sortedKeys.count - 1 ? "," : ""
                    print("  \"\(credName)\": \"\(decrypted)\"\(comma)")
                }
            }
            
            print("}")
            
        } catch {
            print("Error: \(error)")
            print("Make sure you have generated credentials with: credential-code generate")
        }
    }
    
    static func decrypt(_ encryptedData: [String: String], using key: SymmetricKey) throws -> String {
        // Decode from base64
        guard let ciphertext = Data(base64Encoded: encryptedData["data"] ?? ""),
              let nonceData = Data(base64Encoded: encryptedData["nonce"] ?? ""),
              let tagData = Data(base64Encoded: encryptedData["tag"] ?? "") else {
            throw RuntimeError.invalidData
        }
        
        // Create nonce and sealed box
        let nonce = try AES.GCM.Nonce(data: nonceData)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tagData)
        
        // Decrypt
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let result = String(data: decryptedData, encoding: .utf8) else {
            throw RuntimeError.decryptionFailed
        }
        
        return result
    }
}

enum RuntimeError: Error {
    case invalidKey
    case invalidData
    case decryptionFailed
}