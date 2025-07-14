import Foundation

@main
struct TestCredentials {
    static func main() {
        print("🔐 Swift Credential Test (External Key Mode)")
        print("============================================")
        
        do {
            // Load the external key
            try Credentials.loadKey(from: "../.credential-code/encryption-key.txt")
            print("✅ Loaded encryption key from file")
            
            // Access credentials
            let apiKey = try Credentials.get(.API_KEY)
            print("✅ API_KEY: \(apiKey)")
            
            let dbUrl = try Credentials.get(.DATABASE_URL)
            print("✅ DATABASE_URL: \(dbUrl)")
            
            let jwtSecret = try Credentials.get(.JWT_SECRET)
            print("✅ JWT_SECRET: \(jwtSecret)")
            
            // Test subscript access
            if let stripe = Credentials[.STRIPE_KEY] {
                print("✅ STRIPE_KEY (subscript): \(stripe)")
            }
            
            print("\n✨ External key mode working correctly!")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
