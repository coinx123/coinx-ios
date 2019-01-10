//
//  Dictionary+Extension.swift
//  Coin
//
//  Created by gm on 2018/11/21.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

extension Dictionary {

    func tojsonStr() -> String? {
        if (!JSONSerialization.isValidJSONObject(self)) {
            return ""
        }
        
        let data : NSData! = try? JSONSerialization.data(withJSONObject: self, options: []) as NSData
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        
        return JSONString! as String
    }
}
