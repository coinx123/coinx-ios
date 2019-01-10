//
//  COINIPSwitchingTool.swift
//  Coin
//
//  Created by gm on 2019/1/8.
//  Copyright © 2019年 COIN. All rights reserved.
//

import UIKit
struct COINWebSocketBaseApi {
    static let bitMexWebSocketApi = "wss://www.bitmex.com/realtime/socket.io/?EIO=4&transport=websocket"
    static let bitMexWebSocketIpArray = [
        "52.51.111.111",
        "54.171.58.202",
        "54.77.142.10",
        "52.215.246.229",
        "52.50.27.138",
        "34.250.48.151",
        "34.246.236.176",
        "52.51.209.196",
        "54.171.18.231",
        "63.32.28.238"
    ]
    
    static let bitMexRequestApi   = "https://www.bitmex.com"
    static let bitMexRequestApiIpArray = [
        "52.51.111.111",
        "54.171.58.202",
        "54.77.142.10",
        "52.215.246.229",
        "52.50.27.138",
        "34.250.48.151",
        "34.246.236.176",
        "52.51.209.196",
        "54.171.18.231",
        "63.32.28.238"
    ]
    
    static let okexWebSocketApi = "wss://real.okex.com:10440/websocket/okexapi?compress=true"
    static let okexWebSocketApiArray = ["149.129.81.70"]
    
    
    static let okexApiArray = ["104.19.212.87","104.19.213.87","47.75.105.229"]
    
}

class COINIPSwitchingTool: NSObject {
    static let okexApiHost: String = COINWebSocketBaseApi.okexApiArray.randomElement() ?? "www.okex.com"
    static let bitmexApiHost: String = COINWebSocketBaseApi.bitMexRequestApiIpArray.randomElement() ?? "www.bitmex.com"
    
    class func getWebSocketApi(platform: Platform)-> String{
        switch platform {
        case .bitmex:

            let ipAddress: String  = COINWebSocketBaseApi.bitMexWebSocketIpArray.randomElement() ?? "www.bitmex.com"
            let requestApi = COINWebSocketBaseApi.bitMexWebSocketApi.replacingOccurrences(of: "www.bitmex.com", with: ipAddress)
            return requestApi
        case .okex:
            let ipAddress: String  = COINWebSocketBaseApi.okexWebSocketApiArray.randomElement() ?? "real.okex.com"
            let requestApi = COINWebSocketBaseApi.okexWebSocketApi.replacingOccurrences(of: "real.okex.com", with: ipAddress)
            return requestApi
        case .other:
            return ""
        }
        
    }
    
   
            
    
    
    class func getRequestApi(platform: Platform)-> String {
        switch platform {
        case .bitmex:
            let ipAddress: String  = self.bitmexApiHost
            let requestApi = COINWebSocketBaseApi.bitMexRequestApi.replacingOccurrences(of: "www.bitmex.com", with: ipAddress)
            return requestApi
        case .okex:
            return self.okexApiHost
        case .other:
            return ""
        }
    }
}
