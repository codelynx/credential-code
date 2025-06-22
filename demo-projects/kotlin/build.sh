#!/bin/bash
echo "Building Kotlin..."
# Remove package declaration for simple compilation
sed '1d' Credentials.kt > CredentialsNoPackage.kt
kotlinc CredentialsNoPackage.kt Test.kt -include-runtime -d test.jar
echo "Run with: java -jar test.jar"
