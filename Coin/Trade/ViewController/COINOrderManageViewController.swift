//
//  OrderManageViewController.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/12.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

class COINOrderManageViewController: COINBaseViewController {
    
    var platform: Platform = .bitmex
    var symbol: String?
    
    var titleView = COINOrderManageTitleView.init(frame: CGRect.init(x: 0, y: 0, width: 180, height: 44), selectedIndex: 0)

    var contentView: COINOrderManageView?
    var confirmOrderView: COINConfirmOrderView?
    var model: COINInstrumentItemModel?
    var positionItem: COINPositionItemModel?
    var marginModel: COINMarginModel?
    
    var accountSymbol_ok: COINAccountsItemModel_ok?
    var positionItemModel_ok: COINOKEXPositionItemModel?
    var priceType: ExchangeHeaderViewPriceType = .customPrice
    var instrumentItem_ok: COINInstrumentItemModel?
    lazy var asks = Array<Array <NSNumber> >()
    lazy var bids = Array<Array <NSNumber> >()
    
    lazy var optionalView: COINOptionalListView = {
        let optionalView = COINOptionalListView.init(frame: CGRect.init(x: -screenWidth, y: 0, width: screenWidth, height: screenHeight - navAndStatusHeight), platform: self.platform)
        weak var weakSelf = self
        optionalView.changeTypeHandle = { type in
            weakSelf?.getOptionalData(type: type)
        }
        optionalView.selectedSymbolHandle = { symbolModel in
            if symbolModel.symbol == weakSelf?.model?.symbol {
                return
            }
            weakSelf?.startCancelArray(subscribeTypes: [.market,.depth])
            weakSelf?.symbol = symbolModel.symbol
            weakSelf?.model = symbolModel
            weakSelf?.contentView?.exchanegView.exchangeHeaderView.instrumentModel = weakSelf?.model
            weakSelf?.updateExchangeHeaderView()
            weakSelf?.startNetWork()
            weakSelf?.startSubscribeArray(subscribeTypes: [.market,.depth])
        }
        return optionalView
    }()
    
    init(platform: Platform, symbol: String) {
        super.init(nibName: nil, bundle: nil)
        self.platform = platform
        self.symbol = symbol
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = whiteColor
        // Do any additional setup after loading the view.
        self.navigationItem.titleView = self.titleView
        
        weak var weakSelf = self
        self.titleView.changeIndexHandle = { index in
            weakSelf?.contentView!.selectedIndex = index
            weakSelf?.changeIndex(index: index)
        }
       
        self.contentView = COINOrderManageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - navAndStatusHeight), selectedIndex: 0, platform: self.platform)
        self.contentView?.orderBookView.selectedSymbol = self.symbol
        self.view.addSubview(self.contentView!)
        self.contentView!.changeIndexHandle = { index in
            weakSelf?.titleView.selectedIndex = index
            weakSelf?.changeIndex(index: index)
        }
        self.contentView?.cancelHandle = { orderModel in
            weakSelf?.cancelOrder(orderModel: orderModel)
        }
        self.contentView?.changeOrderIndexHandle = { index in
            weakSelf?.changeIndex(index: 1)
        }
        self.contentView?.orderBookView.changeSymbolHandle = { symbol in
            weakSelf?.contentView?.orderBookView.selectedSymbol = symbol
            weakSelf?.changeIndex(index: 1)
        }
        self.contentView?.positionView.changeSymbolHandle = { symbol in
            weakSelf?.getMyPosition(symbol: symbol)
            weakSelf?.getMargin()
        }
        self.contentView?.exchanegView.exchangeHeaderView.selectOptionalHandle = {
            weakSelf?.contentView?.scrollView.addSubview((weakSelf?.optionalView)!)
            weakSelf?.getOptionalData(type: 0)
            UIView.animate(withDuration: 0.3, animations: {
                weakSelf?.optionalView.frame = CGRect.init(x: 0, y: (weakSelf?.optionalView.frame.origin.y)!, width: (weakSelf?.optionalView.frame.size.width)!, height: (weakSelf?.optionalView.frame.size.height)!)
            })
        }
        
        addHeaderViewHandel()
        updateExchangeHeaderView()
        startNetWork()
        self.addWS(types: [.market,.depth])
        if self.platform == .okex { //获取标题
            self.getOKEXOptionalData(getTitle: true)
        }
        guard #available(iOS 11.0, *) else {
            self.automaticallyAdjustsScrollViewInsets = false
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.startSubscribeArray(subscribeTypes: [.market,.depth])
    }
    
    func changeIndex(index: Int) {
        self.view.endEditing(true)
        if index == 2 {
            self.getMyPosition(symbol: (self.contentView?.positionView.selectedSymbol)!)
        } else if index == 1 {
            var ordStatus = OrdStatus.new
            switch self.contentView?.orderBookView.selectedIndex {
            case 0:
                ordStatus = .new
            case 1:
                ordStatus = .filled
            case 2:
                ordStatus = .canceled
            default:
                break
            }
            self.getMyOrderBook(ordStatus: ordStatus)
        } else if index == 0 {
            startNetWork()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.startCancelArray(subscribeTypes: [.market,.depth])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - 处理webSocket部分
extension COINOrderManageViewController {
        
    @objc override func receiveOderBook10Noti(noti: Notification){
        let dataArray: Array< Dictionary<String, Any?> > = noti.object as! Array
        let dataDict: [String: Any?] = dataArray.first!
        var tempArray = Array<COINOrderBookItemModel>()
        var asks: Array<Array<NSNumber>> = dataDict["asks"] as! Array
        self.asks = asks
        //补充asks数据到到10个
        for index in 0...(10 - asks.count) {
            if index != 0 {
                asks.append([(0),(-1)])
            }
        }
        
        var bids: Array<Array<NSNumber>> = dataDict["bids"] as! Array
        self.bids = bids
        //补充bids数据到到10个
        for index in 0...(10 - bids.count) {
            if index != 0 {
                bids.append([(0),(-1)])
            }
        }
        
        let zeroValue: Float = 0.0
        for askNum in 0...4{
            let model = COINOrderBookItemModel()
            let array = asks[askNum]
            if array.last!.floatValue < zeroValue {
                model.size = "--"
                model.price = "--"
            }else{
                model.size = "\(array.last!)"
                model.price = "\(array.first!.floatValue.turnPriceStr())"
            }
            
            model.side = "Buy"
            model.currency = self.model?.quoteCurrency
            model.lastPrice = self.model?.priceValue?.turnPriceStr()
            model.indicativeSettlePrice = self.model?.indicativeSettlePrice?.turnPriceStr()
            tempArray.insert(model, at: 0)
        }
        
        for bidNum in 0...4 {
            let model = COINOrderBookItemModel()
            let array = bids[bidNum]
            if (array.last?.floatValue)! < zeroValue {
                model.size = "--"
                model.price = "--"
            }else{
                model.size = "\(array.last!)"
                model.price = "\(array.first!.floatValue.turnPriceStr())"
            }
            
            model.side = "Sell"
            model.currency = self.model?.quoteCurrency
            model.indicativeSettlePrice = self.model?.priceValue?.turnPriceStr()
            model.lastPrice = self.model?.indicativeSettlePrice?.turnPriceStr()
            tempArray.append(model)
        }
        
        let booksModel  = COINOrderBookModel()
        booksModel.data = tempArray
 self.contentView?.exchanegView.exchangeHeaderView.platformOrderBookModel = booksModel
    }
    
    @objc override func receiveInstrumentNoti(noti: Notification){
        let dataArray: Array< Dictionary<String, Any?> > = noti.object as! Array
        let dataDict: [String: Any?] = dataArray.first!
        let symbol: String = dataDict["symbol"] as! String
        if self.model?.symbol == symbol {
            if dataDict.keys.contains("lastChangePcnt"){
                let num = dataDict["lastChangePcnt"] as! NSNumber
                self.model?.lastPcnt = num.floatValue
            }
            
            if dataDict.keys.contains("lastPrice"){
                 let num = dataDict["lastPrice"] as! NSNumber
                 self.model?.priceValue = num.floatValue
            }
            
            if dataDict.keys.contains("indicativeSettlePrice"){
                let num = dataDict["indicativeSettlePrice"] as! NSNumber
                self.model?.indicativeSettlePrice = num.floatValue
            }
            
            if dataDict.keys.contains("prevPrice24h"){
                let num = dataDict["prevPrice24h"] as! NSNumber
                self.model?.prevPrice24h   = num.floatValue
            }
            
            updateExchangeHeaderView()
        }
    }
    
    @objc override func receiveTickerNoti_ok(noti: Notification) {
        if noti.object is [String: Any] {
            let dict: [String: Any] = noti.object as! [String : Any]
            if (self.model == nil) {
                return
            }
            
            if dict["rootSymbol"] != nil && dict["timeStr"] != nil {
                if (self.model?.symbol?.lowercased().hasPrefix(dict["rootSymbol"] as! String))! && (self.model?.symbol?.hasSuffix(dict["timeStr"] as! String))! {
                    if dict["vol"] != nil {
                        self.model?.totalVolume = Float(dict["vol"] as! String)
                    }
                    
                    if dict["high"] != nil {
                        self.model?.highPrice = Float(dict["high"] as! String)
                    }
                    
                    if dict["low"] != nil {
                        self.model?.lowPrice = Float(dict["low"] as! String)
                    }
                    
                    if dict["last"] != nil {
                        self.model?.priceValue = Float(dict["last"] as! String)
                    }
                    
                    if dict["last"] != nil && dict["high"] != nil && dict["low"] != nil {
                        let priceValue: Float  = Float(dict["last"] as! String) ?? 0
                        let high: Float        = Float(dict["high"] as! String) ?? 0
                        let low: Float         = Float(dict["low"] as! String) ?? 0
                        let middle             = (high + low) * 0.5
                        let lastPcnt           = (priceValue - middle) / middle
                        self.model?.prevPrice24h = middle
                        self.model?.lastPcnt = lastPcnt
                    }
                    
                    updateExchangeHeaderView()
                }
            }
        }
    }
    
    @objc override func receiveDepthNoti_ok(noti: Notification) {
        let dict: [String: Any] = noti.object as! [String : Any]
        let asks: Array<Array<NSNumber>> = dict["asks"] as! Array
        let bids: Array<Array<NSNumber>> = dict["bids"] as! Array
        var tempArray = [COINOrderBookItemModel]()
        self.asks = asks
        for ask in asks {
            let model  = COINOrderBookItemModel()
            model.price = String.init(format: "%@", ask.first ?? "--")
            model.size  = String.init(format: "%@", ask[1])
            model.side  = "Buy"
            tempArray.append(model)
        }
        
        self.bids = bids
        for bid in bids {
            let model  = COINOrderBookItemModel()
            model.price = String.init(format: "%@", bid.first ?? "--")
            model.size  = String.init(format: "%@", bid[1])
            model.side  = "Sell"
            tempArray.append(model)
        }
        
        let booksModel  = COINOrderBookModel()
        booksModel.data = tempArray
        self.contentView?.exchanegView.exchangeHeaderView.platformOrderBookModel = booksModel
    }
}


// MARK: - 头部view更新值
extension COINOrderManageViewController {
    
    func addHeaderViewHandel(){

        let exchangeHeaderView = self.contentView?.exchanegView.exchangeHeaderView
        weak var weakSelf = self
        // 交易按钮点击
        exchangeHeaderView!.callBack = { event in
            weakSelf?.orderBtnClick(event)
        }
        
        // 交易价格类型点击
        exchangeHeaderView!.priceTypeCallback = { priceType in
            weakSelf?.priceType = priceType
            switch priceType {
            case .customPrice:
                exchangeHeaderView?.priceTextField.text = weakSelf?.model?.priceValue?.turnPriceStr()
                exchangeHeaderView?.priceTextField.isUserInteractionEnabled = true
                break
            case .marketPrice:
                exchangeHeaderView?.priceTextField.text = "市场价"
                exchangeHeaderView?.priceTextField.isUserInteractionEnabled = false
                break
            case .buyFirstPrice:
                exchangeHeaderView?.priceTextField.text = "买一价"
                exchangeHeaderView?.priceTextField.isUserInteractionEnabled = false
                break
            case .sellFirstPrice:
                exchangeHeaderView?.priceTextField.text = "卖一价"
                exchangeHeaderView?.priceTextField.isUserInteractionEnabled = false
                break
            }
        }
        // 平仓还是开仓
        exchangeHeaderView?.positionCallBack = { isOpenPosition in
            weakSelf?.updateMarginUI()
        }
        
        exchangeHeaderView?.changeLeverageHandle = { string in
            weakSelf?.changeLeverage(leverage: string)
            weakSelf?.updateMarginUI()
        }
        
        exchangeHeaderView?.pricePcntBtn.addTarget(self, action: #selector(gotoKLine), for: .touchUpInside)
    }
    
    @objc func gotoKLine() {
        let vc = COINTradeBucketViewController.init(instrument: self.model, platform: self.platform)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateMarginUI(){
        if self.platform == .okex{
            updateMarginUI_okex()
            return
        }
        
        if (self.positionItem?.leverage == nil) || (self.marginModel == nil) {
            return
        }
        
        let exchangeHeaderView = self.contentView?.exchanegView.exchangeHeaderView
        
        if exchangeHeaderView?.selectedType == 0 {
            
            let canUseStr = self.marginModel?.availableMargin?.fourDecimalPlacesWithUnits()
            let canOpenMoreStr = ((self.marginModel?.availableMargin)! * Float((self.positionItem?.leverage)!)!).fourDecimalPlacesWithUnits()
            
            exchangeHeaderView?.buyCanUseCountLabel.text       = canUseStr
            exchangeHeaderView?.canOpenMoreCountLabel.text     = canOpenMoreStr
            exchangeHeaderView?.sellerOpenMoreCountLabel.text  = canOpenMoreStr
            exchangeHeaderView?.sellerCanUseCountLabel.text    = canUseStr
        } else {
            let zeroQty            = positionQtyAddingUnit(0)
            let positionQty: Float = Float(self.positionItem?.currentQty ?? "0.0")!
            let canOpenMoreStr     = positionQtyAddingUnit(positionQty)
            if positionQty <= 0 {
                let buyQty: Float  = Float(self.positionItem?.openOrderBuyQty ?? "0.0")!
                let buyQtyStr      = positionQtyAddingUnit(fabsf(positionQty) - fabsf(buyQty))
                exchangeHeaderView?.buyCanUseCountLabel.text       = buyQtyStr
                exchangeHeaderView?.sellerCanUseCountLabel.text    = zeroQty
                exchangeHeaderView?.canOpenMoreCountLabel.text     = canOpenMoreStr
                exchangeHeaderView?.sellerOpenMoreCountLabel.text  = zeroQty
            }else{
                let sellQty: Float  = Float(self.positionItem?.openOrderSellQty ?? "0.0")!
                let sellQtyStr         = positionQtyAddingUnit(fabsf(positionQty) - fabsf(sellQty))
                exchangeHeaderView?.buyCanUseCountLabel.text       =  zeroQty
                exchangeHeaderView?.sellerCanUseCountLabel.text    =  sellQtyStr
                exchangeHeaderView?.canOpenMoreCountLabel.text     =  zeroQty
                exchangeHeaderView?.sellerOpenMoreCountLabel.text  = canOpenMoreStr
            }
        }
    }
    
    
    /// 更新ok交易可用可开多等数据
    func updateMarginUI_okex(){
        let exchangeHeaderView = self.contentView?.exchanegView.exchangeHeaderView
        var rootSymbol: String = self.symbol?.parsingInstrument_Id().rootSymol ?? ""
        rootSymbol             = rootSymbol.uppercased()
        if exchangeHeaderView?.selectedType == 0 {
            if self.accountSymbol_ok == nil {
                return
            }
            
            let leverageStr = exchangeHeaderView?.leverageTextField.text?.replacingOccurrences(of: "X", with: "")
            var total_avail_balance: Float = self.accountSymbol_ok?.total_avail_balance ?? 0
            if self.accountSymbol_ok?.margin_mode == "fixed" {
                total_avail_balance = self.accountSymbol_ok?.contracts?.first?.available_qty ?? 0
            }
            
            let leverage: Float    = Float(leverageStr ?? "1") ?? 1
            let openMore =  total_avail_balance * leverage
            let openMoreStr = "\(openMore)"            + rootSymbol
            let canUseStr   = "\(total_avail_balance)" + rootSymbol
            exchangeHeaderView?.buyCanUseCountLabel.text       = canUseStr
            exchangeHeaderView?.sellerCanUseCountLabel.text    = canUseStr
            exchangeHeaderView?.canOpenMoreCountLabel.text     = openMoreStr
            exchangeHeaderView?.sellerOpenMoreCountLabel.text  = openMoreStr
        }else{
            let long_qty: Float        = Float(self.positionItemModel_ok?.long_qty ?? 0)
            let long_avail_qty: Float  = Float(self.positionItemModel_ok?.long_avail_qty ?? 0)
            let short_qty: Float       = Float(self.positionItemModel_ok?.short_qty ?? 0)
            let short_avail_qty: Float = Float(self.positionItemModel_ok?.short_avail_qty ?? 0)
            let sellCanUseStr    = "\(long_qty)" + "张"
            let sellOpenMoreStr  = "\(long_avail_qty)" + "张"
            let buyCanUseStr     = "\(short_qty )" + "张"
            let buyOpenMoreStr   = "\(short_avail_qty)" + "张"
            exchangeHeaderView?.buyCanUseCountLabel.text       = buyCanUseStr
            exchangeHeaderView?.sellerCanUseCountLabel.text    = sellCanUseStr
            exchangeHeaderView?.canOpenMoreCountLabel.text     =  buyOpenMoreStr
            exchangeHeaderView?.sellerOpenMoreCountLabel.text  =  sellOpenMoreStr
        }
    }
    
    func positionQtyAddingUnit(_ positionQty: Float) -> String{
        return String.init(format: "%.4f(%@)", fabsf(positionQty),"张")
    }
    
    func updateExchangeHeaderView(){
        if self.model == nil {
            return
        }
        let headerView = self.contentView?.exchanegView.exchangeHeaderView
        
        if !(headerView?.priceTextField.isEditing)!
            && !(headerView?.coinCountTextField.isEditing)!
            && (headerView?.priceTextField.isUserInteractionEnabled)! && (headerView!.priceTextField.text == nil || headerView!.priceTextField.text?.count == 0) {
            headerView!.priceTextField.text = self.model?.priceValue?.turnPriceStr()
        }
        headerView?.lastPriceLabel?.text = self.model?.priceValue?.turnPriceStr()
        headerView!.priceLabel.text = self.model?.priceValue?.turnPriceStr()
        if self.model?.lastPcnt != nil {
            headerView?.priceLabel.isGreen = (self.model?.lastPcnt)! >= 0
        }
        if self.model?.priceValue != nil && self.model?.prevPrice24h != nil {
            headerView?.priceDifferenceLabel.text = ((self.model?.priceValue)! - (self.model?.prevPrice24h)!).turnPriceStr()
        }
        
        headerView!.pricePcntBtn.setTitle(self.model?.lastPcnt?.lastPecnStr(), for: .normal)
        if Float(self.model?.lastPcnt ?? 0) > 0 {
            headerView!.pricePcntBtn.backgroundColor = COINUseHabitHelper.shared().bgRiseColor
        } else {
            headerView!.pricePcntBtn.backgroundColor = COINUseHabitHelper.shared().bgDropColor
        }
        
        headerView!.nameLabel.attributedText = self.model?.getAttrTitle(platform: self.platform)
        headerView?.leftLabel.text = "价格(\(self.model?.quoteCurrency ?? "USD"))"
        headerView?.coinCountTextFieldLeftLabel.text = "数量(张)"
    }
    
    func orderBtnClick(_ event: ExchangeHeaderViewEvent) {
        if self.contentView?.exchanegView.exchangeHeaderView.coinCountTextField.text?.count ?? 0 == 0 {
            self.view.makeToast("请输入数量", duration: 2, position: .center)
            return
        }
        if self.contentView?.exchanegView.exchangeHeaderView.priceTextField.text?.count ?? 0 == 0 {
            self.view.makeToast("请输入价格", duration: 2, position: .center)
            return
        }
        if !COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.tradeSureKey) {
            let btn = UIButton()
            btn.tag = event.rawValue
            self.finishBtnClick(btn: btn)
            return
        }
        let view = COINConfirmOrderView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        UIApplication.shared.keyWindow!.addSubview(view)
        self.confirmOrderView = view
        view.finishBtn.tag = event.rawValue
        view.finishBtn.addTarget(self, action: #selector(finishBtnClick(btn:)), for: .touchUpInside)
        
        let headerView = self.contentView?.exchanegView.exchangeHeaderView
        var price = headerView?.priceTextField.text
        switch self.priceType {
        case .customPrice:
            break
        case .marketPrice:
            price = "市场价"
            view.typeLabel.text = "市价"
            break
        case .buyFirstPrice:
            let lastPrice = self.asks.last?.first
            if (lastPrice != nil) {
                price = lastPrice!.stringValue
            }
            break
        case .sellFirstPrice:
            let firstPrice = self.bids.first?.first
            if (firstPrice != nil) {
                price = firstPrice!.stringValue
            }
            break
        }
        
        let nameAttr = self.model?.getAttrTitle(platform: self.platform)
        nameAttr?.append(NSAttributedString.init(string: "  \((self.contentView?.exchanegView.exchangeHeaderView.leverageTextField.text)!)", attributes: [NSAttributedString.Key.font : font12, NSAttributedString.Key.foregroundColor: titleBlueColor_Light]))
        nameAttr?.addAttribute(NSAttributedString.Key.foregroundColor, value: titleBlueColor_Light, range: NSRange.init(location: 0, length: nameAttr!.length))
        view.nameLabel.attributedText  = nameAttr
        view.titleLabel.text = "委托价(\((self.model?.quoteCurrency!)!.uppercased()))"
        
        var color: UIColor?
        let percentageColor = COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.percentageColor)
        if event == .openPositionsBuy || event == .closePositionBuy {
            color = COINUseHabitHelper.shared().bgRiseColor
            view.modeLabel.textColor = COINUseHabitHelper.shared().bgRiseColor
            if event == .openPositionsBuy {
                view.modeLabel.text = "买入开多"
            } else {
                view.modeLabel.text = "买入平空"
            }
            if percentageColor {
                view.roundView.image = UIImage(named: "trade_round_red")
            } else {
                view.roundView.image = UIImage(named: "trade_round_green")
            }
        } else {
            color = COINUseHabitHelper.shared().bgDropColor
            view.modeLabel.textColor = COINUseHabitHelper.shared().bgDropColor
            if event == .openPositionsSell {
                view.modeLabel.text = "卖出开空"
            } else {
                view.modeLabel.text = "卖出平多"
            }
            if percentageColor {
                view.roundView.image = UIImage(named: "trade_round_green")
            } else {
                view.roundView.image = UIImage(named: "trade_round_red")
            }
        }
        
        let priceAttr = NSMutableAttributedString.init()
        priceAttr.append(NSAttributedString.init(string: price!, attributes: [NSAttributedString.Key.font : fontBold20, NSAttributedString.Key.foregroundColor: color!]))
        priceAttr.append(NSAttributedString.init(string: " x\((self.contentView?.exchanegView.exchangeHeaderView.coinCountTextField.text)!)", attributes: [NSAttributedString.Key.font : font10, NSAttributedString.Key.foregroundColor: color!]))
        view.priceLabel.attributedText = priceAttr
        
        
        view.showView()
    }
    
    @objc func finishBtnClick(btn: UIButton) {
        if COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.tradeSureKey) {
            self.confirmOrderView?.hideView()
        }
        
        if btn.tag % 2 == 0 {
            submitOrders("Buy")
        }else{
            submitOrders("Sell")
        }
    }
}

