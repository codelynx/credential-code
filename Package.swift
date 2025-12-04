// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CredentialCode",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "credential-code",
            targets: ["CredentialCode"]
        ),
        .library(
            name: "CredentialCodeKit",
            targets: ["CredentialCodeKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "CredentialCodeKit",
            dependencies: []
        ),
        .executableTarget(
            name: "CredentialCode",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "CredentialCodeKit"
            ]
        ),
        .testTarget(
            name: "CredentialCodeTests",
            dependencies: ["CredentialCode"]
        )
    ]
)
