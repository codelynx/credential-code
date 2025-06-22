import ArgumentParser
import Foundation

struct RemoveCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove a credential"
    )
    
    @Argument(help: "The credential key to remove")
    var key: String
    
    @Flag(name: .shortAndLong, help: "Skip confirmation prompt")
    var force = false
    
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
        var credentialsJson = try JSONSerialization.jsonObject(with: credentialsData) as? [String: Any] ?? [:]
        var credentials = credentialsJson["credentials"] as? [String: String] ?? [:]
        
        // Check if key exists
        guard credentials[key] != nil else {
            print("Error: Key '\(key)' not found.")
            throw ExitCode.failure
        }
        
        // Confirm removal
        if !force {
            print("Are you sure you want to remove '\(key)'? (y/N): ", terminator: "")
            let response = readLine()?.lowercased()
            if response != "y" && response != "yes" {
                print("Cancelled.")
                return
            }
        }
        
        // Remove the key
        credentials.removeValue(forKey: key)
        
        // Save updated credentials
        credentialsJson["credentials"] = credentials
        let updatedData = try JSONSerialization.data(withJSONObject: credentialsJson, options: .prettyPrinted)
        try updatedData.write(to: credentialsFile)
        
        print("✅ Removed credential '\(key)'")
    }
}