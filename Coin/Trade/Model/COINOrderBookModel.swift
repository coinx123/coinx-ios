//
//  OrderBookModel.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/14.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

class COINOrderBookModel: COINBaseModel {
    var data: [COINOrderBookItemModel]?
}

class COINOrderBookItemModel: COINBaseModel {
    var symbol: String? //币种名称
    var side: String? //Sell或者Buy
    var size: String? //数量
    var price: String? //价格
    var orderID: String? //委托订单ID
    var lastPrice: String?//最新价格
    var indicativeSettlePrice: String?//指数价格
    var orderQty: String? //委托量
    var timestamp: String? //创建的时间
    var avgPx: String? //均价
    var currency: String? //法币名称
    var ordStatus: String? //委托订单状态,New未成交，Filled已成交，Canceled已撤销
    var settlCurrency: String? //结算货币
    var ordType: String? //订单类型
    var cumQty: String? //成交量，跟orderQty对应
    var fee: String? //手续费
    
    var titleAttr: NSMutableAttributedString?
    var type: String?
    
}


class COINBitmexOrderBookModel: COINBaseModel {
    var data: [COINBitmexOrderBookItemModel]?
    
    func toOrderBookModel() -> COINOrderBookModel {
        let orderBookModel = COINOrderBookModel()
        var arr = [COINOrderBookItemModel]()
        for (_,item) in self.data?.enumerated() ?? [COINBitmexOrderBookItemModel]().enumerated() {
            let orderBookItemModel = COINOrderBookItemModel()
            orderBookItemModel.symbol = item.symbol
            orderBookItemModel.side = item.side
            orderBookItemModel.size = item.size
            orderBookItemModel.price = item.price
            orderBookItemModel.lastPrice = item.lastPrice
            orderBookItemModel.indicativeSettlePrice = item.indicativeSettlePrice
            orderBookItemModel.orderID = item.orderID
            orderBookItemModel.orderQty = item.orderQty
            orderBookItemModel.timestamp = item.timestamp
            orderBookItemModel.avgPx = item.avgPx
            orderBookItemModel.currency = item.currency
            orderBookItemModel.ordStatus = item.ordStatus
            orderBookItemModel.settlCurrency = item.settlCurrency
            orderBookItemModel.ordType = item.ordType
            orderBookItemModel.cumQty = item.cumQty
            self.getAttrTitle(orderBookModel: orderBookItemModel)
            arr.append(orderBookItemModel)
            if item.clOrdID != nil && item.clOrdLinkID!.count > 0 {
                print(item)
            }
        }
        orderBookModel.data = arr
        return orderBookModel
    }
    
    func getAttrTitle(orderBookModel: COINOrderBookItemModel) {
        let type = orderBookModel.symbol?.bitmexTimeType()
        orderBookModel.type = type?.0
        orderBookModel.titleAttr = type?.1
    }
}

class COINBitmexOrderBookItemModel: COINBaseModel {
    var symbol: String? //币种名称
    var id: String? //币种id
    var side: String? //Sell或者Buy
    var size: String? //数量
    var price: String? //价格
    
    /// 最新价格
    var lastPrice: String?
    
    /// 指数价格
    var indicativeSettlePrice: String?
    var orderID: String? //委托订单ID
    var clOrdID: String? //Sell或者Buy
    var clOrdLinkID: String? //关联订单ID
    var account: String? //账户名
    var simpleOrderQty: String? //单一委托量
    var orderQty: String? //委托量
    var displayQty: String? //显示的数量
    var stopPx: String? //止损价格
    var pegOffsetValue: String? //
    var pegPriceType: String? //
    var currency: String? //法币名称
    var settlCurrency: String? //结算货币
    var ordType: String? // 订单类型
    var timeInForce: String? //
    var execInst: String? //
    var contingencyType: String? //
    var exDestination: String? //
    var ordStatus: String? //委托订单状态
    var triggered: String? //
    var workingIndicator: String? //
    var ordRejReason: String? //拒绝原因
    var simpleLeavesQty: String? // 单一剩余量，跟simpleOrderQty对应
    var leavesQty: String? // 剩余量，跟orderQty对应
    var simpleCumQty: String? // 单一累积量，跟simpleOrderQty对应
    var cumQty: String? //成交量，跟orderQty对应
    var avgPx: String? //均价
    var multiLegReportingType: String? //
    var text: String? //备注
    var transactTime: String? //交易时间、处理时间
    var timestamp: String? //创建的时间
}

class COINOKEXOrderBookModel: COINBaseModel {
    var result: Bool?
    var order_info: [COINOKEXOrderBookItemModel]?
    
    func toOrderBookModel() -> COINOrderBookModel {
        let orderBookModel = COINOrderBookModel()
        var arr = [COINOrderBookItemModel]()
        
        for (_,item) in self.order_info?.enumerated() ?? [COINOKEXOrderBookItemModel]().enumerated() {
            let orderBookItemModel = COINOrderBookItemModel()
            orderBookItemModel.symbol = item.instrument_id
            let instrument_id = item.instrument_id ?? "BTC"
            let instrumentArray: [String] = instrument_id.components(separatedBy: "-")
            if instrumentArray.count > 1 {
                orderBookItemModel.currency = instrumentArray[1]
                orderBookItemModel.settlCurrency = instrumentArray[1]
                let time = instrumentArray[2]
                let timeType = time.okexTime()
                var timeStrTemp: NSString = instrumentArray.last! as NSString
                timeStrTemp = timeStrTemp.substring(from: 2) as NSString
                let attr = NSMutableAttributedString.init(string: "\(instrumentArray[0]) \(timeType)-\(timeStrTemp)")
                attr.addAttributes([NSAttributedString.Key.font: fontBold16], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.font: font12], range: NSMakeRange(3, attr.length - 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleBlackColor], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleGrayColor], range: NSMakeRange(3, attr.length - 3))
                orderBookItemModel.titleAttr = attr
            }
            orderBookItemModel.size = item.size ?? item.qty
            if item.side != nil && item.side!.count > 0 {
                orderBookItemModel.side = item.side
            } else if item.type != nil {
                orderBookItemModel.side = item.type
            }
            orderBookItemModel.timestamp = item.timestamp
            orderBookItemModel.orderID = item.order_id
            orderBookItemModel.price = item.price
            orderBookItemModel.avgPx = item.price_avg
            orderBookItemModel.orderQty = item.size ?? item.qty
            orderBookItemModel.cumQty = item.filled_qty
            orderBookItemModel.fee = item.fee
            if item.status != nil {
                let status = Int(item.status!)
                if status == -1 {
                    orderBookItemModel.ordStatus = "Canceled"
                } else if status == 2 {
                    orderBookItemModel.ordStatus = "Filled"
                } else {
                    orderBookItemModel.ordStatus = "New"
                }
            }
            arr.insert(orderBookItemModel, at: 0)
        }
        orderBookModel.data = arr
        return orderBookModel
    }
}

class COINOKEXTradeModel: COINBaseModel {
    var data: [COINOKEXOrderBookItemModel]?
    
    func toOrderBookModel() -> COINOrderBookModel {
        let orderBookModel = COINOrderBookModel()
        var arr = [COINOrderBookItemModel]()
        for (_,item) in self.data?.enumerated() ?? [COINOKEXOrderBookItemModel]().enumerated() {
            let orderBookItemModel = COINOrderBookItemModel()
            
            orderBookItemModel.symbol = item.instrument_id
            let instrument_id = item.instrument_id ?? "BTC"
            let instrumentArray: [String] = instrument_id.components(separatedBy: "-")
            if instrumentArray.count > 1 {
                orderBookItemModel.currency = instrumentArray[1]
                orderBookItemModel.settlCurrency = instrumentArray[1]
                let time = instrumentArray[2]
                let timeType = time.okexTime()
                var timeStrTemp: NSString = instrumentArray.last! as NSString
                timeStrTemp = timeStrTemp.substring(from: 2) as NSString
                let attr = NSMutableAttributedString.init(string: "\(instrumentArray[0]) \(timeType)-\(timeStrTemp)")
                attr.addAttributes([NSAttributedString.Key.font: fontBold16], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.font: font12], range: NSMakeRange(3, attr.length - 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleBlackColor], range: NSMakeRange(0, 3))
                attr.addAttributes([NSAttributedString.Key.foregroundColor: titleGrayColor], range: NSMakeRange(3, attr.length - 3))
                orderBookItemModel.titleAttr = attr
            }
            orderBookItemModel.size = item.size ?? item.qty
            if item.side != nil && item.side!.count > 0 {
                orderBookItemModel.side = item.side
            } else if item.type != nil {
                orderBookItemModel.side = item.type
            }
            orderBookItemModel.timestamp = item.timestamp
            orderBookItemModel.orderID = item.order_id
            orderBookItemModel.price = item.price
            orderBookItemModel.avgPx = item.price_avg
            orderBookItemModel.orderQty = item.size ?? item.qty
            orderBookItemModel.cumQty = item.filled_qty
            orderBookItemModel.fee = item.fee
            if item.status != nil {
                let status = Int(item.status!)
                if status == -1 {
                    orderBookItemModel.ordStatus = "Canceled"
                } else if status == 2 {
                    orderBookItemModel.ordStatus = "Filled"
                } else {
                    orderBookItemModel.ordStatus = "New"
                }
            }
            arr.append(orderBookItemModel)
        }
        orderBookModel.data = arr
        return orderBookModel
    }
}

class COINOKEXOrderBookItemModel: COINBaseModel {
    var instrument_id: String? //合约ID，如BTC-USD-180213
    var size: String? //数量
    var timestamp: String? //委托时间
    var filled_qty: String? //成交数量
    var fee: String? //手续费
    var order_id: String? //订单ID
    var price: String? //订单价格
    var price_avg: String? //平均价格
    var status: String? //订单状态(-1.撤单成功；0:等待成交 1:部分成交 2:全部成交 6：未完成（等待成交+部分成交）7：已完成（撤单成功+全部成交））
    var type: String? //订单类型(1:开多 2:开空 3:平多 4:平空)
    var contract_val: String? //合约面值
    var leverage: String? //杠杆倍数 value:10/20 默认10
    
    var qty: String? //成交数量
    var side: String? //成交方向
}
