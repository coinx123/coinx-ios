//
//  COINTradeBucketFullScreenViewController.swift
//  Coin
//
//  Created by dev6 on 2018/11/24.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINTradeBucketFullScreenViewController: COINBaseViewController {

    var platform: Platform = .bitmex
    
    var kLineModel: COINKLineModel?{
        get{
            return _kLineModel
        }
        set{
            _kLineModel = newValue
            if newValue != nil {
                self.setContent()
            } else {
                self.getLineData(kLineType: self.klineType)
            }
        }
    }
    private var _kLineModel: COINKLineModel?
    
    var changeLineTypeHandle: ((KLineType) -> ())?
    
    var instrument: COINInstrumentItemModel?
    
    lazy var topPriceView: UIView = {
        let topPriceView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenHeight, height: 40))
        topPriceView.backgroundColor = whiteColor
        topPriceView.addSubview(self.titleLabel)
        topPriceView.addSubview(self.priceLabel)
        topPriceView.addSubview(self.pricePcntLabel)
        topPriceView.addSubview(self.dayPriceLabel)
        self.titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(15)
            make.top.equalTo(8)
        })
        self.priceLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.titleLabel.snp.right).offset(15)
            make.top.equalTo(8)
        })
        self.pricePcntLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.titleLabel.snp.right).offset(15)
            make.top.equalTo(self.priceLabel.snp.bottom).offset(2)
        })
        self.dayPriceLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.priceLabel.snp.right).offset(15)
            make.top.equalTo(8)
        })
        
        topPriceView.addSubview(self.closeBtn)
        self.closeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        return topPriceView
    }()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = titleGreenColor
        titleLabel.font = font16
        return titleLabel
    }()
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.textColor = titleGreenColor
        priceLabel.font = font16
        return priceLabel
    }()
    lazy var pricePcntLabel: UILabel = {
        let pricePcntLabel = UILabel()
        pricePcntLabel.textColor = titleGreenColor
        pricePcntLabel.font = font12
        return pricePcntLabel
    }()
    lazy var dayPriceLabel: UILabel = {
        let dayPriceLabel = UILabel()
        dayPriceLabel.numberOfLines = 2
        dayPriceLabel.textColor = titleGrayColor
        dayPriceLabel.font = font12
        return dayPriceLabel
    }()
    
    lazy var closeBtn: UIButton = {
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.setImage(UIImage.init(named: "trade_fullScreen"), for: .normal)
        closeBtn.imageView?.contentMode = .center
        closeBtn.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return closeBtn
    }()
    
    lazy var kLineView: COINKLineView = {
        let kLineView = COINKLineView()
        kLineView.clipsToBounds = true
        kLineView.viewWidth = screenHeight
        kLineView.backgroundColor = whiteColor
        return kLineView
    }()
    
    lazy var lineTypeSelectionView: UIView = {
        let lineTypeSelectionView = UIView()
        lineTypeSelectionView.backgroundColor = whiteColor
        let width = screenHeight/7
        for var i in 0..<7 {
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect.init(x: CGFloat(i) * width, y: 0, width: width, height: 38)
            btn.setTitle(self.timeArray[i], for: .normal)
            btn.titleLabel?.font = font12
            if i == self.selectedType {
                btn.setTitleColor(titleBlueColor, for: .normal)
                self.selectedLine.frame = CGRect.init(x: btn.center.x - self.selectedLine.frame.size.width/2, y: self.selectedLine.frame.origin.y, width: self.selectedLine.frame.size.width, height: self.selectedLine.frame.size.height)
            } else {
                btn.setTitleColor(titleGrayColor, for: .normal)
            }
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(changeType(btn:)), for: .touchUpInside)
            if i >= 5 {
                btn.setImage(UIImage.init(named: "trade_more"), for: .normal)
                btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -width*0.4, bottom: 0, right: 0)
                btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: width*0.8, bottom: -6, right: 0)
            }
            lineTypeSelectionView.addSubview(btn)
        }
        let line = UIView.init(frame: CGRect.init(x: 0, y: 37, width: screenHeight, height: 1))
        line.backgroundColor = lineGrayColor
        lineTypeSelectionView.addSubview(line)
        lineTypeSelectionView.addSubview(self.selectedLine)
        return lineTypeSelectionView
    }()
    
    lazy var selectedLine: UIView = {
        let selectedLine = UIView.init(frame: CGRect.init(x: 0, y: 36, width: 12, height: 2))
        selectedLine.backgroundColor = lineBlueColor
        return selectedLine
    }()
    
    let timeArray: [String] = ["分时","5分钟","1小时","4小时","日线","更多","指标"]
    let moreTimeArray: [String] = ["15分钟","30分钟","周线","月线"]
    let indicatorArray: [[String]] = [["主图","MA","BOLL"],["副图","成交量","MACD","KDJ","RSI"]]
    //    let timeArray: [String] = ["分时","5分钟","1小时","4小时","日线","更多","指标"]
    var selectedType = 0 //0.分时 1.5分钟 2.1小时 3.4小时 4.日线 5.15分钟 6.30分钟 7.周线 8.月线
    var selectedMainType = 1 //1.MA 2.BOLL
    var selectedAuxiliaryType = 1 //1.成交量 2.MACD 3.KDJ 4.RSI
    var klineType: KLineType = .MinuteLine
    
    lazy var moreView: UIView = {
        let moreView = UIView.init(frame: CGRect.init(x: 0, y: -38, width: screenHeight, height: 38))
        moreView.backgroundColor = bgColor
        let width = screenHeight/7
        for var i in 0..<self.moreTimeArray.count {
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect.init(x: CGFloat(i) * width, y: 0, width: width, height: 38)
            btn.setTitle(self.moreTimeArray[i], for: .normal)
            btn.titleLabel?.font = font12
            if i+5 == self.selectedType {
                btn.setTitleColor(titleBlueColor, for: .normal)
            } else {
                btn.setTitleColor(titleGrayColor, for: .normal)
            }
            btn.tag = 105 + i
            btn.addTarget(self, action: #selector(changeTypeMore(btn:)), for: .touchUpInside)
            moreView.addSubview(btn)
        }
        return moreView
    }()
    
    lazy var indicatorView: UIView = {
        let indicatorView = UIView.init(frame: CGRect.init(x: 0, y: -70, width: screenHeight, height: 70))
        indicatorView.backgroundColor = bgColor
        let width = screenHeight/7
        let height: CGFloat = indicatorView.frame.size.height/2
        for i in 0..<self.indicatorArray.count {
            let subArray: [String] = self.indicatorArray[i]
            for j in 0..<subArray.count {
                let btn = UIButton.init(type: .custom)
                btn.frame = CGRect.init(x: CGFloat(j) * width, y: CGFloat(i) * height, width: width, height: height)
                btn.setTitle(subArray[j], for: .normal)
                btn.titleLabel?.font = font12
                if j == 0 {
                    btn.isUserInteractionEnabled = false
                }
                if i == 0 {
                    if j == self.selectedMainType {
                        btn.setTitleColor(titleBlueColor, for: .normal)
                    } else {
                        btn.setTitleColor(titleGrayColor, for: .normal)
                    }
                } else {
                    if j == self.selectedAuxiliaryType {
                        btn.setTitleColor(titleBlueColor, for: .normal)
                    } else {
                        btn.setTitleColor(titleGrayColor, for: .normal)
                    }
                }
                btn.tag = i*100 + j
                btn.addTarget(self, action: #selector(changeLineType(btn:)), for: .touchUpInside)
                indicatorView.addSubview(btn)
            }
        }
        return indicatorView
    }()
    
    init(platform: Platform) {
        super.init(nibName: nil, bundle: nil)
        self.platform = platform
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = whiteColor
        self.view.addSubview(self.topPriceView)
        self.view.addSubview(self.kLineView)
        self.kLineView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(80)
            make.bottom.equalTo(0)
        }
        
        self.view.addSubview(self.lineTypeSelectionView)
        self.lineTypeSelectionView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(42)
            make.left.equalTo(0)
            make.height.equalTo(38)
        }
        self.addWS(types: [.market,.kline])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.allowRotate = 1
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.allowRotate = 0
        // 这句很重要
        let unknownValue = UIInterfaceOrientation.unknown.rawValue
        UIDevice.current.setValue(unknownValue, forKey: "orientation")
        
        // 将视图还原成竖屏
        let orientationTarget = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
    }
    
    // 是否支持自转 看具体需求
    override var shouldAutorotate: Bool {
        return false
    }
    
    // 设置横屏方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // 横屏
        return .landscapeLeft
    }
    
    func setContent() {
        self.updateHeader()
        self.kLineView.setContent(kLineModel: _kLineModel , kLineType: self.klineType , selectedMainType: self.selectedMainType , selectedAuxiliaryType: self.selectedAuxiliaryType)
    }
    
    func updateHeader() {
        self.titleLabel.text = self.instrument?.symbol
        self.priceLabel.text = self.instrument?.priceValue?.turnPriceStr()
        self.pricePcntLabel.text = self.instrument?.lastPcnt?.lastPecnStr() ?? "0%"
        
        let attr = NSMutableAttributedString.init(string: "高\(self.instrument?.highPrice ?? 0.0)\n低\(self.instrument?.lowPrice ?? 0.0)")
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 6
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
        self.dayPriceLabel.attributedText = attr
        
        if self.instrument?.lastPcnt ?? 0.0 > 0.0 {
            self.priceLabel.textColor = COINUseHabitHelper.shared().titleRiseColor
            self.pricePcntLabel.textColor = COINUseHabitHelper.shared().titleRiseColor
        } else {
            self.priceLabel.textColor = COINUseHabitHelper.shared().titleDropColor
            self.pricePcntLabel.textColor = COINUseHabitHelper.shared().titleDropColor
        }
    }
    
    @objc func dismissController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func changeTypeMore(btn: UIButton) {
        let btnMore: UIButton = self.lineTypeSelectionView.viewWithTag(100 + 5) as! UIButton
        btnMore.backgroundColor = whiteColor
        btnMore.setTitle(btn.titleLabel?.text, for: .normal)
        self.removeView(view: self.moreView)
        if self.selectedType < 5 {
            let btnOld: UIButton = self.lineTypeSelectionView.viewWithTag(100 + self.selectedType) as! UIButton
            btnOld.setTitleColor(titleGrayColor, for: .normal)
        } else {
            let btnOld: UIButton = self.moreView.viewWithTag(100 + self.selectedType) as! UIButton
            btnOld.setTitleColor(titleGrayColor, for: .normal)
        }
        self.selectedType = btn.tag - 100
        btn.setTitleColor(titleBlueColor, for: .normal)
        UIView.animate(withDuration: 0.2) {
            self.selectedLine.frame = CGRect.init(x: btnMore.center.x - self.selectedLine.frame.size.width/2, y: self.selectedLine.frame.origin.y, width: self.selectedLine.frame.size.width, height: self.selectedLine.frame.size.height)
        }
        self.changeLineAction(index: self.selectedType)
    }
    
    @objc func changeLineType(btn: UIButton) {
        let btnIndicator: UIButton = self.lineTypeSelectionView.viewWithTag(100 + 6) as! UIButton
        btnIndicator.backgroundColor = whiteColor
        self.removeView(view: self.indicatorView)
        let btnOld: UIButton?
        if btn.tag > 100 {
            btnOld = self.indicatorView.viewWithTag(self.selectedAuxiliaryType + 100) as? UIButton
            self.selectedAuxiliaryType = btn.tag - 100
        } else {
            btnOld = self.indicatorView.viewWithTag(self.selectedMainType) as? UIButton
            self.selectedMainType = btn.tag
        }
        btnOld?.setTitleColor(titleGrayColor, for: .normal)
        btn.setTitleColor(titleBlueColor, for: .normal)
        self.setContent()
    }
    
    @objc func changeType(btn: UIButton) {
        if self.selectedType < 5 && self.selectedType == btn.tag - 100 {
            return
        }
        let btnMore: UIButton = btn.superview?.viewWithTag(100 + 5) as! UIButton
        let btnIndicator: UIButton = btn.superview?.viewWithTag(100 + 6) as! UIButton
        if btn != btnMore {
            btnMore.backgroundColor = whiteColor
            self.removeView(view: self.moreView)
        }
        if btn != btnIndicator  {
            btnIndicator.backgroundColor = whiteColor
            self.removeView(view: self.indicatorView)
        }
        if  btn.tag - 100 >= 5 {
            if btn.backgroundColor == bgColor {
                btn.backgroundColor = whiteColor
            } else {
                btn.backgroundColor = bgColor
            }
            if btn.tag - 100 == 5 { //更多
                if self.moreView.superview != nil {
                    self.removeView(view: self.moreView)
                } else {
                    self.kLineView.addSubview(self.moreView)
                    UIView.animate(withDuration: 0.2) {
                        self.moreView.frame = CGRect.init(x: 0, y: 0, width: self.moreView.frame.size.width, height: self.moreView.frame.size.height)
                    }
                }
            } else { //指标
                if self.indicatorView.superview != nil {
                    self.removeView(view: self.indicatorView)
                } else {
                    self.kLineView.addSubview(self.indicatorView)
                    UIView.animate(withDuration: 0.2) {
                        self.indicatorView.frame = CGRect.init(x: 0, y: 0, width: self.moreView.frame.size.width, height: self.indicatorView.frame.size.height)
                    }
                }
            }
        } else {
            btnMore.setTitle(timeArray[5], for: .normal)
            if self.selectedType < 5 {
                let btnOld: UIButton = btn.superview?.viewWithTag(100 + self.selectedType) as! UIButton
                btnOld.setTitleColor(titleGrayColor, for: .normal)
            } else {
                let btnOld: UIButton = self.moreView.viewWithTag(100 + self.selectedType) as! UIButton
                btnOld.setTitleColor(titleGrayColor, for: .normal)
            }
            btn.setTitleColor(titleBlueColor, for: .normal)
            self.selectedType = btn.tag - 100
            self.changeLineAction(index: self.selectedType)
            UIView.animate(withDuration: 0.2) {
                self.selectedLine.frame = CGRect.init(x: btn.center.x - self.selectedLine.frame.size.width/2, y: self.selectedLine.frame.origin.y, width: self.selectedLine.frame.size.width, height: self.selectedLine.frame.size.height)
            }
        }
    }
    
    func removeView(view: UIView) {
        if view.superview == nil {
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            view.frame = CGRect.init(x: 0, y: -view.frame.size.height, width: view.frame.size.width, height: view.frame.size.height)
        }) { (finish) in
            view.removeFromSuperview()
        }
    }
    
    func changeLineAction(index: Int) {
        var klineType = KLineType.MinuteLine
        switch self.selectedType {
        case 0:
            klineType = KLineType.MinuteLine
        case 1:
            klineType = KLineType.FiveMinuteLine
        case 2:
            klineType = KLineType.HourLine
        case 3:
            klineType = KLineType.FourHourLine
        case 4:
            klineType = KLineType.DayLine
        case 5:
            klineType = KLineType.FifteenMinuteLine
        case 6:
            klineType = KLineType.ThirtyMinuteLine
        case 7:
            klineType = KLineType.WeekLine
        case 8:
            klineType = KLineType.MonthLine
        default:
            break
        }
        self.klineType = klineType
        self.getLineData(kLineType: klineType)
    }
    
    deinit {
        print("COINTradeBucketFullScreenViewController--deinit")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: ----bitmex websocket----
extension COINTradeBucketFullScreenViewController {
    @objc override func receiveInstrumentNoti(noti: Notification) {
        let dataArray: Array< Dictionary<String, Any?> > = noti.object as! Array
        let dataDict: [String: Any?] = dataArray.first!
        let instrument = COINInstrumentItemModel.deserialize(from: dataDict as [String : Any])
        
        if self.instrument?.symbol == instrument?.symbol {
            if instrument?.lastPcnt != nil {
                self.instrument?.lastPcnt = instrument?.lastPcnt
            }
            if instrument?.priceValue != nil {
                self.instrument?.priceValue = instrument?.priceValue
            }
            if instrument?.indicativeSettlePrice != nil {
                self.instrument?.indicativeSettlePrice = instrument?.indicativeSettlePrice
            }
            if instrument?.prevPrice24h != nil {
                self.instrument?.prevPrice24h = instrument?.prevPrice24h
            }
            self.updateHeader()
        }
    }
    
    @objc override func receiveTradeBin1mNoti(noti: Notification) {
        let klineModel = COINKLineModel.deserialize(from: ["data":noti.object as Any])
        if klineModel?.data != nil && self.kLineModel != nil {
            if self.kLineView.kLineType == .MinuteLine {
                for item in  (klineModel?.data)! {
                    self.kLineModel?.data?.append(item)
                }
                if self.kLineModel?.data?.count ?? 0 > 0 {
                    let toDateFmt = DateFormatter.init()
                    toDateFmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    let toStringFmt = DateFormatter.init()
                    toStringFmt.dateFormat = "yyyy-MM-dd HH:mm"
                    for item in (self.kLineModel?.data)! {
                        let toDate = toDateFmt.date(from: item.timestamp ?? "")
                        if toDate != nil {
                            var time: Date = toDate!
                            time = Date.init(timeIntervalSince1970: time.timeIntervalSince1970 + 60 * 60 * 8)
                            let timestamp = toStringFmt.string(from: time)
                            item.timestamp = timestamp
                        }
                    }
                }
                _kLineModel = self.kLineModel
                if self.kLineView.superview != nil {
                    self.setContent()
                } else {
                    self.view.addSubview(self.kLineView)
                }
            }
        }
    }
}

// MARK: ----okex websocket----
extension COINTradeBucketFullScreenViewController {
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
                    self.updateHeader()
                }
            }
        }
    }
    
    override func receiveKlineNoti_ok(noti: Notification) {
        if noti.object is [[String]] {
            let dataArray: [[String]] = noti.object as! [[String]]
            let okexKlineModel = COINOKEXKLineModel.deserialize(from: ["data": dataArray])
            if self.kLineView.kLineType == .MinuteLine {
                let klineModel = okexKlineModel?.toKLineModel()
                if klineModel?.data != nil && self.kLineModel != nil {
                    for item in (klineModel?.data)! {
                        if self.kLineModel?.data?.last?.timestamp == item.timestamp {
                            self.kLineModel?.data?.removeLast()
                        }
                        self.kLineModel?.data?.append(item)
                    }
                    _kLineModel = self.kLineModel
                    if self.kLineView.superview != nil {
                        self.setContent()
                    } else {
                        self.view.addSubview(self.kLineView)
                    }
                }
            }
        }
    }
}
