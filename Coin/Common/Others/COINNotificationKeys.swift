//
//  COINNotificationKeys.swift
//  Coin
//
//  Created by gm on 2018/11/9.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

struct COINNotificationKeys {
    
    
    ///  改编百分比颜色通知
    static let percentageColor = Notification.Name.init("percentageColor")
    
    /// 是否隐藏通知
    static let secretNoti = Notification.Name.init("secretNoti")
    
    
    //MARK: --------------bitMex webSocket 通知-------------
    /// 收集通知通知
    static let instrument = Notification.Name.init("instrument")
    
    /// 实时交易通知
    static let trade = Notification.Name.init("trade")
    
    /// 每分钟交易数据通知
    static let tradeBin1m = Notification.Name.init("tradeBin1m")
    
    ///前10层的委托列表，用传统的完整委托列表推送
    static let orderBook10 = Notification.Name.init("orderBook10")
    
    
    
    //MARK: --------------okex webSocket 通知-------------
    
    /// okex指数行情
    static let ticker_ok = Notification.Name.init("ticker_ok")
    
    static let kline_ok = Notification.Name.init("kline_ok")
    
    static let depth_ok = Notification.Name.init("depth_ok")
    
    static let trade_ok = Notification.Name.init("trade_ok")
    
    
    //MARK: --------------huobi webSocket 通知-------------
    static let ticker_huobi = Notification.Name.init("ticker_ok")
    
    static let kline_huobi  = Notification.Name.init("kline_ok")
    
    static let depth_huobi  = Notification.Name.init("depth_ok")
    
    static let trade_huobi  = Notification.Name.init("trade_ok")
}
