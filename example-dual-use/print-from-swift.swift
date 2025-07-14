// Example 1: Print credentials from Credentials.swift
// This demonstrates the compiled approach where credentials are embedded in the code

import Foundation

@main
struct PrintFromSwift {
    static func main() {
        print("=== Credentials from Swift Code ===")
        print("{")
        
        // Access each credential using the embedded key
        let credentials: [(String, CredentialKey)] = [
            ("API_KEY", .API_KEY),
            ("AWS_ACCESS_KEY", .AWS_ACCESS_KEY),
            ("AWS_SECRET_KEY", .AWS_SECRET_KEY),
            ("DATABASE_URL", .DATABASE_URL),
            ("JWT_SECRET", .JWT_SECRET),
            ("STRIPE_KEY", .STRIPE_KEY)
        ]
        
        for (index, (name, key)) in credentials.enumerated() {
            if let value = Credentials.decrypt(key) {
                let comma = index < credentials.count - 1 ? "," : ""
                print("  \"\(name)\": \"\(value)\"\(comma)")
            }
        }
        
        print("}")
    }
}