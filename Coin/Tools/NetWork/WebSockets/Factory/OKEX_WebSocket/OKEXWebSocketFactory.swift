//
//  OKEXWebSocketFactory.swift
//  Coin
//
//  Created by gm on 2018/12/6.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class OKEXWebSocketFactory: NSObject,WebSocketProtocolFactory {
    
    func getWebSocket() -> WebSocketDelegate {
        connectAgain(false)
        return OKEXWebSocket.shareInstance
    }
    
    func connectAgain(_ isRecalculate: Bool) {
        
        objc_sync_enter(self)
        let webSocketDelegate = OKEXWebSocket.shareInstance
        //如果断连 则重连
        if !webSocketDelegate.webSocketState {
            if isRecalculate {
                webSocketDelegate.reconnectionNumber = 0
            }
            var request          = URLRequest.init(url: URL.init(string: COINIPSwitchingTool.getWebSocketApi(platform: .okex))!)
            request.setValue("real.okex.com", forHTTPHeaderField: "Host")
            let webSocket = SRWebSocket.init(urlRequest: request, protocols: nil, allowsUntrustedSSLCertificates: true)
            let webSocketFactory = WebSocketFactory.init(srWebSocket: webSocket)
            webSocketDelegate.webSocketProtocol = webSocketFactory
            webSocketFactory.delegate = webSocketDelegate
            webSocketDelegate.webSocketProtocol?.open()
        }
        objc_sync_exit(self)
    }
    

}
