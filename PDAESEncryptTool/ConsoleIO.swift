//
//  ConsoleIO.swift
//  PDAESEncryptTool
//
//  Created by lei wang on 2020/6/5.
//  Copyright © 2020 lei wang. All rights reserved.
//

import Foundation

enum OutputType {
    case standard
    case error
}

class ConsoleIO {
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
            case .standard:
                print("\u{001B}[;m\(message)")
            case .error:
                fputs("\u{001B}[0;31m\(message)\n", stderr)
        }
    }
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent

        writeMessage("Usage: \(executableName) -s SourceFilePath [-p | -k] thePasswordStuff [-o] destinationPath")
        writeMessage("Or")
        writeMessage("\(executableName) -h to show usage information")
        
        writeMessage("-s specify the path of source file.")
        writeMessage("-k specify the path of secret file.")
        writeMessage("-p specify the password text.")
        writeMessage("-o specify the path of output file.")
    }
}
