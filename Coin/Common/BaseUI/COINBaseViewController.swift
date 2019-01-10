//
//  COINBaseViewController.swift
//  Coin
//
//  Created by gm on 2018/12/5.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

enum SubscribeType: Int {
    case market = 0 //行情
    case kline = 1   //k线
    case depth = 2   //深度
    case trade = 3   //交易
}
class COINBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getBitmexSunscribes(types: [SubscribeType]) -> [BitMexSubscribeType] {
        var subscribes = [BitMexSubscribeType]()
        for type in types {
            switch type {
            case .market:
                subscribes.append(.instrument)
            case .kline:
                subscribes.append(.tradeBin1m)
            case .depth:
                subscribes.append(.OrderBook10)
            case .trade:
                subscribes.append(.trade)
            }
        }
        return subscribes
    }
    
    func getOKEXSunscribes(types: [SubscribeType]) -> [OkexSubscribeType] {
        var subscribes = [OkexSubscribeType]()
        for type in types {
            switch type {
            case .market:
                subscribes.append(.ticker_ok)
            case .kline:
                subscribes.append(.kline_ok)
            case .depth:
                subscribes.append(.depth_ok)
            case .trade:
                subscribes.append(.trade_ok)
            }
        }
        return subscribes
    }
    
    func getOKEXTimeType(symbol: String) -> (OkexTimeType, String) {
        let instrumentArray: [String] = symbol.components(separatedBy: "-")
        var timeType: OkexTimeType = .thisWeek
        var rootSymbol: String?
        let toDateFmt = DateFormatter.init()
        toDateFmt.dateFormat = "yyMMdd"
        if instrumentArray.count > 1 {
            rootSymbol = instrumentArray[0]
            let time = instrumentArray[2]
            let date = toDateFmt.date(from: time)
            if date != nil {
                if date!.timeIntervalSince1970 - Date().timeIntervalSince1970 > 60 * 60 * (24 * 7 - 16) {
                    if date!.timeIntervalSince1970 - Date().timeIntervalSince1970 < 60 * 60 * (24 * 14 - 16){
                        timeType = .nextWeek
                    } else {
                        timeType = .quarter
                    }
                }
            }
        }
        return (timeType, rootSymbol?.lowercased() ?? "btc")
    }
}


