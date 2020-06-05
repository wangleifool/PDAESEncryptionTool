//
//  main.swift
//  PDAESEncryptTool
//
//  Created by lei wang on 2020/6/5.
//  Copyright © 2020 lei wang. All rights reserved.
//

import Foundation

//print("encrypt file")
//let sourceFilePath = "/Users/leiwang/workspace/ios/PianoDisc/PDSubscription/encryptTest/test.mp3"
//let keyPath = "/Users/leiwang/workspace/ios/PianoDisc/PDSubscription/encryptTest/secret.key"
//let encryptFile = encryptBaseFile(from: sourceFilePath, with: keyPath)
//
//if FileManager.default.fileExists(atPath: encryptFile ?? "") {
//    let _ = decryptionBaseFile(from: encryptFile!, with: keyPath)
//    print("output encrypt file: \(encryptFile)")
//} else {
//    print("encrypt fail")
//}

let encryptor = PDEncrypt()
encryptor.staticMode()
