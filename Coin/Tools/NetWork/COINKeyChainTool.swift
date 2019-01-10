//
//  COINKeyChainTool.swift
//  Coin
//
//  Created by dev6 on 2018/11/21.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit
import KeychainAccess

/// 保存在keychain中的key
public struct PlistKey {
    public static let OKEXSecretKey = "OKEXSecretKey"
    public static let OKEXAPIKey = "OKEXAPIKey"
    public static let OKEXPassphrase = "OKEXPassphrase"
    public static let BitMEXSecretKey = "BitMEXSecretKey"
    public static let BitMEXAPIKey = "BitMEXAPIKey"
}

class COINKeyChainTool: NSObject {
    static let instance: COINKeyChainTool = COINKeyChainTool()
    public class func shared() -> COINKeyChainTool {
        return instance
    }
    let keychain = Keychain(service: COINKeyChainTool.getKCString())
    
    /// 保存绑定平台的apikey
    ///
    /// - Parameters:
    ///   - platform: 要绑定的平台
    ///   - apiKey: 要绑定的apikey，必填
    ///   - secretKey: 要绑定的secretKey，必填
    ///   - passphrase: 要绑定的passphrase，选填
    public func save(platform: Platform , apiKey: String, secretKey: String, passphrase: String? = nil
        ) {
        if platform == .bitmex {
            keychain[PlistKey.BitMEXAPIKey] = apiKey
            keychain[PlistKey.BitMEXSecretKey] = secretKey
        } else if platform == .okex {
            keychain[PlistKey.OKEXAPIKey] = apiKey
            keychain[PlistKey.OKEXSecretKey] = secretKey
            keychain[PlistKey.OKEXPassphrase] = passphrase
        }
    }
    
    /// 删除平台绑定的apikey
    ///
    /// - Parameter platform: 要删除的平台
    public func delete(platform: Platform) {
        if platform == .bitmex {
            keychain[PlistKey.BitMEXAPIKey] = nil
            keychain[PlistKey.BitMEXSecretKey] = nil
        } else if platform == .okex {
            keychain[PlistKey.OKEXAPIKey] = nil
            keychain[PlistKey.OKEXSecretKey] = nil
            keychain[PlistKey.OKEXPassphrase] = nil
        }
    }
    
    /// 查询判断是否绑定apikey
    ///
    /// - Parameter platform: 查询平台
    /// - Returns: 是否绑定，true为已绑定，false为未绑定
    public func hasBind(platform: Platform) -> Bool {
        if platform == .bitmex {
            if COINKeyChainTool.instance.keychain[PlistKey.BitMEXSecretKey] == nil || COINKeyChainTool.instance.keychain[PlistKey.BitMEXAPIKey] == nil {
                return false
            }
        } else if platform == .okex {
            if COINKeyChainTool.instance.keychain[PlistKey.OKEXAPIKey] == nil || COINKeyChainTool.instance.keychain[PlistKey.OKEXSecretKey] == nil || COINKeyChainTool.instance.keychain[PlistKey.OKEXPassphrase] == nil {
                return false
            }
        }
        return true
    }
    
    
    class func getKCString() -> String {
        let strings = ["com","coiniOSSwift","www"]
        var string = ""
        for (_,str) in strings.enumerated() {
            string.append(str)
            string.append(".")
        }
        string.remove(at: string.index(before: string.endIndex))
        return string
    }
}
