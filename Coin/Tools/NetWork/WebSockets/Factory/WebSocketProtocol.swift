//
//  WebSocketProtocol.swift
//  WebSocketFactory
//
//  Created by gm on 2018/10/30.
//  Copyright © 2018年 gm. All rights reserved.
//

import UIKit

public protocol WebSocketProtocol: class {
    
     var delegate: WebSocketDelegate? { get set }
    
     func open()
     func close()
     func closeWithCode(code: NSInteger, reason:String?)
     func sendStrMessage(string:String) throws
     func sendDataMessage(data:Data?) throws
     func sendDataNoCopy(data:Data?)  throws
     func sendPing(data:Data?) throws
}

public protocol WebSocketDelegate: class {
    var  webSocketProtocol: WebSocketProtocol? { get set }
    var  webSocketState: Bool { get set }
    func sendStrMessage(string: String)
    func webSocketConnectAgain()
    func didFailWithError(_ error: Error, _ webSocket: WebSocketProtocol)
    
    func didReceivePong(_ pongPayload: Data?, _ webSocket: WebSocketProtocol)
    
    func didCloseWithCode(_ code: Int, reason: String?, wasClean: Bool,_ webSocket: WebSocketProtocol)
    func webSocketDidOpen(_ webSocket: WebSocketProtocol)
    
    func didReceiveMessage(_ message: Any,_ webSocket: WebSocketProtocol)
}
