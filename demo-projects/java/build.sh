#!/bin/bash
echo "Building Java..."
# Remove package declaration for simple compilation
sed '1d' Credentials.java > CredentialsNoPackage.java
javac CredentialsNoPackage.java Test.java
echo "Run with: java Test"
