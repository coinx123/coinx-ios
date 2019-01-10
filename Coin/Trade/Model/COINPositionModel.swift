//
//  PositionModel.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/15.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

class COINPositionModel: COINBaseModel {
    var _positionItemModelArray: [COINPositionItemModel]?
    // 只现实xbt 和 usd 两种货币
    var data: [COINPositionItemModel]?
}

class COINPositionItemModel: COINBaseModel {
    var symbol: String? //币种名称
    var currency: String? //法币名称
    var underlying: String?
    var avgCostPrice: String?  //开仓价格(均价)
    var realisedPnl: String? //已实现盈亏
    var unrealisedPnlPcnt: String? //未实现盈亏
    var unrealisedPnl: String?
    var crossMargin: String? //交叉保证金
    var maintMargin: String? //仓位保证金
    var initMargin: String? //委托保证金 //
    var posMaint: String? //
    var posInit: String? //
    var leverage: String? //杠杆
    var foreignNotional: String? //持仓价值
    var currentQty: String? //持仓量
    var quoteCurrency: String?
    var liquidationPrice: String? //强平价格
    var openOrderSellQty: String?
    var openOrderBuyQty: String?
    var lastPrice: String?
    
    var titleAttr: NSMutableAttributedString?
    var type: String?
    
    lazy var rootSymbolArray = ["xbt","btc","eth","ada","bch","eos","ltc","trx"]
}

extension COINPositionItemModel {
    
    func conversionSettingInfoModel()-> COINSettingInfoModel {
        let settingInfoModel = COINSettingInfoModel()
        let imageName         =  self.rootSymbolArray.filter({(self.symbol?.lowercased().hasPrefix($0))!})
        settingInfoModel.platformType  = .bitmex
        settingInfoModel.imageName     = imageName.first ?? ""
        settingInfoModel.symbol        = settingInfoModel.imageName.uppercased()
        settingInfoModel.maintMargin   = Float(self.maintMargin ?? "0")!
        settingInfoModel.initMargin    = Float(self.initMargin ?? "0")!
        settingInfoModel.realisedPnl   = Float(self.realisedPnl ?? "0.0")!
        settingInfoModel.unrealisedPnl = Float(self.unrealisedPnl ?? "0")!
        return settingInfoModel
    }
}



class COINBitmexPositionModel: COINBaseModel {
    var data: [COINBitmexPositionItemModel]?
    
    func toPositionModel() -> COINPositionModel {
        let positionModel = COINPositionModel()
        var arr = [COINPositionItemModel]()
        for (_,item) in self.data?.enumerated() ?? [COINBitmexPositionItemModel]().enumerated() {
            let positionItemModel = COINPositionItemModel()
            positionItemModel.symbol = item.symbol
            positionItemModel.currency = item.currency
            positionItemModel.underlying = item.underlying
            positionItemModel.avgCostPrice = item.avgCostPrice
            positionItemModel.realisedPnl = item.realisedPnl
            positionItemModel.unrealisedPnlPcnt = item.unrealisedPnlPcnt
            positionItemModel.unrealisedPnl = item.unrealisedPnl
            positionItemModel.crossMargin = item.crossMargin
            positionItemModel.maintMargin = item.maintMargin
            positionItemModel.initMargin = item.initMargin
            positionItemModel.posInit = item.posInit
            positionItemModel.posMaint = item.posMaint
            positionItemModel.leverage = item.leverage
            positionItemModel.foreignNotional = item.foreignNotional
            positionItemModel.currentQty = item.currentQty
            positionItemModel.quoteCurrency = item.quoteCurrency
            positionItemModel.liquidationPrice = item.liquidationPrice
            positionItemModel.openOrderSellQty = item.openOrderSellQty
            positionItemModel.openOrderBuyQty = item.openOrderBuyQty
            positionItemModel.lastPrice = item.lastPrice
            self.getAttrTitle(positionModel: positionItemModel)
            arr.append(positionItemModel)
        }
        positionModel.data = arr
        return positionModel
    }
    
    func getAttrTitle(positionModel: COINPositionItemModel) {
        let type = positionModel.symbol?.bitmexTimeType()
        positionModel.type = type?.0
        positionModel.titleAttr = type?.1
    }
}

class COINBitmexPositionItemModel: COINBaseModel {
    var symbol: String? //币种名称
    var account: String?
    var currency: String? //法币名称
    var underlying: String?
    var quoteCurrency: String?
    var commission: String? //佣金
    var initMarginReq: Float?
    var maintMarginReq: String?
    var riskLimit: String?
    var leverage: String? //杠杆
    var crossMargin: String? //交叉保证金
    var deleveragePercentile: String?
    var rebalancedPnl: String?
    var prevRealisedPnl: String?
    var currentQty: String? //持仓量
    var currentCost: String?
    var currentComm: String?
    var realisedCost: String?
    var unrealisedCost: String?
    var grossOpenCost: String?
    var grossOpenPremium: String?
    var markPrice: String?
    var markValue: String?
    var homeNotional: String?
    var foreignNotional: String?
    var realisedPnl: String? //已实现盈亏
    var unrealisedPnlPcnt: String? //未实现盈亏
    var unrealisedGrossPnl: String?
    var unrealisedPnl: String?
    var liquidationPrice: String? //强平价格
    var bankruptPrice: String? //
    var avgCostPrice: String?  //开仓价格(均价)
    var avgEntryPrice: String?
    var breakEvenPrice: String?
    var currentTimestamp: String?
    var execBuyCost: String?
    var execBuyQty: String?
    var execComm: String?
    var execCost: String?
    var execQty: String?
    var execSellCost: String?
    var execSellQty: String?
    var grossExecCost: String?
    var indicativeTax: String?
    var indicativeTaxRate: String?
    var initMargin: String? //委托保证金 //
    var isOpen: String?
    var lastPrice: String?
    var lastValue: String?
    var longBankrupt: String?
    var maintMargin: String? //仓位保证金
    var openOrderBuyCost: String?
    var openOrderBuyPremium: String?
    var openOrderBuyQty: String?
    var openOrderSellCost: String?
    var openOrderSellPremium: String?
    var openOrderSellQty: String?
    var openingComm: String?
    var openingCost: String?
    var openingQty: String?
    var openingTimestamp: String?
    var posAllowance: String?
    var posComm: String?
    var posCost: String?
    var posCost2: String?
    var posCross: String?
    var posInit: String?
    var posLoss: String?
    var posMaint: String?
    var posMargin: String?
    var posState: String?
    var prevClosePrice: String?
    var prevUnrealisedPnl: String?
    var realisedGrossPnl: String?
    var realisedTax: String?
    var riskValue: String?
    var sessionMargin: String?
    var shortBankrupt: String?
    var simpleCost: String?
    var simplePnl: String?
    var simplePnlPcnt: String?
    var simpleQty: String?
    var simpleValue: String?
    var targetExcessMargin: String?
    var taxBase: String?
    var taxableMargin: String?
    var timestamp: String?
    var unrealisedRoePcnt: String?
    var unrealisedTax: String?
    var varMargin: String?
}

class COINOKEXPositionModel: COINBaseModel {
    var holding: [[COINOKEXPositionItemModel]]?
    var result: Bool?
    
    func toPositionModel() -> COINPositionModel {
        let positionModel = COINPositionModel()
        var arr = [COINPositionItemModel]()
        for datas in self.holding ?? [[COINOKEXPositionItemModel]]() {
            for item in datas {
                let positionItemModel = COINPositionItemModel()
                positionItemModel.symbol = item.instrument_id
                
                let instrument_id = item.instrument_id ?? "BTC"
                let instrumentArray: [String] = instrument_id.components(separatedBy: "-")
                if instrumentArray.count > 1 {
                    positionItemModel.currency = instrumentArray[1]
                    positionItemModel.quoteCurrency = instrumentArray[1]
                    positionItemModel.underlying = instrumentArray[0]
                    let time = instrumentArray[2]
                    let timeType = time.okexTime()
                    var timeStrTemp: NSString = instrumentArray.last! as NSString
                    timeStrTemp = timeStrTemp.substring(from: 2) as NSString
                    let attr = NSMutableAttributedString.init(string: "\(positionItemModel.underlying!) \(timeType)-\(timeStrTemp)")
                    attr.addAttributes([NSAttributedString.Key.font: fontBold16], range: NSMakeRange(0, 3))
                    attr.addAttributes([NSAttributedString.Key.font: font12], range: NSMakeRange(3, attr.length - 3))
                    attr.addAttributes([NSAttributedString.Key.foregroundColor: titleBlackColor], range: NSMakeRange(0, 3))
                    attr.addAttributes([NSAttributedString.Key.foregroundColor: titleGrayColor], range: NSMakeRange(3, attr.length - 3))
                    positionItemModel.titleAttr = attr
                }
                if item.long_qty ?? 0 > 0 {
                    positionItemModel.currentQty = String(format: "%d", item.long_qty ?? 0)
                    positionItemModel.avgCostPrice = item.long_avg_cost
                    positionItemModel.maintMargin = String(format: "%d",Int((Float(item.long_margin ?? "0.0") ?? 0.0) * 100000000.0))
                    positionItemModel.lastPrice = item.long_settlement_price
                    positionItemModel.realisedPnl = item.realized_pnl
                    positionItemModel.unrealisedPnl = item.realized_pnl
                    if item.margin_mode == "crossed" {
                        positionItemModel.crossMargin = String(true)
                        positionItemModel.leverage = item.leverage
                        positionItemModel.liquidationPrice = item.liquidation_price
                        positionItemModel.unrealisedPnlPcnt = String(format: "%f", (Float(item.realized_pnl ?? "0") ?? 0.0)/(Float(item.long_avg_cost ?? "1") ?? 1.0))
                    } else {
                        positionItemModel.crossMargin = String(false)
                        positionItemModel.leverage = item.long_leverage
                        positionItemModel.liquidationPrice = item.long_liqui_price
                        positionItemModel.unrealisedPnlPcnt = String(format: "%f", (item.long_pnl_ratio ?? 0.0)/(Float(item.long_leverage ?? "10") ?? 10.0))
                    }
                    arr.insert(positionItemModel, at: 0)
                }
                if item.short_qty ?? 0 > 0 {
                    let short_positionItemModel = COINPositionItemModel()
                    short_positionItemModel.symbol = positionItemModel.symbol
                    short_positionItemModel.currency = positionItemModel.currency
                    short_positionItemModel.quoteCurrency = positionItemModel.quoteCurrency
                    short_positionItemModel.underlying = positionItemModel.underlying
                    short_positionItemModel.titleAttr = positionItemModel.titleAttr
                    short_positionItemModel.currentQty = String(format: "%d", -(item.short_qty ?? 0))
                    short_positionItemModel.avgCostPrice = item.short_avg_cost
                    short_positionItemModel.maintMargin = String(format: "%d",Int((Float(item.short_margin ?? "0.0") ?? 0.0) * 100000000.0))
                    short_positionItemModel.lastPrice = item.short_settlement_price
                    short_positionItemModel.realisedPnl = item.realized_pnl
                    short_positionItemModel.unrealisedPnl = item.realized_pnl
                    if item.margin_mode == "crossed" {
                        short_positionItemModel.crossMargin = String(true)
                        short_positionItemModel.leverage = item.leverage
                        short_positionItemModel.liquidationPrice = item.liquidation_price
                        short_positionItemModel.unrealisedPnlPcnt = String(format: "%f", (Float(item.realized_pnl ?? "0") ?? 0.0)/(Float(item.short_avg_cost ?? "1") ?? 1.0))
                    } else {
                        short_positionItemModel.crossMargin = String(false)
                        short_positionItemModel.leverage = item.short_leverage
                        short_positionItemModel.liquidationPrice = item.short_liqui_price
                        short_positionItemModel.unrealisedPnlPcnt = String(format: "%f", (item.short_pnl_ratio ?? 0.0)/(Float(item.short_leverage ?? "10") ?? 10.0))
                    }
                    arr.insert(short_positionItemModel, at: 0)
                }
            }
        }
        positionModel.data = arr
        return positionModel
    }
}

class COINOKEXPositionSingleModel: COINBaseModel {
    var holding: [COINOKEXPositionItemModel]?
    var result: Bool?
    var margin_mode: String? //账户类型：全仓 crossed  逐仓 fixed
    
    func toPositionModel() -> COINPositionModel {
        let positionModel = COINPositionModel()
        var arr = [COINPositionItemModel]()
        for item in self.holding ?? [COINOKEXPositionItemModel]() {
            let positionItemModel = COINPositionItemModel()
            positionItemModel.symbol = item.instrument_id
            
            let instrument_id = item.instrument_id ?? "BTC"
            let instrumentArray: [String] = instrument_id.components(separatedBy: "-")
            if instrumentArray.count > 1 {
                positionItemModel.currency = instrumentArray[1]
                positionItemModel.quoteCurrency = instrumentArray[1]
                positionItemModel.underlying = instrumentArray[0]
                let time = instrumentArray[2]
                let timeType = time.okexTime()
                var timeStrTemp: NSString = instrumentArray.last! as NSString
                timeStrTemp = timeStrTemp.substring(from: 2) as NSString
                let attr = NSMutableAttributedString.init(string: "\(positionItemModel.underlying!) \(timeType)-\(timeStrTemp)")
                attr.addAttributes([NSAttributedString.Key.font: fontBold16], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.font: font12], range: NSMakeRange(3, attr.length - 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleBlackColor], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleGrayColor], range: NSMakeRange(3, attr.length - 3))
                positionItemModel.titleAttr = attr
            }
            if item.long_qty ?? 0 > 0 {
                positionItemModel.currentQty = String(format: "%d", item.long_qty ?? 0)
                positionItemModel.avgCostPrice = item.long_avg_cost
                positionItemModel.maintMargin = String(format: "%d",Int((Float(item.long_margin ?? "0.0") ?? 0.0) * 100000000.0))
                positionItemModel.lastPrice = item.long_settlement_price
                positionItemModel.realisedPnl = item.realized_pnl
                positionItemModel.unrealisedPnl = item.realized_pnl
                if item.margin_mode == "crossed" {
                    positionItemModel.crossMargin = String(true)
                    positionItemModel.leverage = item.leverage
                    positionItemModel.liquidationPrice = item.liquidation_price
                    positionItemModel.unrealisedPnlPcnt = String(format: "%f", (Float(item.realized_pnl ?? "0") ?? 0.0)/(Float(item.long_avg_cost ?? "1") ?? 1.0))
                } else {
                    positionItemModel.crossMargin = String(false)
                    positionItemModel.leverage = item.long_leverage
                    positionItemModel.liquidationPrice = item.long_liqui_price
                    positionItemModel.unrealisedPnlPcnt = String(format: "%f", (item.long_pnl_ratio ?? 0.0)/(Float(item.long_leverage ?? "10") ?? 10.0))
                }
                arr.insert(positionItemModel, at: 0)
            }
            if item.short_qty ?? 0 > 0 {
                let short_positionItemModel = COINPositionItemModel()
                short_positionItemModel.symbol = positionItemModel.symbol
                short_positionItemModel.currency = positionItemModel.currency
                short_positionItemModel.quoteCurrency = positionItemModel.quoteCurrency
                short_positionItemModel.underlying = positionItemModel.underlying
                short_positionItemModel.titleAttr = positionItemModel.titleAttr
                short_positionItemModel.currentQty = String(format: "%d", -(item.short_qty ?? 0))
                short_positionItemModel.avgCostPrice = item.short_avg_cost
                short_positionItemModel.maintMargin = String(format: "%d",Int((Float(item.short_margin ?? "0.0") ?? 0.0) * 100000000.0))
                short_positionItemModel.lastPrice = item.short_settlement_price
                short_positionItemModel.realisedPnl = item.realized_pnl
                short_positionItemModel.unrealisedPnl = item.realized_pnl
                if item.margin_mode == "crossed" {
                    short_positionItemModel.crossMargin = String(true)
                    short_positionItemModel.leverage = item.leverage
                    short_positionItemModel.liquidationPrice = item.liquidation_price
                    short_positionItemModel.unrealisedPnlPcnt = String(format: "%f", (Float(item.realized_pnl ?? "0") ?? 0.0)/(Float(item.short_avg_cost ?? "1") ?? 1.0))
                } else {
                    short_positionItemModel.crossMargin = String(false)
                    short_positionItemModel.leverage = item.short_leverage
                    short_positionItemModel.liquidationPrice = item.short_liqui_price
                    short_positionItemModel.unrealisedPnlPcnt = String(format: "%f", (item.short_pnl_ratio ?? 0.0)/(Float(item.short_leverage ?? "10") ?? 10.0))
                }
                arr.insert(short_positionItemModel, at: 0)
            }
        }
        positionModel.data = arr
        return positionModel
    }
}

class COINOKEXPositionItemModel: COINBaseModel {
    var margin_mode: String? //账户类型：全仓 crossed  逐仓 fixed
    var instrument_id: String? //合约ID，如BTC-USD-180213
    var created_at: String? //创建时间
    var updated_at: String? //最近一次加减仓的更新时间
    var long_qty: Int? //多仓数量
    var long_avail_qty: Int? //多仓可平仓数量
    var long_avg_cost: String? //开仓平均价
    var long_settlement_price: String? //多仓结算基准价
    var realized_pnl: String? //已实现盈余
    var short_qty: Int? //空仓数量
    var short_avail_qty: Int? //空仓可平仓数量
    var short_avg_cost: String? //开仓平均价
    var short_settlement_price: String? //空仓结算基准价
    //全仓参数
    var liquidation_price: String? //预估爆仓价
    var leverage: String? //杠杆倍数
    //逐仓参数
    var long_margin: String? //多仓保证金
    var long_liqui_price: String? //多仓强平价格
    var long_pnl_ratio: Float? //多仓收益率
    var long_leverage: String? //多仓杠杆倍数
    var short_margin: String? //空仓保证金
    var short_liqui_price: String? //空仓强平价格
    var short_pnl_ratio: Float? //空仓收益率
    var short_leverage: String? //空仓杠杆倍数
}
