//
//  TradeBucketViewController.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/12.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit
import Charts

public enum KLineType: Int {
    case MinuteLine = 0
    case FiveMinuteLine   = 1
    case FifteenMinuteLine   = 2
    case ThirtyMinuteLine   = 3
    case HourLine   = 4
    case FourHourLine   = 5
    case DayLine   = 6
    case WeekLine   = 7
    case MonthLine   = 8
}

class COINTradeBucketViewController: COINBaseViewController {
    
    var platform: Platform = .bitmex
    
    var instrument: COINInstrumentItemModel?
    
    var lineData: COINKLineModel?
    
    lazy var lineView: COINTradeBucketView = {
        let view = COINTradeBucketView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - navAndStatusHeight), kLineModel:self.lineData, platform: self.platform)
        weak var weakSelf = self
        view.changeLineTypeHandle = { kLineType in
            weakSelf?.getLineData(kLineType: kLineType)
        }
        view.orderActionHandle = { type in
            let vc: UIViewController = (weakSelf?.navigationController?.viewControllers[(weakSelf?.navigationController?.viewControllers.count)! - 2])!
            if vc.isKind(of: COINOrderManageViewController.self) {
                weakSelf?.navigationController?.popViewController(animated: true)
            } else {
                let orderManegerViewController = COINOrderManageViewController.init(platform: weakSelf!.platform, symbol: weakSelf?.instrument?.symbol ?? "")
                orderManegerViewController.hidesBottomBarWhenPushed = true
                weakSelf?.navigationController?.pushViewController(orderManegerViewController, animated: true)
            }
        }
        return view
    }()
    
    init(instrument: COINInstrumentItemModel?, platform: Platform, needLoadData: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.instrument = instrument
        self.platform = platform
        self.lineView.instrument = self.instrument
        self.view.addSubview(self.lineView)
        if needLoadData {
            self.getInstrumentData(symbol: (instrument?.symbol)!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = whiteColor
        // Do any additional setup after loading the view.
        self.title = self.instrument?.symbol ?? "XBT"
        
        self.addRightItem()
        self.getLineData(kLineType: .MinuteLine)
        self.getTradeHistoryData()
        self.addWS(types: [.market,.trade,.kline])
        self.startSubscribeArray(subscribeTypes: [.market,.trade,.kline])
        guard #available(iOS 11.0, *) else {
            self.automaticallyAdjustsScrollViewInsets = false
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func addRightItem() {
        let collectBtn = UIButton.init(type: .custom)
        collectBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 40)
        collectBtn.setImage(UIImage.init(named: "collection"), for: .normal)
        collectBtn.imageView?.contentMode = .center
        collectBtn.addTarget(self, action: #selector(collectAction(btn:)), for: .touchUpInside)
        
        let objArray = COINUserDefaultsHelper.getObjArray(UserDefaultsHelperKey.collectionsKey, platformType: self.platform)
        for object in objArray {
            let model = object as? Dictionary<String, Any>
            if model?["symbol"] as? String == self.instrument?.symbol {
                collectBtn.setImage(UIImage.init(named: "collection_sel"), for: .normal)
                collectBtn.isSelected = true
                break
            }
        }
        
        let fullScreenBtn = UIButton.init(type: .custom)
        fullScreenBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 40)
        fullScreenBtn.setImage(UIImage.init(named: "trade_fullScreen"), for: .normal)
        fullScreenBtn.imageView?.contentMode = .center
        fullScreenBtn.addTarget(self, action: #selector(fullScreenAction(btn:)), for: .touchUpInside)
        
        let collectItem = UIBarButtonItem.init(customView: collectBtn)
        let fullScreenItem = UIBarButtonItem.init(customView: fullScreenBtn)
        
        self.navigationItem.rightBarButtonItems = [fullScreenItem,collectItem]
    }
    
    @objc func collectAction(btn: UIButton) {
        if btn.isSelected {
            btn.isSelected = false
            var objArray = COINUserDefaultsHelper.getObjArray(UserDefaultsHelperKey.collectionsKey, platformType: self.platform)
            objArray.removeAll(where: { (dict) -> Bool in
                let model = dict as? Dictionary<String, Any>
                let temp: String? = model?["symbol"] as? String
                return self.instrument?.symbol == temp
            })
            btn.setImage(UIImage.init(named: "collection"), for: .normal)
            COINUserDefaultsHelper.saveObj(obj: objArray, userdfalutKay: UserDefaultsHelperKey.collectionsKey, platformType: self.platform)
        } else {
            btn.isSelected = true
            btn.setImage(UIImage.init(named: "collection_sel"), for: .normal)
            self.instrument?.platformValue = self.platform == .bitmex ? 0 : 1
            COINUserDefaultsHelper.saveObjToArray(self.instrument?.toJSON() as Any, UserDefaultsHelperKey.collectionsKey, platformType: self.platform)
        }
    }
    
    @objc func fullScreenAction(btn: UIButton) {
        self.startSubscribeArray(subscribeTypes: [.trade])
        let vc = COINTradeBucketFullScreenViewController.init(platform: self.platform)
        vc.instrument = self.instrument
        if self.lineView.klineType == .MinuteLine {
            vc.kLineModel = self.lineData
        } else {
            vc.kLineModel = nil
        }
        let nav = UINavigationController.init(rootViewController: vc)
        vc.navigationController?.isNavigationBarHidden = true
        self.present(nav, animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    deinit {
        print("COINTradeBucketViewController--deinit")
        NotificationCenter.default.removeObserver(self)
        self.startCancelArray(subscribeTypes: [.trade,.kline])
    }
}
// MARK: ----bitmex websocket----
extension COINTradeBucketViewController {
    override func receiveInstrumentNoti(noti: Notification) {
        let dataArray: Array< Dictionary<String, Any?> > = noti.object as! Array
        let dataDict: [String: Any?] = dataArray.first!
        let instrument = COINBitmexInstrumentItemModel.deserialize(from: dataDict as [String : Any])
        if self.instrument?.symbol == instrument?.symbol {
            if instrument?.lastChangePcnt != nil {
                self.instrument?.lastPcnt = instrument?.lastChangePcnt
            }
            if instrument?.lastPrice != nil {
                self.instrument?.priceValue = instrument?.lastPrice
            }
            if instrument?.indicativeSettlePrice != nil {
                self.instrument?.indicativeSettlePrice = instrument?.indicativeSettlePrice
            }
            if instrument?.prevPrice24h != nil {
                self.instrument?.prevPrice24h = instrument?.prevPrice24h
            }
            self.lineView.instrument = self.instrument
            self.lineView.updateHeader()
        }
    }
    
    override func receiveTradeNoti(noti: Notification) {
        let tradeModel = COINOrderBookModel.deserialize(from: ["data":noti.object as Any])
        if tradeModel?.data != nil {
            for item in  (tradeModel?.data)! {
                self.lineView.tradeHistoryView.tradeHistoryModel?.data?.insert(item, at: 0)
            }
            let arr = self.lineView.tradeHistoryView.tradeHistoryModel?.data
            if arr?.count ?? 0 > 10 {
                self.lineView.tradeHistoryView.tradeHistoryModel?.data = Array(arr![0...10])
            }
            self.lineView.tradeHistoryView.tradeHistoryModel =
                self.lineView.tradeHistoryView.tradeHistoryModel
        }
    }
    
    override func receiveTradeBin1mNoti(noti: Notification) {
        let klineModel = COINKLineModel.deserialize(from: ["data":noti.object as Any])
        if klineModel?.data != nil && self.lineData != nil {
            if self.lineView.klineType == .MinuteLine {
                for item in  (klineModel?.data)! {
                    self.lineData?.data?.append(item)
                }
                if self.lineView.superview != nil {
                    self.lineView.kLineModel = self.lineData
                } else {
                    self.view.addSubview(self.lineView)
                }
            }
        }
    }
}

// MARK: ----okex websocket----
extension COINTradeBucketViewController {
    override func receiveTickerNoti_ok(noti: Notification) {
        if noti.object is [String: Any] {
            let dict: [String: Any] = noti.object as! [String : Any]
            if self.instrument == nil {
                self.instrument = COINInstrumentItemModel()
            }
            if dict["rootSymbol"] != nil && dict["timeStr"] != nil {
                if (self.instrument?.symbol?.lowercased().hasPrefix(dict["rootSymbol"] as! String))! && (self.instrument?.symbol?.hasSuffix(dict["timeStr"] as! String))! {
                    if dict["vol"] != nil {
                        self.instrument?.totalVolume = Float(dict["vol"] as! String)
                    }
                    if dict["high"] != nil {
                        self.instrument?.highPrice = Float(dict["high"] as! String)
                    }
                    if dict["low"] != nil {
                        self.instrument?.lowPrice = Float(dict["low"] as! String)
                    }
                    if dict["last"] != nil {
                        self.instrument?.priceValue = Float(dict["last"] as! String)
                    }
                    if dict["last"] != nil && dict["high"] != nil && dict["low"] != nil {
                        let priceValue: Float  = Float(dict["last"] as! String) ?? 0
                        let high: Float        = Float(dict["high"] as! String) ?? 0
                        let low: Float         = Float(dict["low"] as! String) ?? 0
                        let middle             = (high + low) * 0.5
                        let lastPcnt           = (priceValue - middle) / middle
                        self.instrument?.prevPrice24h = middle
                        self.instrument?.lastPcnt = lastPcnt
                    }
                    self.lineView.instrument = self.instrument
                    self.lineView.updateHeader()
                }
            }
        }
    }
    
    override func receiveTradeNoti_ok(noti: Notification) {
        if noti.object is [[String]] {
            let dataArray: [[String]] = noti.object as! [[String]]
            let tradeModel = COINOKEXTradeModel()
            var data = [COINOKEXOrderBookItemModel]()
            for items in dataArray { //[交易序号, 价格, 成交量(张), 时间, 买卖类型，成交量(币-新增)]
                let model = COINOKEXOrderBookItemModel()
                model.price = items[1]
                model.qty = items[2]
                model.timestamp = items[3]
                model.side = items[4] == "ask" ? "buy" : "sell"
                model.timestamp = items[3]
                data.append(model)
            }
            tradeModel.data = data
            
            for item in (tradeModel.toOrderBookModel().data)! {
                self.lineView.tradeHistoryView.tradeHistoryModel?.data?.insert(item, at: 0)
            }
            let arr = self.lineView.tradeHistoryView.tradeHistoryModel?.data
            if arr?.count ?? 0 > 10 {
                self.lineView.tradeHistoryView.tradeHistoryModel?.data = Array(arr![0...10])
            }
            self.lineView.tradeHistoryView.tradeHistoryModel =
                self.lineView.tradeHistoryView.tradeHistoryModel
        }
    }
    
    override func receiveKlineNoti_ok(noti: Notification) {
        if noti.object is [[String]] {
            let dataArray: [[String]] = noti.object as! [[String]]
            let okexKlineModel = COINOKEXKLineModel.deserialize(from: ["data": dataArray])
            if self.lineView.klineType == .MinuteLine {
                let klineModel = okexKlineModel?.toKLineModel()
                if klineModel?.data != nil && self.lineData != nil {
                    for item in (klineModel?.data)! {
                        if self.lineData?.data?.last?.timestamp == item.timestamp {
                            self.lineData?.data?.removeLast()
                        }
                        self.lineData?.data?.append(item)
                    }
                    if self.lineView.superview != nil {
                        self.lineView.kLineModel = self.lineData
                    } else {
                        self.view.addSubview(self.lineView)
                    }
                }
            }
        }
    }
}
