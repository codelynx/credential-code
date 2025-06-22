import Foundation

@main
struct TestCredentials {
    static func main() {
        print("🔐 Swift Credential Test")
        print("=======================")

        if let apiKey = Credentials.decrypt(.API_KEY) {
            print("✅ API_KEY: \(apiKey)")
        }

        if let dbUrl = Credentials.decrypt(.DATABASE_URL) {
            print("✅ DATABASE_URL: \(dbUrl)")
        }

        if let jwtSecret = Credentials.decrypt(.JWT_SECRET) {
            print("✅ JWT_SECRET: \(jwtSecret)")
        }

        // Test caching
        print("\n📦 Testing cached access...")
        if let stripe = Credentials.decryptCached(.STRIPE_KEY) {
            print("✅ STRIPE_KEY (cached): \(stripe)")
        }

        Credentials.clearCache()
        print("🧹 Cache cleared")
    }
}
