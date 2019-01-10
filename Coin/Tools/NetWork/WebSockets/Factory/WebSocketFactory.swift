//
//  WebSocketFactory.swift
//  WebSocketFactory
//
//  Created by gm on 2018/10/30.
//  Copyright © 2018年 gm. All rights reserved.
//

import UIKit

class WebSocketFactory: NSObject,SRWebSocketDelegate,WebSocketProtocol {
    
    fileprivate let srWebSocket: SRWebSocket
    
    init(srWebSocket:SRWebSocket) {
        self.srWebSocket = srWebSocket
        super.init()
        self.srWebSocket.delegate = self
    }
    
    //MARK: ----WebSocketProtocol-----
    weak var delegate: WebSocketDelegate?
    
    func open() {
        self.srWebSocket.open()
    }
    
    func close() {
        self.srWebSocket.close()
    }
    
    func closeWithCode(code: NSInteger, reason: String?) {
        self.srWebSocket.close(withCode: code, reason: reason)
    }
    
    func sendStrMessage(string: String) throws {
        do {
            try self.srWebSocket.send(string: string)
        }catch{
            throw(error)
        }
    }
    
    func sendDataMessage(data: Data?) throws {
        do {
            try self.srWebSocket.send(data: data)
        }catch{
            throw(error)
        }
    }
    
    func sendDataNoCopy(data: Data?) throws {
        do {
            try self.srWebSocket.send(dataNoCopy: data)
        }catch{
            throw(error)
        }
    }
    
    func sendPing(data: Data?) throws {
        do {
            try self.srWebSocket.sendPing(data)
        }catch{
            throw(error)
        }
    }
    
    //MARK: ----SRWebSocketDelegate-----
    
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        delegate?.didFailWithError(error, self)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceivePong pongPayload: Data?) {
        delegate?.didReceivePong(pongPayload, self)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        delegate?.didCloseWithCode(code, reason: reason, wasClean: wasClean, self)
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        delegate?.webSocketDidOpen(self)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        delegate?.didReceiveMessage(message, self)
    }

}
