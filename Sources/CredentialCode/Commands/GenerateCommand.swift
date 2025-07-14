import ArgumentParser
import Foundation
import CryptoKit

struct GenerateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate code and .creds file with encrypted credentials"
    )
    
    @Option(name: .shortAndLong, help: "Target programming language")
    var language: Language = .swift
    
    @Option(name: .shortAndLong, help: "Output file path")
    var output: String?
    
    @Flag(name: .long, inversion: .prefixedNo, help: "Generate with embedded key (default: uses external key)")
    var embeddedKey = false
    
    @Option(name: .long, help: "Path for the external key file (default: .credential-code/encryption-key.txt)")
    var keyFile: String?
    
    @Flag(name: .long, help: "Generate with external key as source code instead of text file")
    var externalKeySource = false
    
    @Option(name: .long, help: "Path for the external key source file (only with --external-key-source)")
    var keySourceOutput: String?
    
    @Flag(name: .long, inversion: .prefixedNo, help: "Generate .creds file for backend/runtime use (default: true)")
    var generateCreds = true
    
    @Option(name: .long, help: "Path for the .creds file (default: Generated/credentials.creds)")
    var credsOutput: String?
    
    enum Language: String, ExpressibleByArgument, CaseIterable {
        case swift
        case kotlin
        case java
        case python
        case c
        case cpp = "c++"
        
        var defaultFileName: String {
            switch self {
            case .swift: return "Credentials.swift"
            case .kotlin: return "Credentials.kt"
            case .java: return "Credentials.java"
            case .python: return "credentials.py"
            case .c: return "credentials.c"
            case .cpp: return "credentials.cpp"
            }
        }
    }
    
    mutating func run() throws {
        let credentialDir = URL(fileURLWithPath: ".credential-code")
        
        // Check if initialized
        guard FileManager.default.fileExists(atPath: credentialDir.path) else {
            print("Error: Not initialized. Run 'credential-code init' first.")
            throw ExitCode.failure
        }
        
        // Load credentials (now in plain text)
        let credentialsFile = credentialDir.appendingPathComponent("credentials.json")
        
        let credentialsData = try Data(contentsOf: credentialsFile)
        let credentials = try JSONSerialization.jsonObject(with: credentialsData) as? [String: String] ?? [:]
        
        if credentials.isEmpty {
            print("Warning: No credentials to generate.")
            return
        }
        
        // Check for existing key or generate new one
        let keyFilePath = credentialDir.appendingPathComponent("encryption-key.txt")
        let encryptionKey: Data
        
        if FileManager.default.fileExists(atPath: keyFilePath.path) {
            // Read existing key
            let keyString = try String(contentsOf: keyFilePath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let keyData = Data(base64Encoded: keyString) else {
                print("Error: Invalid key format in \(keyFilePath.path)")
                throw ExitCode.failure
            }
            encryptionKey = keyData
            print("📋 Using existing encryption key from \(keyFilePath.path)")
        } else {
            // Generate a new key
            var keyBytes = [UInt8](repeating: 0, count: 32) // 256 bits for AES-256
            _ = SecRandomCopyBytes(kSecRandomDefault, keyBytes.count, &keyBytes)
            encryptionKey = Data(keyBytes)
            
            // Save key to file as base64 string
            let keyString = encryptionKey.base64EncodedString()
            try keyString.write(to: keyFilePath, atomically: true, encoding: .utf8)
            print("🔑 Generated new encryption key: \(keyFilePath.path)")
            print("\nKey (copy this for manual use):\n\(keyString)\n")
        }
        
        // Select code generator based on language
        let generator: CodeGenerator
        switch language {
        case .swift:
            generator = SwiftCodeGenerator()
        case .kotlin:
            generator = KotlinCodeGenerator()
        case .java:
            generator = JavaCodeGenerator()
        case .python:
            generator = PythonCodeGenerator()
        case .cpp:
            generator = CppCodeGenerator()
        default:
            print("Error: \(language.rawValue) language support not yet implemented.")
            throw ExitCode.failure
        }
        
        // Generate code
        let generatedCode: String
        if embeddedKey {
            // Generate code with embedded key (legacy behavior)
            generatedCode = try generator.generate(credentials: credentials, encryptionKey: encryptionKey)
        } else if externalKeySource {
            // Generate code without embedded key (for source code key)
            if language != .swift {
                print("⚠️  External key source mode is not yet supported for \(language.rawValue)")
                print("   Using embedded key mode instead...")
                generatedCode = try generator.generate(credentials: credentials, encryptionKey: encryptionKey)
            } else {
                generatedCode = try generator.generateWithExternalKeySource(credentials: credentials, encryptionKey: encryptionKey)
                
                // Generate key source file
                let keySourcePath = keySourceOutput ?? getDefaultKeySourcePath(for: language)
                let keySourceURL = URL(fileURLWithPath: keySourcePath)
                
                // Create parent directory if needed
                let keyParentDir = keySourceURL.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: keyParentDir.path) {
                    try FileManager.default.createDirectory(at: keyParentDir, withIntermediateDirectories: true)
                }
                
                // Generate key source code
                let keySourceCode = try generator.generateKeySource(encryptionKey: encryptionKey)
                try keySourceCode.write(to: keySourceURL, atomically: true, encoding: .utf8)
                
                print("✅ Generated key source file: \(keySourcePath)")
            }
        } else {
            // Default: Generate code without embedded key (using external key file)
            if language != .swift {
                print("⚠️  External key mode is not yet supported for \(language.rawValue)")
                print("   Using embedded key mode instead...")
                print("   To silence this warning, use: --embedded-key")
                generatedCode = try generator.generate(credentials: credentials, encryptionKey: encryptionKey)
            } else {
                generatedCode = try generator.generateWithExternalKey(credentials: credentials, encryptionKey: encryptionKey)
            }
            
            // If user specified custom key file location, copy key there
            if let customKeyPath = keyFile {
                let keyString = encryptionKey.base64EncodedString()
                let customKeyURL = URL(fileURLWithPath: customKeyPath)
                
                // Create parent directory if needed
                let keyParentDir = customKeyURL.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: keyParentDir.path) {
                    try FileManager.default.createDirectory(at: keyParentDir, withIntermediateDirectories: true)
                }
                
                try keyString.write(to: customKeyURL, atomically: true, encoding: .utf8)
                print("📋 Copied key to: \(customKeyPath)")
            }
        }
        
        // Write to output file
        let outputPath = output ?? generator.defaultFileName
        let outputURL = URL(fileURLWithPath: outputPath)
        
        // Create parent directory if needed
        let parentDir = outputURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        
        try generatedCode.write(to: outputURL, atomically: true, encoding: .utf8)
        
        print("✅ Generated \(language.rawValue) code: \(outputPath)")
        
        // Generate .creds file if requested
        if generateCreds {
            let credsPath = credsOutput ?? "Generated/credentials.creds"
            try generateCredsFile(credentials: credentials, encryptionKey: encryptionKey, outputPath: credsPath)
            print("✅ Generated .creds file: \(credsPath)")
            print("   Use with encryption key file: \(keyFilePath.path)")
        }
    }
    
    private func getDefaultKeySourcePath(for language: Language) -> String {
        switch language {
        case .swift:
            return "Generated/CredentialKey.swift"
        case .kotlin:
            return "Generated/CredentialKey.kt"
        case .java:
            return "Generated/CredentialKey.java"
        case .python:
            return "Generated/credential_key.py"
        case .c:
            return "Generated/credential_key.c"
        case .cpp:
            return "Generated/credential_key.cpp"
        }
    }
    
    private func generateCredsFile(credentials: [String: String], encryptionKey: Data, outputPath: String) throws {
        // Encrypt credentials
        let runtimeKey = SymmetricKey(data: encryptionKey)
        var encryptedData: [String: [String: String]] = [:]
        
        for (key, value) in credentials {
            guard let plaintext = value.data(using: .utf8) else {
                throw ExitCode.failure
            }
            
            // Encrypt with AES-GCM
            let sealedBox = try AES.GCM.seal(plaintext, using: runtimeKey)
            
            encryptedData[key] = [
                "data": sealedBox.ciphertext.base64EncodedString(),
                "nonce": sealedBox.nonce.withUnsafeBytes { Data($0) }.base64EncodedString(),
                "tag": sealedBox.tag.base64EncodedString()
            ]
        }
        
        // Create .creds file structure
        let credsStructure: [String: Any] = [
            "version": "1.0",
            "algorithm": "AES-256-GCM",
            "credentials": encryptedData
        ]
        
        // Write to file
        let jsonData = try JSONSerialization.data(withJSONObject: credsStructure, options: .prettyPrinted)
        let outputURL = URL(fileURLWithPath: outputPath)
        
        // Create parent directory if needed
        let parentDir = outputURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        
        try jsonData.write(to: outputURL)
    }
}

