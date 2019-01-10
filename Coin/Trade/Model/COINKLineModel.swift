//
//  KLineModel.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/14.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

class COINKLineModel: COINBaseModel {
    var data: [COINKLineItemModel]?
}
class COINKLineItemModel: COINBaseModel {
    var symbol: String?
    var close: String?
    var foreignNotional: String?
    var high: String?
    var homeNotional: String?
    var lastSize: String?
    var low: String?
    var open: String?
    var timestamp: String?
    var trades: String?
    var turnover: String?
    var volume: String?
    var vwap: String?
    
    // MARK: 指标
    // 该model以及之前所有开盘价之和
    var sumOpen: Double?
    
    // 该model以及之前所有收盘价之和
    var sumClose: Double?
    
    // 该model以及之前所有最高价之和
    var sumHigh: Double?
    
    // 该model以及之前所有最低价之和
    var sumLow: Double?
    
    // 该model以及之前所有成交量之和
    var sumVolume: Double?
    
    // MARK: MA - MA(N) = (C1+C2+……CN) / N, C:收盘价
    var MAs: [Double?]?
    var MA_VOLUMEs: [Double?]?
    
    // MARK: EMA - EMA(N) = 2 / (N+1) * (C-昨日EMA) + 昨日EMA, C:收盘价
    var EMAs: [Double?]?
    var EMA_VOLUMEs: [Double?]?
    
    // MARK: MACD
    // DIF = EMA(12) - EMA(26)
    var DIF: Double?
    // DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
    var DEA: Double?
    // MACD(12,26,9) = (DIF - DEA) * 2
    var MACD: Double?
    
    // MARK: KDJ(9,3,3) 代表指标分析周期为9天，K值D值为3天
    // 九个交易日内最低价
    var minPriceOfNineClock: Double?
    // 九个交易日最高价
    var maxPriceOfNineClock: Double?
    // RSV(9) =（今日收盘价－9日内最低价）/（9日内最高价－9日内最低价）* 100
    var RSV9: Double?
    // K(3) =（当日RSV值+2*前一日K值）/ 3
    var KDJ_K: Double?
    // D(3) =（当日K值 + 2*前一日D值）/ 3
    var KDJ_D: Double?
    // J = 3K － 2D
    var KDJ_J: Double?
    
    // MARK: BOLL
    // 中轨线
    var BOLL_MB: Double?
    // 上轨线
    var BOLL_UP: Double?
    // 下轨线
    var BOLL_DN: Double?
    
    // MARK: RSI
    var RSI6: Double?
    var RSI12: Double?
    var RSI24: Double?
}


// MARK: ----BOLL----
extension COINKLineModel {
    public func fetchDrawBOLLData(drawRange: NSRange? = nil) -> [COINKLineItemModel] {
        var datas = [COINKLineItemModel]()
        if self.data == nil {
            return datas
        }
        guard self.data!.count > 0 else {
            return datas
        }
        
        for (index, model) in self.data!.enumerated() {
            model.sumClose = Double(model.close!)! + (index > 0 ? self.data![index - 1].sumClose! : 0)
            let day = 20
            if index < (day - 1) {
                continue
            }
            let MA = handleMA(day: day, model: model, index: index, models: self.data!) //N日内的收盘价之和÷N
            let MD = handleMD(day: day, model: model, MAValue: MA) //平方根N日的（C－MA）的两次方之和除以N
            model.BOLL_MB = handleMA(day: day-1, model: model, index: index, models: self.data!) //MB=（N－1）日的MA
            model.BOLL_UP = handleUP(MB: model.BOLL_MB, MD: MD) //UP=MB+2×MD
            model.BOLL_DN = handleDN(MB: model.BOLL_MB, MD: MD) //DN=MB－2×MD
            
            datas.append(model)
        }
        
        if let range = drawRange {
            return Array(datas[range.location..<range.location+range.length])
        } else {
            return datas
        }
    }
    
    private func handleMD(day: Int, model: COINKLineItemModel, MAValue: Double?) -> Double? {
        if let MA = MAValue {
            return sqrt(pow((Double(model.close!)! - MA), 2) / Double(day))
        }
        return nil
    }
    
    private func handleMA(day: Int, model: COINKLineItemModel, index: Int, models: [COINKLineItemModel]) -> Double? {
        if day <= 0 || index < (day - 1) {
            return nil
        }
        else if index == (day - 1) {
            return model.sumClose! / Double(day)
        }
        else {
            return (model.sumClose! - models[index - day].sumClose!) / Double(day)
        }
    }
    
    private func handleUP(MB: Double?, MD: Double?) -> Double? {
        if let MB = MB,
            let MD = MD {
            return MB + 2 * MD
        }
        return nil
    }
    
    private func handleDN(MB: Double?, MD: Double?) -> Double? {
        if let MB = MB,
            let MD = MD {
            return MB - 2 * MD
        }
        return nil
    }
}


// MARK: ----MACD----
extension COINKLineModel {
    public func fetchDrawMACDData(drawRange: NSRange? = nil) -> [COINKLineItemModel] {
        
        var datas = [COINKLineItemModel]()
        if self.data == nil {
            return datas
        }
        guard self.data!.count > 0 else {
            return datas
        }
        var lastEMA12: Double?
        var lastEMA26: Double?
        
        for (index, model) in self.data!.enumerated() {
            let previousModel: COINKLineItemModel? = index > 0 ? self.data![index - 1] : nil
            
            let ema12 = handleEMA(day: 12, model: model, index: index, previousEMA: lastEMA12) //EMA（12）=前一日EMA（12）×11/13+今日收盘价×2/13
            let ema26 = handleEMA(day: 26, model: model, index: index, previousEMA: lastEMA26) //EMA（26）=前一日EMA（26）×25/27+今日收盘价×2/27
            lastEMA12 = ema12
            lastEMA26 = ema26
            guard let _ = ema12,
                let _ = ema26 else {
                    continue
            }
            model.DIF = handleDIF(EMA12: ema12, EMA26: ema26) //DIF=今日EMA（12）－今日EMA（26）
            model.DEA = handleDEA(model: model, previousModel: previousModel) //今日DEA（MACD）=前一日DEA×8/10+今日DIF×2/10。
            model.MACD = handleMACD(model: model)
            
            datas.append(model)
        }
        
        if let range = drawRange {
            return Array(datas[range.location..<range.location+range.length])
        } else {
            return datas
        }
    }
    
    private func handleEMA(day: Int, model: COINKLineItemModel, index: Int, previousEMA: Double?) -> Double? {
        if day <= 0 || index < (day - 1) {
            return nil
        } else {
            if previousEMA != nil {
                return Double(day - 1) / Double(day + 1) * previousEMA! + 2 / Double(day + 1) * Double(model.close!)!
            } else {
                return 2 / Double(day + 1) * Double(model.close!)!
            }
        }
    }
    
    private func handleDIF(EMA12: Double?, EMA26: Double?) -> Double? {
        guard let ema12 = EMA12,
            let ema26 = EMA26 else {
                return nil
        }
        return ema12 - ema26
    }
    
    private func handleDEA(model: COINKLineItemModel, previousModel: COINKLineItemModel?) -> Double? {
        
        guard let dif = model.DIF else {
            return nil
        }
        
        if let previousDEA = previousModel?.DEA {
            return dif * 0.2 + previousDEA * 0.8
        } else {
            return dif * 0.2
        }
    }
    
    private func handleMACD(model: COINKLineItemModel) -> Double? {
        guard let dif = model.DIF,
            let dea = model.DEA else {
                return nil
        }
        return (dif - dea) * 2
    }
}
// MARK: ----KDJ----
extension COINKLineModel {
    public func fetchDrawKDJData(drawRange: NSRange? = nil) -> [COINKLineItemModel] {
        var datas = [COINKLineItemModel]()
        if self.data == nil {
            return datas
        }
        guard self.data!.count > 0 else {
            return datas
        }
        
        for (index, model) in self.data!.enumerated() {
            let previousModel: COINKLineItemModel? = index > 0 ? self.data![index - 1] : nil
            model.minPriceOfNineClock = handleMinPriceOfNineClock(index: index, models: self.data!)
            model.maxPriceOfNineClock = handleMaxPriceOfNineClock(index: index, models: self.data!)
            model.RSV9 = handleRSV9(model: model) //9日RSV=（C－L9）÷（H9－L9）×100
            model.KDJ_K = handleKDJ_K(model: model, previousModel: previousModel) //K值=2/3×第8日K值+1/3×第9日RSV
            model.KDJ_D = handleKDJ_D(model: model, previousModel: previousModel) //D值=2/3×第8日D值+1/3×第9日K值
            model.KDJ_J = handleKDJ_J(model: model) //J值=3*第9日K值-2*第9日D值
            datas.append(model)
        }
        
        if let range = drawRange {
            return Array(datas[range.location..<range.location+range.length])
        } else {
            return datas
        }
    }
    
    private func handleMinPriceOfNineClock(index: Int, models: [COINKLineItemModel]) -> Double {
        var minValue = Double(models[index].low!)!
        let startIndex = index < 9 ? 0 : (index - (9 - 1))
        
        for i in startIndex..<index {
            if Double(models[i].low!)! < minValue {
                minValue = Double(models[i].low!)!
            }
        }
        return minValue
    }
    
    private func handleMaxPriceOfNineClock(index: Int, models: [COINKLineItemModel]) -> Double {
        var maxValue = Double(models[index].high!)!
        let startIndex = index < 9 ? 0 : (index - (9 - 1))
        
        for i in startIndex..<index {
            if Double(models[i].high!)! < maxValue {
                maxValue = Double(models[i].high!)!
            }
        }
        return maxValue
    }
    
    private func handleRSV9(model: COINKLineItemModel) -> Double {
        
        guard let minPrice = model.minPriceOfNineClock,
            let maxPrice = model.maxPriceOfNineClock else {
                return 100.0
        }
        
        if minPrice == maxPrice {
            return 100.0
        } else {
            return (Double(model.close!)! - minPrice) / (maxPrice - minPrice) * 100
        }
    }
    
    private func handleKDJ_K(model: COINKLineItemModel, previousModel: COINKLineItemModel?) -> Double {
        
        if previousModel == nil { // 第一个数据
            return (model.RSV9! + 2 * 50) / 3
        } else {
            return (model.RSV9! + 2 * previousModel!.KDJ_K!) / 3
        }
    }
    
    private func handleKDJ_D(model: COINKLineItemModel, previousModel: COINKLineItemModel?) -> Double {
        
        if previousModel == nil { // 第一个数据
            return (model.KDJ_K! + 2 * 50) / 3
        } else {
            return (model.KDJ_K! + 2 * previousModel!.KDJ_D!) / 3
        }
    }
    
    private func handleKDJ_J(model: COINKLineItemModel) -> Double {
        return model.KDJ_K! * 3 - model.KDJ_D! * 2
    }
}

// MARK: ----RSI----
extension COINKLineModel {
    public func fetchDrawRSIData() -> [COINKLineItemModel] {
        var datas = [COINKLineItemModel]()
        if self.data == nil {
            return datas
        }
        guard self.data!.count > 0 else {
            return datas
        }
        
        for (index, model) in self.data!.enumerated() {
            if index < 6 {
                model.RSI6 = 0
                model.RSI12 = 0
                model.RSI24 = 0
            } else if index < 12 {
                model.RSI6 = 100 * self.getRS(dataArray: Array(self.data![(index-6)..<index]))
                model.RSI12 = 0
                model.RSI24 = 0
            } else if index  < 24 {
                model.RSI6 = 100 * self.getRS(dataArray: Array(self.data![(index-6)..<index]))
                model.RSI12 = 100 * self.getRS(dataArray: Array(self.data![(index-12)..<index]))
                model.RSI24 = 0
            } else {
                model.RSI6 = 100 * self.getRS(dataArray: Array(self.data![(index-6)..<index]))
                model.RSI12 = 100 * self.getRS(dataArray: Array(self.data![(index-12)..<index]))
                model.RSI24 = 100 * self.getRS(dataArray: Array(self.data![(index-24)..<index]))
            }
            datas.append(model)
        }
        return datas
    }
    
    func getRS(dataArray:[COINKLineItemModel]) -> Double {
        var rsUP = 0.0
        var rsDown = 0.0
        for model in dataArray {
            if Double(model.close!)! - Double(model.open!)! > 0 {
                rsUP += (Double(model.close!)! - Double(model.open!)!)
            } else {
                rsDown += (Double(model.open!)! - Double(model.close!)!)
            }
        }
        return rsUP/(rsDown + rsUP)
    }
}

class COINBitmexKLineModel: COINBaseModel {
    var data: [COINBitmexKLineItemModel]?
    
    func toKLineModel() -> COINKLineModel {
        let kLineModel = COINKLineModel()
        var arr = [COINKLineItemModel]()
        for (_,item) in self.data?.enumerated() ?? [COINBitmexKLineItemModel]().enumerated() {
            let kLineItemModel = COINKLineItemModel()
            kLineItemModel.symbol = item.symbol
            kLineItemModel.close = item.close
            kLineItemModel.foreignNotional = item.foreignNotional
            kLineItemModel.high = item.high
            kLineItemModel.homeNotional = item.homeNotional
            kLineItemModel.lastSize = item.lastSize
            kLineItemModel.low = item.low
            kLineItemModel.open = item.open
            kLineItemModel.timestamp = item.timestamp
            kLineItemModel.trades = item.trades
            kLineItemModel.turnover = item.turnover
            kLineItemModel.volume = item.volume
            kLineItemModel.vwap = item.vwap
            arr.append(kLineItemModel)
        }
        kLineModel.data = arr
        return kLineModel
    }
}

class COINBitmexKLineItemModel: COINBaseModel {
    var symbol: String?
    var close: String?
    var foreignNotional: String?
    var high: String?
    var homeNotional: String?
    var lastSize: String?
    var low: String?
    var open: String?
    var timestamp: String?
    var trades: String?
    var turnover: String?
    var volume: String?
    var vwap: String?
}

class COINOKEXKLineModel: COINBaseModel {
    var data: [[String]]?
    
    func toKLineModel() -> COINKLineModel {
        let kLineModel = COINKLineModel()
        var arr = [COINKLineItemModel]()
        let toStringFmt = DateFormatter.init()
        toStringFmt.dateFormat = "yyyy-MM-dd HH:mm"
        for (_,item) in self.data?.enumerated() ?? [[String]]().enumerated() {
            let kLineItemModel = COINKLineItemModel()
            if item.count == 7 { //[timestamp,open,high,low,close,volume,currency_volume]
                let time = Date.init(timeIntervalSince1970: TimeInterval(item[0])!/1000)
                kLineItemModel.timestamp = toStringFmt.string(from: time)
                kLineItemModel.open = item[1]
                kLineItemModel.high = item[2]
                kLineItemModel.low = item[3]
                kLineItemModel.close = item[4]
                kLineItemModel.volume = item[5]
                kLineItemModel.trades = item[6]
            }
            arr.insert(kLineItemModel, at: 0)
        }
        kLineModel.data = arr
        return kLineModel
    }
}
