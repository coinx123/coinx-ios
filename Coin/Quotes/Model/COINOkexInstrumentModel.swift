//
//  COINOkexInstrumentModel.swift
//  Coin
//
//  Created by gm on 2018/12/7.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINInstrumentModel_OK: COINBaseModel {
    var data: [COINOKEXInstrumentModel]?
    
    func toInstrumentModel(needRootSymbol: Bool = false) -> [COINInstrumentItemModel] {
        var arr = [COINInstrumentItemModel]()
        for (_,item) in self.data?.enumerated() ?? [COINOKEXInstrumentModel]().enumerated() {
            let instrumentModel = COINInstrumentItemModel()
            item.toInstrumentModel(instrumentModel:instrumentModel)
            instrumentModel.needRootSymbol = needRootSymbol
            arr.append(instrumentModel)
        }
        return arr
    }
}

//class COINOkexInstrumentItemModel: COINBaseModel {
//
//    var instrument_id: String? //币对名称
//    var last: String? //最新成交价
//    var best_bid: String? //买一价
//    var best_ask: String? //卖一价
//    var open_24h: String? //24小时开盘价
//    var high_24h: String? //24小时最高价
//    var low_24h: String? //24小时最低价
//    var volume_24h: String? //24小时成交量，按计价货币统计
//    var timestamp: String? //系统时间戳
//    var lastPcnt: Float = 0.0 //百分比
//    var timeStr: String?
//
//}

//extension COINOkexInstrumentItemModel {
//
////    func conversionSymbolInfoModel(needRootSymbol: Bool = false) -> COINInstrumentItemModel {
////        let model = COINInstrumentItemModel()
////        let instrument_id = self.instrument_id ?? "BTC"
////        let instrumentArray: [String] = instrument_id.components(separatedBy: "-")
////        let rootSymbol: String = instrumentArray.first ?? "BTC"
////        if  instrumentArray.count > 1 {
////            let currency = instrumentArray[1]
////            model.quoteCurrency      = currency
////        }
////
////        let iconName: String  = rootSymbol.lowercased()
////        let lastPrice: String = self.last ?? ""
////        let lastChangePcnt: String =  self.lastPcnt.lastPecnStr()
////        let foreignNotional24h: String = self.volume_24h ?? ""
////        let indicativeSettlePrice: String = ""
////
////        model.priceValue         = lastPrice
////        model.lastChangePcnt     = lastChangePcnt
////        model.foreignNotional24h = foreignNotional24h
////        model.timeStr            = self.timeStr ?? ""
////        model.needRootSymbol     = needRootSymbol
////        model.lastPcnt           = self.lastPcnt
////        model.rootSymbol         = rootSymbol
////        model.symbol             = self.instrument_id ?? "BTC"
////        model.platformValue      = 1
////        model.indicativeSettlePrice = indicativeSettlePrice
////        return model
////    }
//
//    func getMiddlePrice() -> Float {
//        let low_24h: Float   = Float(self.low_24h ?? "0.0")!
//        let high_24h: Float   = Float(self.high_24h ?? "0.0")!
//        let middle = (low_24h + high_24h) * 0.5
//        return middle
//    }
//
//    func getLastPcnt() -> Float {
//        let price: Float   = Float(self.last ?? "0.0")!
//        let middle = getMiddlePrice()
//        return  (price - middle) / middle
//    }
//}
