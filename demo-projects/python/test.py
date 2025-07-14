#!/usr/bin/env python3
from credentials import Credentials, CredentialKey

print("🔐 Python Credential Test")
print("========================")

api_key = Credentials.decrypt(CredentialKey.API_KEY)
if api_key:
    print(f"✅ API_KEY: {api_key}")

db_url = Credentials.decrypt(CredentialKey.DATABASE_URL)
if db_url:
    print(f"✅ DATABASE_URL: {db_url}")

jwt_secret = Credentials.decrypt(CredentialKey.JWT_SECRET)
if jwt_secret:
    print(f"✅ JWT_SECRET: {jwt_secret}")

# Test caching
print("\n📦 Testing cached access...")
stripe = Credentials.decrypt_cached(CredentialKey.STRIPE_KEY)
if stripe:
    print(f"✅ STRIPE_KEY (cached): {stripe}")

Credentials.clear_cache()
print("🧹 Cache cleared")
