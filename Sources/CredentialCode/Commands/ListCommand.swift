import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all credential keys (values are not shown)"
    )
    
    mutating func run() throws {
        let credentialDir = URL(fileURLWithPath: ".credential-code")
        
        // Check if initialized
        guard FileManager.default.fileExists(atPath: credentialDir.path) else {
            print("Error: Not initialized. Run 'credential-code init' first.")
            throw ExitCode.failure
        }
        
        // Load credentials
        let credentialsFile = credentialDir.appendingPathComponent("credentials.json")
        let credentialsData = try Data(contentsOf: credentialsFile)
        let credentialsJson = try JSONSerialization.jsonObject(with: credentialsData) as? [String: Any] ?? [:]
        let credentials = credentialsJson["credentials"] as? [String: String] ?? [:]
        
        if credentials.isEmpty {
            print("No credentials stored.")
            return
        }
        
        print("Stored credentials:")
        for key in credentials.keys.sorted() {
            print("  • \(key)")
        }
        print("\nTotal: \(credentials.count) credential(s)")
    }
}