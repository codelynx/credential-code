public class Test {
    public static void main(String[] args) {
        System.out.println("🔐 Java Credential Test");
        System.out.println("======================");
        
        String apiKey = Credentials.decrypt(Credentials.CredentialKey.API_KEY);
        if (apiKey != null) {
            System.out.println("✅ API_KEY: " + apiKey);
        }
        
        String dbUrl = Credentials.decrypt(Credentials.CredentialKey.DATABASE_URL);
        if (dbUrl != null) {
            System.out.println("✅ DATABASE_URL: " + dbUrl);
        }
        
        String jwtSecret = Credentials.decrypt(Credentials.CredentialKey.JWT_SECRET);
        if (jwtSecret != null) {
            System.out.println("✅ JWT_SECRET: " + jwtSecret);
        }
        
        // Test caching
        System.out.println("\n📦 Testing cached access...");
        String stripe = Credentials.decryptCached(Credentials.CredentialKey.STRIPE_KEY);
        if (stripe != null) {
            System.out.println("✅ STRIPE_KEY (cached): " + stripe);
        }
        
        Credentials.clearCache();
        System.out.println("🧹 Cache cleared");
    }
}
