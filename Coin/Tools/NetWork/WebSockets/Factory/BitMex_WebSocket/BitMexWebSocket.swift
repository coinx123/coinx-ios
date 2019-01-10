//
//  BitMexWebSocket.swift
//  WebSocketFactory
//
//  Created by gm on 2018/10/30.
//  Copyright © 2018年 gm. All rights reserved.
//

import UIKit
import HandyJSON


class BitMexWebSocket: NSObject,WebSocketDelegate {
    
    //创建下载管理器单例
    static let shareInstance: BitMexWebSocket = {
        let instance = BitMexWebSocket()
        return instance
    }()
    lazy var messageDict: [String: COINWebSocketMessageInfo] = Dictionary()
    lazy var cannotCancelMessageArray: [String] = Array()
    var webSocketState: Bool = false
    var webSocketProtocol: WebSocketProtocol?
    var reconnectionNumber = 0
    
    func sendStrMessageCannotCancel(string: String){
        
        
        if !self.cannotCancelMessageArray.contains(string){
            self.cannotCancelMessageArray.append(string)
        }
        sendStrMessage(string: string)
    }
    
    func sendStrMessage(string: String) {
        
        //如果webSocket是未连接状态 先存储起来 等到建立连接以后再发送
        if !self.webSocketState {
            self.messageDict[string] = COINWebSocketMessageInfo.init(message: string)
            BitMexWebSocketFactory().connectAgain(false)
            return
        }
        
        //如果存在于messageDict 则说明有订阅
        if self.messageDict.keys.contains(string){
            
            let messageInfo = self.messageDict[string]
            //如果已经订阅了 就不重新订阅
            if (messageInfo?.isSend)!{
                return
            }
            messageInfo?.isSend = true
            
            //如果是取消订阅 就需要把前面订阅的信息移除字典
            if string.contains("unsubscribe") {
                
                self.messageDict.removeValue(forKey: string)
                let stringTemp = string.replacingOccurrences(of: "unsubscribe", with: "subscribe")
                
                //不能取消的订阅
                if self.cannotCancelMessageArray.contains(stringTemp){
                    return
                }
                
                if self.messageDict.keys.contains(stringTemp){
                    let messageInfo = self.messageDict[string]
                    if messageInfo != nil && messageInfo!.isSend {
                        self.messageDict.removeValue(forKey: stringTemp)
                    }
                }
            }
            
        }else{
            //如果是取消订阅 就需要把前面订阅的信息移除字典
            if string.contains("unsubscribe") {
                let stringTemp = string.replacingOccurrences(of: "unsubscribe", with: "subscribe")
                //不能取消的订阅
                if self.cannotCancelMessageArray.contains(stringTemp){
                    return
                }
                if self.messageDict.keys.contains(stringTemp){
                    let messageInfo = self.messageDict[stringTemp]
                    if (messageInfo?.isSend)! {
                        self.messageDict.removeValue(forKey: stringTemp)
                    }
                }
            }else{
                let messageInfo = COINWebSocketMessageInfo.init(message: string)
                messageInfo.isSend = true
                self.messageDict[string] = messageInfo
            }
            
        }
        
        
        do{
            debugPrint("start send",string)
            try self.webSocketProtocol?.sendStrMessage(string: string)
        }catch{
           debugPrint(error.localizedDescription)
        }
    }
    
    func didFailWithError(_ error: Error, _ webSocket: WebSocketProtocol) {
        webSocketConnectAgain()
    }
    
    func didReceivePong(_ pongPayload: Data?, _ webSocket: WebSocketProtocol) {
        //debugPrint("didReceivePong")
    }
    
    func didCloseWithCode(_ code: Int, reason: String?, wasClean: Bool, _ webSocket: WebSocketProtocol) {
        webSocketConnectAgain()
    }
    
    func webSocketConnectAgain() {
        objc_sync_enter(self)
        self.reconnectionNumber += 1
        //最多两次次重连
        if self.reconnectionNumber == 3 {
            return
        }
        
        self.webSocketState = false
        for model in self.messageDict.values {
            model.isSend = false
        }
        let waitTime: Double = Double(self.reconnectionNumber * 2)//延时一段时间再重连
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + waitTime) {
            OKEXWebSocketFactory().connectAgain(false)
            debugPrint("bitMexWebSocket connect again")
        }
        objc_sync_exit(self)
    }
    
    func webSocketDidOpen(_ webSocket: WebSocketProtocol) {
        debugPrint("webSocketDidOpen",self.timer)
        self.reconnectionNumber = 0
        self.webSocketState = true
        for message in self.messageDict.keys {
            sendStrMessage(string: message)
        }
        RunLoop.main.add(self.timer, forMode: .common)
       //try! webSocketProtocol!.sendStrMessage(string: "{\"op\": \"subscribe\", \"args\": [\"quoteBin1d:XBTUSD\",\"quoteBin1d:XBT7D_U105\"]}")
    }
    
    func didReceiveMessage(_ message: Any, _ webSocket: WebSocketProtocol) {
        
        let messageStr: String = message as! String
        if messageStr.contains("\"table\":\""){
           //debugPrint(messageStr)
           postWebSocketMessage(message as! String)
        }
        
    }
    
    lazy var timer: Timer = {
        
        let timerTemp = HWWeakTimer.scheduledTimer(withTimeInterval: 5, target: self, selector:#selector(sendPing), userInfo: nil, repeats: true)
        
        return timerTemp!
    }()
    
   @objc func sendPing(){
    
        do{
           try self.webSocketProtocol?.sendPing(data: "ping".data(using: String.Encoding.utf8))
        }catch{
            debugPrint(error.localizedDescription)
        }
    }
    
}

extension BitMexWebSocket {
    
   func postWebSocketMessage(_ message:String){
    
    let dict = message.jsonStringToDict()
    
    let table: String = dict["table"] as! String
    
     NotificationCenter.default.post(name:
        Notification.Name.init(table),
        object: dict["data"],
        userInfo: nil)
    
  }
}

