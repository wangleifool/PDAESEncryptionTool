//
//  PDEncrypt.swift
//  PDAESEncryptTool
//
//  Created by lei wang on 2020/6/5.
//  Copyright © 2020 lei wang. All rights reserved.
//

import Foundation

enum OptionType: String {
    case sourcePath = "s"
    case secretKeyPath = "k"
    case password = "p"
    case destinationPath = "o"
    case help = "h"
    case unknown
  
    init(value: String) {
        switch value {
        case "-s":
            self = .sourcePath
        case "-k":
            self = .secretKeyPath
        case "-p":
            self = .password
        case "-o":
            self = .destinationPath
        case "-h":
            self = .help
        default:
            self = .unknown
        }
    }
}

class PDEncrypt {
    var consoleIO = ConsoleIO()
    
    func getOption(_ option: String) -> (option: OptionType, value: String) {
        return (OptionType(value: option), option)
    }
    
    func staticMode() {
        //1
        let argCount = CommandLine.argc
        let commandName = CommandLine.arguments[0]
        if (argCount < 2) {
            consoleIO.printUsage()
        } else {
            
            var sourcePath: String?
            var password: String?
            var keyPath: String?
            var destinationPath = "./encrypted.file"
            
            let arguments = CommandLine.arguments
                .filter { $0 != commandName }
                .map {
                    return getOption($0)
                }
            
            if arguments.count == 1, arguments.first?.option == OptionType.help {
                consoleIO.printUsage()
                return
            } else if arguments.count % 2 != 0 {
                consoleIO.writeMessage("Some parameter don't have value.", to: .error)
                consoleIO.printUsage()
                return
            }
            
            // parse sourcePath
            sourcePath = extractValue(from: arguments, fromOption: .sourcePath)
            password = extractValue(from: arguments, fromOption: .password, necceray: false)
            keyPath = extractValue(from: arguments, fromOption: .secretKeyPath, necceray: false)
            if let destination = extractValue(from: arguments, fromOption: .destinationPath, necceray: false) {
                destinationPath = destination
            }
            
            
            
            if let theSourcePath = sourcePath {
                if let thePassword = password {
                    encrypt(with: theSourcePath, password: thePassword, destination: destinationPath)
                } else if let keyPath = keyPath {
                    encrypt(with: theSourcePath, secretKey: keyPath, destination: destinationPath)
                } else {
                    consoleIO.writeMessage("Missing parameter", to: .error)
                    consoleIO.printUsage()
                }
            }
        }
    }
    
    func extractValue(from arguments: [(option: OptionType, value: String)], fromOption: OptionType, necceray: Bool = true) -> String? {
        guard let index = arguments.firstIndex(where: { (tuple) -> Bool in
            tuple.option == fromOption
        }) else {
            if (necceray) {
                consoleIO.writeMessage("The parameter \(fromOption.rawValue) is necceray", to: .error)
                consoleIO.printUsage()
            }
            return nil
        }
        
        guard let value = arguments.safeObject(at: index + 1)?.value else {
            consoleIO.writeMessage("The parameter \(fromOption.rawValue) must specify value", to: .error)
            consoleIO.printUsage()
            return nil
        }
        return value
    }
}

extension PDEncrypt {
    func measure(block: () -> Void) {
        print("START")
        let start = Date()
        block()
        let finish = Date()
        print("FINISH: \(finish.timeIntervalSince(start))")
    }

    // MARK: - Encrypt
    func encrypt(with data: Data, password: String, destination: String) {
        let encryptedData = RNCryptor.encrypt(data: data, withPassword: password)
        if (!FileManager.default.createFile(atPath: destination, contents: encryptedData, attributes: nil)) {
            consoleIO.writeMessage("write encrypted data failed", to: .error)
        } else {
            consoleIO.writeMessage("Encryption is successful. The Output path is \(destination)")
        }
    }
    
    func encrypt(with file: String, password: String, destination: String) {
        let filePath = URL(fileURLWithPath: file)
        do {
            let originData = try Data(contentsOf: filePath)
            guard FileManager.default.fileExists(atPath: file) else {
                consoleIO.writeMessage("the source file not exist", to: .error)
                return
            }
            encrypt(with: originData, password: password, destination: destination)
        } catch {
            consoleIO.writeMessage("read the source file failed", to: .error)
        }
    }
    
    
    /// 用指定密钥文件给指定文件进行加密
    /// - Parameters:
    ///   - file: 需要加密的文件路径
    ///   - secretKey: 密钥文件路径
    ///   - destination: 加密后的文件路径
    /// - Throws: 如果源文件或密钥找不到，会抛出EncryptError
    func encrypt(with file: String, secretKey: String, destination: String) {
        let keyPath = URL(fileURLWithPath: secretKey)
        do {
            let key = try String(contentsOf: keyPath)
            guard FileManager.default.fileExists(atPath: secretKey) else {
                consoleIO.writeMessage("secret key file not exist", to: .error)
                return
            }
            
            encrypt(with: file, password: key, destination: destination)
        } catch {
            consoleIO.writeMessage("read the secret file failed", to: .error)
        }
        
    }
    
    // MARK: - decrypt
    func decrypt(with data: Data, password: String, destination: String) {
        do {
            let decryptedData = try RNCryptor.decrypt(data: data, withPassword: password)
            if (!FileManager.default.createFile(atPath: destination, contents: decryptedData, attributes: nil)) {
                consoleIO.writeMessage("write data to destination file fail", to: .error)
            }
        } catch {
            consoleIO.writeMessage("decrypt is fail. please check the usage", to: .error)
            consoleIO.printUsage()
        }
        
    }
    
    func decrypt(with file: String, password: String, destination: String) {
        let filePath = URL(fileURLWithPath: file)
        do {
            let originData = try Data(contentsOf: filePath)
            guard FileManager.default.fileExists(atPath: file) else {
                consoleIO.writeMessage("decrypt is fail. please check the usage", to: .error)
                return
            }
            
            decrypt(with: originData, password: password, destination: destination)
        } catch {
            consoleIO.writeMessage("read source file fail", to: .error)
        }
        
    }
    
    
    /// 使用指定密钥给指定文件进行解密
    /// - Parameters:
    ///   - file: 待解密的文件
    ///   - secretKey: 密钥文件
    ///   - destination: 解密后的文件路径
    /// - Throws: 解密过程中出现的错误
    func decrypt(with file: String, secretKey: String, destination: String) {
        let keyPath = URL(fileURLWithPath: secretKey)
        do {
            let key = try String(contentsOf: keyPath)
            guard FileManager.default.fileExists(atPath: secretKey) else {
                consoleIO.writeMessage("secret file not exist", to: .error)
                return
            }
            
            decrypt(with: file, password: key, destination: destination)
        } catch {
            consoleIO.writeMessage("read secret key file fail", to: .error)
        }
        
    }
}

extension Array {
    public func safeObject(at index: Int) -> Element? {
        if (0..<count).contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}

extension URL {
    func absoluteString(removeSchema: Bool) -> String {
        guard let schemaStr = scheme,
            let range = absoluteString.range(of: schemaStr+"://") else {
            return absoluteString
        }
        
        return String(self.absoluteString[range.upperBound ..< self.absoluteString.endIndex])
    }
}
