import Foundation

public protocol CodeGenerator {
    var language: String { get }
    var defaultFileName: String { get }

    func generate(credentials: [String: String], encryptionKey: Data) throws -> String
    func generateWithExternalKey(credentials: [String: String], encryptionKey: Data) throws -> String
    func generateWithExternalKeySource(credentials: [String: String], encryptionKey: Data) throws -> String
    func generateKeySource(encryptionKey: Data) throws -> String
}

public struct EncryptedCredential {
    public let key: String
    public let encryptedData: Data
    public let nonce: Data
    public let tag: Data

    public init(key: String, encryptedData: Data, nonce: Data, tag: Data) {
        self.key = key
        self.encryptedData = encryptedData
        self.nonce = nonce
        self.tag = tag
    }
}

public enum CredentialError: Error {
    case invalidEncryptedData
    case decryptionFailed
    case notImplemented(String)
}
