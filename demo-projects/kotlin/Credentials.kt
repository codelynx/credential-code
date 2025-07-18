// Auto-generated by credential-code
// DO NOT EDIT - This file will be overwritten

package com.example.credentials

import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

enum class CredentialKey {
    API_KEY,
    AWS_SECRET_KEY,
    DATABASE_URL,
    JWT_SECRET,
    STRIPE_KEY,
}

object Credentials {
    private data class EncryptedData(
        val data: ByteArray,
        val nonce: ByteArray,
        val tag: ByteArray
    )
    
    // Encrypted credential data as byte arrays
    private val encryptedData = mapOf(
        CredentialKey.API_KEY to EncryptedData(
            data = byteArrayOf(
                0x22, 0x2F, 0x39, 0x74, -25, 0x75, 0x74, -29,
                -64, 0x0C, -7, 0x69, -117, 0x60, 0x40, -38,
                0x06, 0x12, 0x15, 0x2A, -65, 0x76, -24, 0x20
            ),
            nonce = byteArrayOf(
                0x73, -39, -51, 0x02, 0x56, 0x62, 0x6A, 0x21,
                0x31, 0x2E, -90, 0x14
            ),
            tag = byteArrayOf(
                -120, -42, -97, 0x23, 0x4C, 0x79, 0x1F, 0x2B,
                0x2F, 0x35, -40, 0x68, -69, -42, 0x15, -64
            )
        ),
        CredentialKey.AWS_SECRET_KEY to EncryptedData(
            data = byteArrayOf(
                -51, -111, -74, 0x08, -28, -123, -78, -54,
                0x6E, 0x5E, 0x59, -34, -59, -41, 0x44, 0x40,
                0x3B, 0x43, -25, -14, -78, -72, 0x2A, -57,
                -54, 0x2D, 0x4E, -123, -122, 0x77, 0x0A, 0x77
            ),
            nonce = byteArrayOf(
                -79, 0x7A, 0x64, -114, 0x63, -51, 0x6B, 0x3F,
                0x68, -38, 0x37, 0x68
            ),
            tag = byteArrayOf(
                -33, -12, 0x6C, 0x33, -68, 0x79, 0x42, 0x3E,
                -7, 0x76, -19, -113, -7, -125, -7, 0x2B
            )
        ),
        CredentialKey.DATABASE_URL to EncryptedData(
            data = byteArrayOf(
                0x47, 0x03, 0x6F, 0x25, -29, -12, 0x51, -47,
                0x41, -24, 0x7A, 0x65, 0x6E, 0x1F, 0x08, -93,
                -14, -20, -16, -19, -79, 0x47, 0x08, -36,
                0x56, -120, -62, 0x48, 0x52, -102, -8, 0x67,
                0x7A, 0x4F, -75, 0x1C, -104, -39, 0x4C, 0x32,
                0x19, -101, 0x17, 0x7B
            ),
            nonce = byteArrayOf(
                0x76, 0x44, -117, 0x78, 0x5A, 0x1A, 0x0A, -121,
                0x5B, 0x7F, -56, 0x7B
            ),
            tag = byteArrayOf(
                -85, -7, -66, 0x76, 0x10, -71, 0x15, 0x0F,
                -39, -102, -96, 0x10, 0x37, -25, -102, 0x76
            )
        ),
        CredentialKey.JWT_SECRET to EncryptedData(
            data = byteArrayOf(
                0x31, 0x34, -73, 0x4B, 0x51, -118, -62, 0x6C,
                0x43, 0x01, 0x78, 0x3A, 0x5B, -82, -100, -70,
                0x5A, -3, 0x04, -113, 0x23, -29, -29, -46,
                0x3D, 0x2C, -73, -41, 0x7B
            ),
            nonce = byteArrayOf(
                0x49, -22, 0x6B, -58, 0x4A, 0x11, 0x1A, 0x4C,
                0x2C, -45, 0x16, 0x0F
            ),
            tag = byteArrayOf(
                -80, 0x53, -13, 0x68, 0x03, -113, -89, 0x54,
                0x7A, -56, -102, -34, 0x6E, -48, -18, 0x08
            )
        ),
        CredentialKey.STRIPE_KEY to EncryptedData(
            data = byteArrayOf(
                0x1C, 0x44, -30, 0x0C, -63, -73, 0x11, -71,
                0x23, -60, 0x2B, -120, 0x19, -73, 0x41, -13,
                0x38, -70, -29, 0x52, 0x45, -107, 0x39, -112,
                0x03, -75, -65
            ),
            nonce = byteArrayOf(
                -100, 0x1E, 0x5F, -29, -81, 0x1B, -41, -84,
                -16, -25, 0x42, -28
            ),
            tag = byteArrayOf(
                -72, -62, -100, -26, 0x6A, -1, 0x58, -61,
                0x57, -52, 0x23, -77, 0x4E, 0x6F, 0x24, 0x0F
            )
        ),
    )

    // Runtime decryption key (obfuscated)
    private val keyComponents = arrayOf(
        byteArrayOf(-30, -99, -39, 0x31),
        byteArrayOf(0x3C, -126, 0x02, 0x1B),
        byteArrayOf(0x4D, -29, -4, -13),
        byteArrayOf(0x78, -71, -5, 0x7D),
        byteArrayOf(0x71, 0x64, -127, -124),
        byteArrayOf(0x37, 0x70, -101, 0x06),
        byteArrayOf(0x11, -98, -17, 0x02),
        byteArrayOf(-128, -7, -116, -19),
    )

    @JvmStatic
    fun decrypt(key: CredentialKey): String? {
        val encrypted = encryptedData[key] ?: return null
        
        return try {
            // Reconstruct the decryption key
            val keyData = keyComponents.flatMap { it.toList() }.toByteArray()
            val secretKey = SecretKeySpec(keyData, "AES")
            
            // Setup cipher for AES-GCM
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            val gcmSpec = GCMParameterSpec(128, encrypted.nonce)
            cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec)
            
            // Combine ciphertext and tag for decryption
            val cipherTextWithTag = encrypted.data + encrypted.tag
            val decrypted = cipher.doFinal(cipherTextWithTag)
            
            String(decrypted, Charsets.UTF_8)
        } catch (e: Exception) {
            null
        }
    }
    
    // Optional: Decrypt with caching
    private val cache = mutableMapOf<CredentialKey, String>()
    
    @JvmStatic
    fun decryptCached(key: CredentialKey): String? {
        cache[key]?.let { return it }
        
        val decrypted = decrypt(key) ?: return null
        cache[key] = decrypted
        return decrypted
    }
    
    // Clear cache when needed
    @JvmStatic
    fun clearCache() {
        cache.clear()
    }
}