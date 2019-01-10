//
//  COINUserDefaultsHelper.swift
//  Coin
//
//  Created by gm on 2018/11/8.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

struct UserDefaultsHelperKey {
    
    ///是否隐藏的key
    static let ud_secret_key = "ud_secret_key"
    
    /// 涨跌幅百分比颜色key bool类型
    static let percentageColor = "Percentage color"
    
    
    /// 添加自选的key
    static let collectionsKey = "collectionsKey"
    
    /// 交易确认提示的key,true为需要提示，false为不需要提示
    static let tradeSureKey = "tradeSureKey"
    
    ///本地服务器端口号
    static let localPortKey = "localPortKey"
    
    ///okex服务器时间
    static let okexTimeKey = "okexTimeKey"
}

class COINUserDefaultsHelper: NSObject {
    
    class func getObjArray(_ key: String,platformType: Platform = .bitmex)-> Array<Any> {
        let udKey = getUDKey(key, platformType: platformType)
        var objArray = UserDefaults.standard.object(forKey: udKey) as? Array<NSObject>
        if (objArray == nil) {
            objArray = Array()
        }
        
        return objArray!
    }
    
    class func saveObjToArray(_ obj: Any, _ key: String,platformType: Platform = .bitmex){
        var objArray = getObjArray(key, platformType: platformType)
        objArray.append(obj as! NSObject)
        saveObj(obj: objArray, userdfalutKay: key, platformType: platformType)
    }
    
    class func saveObj(obj: Any?, userdfalutKay  key:String,platformType: Platform = .bitmex){
        let udKey = getUDKey(key, platformType: platformType)
        UserDefaults.standard.set(obj, forKey: udKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getObj(userdfalutKay  key:String,platformType: Platform = .bitmex) -> Any? {
        let udKey = getUDKey(key, platformType: platformType)
        return UserDefaults.standard.object(forKey: udKey)
    }
    
   class func getBoolValue(forKey key:String, platformType: Platform = .bitmex) -> Bool {
        let udKey = getUDKey(key, platformType: platformType)
        return UserDefaults.standard.bool(forKey: udKey)
    }
    
   class func saveBoolValue(value: Bool, forKey  key: String,platformType: Platform = .bitmex){
        let udKey = getUDKey(key, platformType: platformType)
        UserDefaults.standard.set(value, forKey: udKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getIntValue(forKey key:String, platformType: Platform = .bitmex) -> Int {
        let udKey = getUDKey(key, platformType: platformType)
        return UserDefaults.standard.integer(forKey: udKey)
    }
    
    class func saveIntValue(value: Int, forKey  key: String,platformType: Platform = .bitmex){
        let udKey = getUDKey(key, platformType: platformType)
        UserDefaults.standard.set(value, forKey: udKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getFloatValue(forKey key:String, platformType: Platform = .bitmex) -> Float {
        let udKey = getUDKey(key, platformType: platformType)
        return UserDefaults.standard.float(forKey: udKey)
    }
    
    class func saveFloatValue(value: Float, forKey  key: String,platformType: Platform = .bitmex) {
        let udKey = getUDKey(key, platformType: platformType)
        UserDefaults.standard.set(value, forKey: udKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getUDKey(_ key: String, platformType: Platform) -> String{
        var platformStr = "bitMex"
        switch platformType {
            case .bitmex:
                break
            case .okex:
                platformStr = "okex"
                break
            case .other:
                platformStr = ""
                break
        }
        return key + platformStr
    }
}
