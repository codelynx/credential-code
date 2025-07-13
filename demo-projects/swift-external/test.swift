import Foundation

@main
struct TestExternalKeyCredentials {
    static func main() {
        print("🔐 Swift External Key Source Test")
        print("=================================")
        
        do {
            // No need to load key - it's provided by CredentialKeyProvider
            print("✅ Using key from CredentialKeyProvider.swift")
            
            // Access credentials directly
            let apiKey = try Credentials.get(.API_KEY)
            print("✅ API_KEY: \(apiKey)")
            
            let dbUrl = try Credentials.get(.DATABASE_URL)
            print("✅ DATABASE_URL: \(dbUrl)")
            
            // Test subscript access
            if let jwtSecret = Credentials[.JWT_SECRET] {
                print("✅ JWT_SECRET (subscript): \(jwtSecret)")
            }
            
            print("\n✨ External key source mode working correctly!")
            print("   Key is provided as source code.")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
