import ArgumentParser
import Foundation

struct GenerateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate code with encrypted credentials"
    )
    
    @Option(name: .shortAndLong, help: "Target programming language")
    var language: Language = .swift
    
    @Option(name: .shortAndLong, help: "Output file path")
    var output: String?
    
    @Flag(name: .long, help: "Generate with external key file (splits key from code)")
    var externalKey = false
    
    @Option(name: .long, help: "Path for the external key file (only with --external-key)")
    var keyFile: String?
    
    @Flag(name: .long, help: "Generate with external key as source code instead of JSON")
    var externalKeySource = false
    
    @Option(name: .long, help: "Path for the external key source file (only with --external-key-source)")
    var keySourceOutput: String?
    
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
        
        // Generate a random encryption key for this build
        var keyBytes = [UInt8](repeating: 0, count: 32) // 256 bits for AES-256
        _ = SecRandomCopyBytes(kSecRandomDefault, keyBytes.count, &keyBytes)
        let encryptionKey = Data(keyBytes)
        
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
        if externalKeySource {
            // Generate code without embedded key (for source code key)
            generatedCode = try generator.generateWithExternalKey(credentials: credentials, encryptionKey: encryptionKey)
            
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
        } else if externalKey {
            // Generate code without embedded key
            generatedCode = try generator.generateWithExternalKey(credentials: credentials, encryptionKey: encryptionKey)
            
            // Save key to external file
            let keyFilePath = keyFile ?? "credential-key.json"
            let keyURL = URL(fileURLWithPath: keyFilePath)
            
            // Create key data structure
            let keyData: [String: Any] = [
                "version": "1.0",
                "algorithm": "AES-256-GCM",
                "key": encryptionKey.base64EncodedString()
            ]
            
            let keyJSON = try JSONSerialization.data(withJSONObject: keyData, options: .prettyPrinted)
            try keyJSON.write(to: keyURL)
            
            print("✅ Generated key file: \(keyFilePath)")
        } else {
            // Generate code with embedded key (existing behavior)
            generatedCode = try generator.generate(credentials: credentials, encryptionKey: encryptionKey)
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
}