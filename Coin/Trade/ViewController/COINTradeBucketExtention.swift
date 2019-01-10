//
//  COINTradeBucketExtention.swift
//  Coin
//
//  Created by dev6 on 2018/12/13.
//  Copyright © 2018 COIN. All rights reserved.
//

import Foundation

extension COINTradeBucketViewController {
    
    func getInstrumentData(symbol: String) {
        if self.platform == .bitmex {
            self.getBitmexInstrument(symbol: symbol)
        } else {
            self.getOKEXCurrentTicker(symbol: symbol)
        }
    }
    
    func getTradeHistoryData() {
        if self.platform == .bitmex {
            self.getBitmexTradeHistoryData()
        } else {
            self.getOKEXTradeHistoryData()
        }
    }
    
    func getLineData(kLineType: KLineType) {
        if self.platform == .bitmex {
            self.getBitmexLineData(kLineType: kLineType)
        } else {
            self.getOKEXLineData(kLineType: kLineType)
        }
    }
    
    func addWS(types: [SubscribeType]) {
        if self.platform == .bitmex {
            self.addBitMex(subscribeTypeArray: self.getBitmexSunscribes(types: types))
        } else {
            self.addOkex(subscribeTypeArray: self.getOKEXSunscribes(types: types))
        }
    }
    
    func startCancelArray(subscribeTypes: [SubscribeType]) {
        if self.instrument?.symbol == nil {
            return
        }
        if self.platform == .bitmex {
            self.startCancelArray_bitMex(symbol: (self.instrument?.symbol)!, subscribeTypeArray: self.getBitmexSunscribes(types: subscribeTypes))
        } else {
            for type in subscribeTypes {
                switch type {
                case .market:
                    self.startCancel_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .ticker_ok)
                case .kline:
                    self.startCancel_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .kline_ok, parameterType: .min1)
                case .depth:
                    self.startCancel_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .depth_ok, parameterType: .depth_5)
                case .trade:
                    self.startCancel_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .trade_ok)
                }
            }
        }
    }
    
    func startSubscribeArray(subscribeTypes: [SubscribeType]) {
        if self.instrument?.symbol == nil {
            return
        }
        if self.platform == .bitmex {
            self.startSubscribeArray_bitMex(symbol: (self.instrument?.symbol)!, subscribeTypeArray: self.getBitmexSunscribes(types: subscribeTypes))
        } else {
            for type in subscribeTypes {
                switch type {
                case .market:
                    self.startSubscribe_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .ticker_ok)
                case .kline:
                    self.startSubscribe_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .kline_ok, parameterType: .min1)
                case .depth:
                    self.startSubscribe_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .depth_ok, parameterType: .depth_5)
                case .trade:
                    self.startSubscribe_ok(instrument_Id: (self.instrument?.symbol)!, subscribeType: .trade_ok)
                }
            }
        }
    }
}
//bitmex
extension COINTradeBucketViewController {
    func getBitmexInstrument(symbol: String?) {
        if symbol == nil {
            return
        }
        let  parameters = ["symbol": symbol!]
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/v1/instrument", platform: self.platform, parameters: parameters, responseClass: COINBitmexInstrumentModel.self, successHandler: { (instrumentModel) in
            weakSelf?.instrument = instrumentModel?.toInstrumentModel().data?.first
            weakSelf?.lineView.instrument = weakSelf?.instrument
            weakSelf?.lineView.updateHeader()
        })
    }
    
    func getBitmexTradeHistoryData() {
        if self.instrument?.symbol == nil {
            return
        }
        let requestPath = "/api/v1/trade"
        let parameters: [String: Any] = ["symbol":self.instrument?.symbol ?? "XBTUSD","count":10,"reverse":true]
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, responseClass: COINOrderBookModel.self,successHandler: { (response) in
            //            print(response?.data)
            weakSelf?.lineView.tradeHistoryView.tradeHistoryModel = response
        })
    }
    
    func getBitmexLineData(kLineType: KLineType) {
        if self.instrument?.symbol == nil {
            return
        }
        if kLineType == .MinuteLine {
            self.startSubscribe_bitMex(symbol: (self.instrument?.symbol)!, subscribeType: .tradeBin1m)
        } else {
            self.startCancel_bitMex(symbol: (self.instrument?.symbol)!, subscribeType: .tradeBin1m)
        }
        let requestPath = "/api/v1/trade/bucketed"
        
        var count = 100
        var timeMinute = 0
        var binSize = "1m"
        var multiple = 1
        switch kLineType {
        case .MinuteLine:
            count = 300
            timeMinute = 300
            binSize = "1m" //1分钟线取5小时
            multiple = 1
        case .FiveMinuteLine:
            timeMinute = 60 * 24 //5分钟线取1天
            count = timeMinute/5
            binSize = "5m"
            multiple = 1
        case .FifteenMinuteLine:
            timeMinute = 60 * 24 //15分钟线取1天
            count = timeMinute/5
            binSize = "5m"
            multiple = 3
        case .ThirtyMinuteLine:
            timeMinute = 60 * 24 * 2 //30分钟线取2天
            count = timeMinute/5
            binSize = "5m"
            multiple = 6
        case .HourLine:
            timeMinute = 60 * 24 * 12 //1小时线12天
            count = timeMinute/60
            binSize = "1h"
            multiple = 1
        case .FourHourLine:
            timeMinute = 60 * 24 * 15 //4小时线取半个月月
            count = timeMinute/(60)
            binSize = "1h"
            multiple = 4
        case .DayLine:
            timeMinute = 60 * 24 * 30 * 6 //日线取半年
            count = timeMinute/(60*24)
            binSize = "1d"
            multiple = 1
        case .WeekLine:
            timeMinute = 60 * 24 * 30 * 12 //周线取1年
            count = timeMinute/(60*24)
            binSize = "1d"
            multiple = 7
        case .MonthLine:
            timeMinute = 60 * 24 * 30 * 12 //月线取1年
            count = timeMinute/(60*24)
            binSize = "1d"
            multiple = 30
        }
        
        let date = DateFormatter.init()
        date.timeZone = TimeZone.init(identifier: "Europe/London")//要0时区，即伦敦时区
        date.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let time = date.string(from: Date.init(timeIntervalSince1970: Date.init().timeIntervalSince1970 - Double(timeMinute * 60)))
        let parameters: [String: Any] = ["symbol":self.instrument?.symbol ?? "XBTUSD","binSize":binSize,"count":count,"startTime":time,"partial":true]
        print(parameters)
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, responseClass: COINBitmexKLineModel.self, successHandler: { (response) in
            //            print(response?.toJSON())
            if response != nil && response?.data != nil {
                var dataModel: COINKLineModel?
                if multiple == 1 {
                    dataModel = response?.toKLineModel()
                } else {
                    var models = [COINKLineItemModel]()
                    var i = (response!.data?.count ?? 0) - 1
                    while i - multiple >= 0 && i >= 0 {
                        let modelNew = COINKLineItemModel()
                        var j = i - multiple
                        var low = MAXFLOAT
                        var high = 0.0
                        var volume = 0.0
                        modelNew.open = response?.data![j].open
                        modelNew.close = response?.data![i].close
                        modelNew.timestamp = response?.data![i].timestamp
                        while j <= i {
                            let model = response?.data![j]
                            if Float(model!.low!)! < low {
                                low = Float(model!.low!)!
                            }
                            if Double(model!.high!)! > high && Double(model!.high!)! < 20000 {
                                high = Double(model!.high!)!
                            }
                            volume += Double(model!.volume!)!
                            j += 1
                        }
                        modelNew.low = String(low)
                        modelNew.high = String(high)
                        modelNew.volume = String(volume)
                        models.insert(modelNew, at: 0)
                        i -= multiple
                    }
                    dataModel = COINKLineModel()
                    dataModel?.data = models
                }
                weakSelf?.lineData = dataModel!
                if weakSelf?.lineView.superview != nil {
                    weakSelf?.lineView.kLineModel = dataModel!
                } else {
                    weakSelf?.view.addSubview((weakSelf?.lineView)!)
                }
            }
        })
    }
}
//okex
extension COINTradeBucketViewController {
    func getOKEXCurrentTicker(symbol: String?) {
        if symbol == nil {
            return
        }
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/futures/v3/instruments/\(symbol!)/ticker", platform: self.platform, parameters: nil, responseClass: COINOKEXInstrumentModel.self, isArray: false, successHandler: { instrumentModel in
            if weakSelf?.instrument == nil {
                weakSelf?.instrument = COINInstrumentItemModel()
                weakSelf?.instrument?.symbol = symbol
            }
            instrumentModel?.toInstrumentModel(instrumentModel: (weakSelf?.instrument)!)
            weakSelf?.lineView.instrument = weakSelf?.instrument
            weakSelf?.lineView.updateHeader()
        })
    }
    func getOKEXTradeHistoryData() {
        if self.instrument?.symbol == nil {
            return
        }
        let requestPath = "/api/futures/v3/instruments/\((self.instrument?.symbol)!)/trades"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINOKEXTradeModel.self,successHandler: { (response) in
            //            print(response?.data)
            weakSelf?.lineView.tradeHistoryView.tradeHistoryModel = response?.toOrderBookModel()
        })
    }
    
    func getOKEXLineData(kLineType: KLineType) {
        if self.instrument?.symbol == nil {
            return
        }
        if kLineType == .MinuteLine {
            self.startSubscribeArray(subscribeTypes: [.kline])
        } else {
            self.startCancelArray(subscribeTypes: [.kline])
        }
        var timeMinute = 0
        var binSize = 60
        var multiple = 1
        switch kLineType { //okex每次返回200个数据
        case .MinuteLine:
            timeMinute = 200//1分钟线
            binSize = 60
        case .FiveMinuteLine:
            timeMinute = 5 * 200 //5分钟线
            binSize = 300
        case .FifteenMinuteLine:
            timeMinute = 15 * 200  //15分钟线
            binSize = 900
        case .ThirtyMinuteLine:
            timeMinute = 30 * 200  //30分钟线
            binSize = 1800
        case .HourLine:
            timeMinute = 60 * 200  //1小时线
            binSize = 3600
        case .FourHourLine:
            timeMinute = 60 * 4 * 200  //4小时线
            binSize = 14400
        case .DayLine:
            timeMinute = 60 * 24 * 200  //日线
            binSize = 86400
        case .WeekLine:
            timeMinute = 60 * 24 * 7 * 200 //周线
            binSize = 604800
        case .MonthLine:
            timeMinute = 60 * 24 * 7 * 200 //月线
            binSize = 604800
            multiple = 4
        }
        
        let date = DateFormatter.init()
        date.timeZone = TimeZone.init(identifier: "Europe/London")//要0时区，即伦敦时区
        date.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateNow = Date.init()
        let endTime = date.string(from: dateNow)
        let startTime = date.string(from: Date.init(timeIntervalSince1970:dateNow.timeIntervalSince1970  - Double(timeMinute * 60)))

        let requestPath = "/api/futures/v3/instruments/\((self.instrument?.symbol)!)/candles?start=\(startTime)&end=\(endTime)&granularity=\(binSize)"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINOKEXKLineModel.self, successHandler: { (response) in
            //            print(response?.toJSON())
            if response != nil && response?.data != nil {
                var dataModel: COINKLineModel?
                if multiple == 1 {
                    dataModel = response?.toKLineModel()
                } else {
                    var models = [COINKLineItemModel]()
                    var i = (response!.data?.count ?? 0) - 1
                    let toStringFmt = DateFormatter.init()
                    toStringFmt.dateFormat = "yyyy-MM-dd HH:mm"
                    while i - multiple >= 0 && i >= 0 {
                        let modelNew = COINKLineItemModel()
                        var j = i - multiple
                        var low = MAXFLOAT
                        var high = 0.0
                        var volume = 0.0
                        modelNew.open = response?.data![j][1]
                        modelNew.close = response?.data![i][4]
                        let time = Date.init(timeIntervalSince1970: TimeInterval(response!.data![i][0])!/1000)
                        modelNew.timestamp = toStringFmt.string(from: time)
                        while j <= i {
                            let model = response?.data![j]
                            if Float(model![3])! < low {
                                low = Float(model![3])!
                            }
                            if Double(model![2])! > high && Double(model![2])! < 20000 {
                                high = Double(model![2])!
                            }
                            volume += Double(model![5])!
                            j += 1
                        }
                        modelNew.low = String(low)
                        modelNew.high = String(high)
                        modelNew.volume = String(volume)
                        models.append(modelNew)
                        i -= multiple
                    }
                    dataModel = COINKLineModel()
                    dataModel?.data = models
                }
                weakSelf?.lineData = dataModel!
                if weakSelf?.lineView.superview != nil {
                    weakSelf?.lineView.kLineModel = dataModel!
                } else {
                    weakSelf?.view.addSubview((weakSelf?.lineView)!)
                }
            }
        })
    }
}
