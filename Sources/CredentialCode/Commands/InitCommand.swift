import ArgumentParser
import Foundation

struct InitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize credential storage in the current directory"
    )
    
    @Option(name: .shortAndLong, help: "Directory to initialize (default: current directory)")
    var path: String = "."
    
    mutating func run() throws {
        let fileManager = FileManager.default
        let credentialDir = URL(fileURLWithPath: path).appendingPathComponent(".credential-code")
        
        // Create .credential-code directory
        if fileManager.fileExists(atPath: credentialDir.path) {
            print("Error: .credential-code directory already exists")
            throw ExitCode.failure
        }
        
        try fileManager.createDirectory(at: credentialDir, withIntermediateDirectories: true)
        
        // Generate encryption key
        let key = generateEncryptionKey()
        let keyFile = credentialDir.appendingPathComponent("credentials.key")
        try key.write(to: keyFile)
        
        // Create empty credentials.json
        let credentials: [String: String] = [:]
        let credentialsData = try JSONEncoder().encode(["credentials": credentials])
        let credentialsFile = credentialDir.appendingPathComponent("credentials.json")
        try credentialsData.write(to: credentialsFile)
        
        // Update .gitignore
        try updateGitignore()
        
        print("✅ Initialized credential storage in \(credentialDir.path)")
        print("⚠️  Added .credential-code/credentials.key to .gitignore")
        print("📝 You can now add credentials using: credential-code add <KEY> <VALUE>")
    }
    
    private func generateEncryptionKey() -> Data {
        var bytes = [UInt8](repeating: 0, count: 32) // 256 bits for AES-256
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64EncodedData()
    }
    
    private func updateGitignore() throws {
        let gitignorePath = URL(fileURLWithPath: path).appendingPathComponent(".gitignore")
        let gitignoreEntries = [
            "\n# Credential Code",
            ".credential-code/credentials.key",
            ""
        ].joined(separator: "\n")
        
        if FileManager.default.fileExists(atPath: gitignorePath.path) {
            let existingContent = try String(contentsOf: gitignorePath, encoding: .utf8)
            if !existingContent.contains(".credential-code/credentials.key") {
                try (existingContent + gitignoreEntries).write(to: gitignorePath, atomically: true, encoding: .utf8)
            }
        } else {
            try gitignoreEntries.write(to: gitignorePath, atomically: true, encoding: .utf8)
        }
    }
}