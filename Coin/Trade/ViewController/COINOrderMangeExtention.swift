//
//  COINOrderMangeExtention.swift
//  Coin
//
//  Created by dev6 on 2018/12/11.
//  Copyright © 2018 COIN. All rights reserved.
//

import Foundation

public enum OrdStatus: String {
    case new = "New" //未成交
    case canceled = "Canceled" //已撤销
    case filled = "Filled" //已成交
}

extension COINOrderManageViewController {
    func startNetWork() {
        weak var weakSelf = self
        DispatchQueue.global().async {
            if weakSelf?.platform == .bitmex {
                weakSelf?.getBitmexCurrentPosition()
                weakSelf?.getBitmexMargin()
                weakSelf?.getMyBitmexNewOrderBook()
                weakSelf?.getBitmexUserCommision()
                weakSelf?.getBitmexInstrument(symbol: weakSelf?.symbol)
                weakSelf?.addBitMex(subscribeTypeArray: [.instrument,.OrderBook10])
            } else if weakSelf?.platform == .okex {
                weakSelf?.getOKEXCurrentTicker()
                weakSelf?.getOKEXleverage()
                weakSelf?.getMyOKEXNewOrderBook()
                weakSelf?.getAccountSymobl()
                weakSelf?.getCurrentPosition_ok()
                weakSelf?.addOkex(subscribeTypeArray: [.ticker_ok,.depth_ok])
            }
        }
    }
    
    func getMargin() {
        if self.platform == .bitmex {
            self.getBitmexMargin()
        }
    }
    
    func getCurrentPosition() {
        if self.platform == .bitmex {
            self.getBitmexCurrentPosition()
        }
    }
    
    func submitOrders(_ side: String) {
        if self.platform == .bitmex {
            self.submitBitmexOrders(side)
        } else if self.platform == .okex {
            self.submitOKEXOrders(side)
        }
    }
    
    func getMyNewOrderBook() {
        if self.platform == .bitmex {
            self.getMyBitmexNewOrderBook()
        } else if self.platform == .okex {
            self.getMyOKEXNewOrderBook()
        }
    }
    
    func getMyOrderBook(ordStatus: OrdStatus) {
        if self.platform == .bitmex {
            self.getMyBitmexOrderBook(ordStatus: ordStatus)
        } else if self.platform == .okex {
            self.getMyOKEXOrderBook(ordStatus: ordStatus, symbol: (self.contentView?.orderBookView.selectedSymbol)!)
        }
    }
    
    func getUserCommision() {
        if self.platform == .bitmex {
            self.getBitmexUserCommision()
        } else if self.platform == .okex {
            self.getOKEXUserCommision()
        }
    }
    
    func cancelOrder(orderModel: COINOrderBookItemModel?) {
        if self.platform == .bitmex {
            self.cancelBitmexOrder(orderModel: orderModel)
        } else if self.platform == .okex {
            self.cancelOKEXOrder(orderModel: orderModel)
        }
    }
    
    func getMyPosition(symbol: String) {
        if self.platform == .bitmex {
            self.getMyBitmexPosition(symbol: symbol)
        } else if self.platform == .okex {
            self.getMyOKEXPosition(symbol: symbol)
        }
    }
    
    func changeLeverage(leverage: String) {
        if self.platform == .bitmex {
            self.changeBitmexLeverage(leverage: leverage)
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
        if self.symbol == nil {
            return
        }
        if self.platform == .bitmex {
            self.startCancelArray_bitMex(symbol: self.symbol!, subscribeTypeArray: self.getBitmexSunscribes(types: subscribeTypes))
        } else {
            for type in subscribeTypes {
                switch type {
                case .market:
                    self.startCancel_ok(instrument_Id: self.symbol!, subscribeType: .ticker_ok)
                case .kline:
                    self.startCancel_ok(instrument_Id: self.symbol!, subscribeType: .kline_ok, parameterType: .min1)
                case .depth:
                    self.startCancel_ok(instrument_Id: self.symbol!, subscribeType: .depth_ok, parameterType: .depth_5)
                case .trade:
                    self.startCancel_ok(instrument_Id: self.symbol!, subscribeType: .trade_ok)
                }
            }
        }
    }
    
    func startSubscribeArray(subscribeTypes: [SubscribeType]) {
        if self.symbol == nil {
            return
        }
        if self.platform == .bitmex {
            self.startSubscribeArray_bitMex(symbol: self.symbol!, subscribeTypeArray: self.getBitmexSunscribes(types: subscribeTypes))
        } else {
            for type in subscribeTypes {
                switch type {
                case .market:
                    self.startSubscribe_ok(instrument_Id: self.symbol!, subscribeType: .ticker_ok)
                case .kline:
                    self.startSubscribe_ok(instrument_Id: self.symbol!, subscribeType: .kline_ok, parameterType: .min1)
                case .depth:
                    self.startSubscribe_ok(instrument_Id: self.symbol!, subscribeType: .depth_ok, parameterType: .depth_5)
                case .trade:
                    self.startSubscribe_ok(instrument_Id: self.symbol!, subscribeType: .trade_ok)
                }
            }
        }
    }
    
    func getOptionalData(type: Int) {
        if type == 0 { //自选
            let data: Array<Dictionary<String, Any>> = COINUserDefaultsHelper.getObjArray(UserDefaultsHelperKey.collectionsKey, platformType: self.platform) as! Array<Dictionary>
            let model = COINInstrumentModel.deserialize(from: ["data":data])
            if model?.data != nil {
                var data = [COINInstrumentItemModel]()
                for item in (model?.data)! {
                    if self.platform == .okex {
                        if !item.getAttrTitle(platform: self.platform).string.contains("过期") {
                            data.append(item)
                        }
                    } else {
                        data.append(item)
                    }
                    item.needRootSymbol = true
                }
                model?.data = data
            }
            self.optionalView.optionalModel = model
        } else { //全部
            if self.platform == .bitmex {
                self.getBitmexOptionalData()
            } else if self.platform == .okex {
                self.getOKEXOptionalData()
            }
        }
    }
}
// MARK: - bitmex处理网络部分
extension COINOrderManageViewController {
    func getBitmexInstrument(symbol: String?) {
        if symbol == nil {
            return
        }
        let  parameters = ["symbol": symbol!]
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/v1/instrument", platform: self.platform, parameters: parameters, responseClass: COINBitmexInstrumentModel.self, successHandler: { (instrumentModel) in
            weakSelf?.model = instrumentModel?.toInstrumentModel().data?.first
            weakSelf?.contentView?.exchanegView.exchangeHeaderView.instrumentModel = weakSelf?.model
            weakSelf?.updateExchangeHeaderView()
        })
    }
    
    
    func getBitmexMargin() {
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/v1/user/margin", platform: self.platform, parameters: ["currency" : "XBt"], method: .get, responseClass: COINBitmexMarginModel.self, isArray: false, successHandler: { (marginModel) in
            let margin = marginModel?.toMarginModel()
            weakSelf?.marginModel = margin
            weakSelf?.contentView?.positionView.marginModel = margin
            weakSelf?.updateMarginUI()
        }) { (error) in
            debugPrint(error as Any)
        }
    }
    
    func getBitmexCurrentPosition() {
        weak var weakSelf = self
        let  parameters = ["filter":"{\"symbol\": \"\(self.symbol!)\"}"]
        COINNetworkTool.request(path: "/api/v1/position", platform: self.platform, parameters: parameters, responseClass: COINBitmexPositionModel.self, successHandler: { positionModel in
            
            if ((positionModel?.data) == nil) {
                weakSelf?.contentView?.exchanegView.exchangeHeaderView.leverageTextField.text = "\(1)"
                return
            };
            let positionItemModel = positionModel?.toPositionModel().data?.first
            if positionItemModel != nil {
                if Bool(positionItemModel?.crossMargin ?? "0")! {
                    weakSelf?.contentView?.exchanegView.exchangeHeaderView.leverageTextField.text = "全仓"
                } else {
                    weakSelf?.contentView?.exchanegView.exchangeHeaderView.leverageTextField.text = "\((positionItemModel?.leverage)!)X"
                }
                weakSelf?.contentView?.exchanegView.exchangeHeaderView.buyCanUseCountLabel.text = positionItemModel?.currentQty
                weakSelf?.contentView?.exchanegView.exchangeHeaderView.sellerCanUseCountLabel.text = positionItemModel?.quoteCurrency
                
                weakSelf?.positionItem = positionItemModel
                weakSelf?.updateMarginUI()
            } else {
                weakSelf?.contentView?.exchanegView.exchangeHeaderView.leverageTextField.text = "全仓"
            }
        })
    }
    
    func submitBitmexOrders(_ side: String) {
        
        let headerView = self.contentView?.exchanegView.exchangeHeaderView
        var orderQty: Float = 0
        if (headerView!.coinCountTextField.text?.count)! > 0 {
            orderQty = Float(headerView!.coinCountTextField.text!)!
        }
        
        var parameters = [
            "side" : side,
            "symbol" : self.model?.symbol! ?? String.self,
            "orderQty" : orderQty,
            ] as [String : Any]
        switch self.priceType {
            
        case .customPrice:
            parameters["ordType"] = "Limit"
            var price: String?
            if self.model?.tickSize != nil {
                price = String(format: "%f", floorf(Float(headerView!.priceTextField.text!)! / self.model!.tickSize!) * self.model!.tickSize!)
            } else {
                if self.model?.underlying == "XBT" && !(self.model?.symbol?.uppercased().contains("7D"))! {
                    price = String(format: "%.0f", Float(headerView!.priceTextField.text!)!) //xbtusd、xbt季度的价格必须是0.5的倍数
                } else {
                    price = headerView?.priceTextField.text
                }
            }
            parameters["price"]   =  price
            break
        case .marketPrice:
            parameters["ordType"] = "Market"
            break
        case .buyFirstPrice:
            parameters["ordType"] = "Limit"
            let lastPrice        = self.asks.last?.first
            if (lastPrice != nil) {
                parameters["price"] = lastPrice!
            }
            break
        case .sellFirstPrice:
            parameters["ordType"] = "Limit"
            let firstPrice        = self.bids.first?.first
            if (firstPrice != nil) {
                parameters["price"] = firstPrice!
            }
            break
        }
        
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/v1/order", platform: self.platform, parameters: parameters, method: .post, responseClass: COINBitmexOrderBookItemModel.self, isArray: false, successHandler: { (bookModel) in
            debugPrint(bookModel?.orderID as Any)
            weakSelf?.getMyBitmexNewOrderBook()
            weakSelf?.getBitmexMargin()
            weakSelf?.getBitmexCurrentPosition()
        }) { (error) in
            debugPrint(error as Any)
        }
    }
    
    func getMyBitmexNewOrderBook() {
        let requestPath = "/api/v1/order"
        //        ,"filter":["ordStatus":"Filled"]  ordStatus:Filled结束了的，Canceled 取消 New 未成交
        let parameters: [String: Any] = ["symbol":self.symbol!,"count":100,"filter":["ordStatus":OrdStatus.new.rawValue],"reverse":true]
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, responseClass: COINBitmexOrderBookModel.self, successHandler: { (response) in
            weakSelf?.contentView?.exchanegView.orderBookModel = response?.toOrderBookModel()
        })
    }
    
    
    func getMyBitmexOrderBook(ordStatus: OrdStatus) {
        let requestPath = "/api/v1/order"
        //        ,"filter":["ordStatus":"Filled"]  ordStatus:Filled结束了的，Canceled 取消 NEW 未成交
        
        let parameters: [String: Any] = ["count":100,"filter":["ordStatus":ordStatus.rawValue],"reverse":true]
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, responseClass: COINBitmexOrderBookModel.self, successHandler: { (response) in
            weakSelf?.contentView?.orderBookView.orderBookModel = response?.toOrderBookModel()
        })
    }
    
    func getBitmexUserCommision() {
        let requestPath = "/api/v1/user/commission"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINCommisionModel.self, successHandler: { (response) in
            weakSelf?.contentView?.exchanegView.commisionModel = response
            weakSelf?.contentView?.orderBookView.commisionModel = response
        })
    }
    
    func cancelBitmexOrder(orderModel: COINOrderBookItemModel?) {
        if orderModel == nil {
            return
        }
        let requestPath = "/api/v1/order"
        
        let parameters: [String: Any] = ["orderID":orderModel!.orderID ?? ""]
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, method: .delete, responseClass: COINBitmexOrderBookModel.self, successHandler: { (response) in
            if response != nil {
                weakSelf?.getMyBitmexNewOrderBook() //交易页面刷新
                weakSelf?.getMyBitmexOrderBook(ordStatus: OrdStatus.new) //委托界面刷新
            }
        })
    }
    
    func getMyBitmexPosition(symbol: String) {
        let requestPath = "/api/v1/position"
        var filter: [String: Any] = ["isOpen":true,"underlying":symbol]
        if symbol == "全部" {
            filter = ["isOpen":true]
        }
        let parameters: [String: Any] = ["count":100,"filter":filter]
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, responseClass: COINBitmexPositionModel.self, successHandler: { (response) in
            //            print(response?.data?.count)
            weakSelf?.contentView?.positionView.positionModel = response?.toPositionModel()
        })
    }
    
    func changeBitmexLeverage(leverage: String) {
        let requestPath = "/api/v1/position/leverage"
        var leverageCount = 0.0
        if leverage == "全仓" {
            leverageCount = 0.0
        } else {
            let endIndex = leverage.index(leverage.endIndex, offsetBy:-1)
            leverageCount = Double(leverage[leverage.startIndex..<endIndex]) ?? 0.0
        }
        let parameters: [String: Any] = ["symbol":self.symbol ?? "XBTUSD","leverage":leverageCount]
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, method: .post, responseClass: COINBitmexPositionItemModel.self, isArray: false, successHandler: { (response) in
            weakSelf!.positionItem?.leverage = response!.leverage
            weakSelf?.updateMarginUI()
        })
    }
    
    func getBitmexOptionalData() {
        let filter: [String: Any] = ["state":"Open"]
        let parameters: [String: Any] = ["count":100,"filter":filter]
        let requestPath = "/api/v1/instrument"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: parameters, responseClass: COINBitmexInstrumentModel.self, successHandler: { (response) in
            weakSelf?.optionalView.optionalModel = response?.toInstrumentModel()
        })
    }
}

// MARK: - okex处理网络部分
extension COINOrderManageViewController {
    
    func getOKEXleverage() {
        if self.symbol == nil {
            return;
        }
        let instrumentArray: [String] = self.symbol!.components(separatedBy: "-")
        let currency = instrumentArray.first
        COINNetworkTool.request(path: "/api/futures/v3/accounts/\(currency!.lowercased())/leverage", platform: self.platform, parameters: nil, responseClass: COINOKEXPositionItemModel.self, isArray: false, successHandler: { instrumentModel in
            
        })
    }
    
    func getOKEXCurrentTicker() {
        if self.symbol == nil {
            return;
        }
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/futures/v3/instruments/\(self.symbol!)/ticker", platform: self.platform, parameters: nil, responseClass: COINOKEXInstrumentModel.self, isArray: false, successHandler: { instrumentModel in
            if weakSelf?.model == nil {
                weakSelf?.model = COINInstrumentItemModel()
                weakSelf?.model?.symbol = weakSelf?.symbol
            }
            instrumentModel?.toInstrumentModel(instrumentModel: (weakSelf?.model)!)
            weakSelf?.updateExchangeHeaderView()
            weakSelf?.contentView?.exchanegView.exchangeHeaderView.leverageTextField.text = "10X"
            
//            weakSelf?.contentView?.exchanegView.exchangeHeaderView.buyCanUseCountLabel.text = positionModel?.data?.first?.currentQty
//            weakSelf?.contentView?.exchanegView.exchangeHeaderView.sellerCanUseCountLabel.text = positionModel?.data?.first?.quoteCurrency
//
//            weakSelf?.positionItem = positionModel?.data?.first
//            weakSelf?.updateMarginUI()
        })
    }
    
    func submitOKEXOrders(_ side: String) {
        
        let headerView = self.contentView?.exchanegView.exchangeHeaderView
        var orderQty: Float = 0
        if (headerView!.coinCountTextField.text?.count)! > 0 {
            orderQty = Float(headerView!.coinCountTextField.text ?? "0.0") ?? 0
        }
        var type = "1"
        if headerView?.selectedType == 0 { //type 1:开多2:开空3:平多4:平空
            if side == "Buy" {
                type = "1"
            } else {
                type = "2"
            }
        } else {
            if side == "Buy" {
                type = "4"
            } else {
                type = "3"
            }
        }
        var leverage = 10
        if (headerView!.leverageTextField.text?.count)! > 1 {
            leverage = Int((headerView!.leverageTextField.text! as NSString).substring(to: headerView!.leverageTextField.text!.count - 1))!
        }
        var parameters = [
            "type" : type,
            "instrument_id" : self.symbol!,
            "size" : orderQty,
            "leverage" : leverage,
            ] as [String : Any]
        switch self.priceType {
            
        case .customPrice:
            parameters["price"] = headerView?.priceTextField.text
            break
        case .marketPrice:
            parameters["match_price"] = "1"
            break
        case .buyFirstPrice:
            let lastPrice        = self.asks.last?.first
            if (lastPrice != nil) {
                parameters["price"] = lastPrice!
            }
            break
        case .sellFirstPrice:
            let firstPrice        = self.bids.first?.first
            if (firstPrice != nil) {
                parameters["price"] = firstPrice!
            }
            break
        }
        
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/futures/v3/order", platform: self.platform, parameters: parameters, method: .post, responseClass: COINOKEXOrderBookItemModel.self, isArray: false, successHandler: { (bookModel) in
            weakSelf?.getMyOKEXNewOrderBook()
        }) { (error) in
            debugPrint(error as Any)
        }
    }
    
    
    func getMyOKEXNewOrderBook() {
        let requestPath = "/api/futures/v3/orders/\(self.symbol ?? "BCH")?status=6"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINOKEXOrderBookModel.self, isArray: false, successHandler: { (response) in
            weakSelf?.contentView?.exchanegView.orderBookModel = response?.toOrderBookModel()
        })
    }
    
    
    func getMyOKEXOrderBook(ordStatus: OrdStatus, symbol: String) {
        var status = 6 //订单状态(-1.撤单成功；0:等待成交 1:部分成交 2:全部成交 6：未完成（等待成交+部分成交）7：已完成（撤单成功+全部成交））
        if ordStatus == OrdStatus.new {
            status = 6
        } else if ordStatus == OrdStatus.canceled {
            status = -1
        } else {
            status = 2
        }
        let requestPath = "/api/futures/v3/orders/\(symbol)?status=\(status)"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINOKEXOrderBookModel.self, isArray: false, successHandler: { (response) in
            weakSelf?.contentView?.orderBookView.orderBookModel = response?.toOrderBookModel()
        })
    }
    
    func getOKEXUserCommision() {
        let requestPath = "/api/v1/user/commission"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINCommisionModel.self, successHandler: { (response) in
            weakSelf?.contentView?.exchanegView.commisionModel = response
            weakSelf?.contentView?.orderBookView.commisionModel = response
        })
    }
    
    func cancelOKEXOrder(orderModel: COINOrderBookItemModel?) {
        if orderModel == nil {
            return
        }
        let requestPath = "/api/futures/v3/cancel_order/\(orderModel!.symbol!)/\(orderModel!.orderID!)"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: ["order_id":orderModel!.orderID!,"instrument_id":orderModel!.symbol!], method: .post, responseClass: COINOKEXOrderBookItemModel.self, isArray: false, successHandler: { (response) in
            if response != nil {
                weakSelf?.getMyOKEXNewOrderBook() //交易页面刷新
                weakSelf?.getMyOKEXOrderBook(ordStatus: OrdStatus.new, symbol: (weakSelf?.contentView?.orderBookView.selectedSymbol)!) //委托界面刷新
            }
        })
    }
    
    func getMyOKEXPosition(symbol: String) {
        weak var weakSelf = self
        if symbol != "全部" {
            let requestPath = "/api/futures/v3/\(symbol)/position"
            COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINOKEXPositionSingleModel.self, isArray: false, successHandler: { (response) in
                weakSelf?.contentView?.positionView.positionModel = response?.toPositionModel()
            })
        } else {
            let requestPath = "/api/futures/v3/position"
            COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINOKEXPositionModel.self, isArray: false, successHandler: { (response) in
                weakSelf?.contentView?.positionView.positionModel = response?.toPositionModel()
            })
        }
    }
    
    func getOKEXOptionalData(getTitle: Bool = false) {
        let requestPath = "/api/futures/v3/instruments/ticker"
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: self.platform, parameters: nil, responseClass: COINInstrumentModel_OK.self, successHandler: { (response) in
            guard var itemArrayTemp: [COINInstrumentItemModel]  = response?.toInstrumentModel() else {
                return
            }
            if getTitle {
                itemArrayTemp.sort(by: { (item1, item2) -> Bool in
                    return item1.rootSymbol != item2.rootSymbol
                })
                var symbolsArr = [String]()
                for (_,item) in itemArrayTemp.enumerated() {
                    symbolsArr.append(item.symbol ?? "BTC")
                }
                symbolsArr.sort(by: { (symbol1, symbol2) -> Bool in
                    return symbol1 < symbol2
                })
                weakSelf?.contentView?.orderBookView.symbolsArr = symbolsArr
                symbolsArr.insert("全部", at: 0)
                weakSelf?.contentView?.positionView.symbolsArr = symbolsArr
            } else {
                let instrument = COINInstrumentModel()
                instrument.data = itemArrayTemp
                weakSelf?.optionalView.optionalModel = instrument
            }
        })
    }
    
    
    /// 获取单个合约信息
    func getAccountSymobl(){
        let requestPath = "/api/futures/v3/accounts/\(self.symbol?.parsingInstrument_Id().rootSymol ?? "")"
        COINNetworkTool.requestOriginal(path: requestPath, platform: .okex, parameters: nil, method: .get) { (respond) in
            guard let respondDict: Dictionary<String,Any> = respond.result.value as? Dictionary<String, Any> else{
                return
            }
            
            let item = COINAccountsItemModel_ok.deserialize(from: respondDict)
            self.accountSymbol_ok = item
            self.updateMarginUI_okex()
        }
    }
    
    
    /// 获取当前position
    func getCurrentPosition_ok(){
        let requestStr = "/api/futures/v3/\(self.symbol ?? "")/position"
        COINNetworkTool.request(path: requestStr, platform: .okex, parameters: nil, method: .get, responseClass: COINOKEXPositionSingleModel.self, isArray: false, successHandler: { (positionModel) in
            let itemModel = positionModel?.holding?.first
            self.positionItemModel_ok = itemModel
            self.updateMarginUI_okex()
        }) { (error) in
            
        }
    }
}
