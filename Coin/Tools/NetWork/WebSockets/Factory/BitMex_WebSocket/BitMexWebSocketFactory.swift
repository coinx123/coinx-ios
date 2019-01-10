//
//  BitMexWebSocketFactory.swift
//  WebServerFactory
//
//  Created by gm on 2018/10/30.
//  Copyright © 2018年 gm. All rights reserved.
//

import UIKit

class BitMexWebSocketFactory: NSObject,WebSocketProtocolFactory {
    
    
    func getWebSocket() -> WebSocketDelegate {
        connectAgain(false)
       return BitMexWebSocket.shareInstance
    }
    
    func connectAgain(_ isRecalculate: Bool){
        
        objc_sync_enter(self)
        let webSocketDelegate = BitMexWebSocket.shareInstance
        //如果断连 则重连
        if !webSocketDelegate.webSocketState {
            if isRecalculate {
                webSocketDelegate.reconnectionNumber = 0
            }
            let url              = URL.init(string: COINIPSwitchingTool.getWebSocketApi(platform: .bitmex))!
            var request          = URLRequest.init(url: url)
            request.setValue("www.bitmex.com", forHTTPHeaderField: "Host")
            let webSocket = SRWebSocket.init(urlRequest: request, protocols: nil, allowsUntrustedSSLCertificates: true)
            let webSocketFactory = WebSocketFactory.init(srWebSocket: webSocket)
            webSocketDelegate.webSocketProtocol = webSocketFactory
            webSocketFactory.delegate = webSocketDelegate
            webSocketDelegate.webSocketProtocol?.open()
        }
        objc_sync_exit(self)
    }
}
