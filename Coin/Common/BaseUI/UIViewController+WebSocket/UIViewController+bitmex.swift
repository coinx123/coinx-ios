//
//  UIViewController+bitmex.swift
//  Coin
//
//  Created by gm on 2018/12/14.
//  Copyright © 2018年 COIN. All rights reserved.
//

//struct BitMexSubscribeType: OptionSet {
//    let rawValue: Int
//    static let instrument  = BitMexSubscribeType(rawValue: 0x0001 << 0)
//    static let OrderBook10 = BitMexSubscribeType(rawValue: 0x0001 << 1)
//    static let trade       = BitMexSubscribeType(rawValue: 0x0001 << 2)
//    static let tradeBin1m  = BitMexSubscribeType(rawValue: 0x0001 << 3)
//}

enum BitMexSubscribeType: String {
    case instrument  = "instrument"   //行情
    case OrderBook10 = "orderBook10"  //委托数据 深度
    case trade       = "trade"        //交易
    
    case tradeBin1m  = "tradeBin1m"   //k线
}

enum BitMexSubscribeCancelState: Int {
    case could       //可取消
    case couldNot    //不可取消
}

extension UIViewController {
    
    
    /// 开启bitMex通知 注意 需要实现监听方法
    ///
    /// - Parameter subscribeTypeArray: 需要监听的通知类型
    final func addBitMex(subscribeTypeArray: [BitMexSubscribeType]){
        _ = (BitMexWebSocketFactory().getWebSocket() as! BitMexWebSocket)
        if subscribeTypeArray.contains(.instrument){
            addInstrumentNoti()
        }
        if subscribeTypeArray.contains(.OrderBook10){
            addOrderBook10Noti()
        }
        if subscribeTypeArray.contains(.trade){
            addTradeNoti()
        }
        if subscribeTypeArray.contains(.tradeBin1m){
            addTradeBin1mNoti()
        }
    }
    
    final func getBitMexWebSocket() -> BitMexWebSocket {
        return BitMexWebSocketFactory().getWebSocket() as! BitMexWebSocket
    }
    
    final func addInstrumentNoti(){
        NotificationCenter.default.addObserver(self, selector: #selector(receiveInstrumentNoti(noti:)), name: COINNotificationKeys.instrument, object: nil)
    }
    
    final func addOrderBook10Noti(){
        NotificationCenter.default.addObserver(self, selector: #selector(receiveOderBook10Noti(noti:)), name: COINNotificationKeys.orderBook10, object: nil)
    }
    
    final func addTradeNoti(){
        NotificationCenter.default.addObserver(self, selector: #selector(receiveTradeNoti(noti:)), name: COINNotificationKeys.trade, object: nil)
    }
    
    final func addTradeBin1mNoti(){
        NotificationCenter.default.addObserver(self, selector: #selector(receiveTradeBin1mNoti(noti:)), name: COINNotificationKeys.tradeBin1m, object: nil)
    }
    
    
    
    //MARK: ------------- 发送命令 -----------------
    
    /// 添加symbol的多种监听类型
    ///
    /// - Parameters:
    ///   - symbol: 合约名称
    ///   - subscribeTypeArray: 多种监听类型
    ///   - cancelState: 是否可以取消 默认是可取消 .could
    final func startSubscribeArray_bitMex(symbol: String, subscribeTypeArray: [BitMexSubscribeType], cancelState: BitMexSubscribeCancelState = .could){
        for subscribeType in subscribeTypeArray {
            startSubscribe_bitMex(symbol: symbol, subscribeType: subscribeType, cancelState: cancelState)
        }
    }
    
    
    /// 取消symbol的多种监听类型
    ///
    /// - Parameters:
    ///   - symbol: 合约名称
    ///   - subscribeTypeArray: 多种监听类型
    final func startCancelArray_bitMex(symbol: String, subscribeTypeArray: [BitMexSubscribeType]){
        for subscribeType in subscribeTypeArray {
            startCancel_bitMex(symbol: symbol, subscribeType: subscribeType)
        }
    }
    
    
    /// 添加symbol的单个监听类型
    ///
    /// - Parameters:
    ///   - symbol: 合约名称
    ///   - subscribeType: 单个监听类型
    ///   - cancelState: 是否可以取消 默认是可取消 .could
    final func startSubscribe_bitMex(symbol: String, subscribeType: BitMexSubscribeType, cancelState: BitMexSubscribeCancelState = .could){
        let dict = [
            "op": "subscribe",
            "args":"\(subscribeType.rawValue):\(symbol)"
            ] as [String : Any]
        if cancelState == .could {
            getBitMexWebSocket().sendStrMessage(string: dict.tojsonStr()!)
        }else{
            getBitMexWebSocket().sendStrMessageCannotCancel(string: dict.tojsonStr()!)
        }
        
    }
    
    
    /// 取消symbol的单个监听类型
    ///
    /// - Parameters:
    ///   - symbol: 合约名称
    ///   - subscribeType: 单个监听类型
    final func startCancel_bitMex(symbol: String, subscribeType: BitMexSubscribeType){
        let dict = [
            "op": "unsubscribe",
            "args":"\(subscribeType.rawValue):\(symbol)"
            ] as [String : Any]
        getBitMexWebSocket().sendStrMessage(string: dict.tojsonStr()!)
    }
    
    //MARK: ------------- 需要覆盖的方法 -----------------
    
    ///Book10 的回调方法 需要重新实现
    ///
    /// - Parameter noti: Book10 的通知数据
    @objc func receiveOderBook10Noti(noti: Notification){}
    
    
    /// Instrument 的回调方法 需要重新实现
    ///
    /// - Parameter noti: Instrument 的通知数据
    @objc func receiveInstrumentNoti(noti: Notification){}
    
    /// trade 的回调方法 需要重新实现
    ///
    /// - Parameter noti: trade 的通知数据
    @objc func receiveTradeNoti(noti: Notification){}
    
    /// tradeBin1m 的回调方法 需要重新实现
    ///
    /// - Parameter noti: tradeBin1m 的通知数据
    @objc func receiveTradeBin1mNoti(noti: Notification){}
    
    
    
    
//    func startSubscribeInstrument(_ symbol: String, cannotCancel: Bool = false){
//        //debugPrint("startSubscribe",symbol)
//        let subscribeStr = "{\"op\": \"subscribe\", \"args\": [\"instrument:\(symbol)\"]}"
//
//        if cannotCancel {
//            getBitMexWebSocket().sendStrMessageCannotCancel(string: subscribeStr)
//        }else{
//            getBitMexWebSocket().sendStrMessage(string: subscribeStr)
//        }
//    }
//
//
//    func startSubscribe(_ symbol:String,subscribeType: [BitMexSubscribeType] = [.instrument]){
//        if subscribeType.contains(.instrument) {
//            startSubscribeInstrument(symbol)
//        }
//        if subscribeType.contains(.OrderBook10) {
//            startSubscribeOrderBook10(symbol)
//        }
//    }
//    func startCancelSubscribe(_ symbol:String,subscribeType: [BitMexSubscribeType] = [.instrument]){
//
//        if subscribeType.contains(.instrument) {
//            startCancelInstrument(symbol)
//        }
//        if subscribeType.contains(.OrderBook10) {
//            startCancelSubscribeOrderBook10(symbol)
//        }
//    }
//
//    func startCancelInstrument(_ symbol: String){
//        //debugPrint("startCancel",symbol)
//        let unsubscribeStr = "{\"op\": \"unsubscribe\", \"args\": [\"instrument:\(symbol)\"]}"
//        getBitMexWebSocket().sendStrMessage(string: unsubscribeStr)
//    }
//
//    func startSubscribeOrderBook10(_ symbol: String){
//        //debugPrint("startSubscribe",symbol)
//        let subscribeStr = "{\"op\": \"subscribe\", \"args\": [\"orderBook10:\(symbol)\"]}"
//        getBitMexWebSocket().sendStrMessage(string: subscribeStr)
//    }
//
//    func startCancelSubscribeOrderBook10(_ symbol: String){
//        //debugPrint("startSubscribe",symbol)
//        let subscribeStr = "{\"op\": \"unsubscribe\", \"args\": [\"orderBook10:\(symbol)\"]}"
//        getBitMexWebSocket().sendStrMessage(string: subscribeStr)
//    }
//
//    func startTradeSubscribe(_ symbol: String){
//        //debugPrint("startSubscribe",symbol)
//        let subscribeStr = "{\"op\": \"subscribe\", \"args\": [\"trade:\(symbol)\"]}"
//        getBitMexWebSocket().sendStrMessage(string: subscribeStr)
//    }
//    func startTradeBin1mSubscribe(_ symbol: String){
//        //debugPrint("startSubscribe",symbol)
//        let subscribeStr = "{\"op\": \"subscribe\", \"args\": [\"tradeBin1m:\(symbol)\"]}"
//        getBitMexWebSocket().sendStrMessage(string: subscribeStr)
//    }
//    func startCancelTradeBin1mSubscribe(_ symbol: String){
//        //debugPrint("startSubscribe",symbol)
//        let subscribeStr = "{\"op\": \"unsubscribe\", \"args\": [\"trade:\(symbol)\"]}"
//        getBitMexWebSocket().sendStrMessage(string: subscribeStr)
//    }
//    func startCancelTradeSubscribe(_ symbol: String){
//        //debugPrint("startSubscribe",symbol)
//        let subscribeStr = "{\"op\": \"unsubscribe\", \"args\": [\"instrument:\(symbol)\"]}"
//        getBitMexWebSocket().sendStrMessage(string: subscribeStr)
//    }
    
}

