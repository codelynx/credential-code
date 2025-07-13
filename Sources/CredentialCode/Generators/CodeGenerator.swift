import Foundation

protocol CodeGenerator {
    var language: String { get }
    var defaultFileName: String { get }
    
    func generate(credentials: [String: String], encryptionKey: Data) throws -> String
    func generateWithExternalKey(credentials: [String: String], encryptionKey: Data) throws -> String
    func generateKeySource(encryptionKey: Data) throws -> String
}

struct EncryptedCredential {
    let key: String
    let encryptedData: Data
    let nonce: Data
    let tag: Data
}