import Foundation

protocol CodeGenerator {
    var language: String { get }
    var defaultFileName: String { get }
    
    func generate(credentials: [String: String], encryptionKey: Data) throws -> String
}

struct EncryptedCredential {
    let key: String
    let encryptedData: Data
    let nonce: Data
    let tag: Data
}