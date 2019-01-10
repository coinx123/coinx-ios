//
//  COINInstrumentModel.swift
//  Coin
//
//  Created by dev6 on 2018/12/11.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINInstrumentModel: COINBaseModel {
    var data: [COINInstrumentItemModel]?
}

class COINInstrumentItemModel: COINBaseModel {
    var symbol: String?
    var rootSymbol: String?
    var underlying: String?
    var priceValue: Float?
    var indicativeSettlePrice:  Float?
    var lastPcnt: Float?
    var foreignNotional24h: String?
    var expiry: String? //time formart utc
    var quoteCurrency: String?
    var prevPrice24h: Float?
    var positionCurrency: String?
    var highPrice: Float?
    var lowPrice: Float?
    var totalVolume: Float?
    var turnover24h: Float?
    var tickSize: Float? //下单价格精度
    var timeStr: String = ""
    var needRootSymbol: Bool = false
    var platformValue: Int   = 0 {
        didSet{
            self.platformType = platformValue == 0 ? .bitmex : .okex
        }
    }
    
    func isBitMexExpiry() -> Bool {
        if (self.expiry != nil) {
            let expiryTime: TimeInterval = self.expiry?.utcConvertedToDate().timeIntervalSince1970 ?? TimeInterval(CGFloat.greatestFiniteMagnitude)
            if Date().timeIntervalSince1970 - expiryTime >= 0{
                return true
            }
        }
        
        return false
    }
    
    func isOkexExpiry() -> Bool {
        let timeStr = self.symbol?.parsingInstrument_Id().timeStr
        if (timeStr != nil) {
            if timeStr!.okexTime().hasPrefix("过期"){
                return true
            }
        }
        
        return false
    }
    
    func getAttrTitle(platform: Platform) -> NSMutableAttributedString {
        if platform == .bitmex {
            let type = self.symbol?.bitmexTimeType()
            return type!.1
        } else {
            let instrument_id = self.symbol ?? "BTC"
            let instrumentArray: [String] = instrument_id.components(separatedBy: "-")
            if instrumentArray.count > 1 {
                let time = instrumentArray[2]
                let timeType = time.okexTime()
                var timeStrTemp: NSString = instrumentArray.last! as NSString
                timeStrTemp = timeStrTemp.substring(from: 2) as NSString
                let attr = NSMutableAttributedString.init(string: "\(instrumentArray[0]) \(timeType)-\(timeStrTemp)")
                attr.addAttributes([NSAttributedString.Key.font: fontBold16], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.font: font12], range: NSMakeRange(3, attr.length - 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleBlackColor], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleGrayColor], range: NSMakeRange(3, attr.length - 3))
                return attr
            }
            return NSMutableAttributedString()
        }
    }
}

class COINBitmexInstrumentModel: COINBaseModel {
    var data: [COINBitmexInstrumentItemModel]?
    
    func toInstrumentModel() -> COINInstrumentModel {
        let instrumentModel = COINInstrumentModel()
        var arr = [COINInstrumentItemModel]()
        for (_,item) in self.data?.enumerated() ?? [COINBitmexInstrumentItemModel]().enumerated() {
            let positionItemModel = COINInstrumentItemModel()
            positionItemModel.symbol = item.symbol
            positionItemModel.rootSymbol = item.rootSymbol
            positionItemModel.underlying = item.underlying
            positionItemModel.priceValue = item.lastPrice
            positionItemModel.indicativeSettlePrice = item.indicativeSettlePrice
            positionItemModel.lastPcnt = item.lastChangePcnt
            positionItemModel.foreignNotional24h = item.foreignNotional24h
            positionItemModel.expiry = item.expiry
            positionItemModel.quoteCurrency = item.quoteCurrency
            positionItemModel.prevPrice24h = item.prevPrice24h
            positionItemModel.positionCurrency = item.positionCurrency
            positionItemModel.highPrice = item.highPrice
            positionItemModel.lowPrice = item.lowPrice
            positionItemModel.totalVolume = item.totalVolume
            positionItemModel.turnover24h = item.turnover24h
            positionItemModel.tickSize = item.tickSize
            
            positionItemModel.timeStr = (item.expiry != nil) ? item.turnCustomTimeStr() : "永续-\(item.symbol ?? "xbt")"
            arr.append(positionItemModel)
        }
        instrumentModel.data = arr
        return instrumentModel
    }
}

class COINBitmexInstrumentItemModel: COINBaseModel {
    var symbol: String?
    var rootSymbol: String?
    var state: String?
    var typ: String?
    var listing: String? //time formart utc
    var front: String? //time formart utc
    var expiry: String? //time formart utc
    var settl: String? //time formart utc
    var relistInterval: String? //time formart utc
    var inverseLeg: String? //time formart utc
    var sellLeg: String?
    var buyLeg: String?
    var optionStrikePcnt: Float?
    var optionStrikeRound: Float?
    var optionStrikePrice: Float?
    var optionMultiplier: Float?
    var positionCurrency: String?
    var underlying: String?
    var quoteCurrency: String?
    var underlyingSymbol: String?
    var reference: String?
    var referenceSymbol: String?
    var calcInterval: String?//time formart utc
    var publishInterval: String?//time formart utc
    var publishTime: String?//time formart utc
    var maxOrderQty: Float?
    var maxPrice: Float?
    var lotSize: Float?
    var tickSize: Float? //下单价格精度
    var multiplier: Float?
    var settlCurrency: String?
    var underlyingToPositionMultiplier: Float?
    var underlyingToSettleMultiplier: Float?
    var quoteToSettleMultiplier: Float?
    var isQuanto: Bool?
    var isInverse: Bool?
    var initMargin: Float?
    var maintMargin: Float?
    var riskLimit: Float?
    var riskStep: Float?
    var limit: Float?
    var capped: Bool?
    var taxed: Bool?
    var deleverage: Bool?
    var makerFee: Float?
    var takerFee: Float?
    var settlementFee: Float?
    var insuranceFee: Float?
    var fundingBaseSymbol: String?
    var fundingQuoteSymbol: String?
    var fundingPremiumSymbol: String?
    var fundingTimestamp: String? //time formart utc
    var fundingInterval: String? //time formart utc
    var fundingRate: Float?
    var indicativeFundingRate: Float?
    var rebalanceTimestamp: String? //time formart utc
    var rebalanceInterval: String? //time formart utc
    var openingTimestamp: String? //time formart utc
    var closingTimestamp: String? //time formart utc
    var sessionInterval: String? //time formart utc
    var prevClosePrice: Float?
    var limitDownPrice: Float?
    var limitUpPrice: Float?
    var bankruptLimitDownPrice: Float?
    var bankruptLimitUpPrice: Float?
    var prevTotalVolume: Float?
    var totalVolume: Float?
    var volume: Float?
    var volume24h: Float?
    var prevTotalTurnover: Float?
    var totalTurnover: Float?
    var turnover: Float?
    var turnover24h: Float?
    var homeNotional24h: Float?
    var foreignNotional24h: String?
    var prevPrice24h: Float?
    var vwap: Float?
    var highPrice: Float?
    var lowPrice: Float?
    var lastPrice: Float?
    var lastPriceProtected: Float?
    var lastTickDirection: String?
    var lastChangePcnt: Float?
    var bidPrice: Float?
    var midPrice: Float?
    var askPrice: Float?
    var impactBidPrice: Float?
    var impactMidPrice: Float?
    var impactAskPrice: Float?
    var hasLiquidity: Bool?
    var openInterest: Float?
    var openValue: Float?
    var fairMethod: String?
    var fairBasisRate: Float?
    var fairBasis: Float?
    var fairPrice: Float?
    var markMethod: String?
    var markPrice:  Float?
    var indicativeTaxRate:  Float?
    var indicativeSettlePrice:  Float?
    var optionUnderlyingPrice:  Float?
    var settledPrice:  Float?
    var timestamp: String? //time formart utc
    
    /// 转换成 ui需求的时间显示
    ///
    /// - Returns: 自定义格式的时间字符串
    func turnCustomTimeStr() -> String{
        
        let expiryDate = self.expiry?.utcConvertedToDate()
        var timeLabelTitle: String = ""
        let yyyyMMdd   = self.expiry?.components(separatedBy: "T").first
        let yyyyMMdds  = yyyyMMdd?.components(separatedBy: "-")
        let mmddStr       = "-\(yyyyMMdds![1])\(yyyyMMdds![2])"
        //判断是不是周
        if (self.symbol?.lowercased().contains("7d"))!{
            //判断是不是本周
            if Calendar.current.isDateInWeek("UTC", Date(), expiryDate!){
                timeLabelTitle.append("当周")
            }else{
                timeLabelTitle.append(contentsOf: "次周")
            }
        }else{
            //判断是不是本季度
            if Calendar.current.isDateInQuarter("UTC", Date(), expiryDate!){
                timeLabelTitle.append(contentsOf: "当季")
            }else{
                timeLabelTitle.append(contentsOf: "次季")
            }
        }
        return timeLabelTitle + mmddStr
    }
}


class COINOKEXInstrumentModel: COINBaseModel {
    var last: String? //最新成交价
    var best_ask: String? //卖一价
    var best_bid: String? //买一价
    var high_24h: String? //24小时最高价
    var low_24h: String? //24小时最低价
    var volume_24h: String? //24小时成交量，按张数统计
    var timestamp: String? //系统时间戳
    
    var limitHigh: String? //最高买入限制价格
    var limitLow: String? //最低卖出限制价格
    var hold_amount: String? //合约价值
    var unitAmount: String? //当前持仓量
    
    var instrument_id: String?
    var rootSymbol: String?
    
    func getTimeStr() ->String {
        let timeStr: String = self.instrument_id!.parsingInstrument_Id().timeStr
        let timeOCStr: NSString = timeStr as NSString
        if timeOCStr.length < 2 {
            return "永续-\(self.rootSymbol!)"
        }else{
            return timeStr.okexTime() + "-" + timeOCStr.substring(from: 2)
        }
    }
    
    func toInstrumentModel(instrumentModel: COINInstrumentItemModel) {
        instrumentModel.platformType = .okex
        instrumentModel.platformValue = 1
        if self.last != nil {
            instrumentModel.priceValue = Float(self.last!)
        }
        
        if self.volume_24h != nil {
            instrumentModel.turnover24h = Float(self.volume_24h!)
            instrumentModel.foreignNotional24h = self.volume_24h
        }
        
        if self.high_24h != nil {
            instrumentModel.highPrice = Float(self.high_24h!)
        }
        
        if self.low_24h != nil {
            instrumentModel.lowPrice = Float(self.low_24h!)
        }
        
        if (self.instrument_id != nil) {
            instrumentModel.symbol     = self.instrument_id
        }
        
        if self.last != nil && self.high_24h != nil && self.low_24h != nil {
            let priceValue: Float  = Float(self.last!) ?? 0
            let high: Float        = Float(self.high_24h!) ?? 0
            let low: Float         = Float(self.low_24h!) ?? 0
            let middle             = (high + low) * 0.5
            let lastPcnt           = (priceValue - middle) / middle
            instrumentModel.prevPrice24h = middle
            instrumentModel.lastPcnt = lastPcnt
        }
        
        if instrumentModel.symbol != nil && instrumentModel.rootSymbol == nil {
            let instrument_id = instrumentModel.symbol ?? "BTC"
            let instrumentArray: [String] = instrument_id.components(separatedBy: "-")
            if instrumentArray.count > 1 {
                instrumentModel.quoteCurrency = instrumentArray[1]
                instrumentModel.positionCurrency = instrumentArray[1]
                instrumentModel.underlying = instrumentArray[0]
                instrumentModel.rootSymbol = instrumentArray[0]
                instrumentModel.timeStr    = self.getTimeStr()
            }
        }
        
    }
}
