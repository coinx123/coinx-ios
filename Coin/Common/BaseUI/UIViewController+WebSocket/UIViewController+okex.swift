//
//  UIViewController+okex.swift
//  Coin
//
//  Created by gm on 2018/12/14.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

//MARK: ------- okex webSocket ---------
enum OkexSubscribeType: String {
    case ticker_ok = "ticker" //行情
    case kline_ok = "kline"   //k线
    case depth_ok = "depth"   //深度
    case trade_ok = "trade"   //交易
}
enum OkexTimeType: String {
    case thisWeek = "this_week" //本周
    case nextWeek = "next_week" //次周
    case quarter  = "quarter"   //季度
}
enum OkexParameterType: String {
    case min1    = "1min"
    case min2    = "3min"
    case min5    = "5min"
    case min15   = "15min"
    case min30   = "30min"
    case hour1   = "1hour"
    case hour2   = "2hour"
    case hour4   = "4hour"
    case hour6   = "6hour"
    case hour12  = "12hour"
    case day      = "day"
    case day3     = "3day"
    case week     = "week"
    case zero     = "zero" //默认为zero 不发送命令
    case depth_5     = "5"
}

extension UIViewController {
    
    /// 开启okex通知 注意 需要实现监听方法
    ///
    /// - Parameter subscribeTypeArray: 需要监听的通知类型
    final func addOkex(subscribeTypeArray: [OkexSubscribeType]){
        _ = (OKEXWebSocketFactory().getWebSocket() as! OKEXWebSocket)
        if subscribeTypeArray.contains(.ticker_ok){
            addTickerNoti_ok()
        }
        if subscribeTypeArray.contains(.kline_ok){
            addKlineNoti_ok()
        }
        if subscribeTypeArray.contains(.depth_ok){
            addDepthNoti_ok()
        }
        if subscribeTypeArray.contains(.trade_ok){
            addTradeNoti_ok()
        }
    }
    final func getOkexWebSocket() -> OKEXWebSocket {
        return OKEXWebSocketFactory().getWebSocket() as! OKEXWebSocket
    }
    final func addTickerNoti_ok(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveTickerNoti_ok(noti:)),
            name: COINNotificationKeys.ticker_ok,
            object: nil
        )
    }
    final func addKlineNoti_ok(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveKlineNoti_ok(noti:)),
            name: COINNotificationKeys.kline_ok,
            object: nil
        )
    }
    final func addDepthNoti_ok(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveDepthNoti_ok(noti:)),
            name: COINNotificationKeys.depth_ok,
            object: nil
        )
    }
    final func addTradeNoti_ok(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveTradeNoti_ok(noti:)),
            name: COINNotificationKeys.trade_ok,
            object: nil
        )
    }
    
    //MARK: ------------- 发送命令 -----------------
    
    /// 监听ok多个通知
    ///
    /// - Parameters:
    ///   - instrument_Id: 合约名称
    ///   - subscribeTypeArray: 多个监听类型
    ///   - klineTimesType: 可选项 k线响应频率
    final func startSubscribeArray_ok( instrument_Id: String, subscribeTypeArray: [OkexSubscribeType], parameterType: OkexParameterType = .zero){
        for subscribeType in subscribeTypeArray {
            startSubscribe_ok(instrument_Id: instrument_Id, subscribeType: subscribeType, parameterType: parameterType)
        }
    }
    
    /// 移除ok多个通知
    ///
    /// - Parameters:
    ///   - instrument_Id: 合约名称
    ///   - subscribeTypeArray: 多个监听类型
    ///   - klineTimesType: 可选项 k线响应频率
    final func startCancelArray_ok( instrument_Id: String, subscribeTypeArray: [OkexSubscribeType], parameterType: OkexParameterType = .zero){
        for subscribeType in subscribeTypeArray {
            startCancel_ok(instrument_Id: instrument_Id, subscribeType: subscribeType, parameterType: parameterType)
        }
    }
    
    /// 监听ok通知
    ///
    /// - Parameters:
    ///   - instrument_Id: 合约名称
    ///   - subscribeType: 监听类型
    ///   - klineTimesType: 可选项 k线响应频率
    final func startSubscribe_ok( instrument_Id: String, subscribeType: OkexSubscribeType, parameterType: OkexParameterType = .zero){
        let instrumentTuples = instrument_Id.parsingInstrument_Id()
        if instrument_Id.count < 1 {
            return
        }
        
        let rootSymbol  = instrumentTuples.rootSymol
        var subFutureusd = "ok_sub_futureusd"
        let timeType    = toOkexTimeType(timeTypeStr: instrumentTuples.timeStr.okexTime())
        subFutureusd.append("_\(rootSymbol.lowercased())")
        subFutureusd.append("_\(subscribeType.rawValue)")
        subFutureusd.append("_\(timeType.rawValue)")
        if parameterType != .zero {
            subFutureusd.append("_\(parameterType.rawValue)")
        }
        
        let dict: Dictionary = [
            "event":"addChannel",
            "channel": subFutureusd
        ]
        
        getOkexWebSocket().sendStrMessage(string: dict.tojsonStr()!)
    }
    
    /// 移除ok通知
    ///
    /// - Parameters:
    ///   - instrument_Id: 合约名称
    ///   - subscribeType: 监听类型
    ///   - klineTimesType: 可选项 k线响应频率
    final func startCancel_ok( instrument_Id: String, subscribeType: OkexSubscribeType, parameterType: OkexParameterType = .zero){
        let instrumentTuples = instrument_Id.parsingInstrument_Id()
        if instrument_Id.count < 1 {
            return
        }
        let rootSymbol  = instrumentTuples.rootSymol
        let timeType    = toOkexTimeType(timeTypeStr: instrumentTuples.timeStr.okexTime())
        var subFutureusd = "ok_sub_futureusd"
        subFutureusd.append("_\(rootSymbol.lowercased())")
        subFutureusd.append("_\(subscribeType.rawValue)")
        subFutureusd.append("_\(timeType.rawValue)")
        if parameterType != .zero {
            subFutureusd.append("_\(parameterType.rawValue)")
        }
        //ok_sub_futureusd_btc_ticker_this_week
        let dict: Dictionary = [
            "event":"removeChannel",
            "channel": subFutureusd
        ]
        getOkexWebSocket().sendStrMessage(string: dict.tojsonStr()!)
    }
    
    func toOkexTimeType(timeTypeStr: String) ->OkexTimeType{
        var timeType: OkexTimeType = .thisWeek
        if timeTypeStr == "次周"{
            timeType = .nextWeek
        }
        
        if timeTypeStr == "季度"{
            timeType = .quarter
        }
        
        return timeType
    }
    //MARK: ------------- 需要覆盖的方法 -----------------
    
    /// 接受到行情数据回调方法
    ///
    /// - Parameter noti: 行情数据
    @objc func receiveTickerNoti_ok(noti: Notification){}
    
    /// 接受到k线数据变化回调方法
    ///
    /// - Parameter noti: k线数据
    @objc func receiveKlineNoti_ok(noti: Notification){}
    
    /// 接受市场深度数据变化回调方法
    ///
    /// - Parameter noti: 深度数据
    @objc func receiveDepthNoti_ok(noti: Notification){}
    
    /// 接受交易数据变化回调方法
    ///
    /// - Parameter noti: 交易数据
    @objc func receiveTradeNoti_ok(noti: Notification){}
}
