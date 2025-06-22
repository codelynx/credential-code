import ArgumentParser

@main
struct CredentialCode: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift CLI tool for managing credentials and authentication codes."
    )
    
    mutating func run() throws {
        print("Hello, World!")
    }
}