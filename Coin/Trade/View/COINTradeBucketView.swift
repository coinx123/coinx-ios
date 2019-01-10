//
//  TradeBucketView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/12.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit
import SnapKit
import Charts

private struct COINTradeBucketViewUX {
    static let HPadding: CGFloat = 12
    static let VPadding: CGFloat = 12
    
    static let TopViewHeight: CGFloat = 115
    static let KLineViewHeight: CGFloat = 320
    static let BottomViewHeight: CGFloat = tabbarHeight
    
    static let CellName: String = "TradeBucketCell"
}

class COINTradeBucketView: UIView {
    var platform: Platform?
    
    var kLineModel: COINKLineModel?{
        get{
            return _kLineModel
        }
        set{
            _kLineModel = newValue
            if newValue?.data?.count ?? 0 > 0 {
                let toDateFmt = DateFormatter.init()
                toDateFmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                let toStringFmt = DateFormatter.init()
                toStringFmt.dateFormat = "yyyy-MM-dd HH:mm"
                for item in (newValue?.data)! {
                    let toDate = toDateFmt.date(from: item.timestamp ?? "")
                    if toDate != nil {
                        var time: Date = toDate!
                        time = Date.init(timeIntervalSince1970: time.timeIntervalSince1970 + 60 * 60 * 8)
                        let timestamp = toStringFmt.string(from: time)
                        item.timestamp = timestamp
                    }
                }
            }
            self.setContent()
        }
    }
    private var _kLineModel: COINKLineModel?
    
    var changeLineTypeHandle: ((KLineType) -> ())?
    
    var orderActionHandle: ((Int)->())? //0买1卖
    
    var instrument: COINInstrumentItemModel?
    
    lazy var baseView: UIScrollView = {
        let baseView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight - navAndStatusHeight - tabbarHeight))
        baseView.bounces = false
        baseView.backgroundColor = bgColor
        baseView.addSubview(self.topPriceView)
        baseView.addSubview(self.lineTypeSelectionView)
        baseView.addSubview(self.kLineView)
        baseView.addSubview(self.tradeHistoryView)
        baseView.contentSize = CGSize.init(width: self.bounds.size.width, height: self.tradeHistoryView.frame.maxY)
        if #available(iOS 11.0, *) {
            baseView.contentInsetAdjustmentBehavior = .never
        }
        return baseView
    }()
    
    lazy var topPriceView: UIView = {
        let topPriceView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: COINTradeBucketViewUX.TopViewHeight))
        topPriceView.backgroundColor = whiteColor
        topPriceView.addSubview(self.priceLabel)
        topPriceView.addSubview(self.stateImageView)
        topPriceView.addSubview(self.pricePcntLabel)
        topPriceView.addSubview(self.priceChangeLabel)
        self.priceLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(COINTradeBucketViewUX.HPadding)
            make.top.equalTo(COINTradeBucketViewUX.VPadding)
        })
        self.stateImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.priceLabel.snp.right).offset(5)
            make.top.equalTo(COINTradeBucketViewUX.VPadding + 5)
            make.size.equalTo(CGSize.init(width: 12, height: 16))
        })
        self.pricePcntLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(COINTradeBucketViewUX.HPadding)
            make.top.equalTo(44)
            make.height.equalTo(20)
        })
        self.priceChangeLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(self.pricePcntLabel.snp.right).offset(10)
            make.top.equalTo(44)
            make.height.equalTo(20)
        })
        
        topPriceView.addSubview(self.dayTitleLabel)
        topPriceView.addSubview(self.dayPriceLabel)
        topPriceView.addSubview(self.countTitleLabel)
        topPriceView.addSubview(self.countLabel)
        return topPriceView
    }()
    
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.textColor = titleGreenColor
        priceLabel.font = fontBold25
        return priceLabel
    }()
    
    lazy var stateImageView: UIImageView = {
        let stateImageView = UIImageView()
        return stateImageView
    }()
    
    lazy var pricePcntLabel: UILabel = {
        let pricePcntLabel = UILabel()
        pricePcntLabel.textColor = whiteColor
        pricePcntLabel.backgroundColor = bgGreenColor
        pricePcntLabel.font = font12
        pricePcntLabel.layer.cornerRadius = 2
        pricePcntLabel.layer.masksToBounds = true
        return pricePcntLabel
    }()
    lazy var priceChangeLabel: UILabel = {
        let priceChangeLabel = UILabel()
        priceChangeLabel.textColor = titleGrayColor
        priceChangeLabel.font = font14
        return priceChangeLabel
    }()
    lazy var dayTitleLabel: UILabel = {
        let dayTitleLabel = UILabel.init(frame: CGRect.init(x: COINTradeBucketViewUX.HPadding, y: 74, width: 50, height: 32))
        dayTitleLabel.numberOfLines = 2
        dayTitleLabel.textColor = titleBlueColor_Light
        dayTitleLabel.font = font12
        dayTitleLabel.text = "24H高:\n24H低:"
        return dayTitleLabel
    }()
    lazy var dayPriceLabel: UILabel = {
        let dayPriceLabel = UILabel.init(frame: CGRect.init(x: 90, y: 74, width: 70, height: 32))
        dayPriceLabel.numberOfLines = 2
        dayPriceLabel.textColor = titleGrayColor
        dayPriceLabel.font = font12
        return dayPriceLabel
    }()
    lazy var countTitleLabel: UILabel = {
        let countTitleLabel = UILabel.init(frame: CGRect.init(x: self.bounds.size.width - 90 - 50, y: 74, width: 50, height: 32))
        countTitleLabel.numberOfLines = 2
        countTitleLabel.textColor = titleBlueColor_Light
        countTitleLabel.font = font12
        countTitleLabel.textAlignment = .right
        countTitleLabel.text = "市值:\n24H量:" 
        return countTitleLabel
    }()
    lazy var countLabel: UILabel = {
        let countLabel = UILabel.init(frame: CGRect.init(x: self.bounds.size.width - COINTradeBucketViewUX.HPadding - 70, y: 74, width: 70, height: 32))
        countLabel.numberOfLines = 2
        countLabel.textColor = titleGrayColor
        countLabel.font = font12
        countLabel.textAlignment = .right
        return countLabel
    }()
    
    
    lazy var lineTypeSelectionView: UIView = {
        let lineTypeSelectionView = UIView.init(frame: CGRect.init(x: 0, y: self.topPriceView.frame.maxY + 10, width: self.bounds.size.width, height: 38))
        lineTypeSelectionView.backgroundColor = whiteColor
        let width = self.bounds.size.width/7
        for var i in 0..<7 {
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect.init(x: CGFloat(i) * width, y: 0, width: width, height: lineTypeSelectionView.frame.size.height)
            btn.setTitle(self.timeArray[i], for: .normal)
            btn.titleLabel?.font = font11
            if i == self.selectedType {
                btn.setTitleColor(titleBlueColor, for: .normal)
                self.selectedLine.frame = CGRect.init(x: btn.center.x - self.selectedLine.frame.size.width/2, y: self.selectedLine.frame.origin.y, width: self.selectedLine.frame.size.width, height: self.selectedLine.frame.size.height)
            } else {
                btn.setTitleColor(titleBlueColor_Light, for: .normal)
            }
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(changeType(btn:)), for: .touchUpInside)
            if i >= 5 {
                btn.setImage(UIImage.init(named: "trade_more"), for: .normal)
                btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -20, bottom: 0, right: 0)
                btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 36, bottom: -6, right: 0)
            }
            lineTypeSelectionView.addSubview(btn)
        }
        let line = UIView.init(frame: CGRect.init(x: 0, y: lineTypeSelectionView.frame.size.height - 1, width: lineTypeSelectionView.frame.size.width, height: 1))
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
        let moreView = UIView.init(frame: CGRect.init(x: 0, y: -38, width: screenWidth, height: 38))
        moreView.backgroundColor = bgColor
        let width = self.bounds.size.width/7
        for var i in 0..<self.moreTimeArray.count {
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect.init(x: CGFloat(i) * width, y: 0, width: width, height: moreView.frame.size.height)
            btn.setTitle(self.moreTimeArray[i], for: .normal)
            btn.titleLabel?.font = font11
            if i+5 == self.selectedType {
                btn.setTitleColor(titleBlueColor, for: .normal)
            } else {
                btn.setTitleColor(titleBlueColor_Light, for: .normal)
            }
            btn.tag = 105 + i
            btn.addTarget(self, action: #selector(changeTypeMore(btn:)), for: .touchUpInside)
            moreView.addSubview(btn)
        }
        return moreView
    }()
    
    lazy var indicatorView: UIView = {
        let indicatorView = UIView.init(frame: CGRect.init(x: 0, y: -70, width: screenWidth, height: 70))
        indicatorView.backgroundColor = bgColor
        let width = self.bounds.size.width/7
        let height = indicatorView.frame.size.height/2
        for i in 0..<self.indicatorArray.count {
            let subArray: [String] = self.indicatorArray[i]
            for j in 0..<subArray.count {
                let btn = UIButton.init(type: .custom)
                btn.frame = CGRect.init(x: CGFloat(j) * width, y: CGFloat(i) * height, width: width, height: height)
                btn.setTitle(subArray[j], for: .normal)
                btn.titleLabel?.font = font11
                if j == 0 {
                    btn.isUserInteractionEnabled = false
                }
                if i == 0 {
                    if j == self.selectedMainType {
                        btn.setTitleColor(titleBlueColor, for: .normal)
                    } else {
                        btn.setTitleColor(titleBlueColor_Light, for: .normal)
                    }
                } else {
                    if j == self.selectedAuxiliaryType {
                        btn.setTitleColor(titleBlueColor, for: .normal)
                    } else {
                        btn.setTitleColor(titleBlueColor_Light, for: .normal)
                    }
                }
                btn.tag = i*100 + j
                btn.addTarget(self, action: #selector(changeLineType(btn:)), for: .touchUpInside)
                indicatorView.addSubview(btn)
            }
        }
        return indicatorView
    }()
    
    lazy var kLineView: COINKLineView = {
        let kLineView = COINKLineView.init(frame: CGRect.init(x: 0, y: self.lineTypeSelectionView.frame.maxY, width: screenWidth, height: COINTradeBucketViewUX.KLineViewHeight))
        kLineView.clipsToBounds = true
        kLineView.backgroundColor = whiteColor
        return kLineView
    }()
    
    lazy var tradeHistoryView: COINMarketTradeHistoryView = {
        let tradeHistoryView = COINMarketTradeHistoryView.init(frame: CGRect.init(x: 0, y: self.kLineView.frame.maxY, width: self.frame.size.width, height: 330))
        return tradeHistoryView
    }()
    
    lazy var bottomView: UIView = {
        let bottomView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height - COINTradeBucketViewUX.BottomViewHeight, width: self.frame.size.width, height: COINTradeBucketViewUX.BottomViewHeight))
        bottomView.backgroundColor = whiteColor
        let line = UIView.init(frame: CGRect.init(x: 0, y: 0, width: bottomView.frame.size.width, height: 1))
        line.backgroundColor = lineGrayColor
        bottomView.addSubview(line)
        bottomView.addSubview(self.buyBtn)
        bottomView.addSubview(self.sellBtn)
        return bottomView
    }()
    
    lazy var buyBtn: UIButton = {
        let buyBtn = UIButton.init(type: .custom)
        buyBtn.frame = CGRect.init(x: 8, y: 8, width: (screenWidth - 26)/2, height: 38)
        buyBtn.setTitle("买入", for: .normal)
        buyBtn.backgroundColor = COINUseHabitHelper.shared().titleRiseColor
        buyBtn.setTitleColor(whiteColor, for: .normal)
        buyBtn.titleLabel?.font = font16
        buyBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 4, height: 4))
        buyBtn.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
        return buyBtn
    }()
    
    lazy var sellBtn: UIButton = {
        let sellBtn = UIButton.init(type: .custom)
        sellBtn.frame = CGRect.init(x: screenWidth/2 + 5, y: 8, width: (screenWidth - 8 - 10 - 8)/2, height: 38)
        sellBtn.setTitle("卖出", for: .normal)
        sellBtn.backgroundColor = COINUseHabitHelper.shared().titleDropColor
        sellBtn.setTitleColor(whiteColor, for: .normal)
        sellBtn.titleLabel?.font = font16
        sellBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 4, height: 4))
        sellBtn.addTarget(self, action: #selector(sellAction), for: .touchUpInside)
        return sellBtn
    }()
    
    init(frame: CGRect,kLineModel: COINKLineModel?,platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        self.backgroundColor = whiteColor
        self.addSubview(self.baseView)
        self.addSubview(self.bottomView)
        if kLineModel != nil {
            self.kLineModel = kLineModel
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buyAction() {
        if self.orderActionHandle != nil {
            self.orderActionHandle!(0)
        }
    }
    
    @objc func sellAction() {
        if self.orderActionHandle != nil {
            self.orderActionHandle!(1)
        }
    }
    
    @objc func changeTypeMore(btn: UIButton) {
        let btnMore: UIButton = self.lineTypeSelectionView.viewWithTag(100 + 5) as! UIButton
        btnMore.backgroundColor = whiteColor
        btnMore.setTitle(btn.titleLabel?.text, for: .normal)
        self.removeView(view: self.moreView)
        if self.selectedType < 5 {
            let btnOld: UIButton = self.lineTypeSelectionView.viewWithTag(100 + self.selectedType) as! UIButton
            btnOld.setTitleColor(titleBlueColor_Light, for: .normal)
        } else {
            let btnOld: UIButton = self.moreView.viewWithTag(100 + self.selectedType) as! UIButton
            btnOld.setTitleColor(titleBlueColor_Light, for: .normal)
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
        btnOld?.setTitleColor(titleBlueColor_Light, for: .normal)
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
                        self.moreView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: self.moreView.frame.size.height)
                    }
                }
            } else { //指标
                if self.indicatorView.superview != nil {
                    self.removeView(view: self.indicatorView)
                } else {
                    self.kLineView.addSubview(self.indicatorView)
                    UIView.animate(withDuration: 0.2) {
                        self.indicatorView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: self.indicatorView.frame.size.height)
                    }
                }
            }
        } else {
            btnMore.setTitle(timeArray[5], for: .normal)
            if self.selectedType < 5 {
                let btnOld: UIButton = btn.superview?.viewWithTag(100 + self.selectedType) as! UIButton
                btnOld.setTitleColor(titleBlueColor_Light, for: .normal)
            } else {
                let btnOld: UIButton = self.moreView.viewWithTag(100 + self.selectedType) as! UIButton
                btnOld.setTitleColor(titleBlueColor_Light, for: .normal)
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
            view.frame = CGRect.init(x: 0, y: -view.frame.size.height, width: screenWidth, height: view.frame.size.height)
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
        if self.changeLineTypeHandle != nil {
            self.changeLineTypeHandle!(klineType)
        }
    }
    
    func setContent() {
        self.updateHeader()
        
        self.kLineView.setContent(kLineModel: _kLineModel , kLineType: self.klineType , selectedMainType: self.selectedMainType , selectedAuxiliaryType: self.selectedAuxiliaryType)
    }
    
    func updateHeader() {
        self.priceLabel.text = self.instrument?.priceValue?.turnPriceStr()
        self.pricePcntLabel.text = " \(self.instrument?.lastPcnt?.lastPecnStr() ?? "0%") "
        self.priceChangeLabel.text = ((self.instrument?.priceValue ?? 0.0 ) - (self.instrument?.prevPrice24h ?? 0.0)).turnPriceStr()
        var imageStr = ""
        var color: UIColor?
        if (self.instrument?.priceValue ?? 0.0 ) - (self.instrument?.prevPrice24h ?? 0.0) > 0 {
            imageStr = "trade_up"
            color = COINUseHabitHelper.shared().bgRiseColor
            self.priceLabel.textColor = COINUseHabitHelper.shared().titleRiseColor
            self.pricePcntLabel.backgroundColor = COINUseHabitHelper.shared().titleRiseColor
        } else {
            imageStr = "trade_down"
            color = COINUseHabitHelper.shared().bgDropColor
            self.priceLabel.textColor = COINUseHabitHelper.shared().titleDropColor
            self.pricePcntLabel.backgroundColor = COINUseHabitHelper.shared().titleDropColor
        }
        var turnoverStr: String?
        let turnover = self.instrument?.turnover24h
        if self.platform == .bitmex {
            if turnover ?? 0.0 > 100000000.0 * 1000 {
                turnoverStr = "\(String(format: "%.2f", (turnover ?? 0.0)/100000000.0/1000.0))亿"
            } else if turnover ?? 0.0 > 10000.0 * 1000 {
                turnoverStr = "\(String(format: "%.2f", (turnover ?? 0.0)/10000.0/1000.0))万"
            } else {
                turnoverStr = "\(String(format: "%.2f", turnover ?? 0.0))"
            }
            self.countTitleLabel.text = "市值:\n24H量:"
            self.countLabel.text = "\(String(format: "%.2f", (self.instrument?.totalVolume ?? 0)/100000000.0))亿\n\(turnoverStr!)"
        } else {
            if turnover ?? 0.0 > 100000000.0 {
                turnoverStr = "\(String(format: "%.2f", (turnover ?? 0.0)/100000000.0))亿"
            } else if turnover ?? 0.0 > 10000.0 {
                turnoverStr = "\(String(format: "%.2f", (turnover ?? 0.0)/10000.0))万"
            } else {
                turnoverStr = "\(String(format: "%.2f", turnover ?? 0.0))"
            }
            self.countTitleLabel.text = "24H量:"
            self.countLabel.text = "\(turnoverStr!)"
        }
        self.stateImageView.image = UIImage.init(named: imageStr)?.createByTintColor(color!)
        self.dayPriceLabel.text = "\(self.instrument?.highPrice ?? 0.0)\n\(self.instrument?.lowPrice ?? 0.0)"
    }
}

