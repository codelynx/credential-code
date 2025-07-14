fun main() {
    println("🔐 Kotlin Credential Test")
    println("========================")
    
    Credentials.decrypt(CredentialKey.API_KEY)?.let {
        println("✅ API_KEY: $it")
    }
    
    Credentials.decrypt(CredentialKey.DATABASE_URL)?.let {
        println("✅ DATABASE_URL: $it")
    }
    
    Credentials.decrypt(CredentialKey.JWT_SECRET)?.let {
        println("✅ JWT_SECRET: $it")
    }
    
    // Test caching
    println("\n📦 Testing cached access...")
    Credentials.decryptCached(CredentialKey.STRIPE_KEY)?.let {
        println("✅ STRIPE_KEY (cached): $it")
    }
    
    Credentials.clearCache()
    println("🧹 Cache cleared")
}
