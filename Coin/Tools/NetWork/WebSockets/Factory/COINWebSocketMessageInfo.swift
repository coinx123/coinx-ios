//
//  COINWebSocketMessageInfo.swift
//  Coin
//
//  Created by gm on 2018/11/9.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINWebSocketMessageInfo: NSObject {
    
    var message: String
    var isSub  : Bool = true
    var isSend : Bool = false
    
    init(message:String) {
        self.message = message
        super.init()
    }
    
}
