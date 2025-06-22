import ArgumentParser
import Foundation

@main
struct CredentialCode: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "credential-code",
        abstract: "Securely manage credentials for any project",
        version: "0.1.0",
        subcommands: [
            InitCommand.self,
            GenerateCommand.self
        ]
    )
}