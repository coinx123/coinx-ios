//
//  OKEXWebSocket.swift
//  Coin
//
//  Created by gm on 2018/12/6.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
import DataCompression

class OKEXWebSocket: NSObject,WebSocketDelegate {
    
    var webSocketProtocol: WebSocketProtocol?
    
    var webSocketState: Bool = false
    lazy var messageDict: [String: COINWebSocketMessageInfo] = Dictionary()
    lazy var cannotCancelMessageArray: [String] = Array()
    var reconnectionNumber = 0
    
    static let shareInstance: OKEXWebSocket = {
        let instance = OKEXWebSocket()
        return instance
    }()
    
    

    func sendStrMessage(string: String) {
        //如果webSocket是未连接状态 先存储起来 等到建立连接以后再发送
        if !self.webSocketState {
            self.messageDict[string] = COINWebSocketMessageInfo.init(message: string)
            OKEXWebSocketFactory().connectAgain(false)
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
            if string.contains("removeChannel") {
                self.messageDict.removeValue(forKey: string)
                let stringTemp = string.replacingOccurrences(of: "removeChannel", with: "addChannel")
                if self.messageDict.keys.contains(stringTemp) {
                    let messageInfo = self.messageDict[string]
                    if messageInfo != nil && messageInfo!.isSend {
                        self.messageDict.removeValue(forKey: stringTemp)
                    }
                }
            }
        }else{
            //如果是取消订阅 就需要把前面订阅的信息移除字典
            if string.contains("removeChannel") {
                let stringTemp = string.replacingOccurrences(of: "removeChannel", with: "addChannel")
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
            debugPrint("okex_start send",string)
            try self.webSocketProtocol?.sendStrMessage(string: string)
        }catch{
            debugPrint(error.localizedDescription)
        }
    }
    
    func didFailWithError(_ error: Error, _ webSocket: WebSocketProtocol) {
        webSocketConnectAgain()
    }
    
    func didReceivePong(_ pongPayload: Data?, _ webSocket: WebSocketProtocol) {
        
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
            debugPrint("OKEXWebSocket connect again")
        }
        objc_sync_exit(self)
    }
    
    func webSocketDidOpen(_ webSocket: WebSocketProtocol) {
        self.reconnectionNumber = 0
        self.webSocketState = true
        for message in self.messageDict.keys {
            sendStrMessage(string: message)
        }
        debugPrint("webSocketDidOpen_okex")
        RunLoop.main.add(self.timer, forMode: .common)
    }
    
    func didReceiveMessage(_ message: Any, _ webSocket: WebSocketProtocol) {
        var unZipData: Data = Data()
        if message is String {
        }else{
            let data: Data = message as! Data
            unZipData = data.inflate() ?? Data()
            let respondMessage = String.init(data: unZipData, encoding: .utf8) ?? "无数据"
            if !respondMessage.contains("{\"event\":\"pong\"}"){
                let jsonArray = respondMessage.jsonStringToArray()
                let dict: [String: Any]     = jsonArray.first as! [String : Any]
                if  dict.keys.contains("channel"){
                    let channel: String  = dict["channel"] as! String
                    postMessage(channel, dict)
                }
            }
        }
    }
    
    lazy var timer: Timer = {
        let timerTemp = HWWeakTimer.scheduledTimer(withTimeInterval: 5, target: self, selector:#selector(sendPing), userInfo: nil, repeats: true)
        return timerTemp!
    }()
    
    @objc func sendPing(){
        do{
            try self.webSocketProtocol?.sendStrMessage(string: "{\"event\":\"ping\"}")
        }catch{
            debugPrint(error.localizedDescription)
        }
    }
}

extension OKEXWebSocket {
    
    func postMessage(_ channel: String,_ dict: Dictionary<String, Any>) {
        let channelArray     = channel.components(separatedBy: "_")
        if channelArray.count > 5 {
            let notiName              = channelArray[4]
            var dataDict  = dict["data"]
            if dataDict is Dictionary<String, Any> {
                var tempDict: Dictionary<String, Any>  = dataDict as! Dictionary<String, Any>
                tempDict["rootSymbol"]    = channelArray[3]
                if tempDict.keys.contains("contractId"){//有些返回没有contractId
                    let contractId: NSNumber  = tempDict["contractId"] as! NSNumber
                    let contractIdStr = NSString.init(format: "%@", contractId)
                    if contractIdStr.length > 8 {
                        let timeStr = contractIdStr.substring(with: NSMakeRange(4, 4))
                        tempDict["timeStr"] = timeStr
                    }
                }
                
                dataDict = tempDict
            }
            
            NotificationCenter.default.post(
                name:Notification.Name.init("\(notiName)_ok"),
                object: dataDict,
                userInfo: nil
            )
        }
    }
    
}
