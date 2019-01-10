//
//  ExchangeView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/7.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit
import SnapKit

import MachO

struct COINExchangeViewUX {
    static let HPadding: CGFloat = 15
    static let VPadding: CGFloat = 12
    
    static let HeaderTopHeight: CGFloat = 64
    static let HeaderViewHeight: CGFloat = 500
    
    static let CellHeight: CGFloat = 165
    static let CellName = "OrderBookCell"
    static let HeaderName = "ExchangeHeaderFooter"
}

class COINExchangeView: UIView, UITableViewDelegate,UITableViewDataSource {
    
    var platform: Platform?
    
    var cancelHandle: ((COINOrderBookItemModel?)->())?
    
    var orderBookModel: COINOrderBookModel?{
        get {
            return _orderBookModel
        }
        set {
            _orderBookModel = newValue
            if _orderBookModel?.data?.count ?? 0 > 0 {
                for item in (_orderBookModel?.data)! {
                    let toDateFmt = DateFormatter.init()
                    toDateFmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    let toStringFmt = DateFormatter.init()
                    toStringFmt.dateFormat = "MM-dd HH:mm"
                    var time: Date = toDateFmt.date(from: item.timestamp ?? "") ?? Date.init()
                    time = Date.init(timeIntervalSince1970: time.timeIntervalSince1970 + 60 * 60 * 8)
                    item.timestamp = toStringFmt.string(from: time)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private var _orderBookModel: COINOrderBookModel?
    
    var commisionModel: COINCommisionModel?{
        get {
            return _commisionModel
        }
        set {
            _commisionModel = newValue
            self.tableView.reloadData()
        }
    }
    private var _commisionModel: COINCommisionModel?
    
    lazy var emptyView: COINEmptyView = {
        let emptyView = COINEmptyView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: 200), type: .noData)
        return emptyView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: self.bounds, style: .grouped)
        tableView.register(COINOrderBookCell.self, forCellReuseIdentifier: COINExchangeViewUX.CellName)
        tableView.register(ExchangeHeaderFooter.self, forHeaderFooterViewReuseIdentifier: COINExchangeViewUX.HeaderName)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = COINExchangeViewUX.CellHeight
        tableView.tableHeaderView = self.exchangeHeaderView
        tableView.backgroundColor = whiteColor
        return tableView
    }()
    
    lazy var exchangeHeaderView: COINExchangeHeaderView = {
        let exchangeHeaderView = COINExchangeHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: COINExchangeViewUX.HeaderViewHeight), platform: self.platform!)
        return exchangeHeaderView
    }()
    
    init(frame: CGRect, platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        self.addSubview(self.tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ----UITableViewDataSource----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _orderBookModel?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: COINOrderBookCell = tableView.dequeueReusableCell(withIdentifier: COINExchangeViewUX.CellName, for: indexPath) as! COINOrderBookCell
        if indexPath.row < 1 {
            cell.line.isHidden = false
        } else {
            cell.line.isHidden = true
        }
        if _orderBookModel?.data?.count ?? 0 > indexPath.row {
            let model = _orderBookModel?.data![indexPath.row]
            cell.commisionModel = _commisionModel
            cell.setContent(orderModel: model!)
            cell.cancelHandle = { orderModel in
                if self.cancelHandle != nil {
                    self.cancelHandle!(orderModel)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: ExchangeHeaderFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: COINExchangeViewUX.HeaderName) as! ExchangeHeaderFooter
        view.titleLabel.text = "当前委托"
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if _orderBookModel?.data?.count == 0 {
            return self.emptyView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if _orderBookModel?.data?.count == 0 {
            return 200
        } else {
            return 0.001
        }
    }
    
    // MARK: ----滑动回收键盘----
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.endEditing(true)
    }
}
enum ExchangeHeaderViewEvent: Int {
    case openPositionsBuy  = 0//
    case openPositionsSell
    case closePositionBuy
    case closePositionSell
}
enum ExchangeHeaderViewPriceType: Int {
    case customPrice  = 0//
    case marketPrice
    case buyFirstPrice
    case sellFirstPrice
}
typealias ExchangeHeaderViewCallBack = (_ event: ExchangeHeaderViewEvent)->()
typealias ExchangeHeaderViewPositionCallBack = (_ isOpenPosition    : Bool)->()
typealias ExchangeHeaderViewPriceTypeCallBack = (_ priceType: ExchangeHeaderViewPriceType)->()
class COINExchangeHeaderView: UIView, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    var platform: Platform?
    
    var platformOrderBookModel: COINOrderBookModel?{
        get {
            return _platformOrderBookModel
        }
        set {
            _platformOrderBookModel = newValue
            self.commissionListTableView.reloadData()
        }
    }
    var callBack: ExchangeHeaderViewCallBack?
    var positionCallBack: ExchangeHeaderViewPositionCallBack?
    var priceTypeCallback: ExchangeHeaderViewPriceTypeCallBack?
    private var _platformOrderBookModel: COINOrderBookModel?
    
    var instrumentModel: COINInstrumentItemModel?
    
    var changeLeverageHandle: ((String)->())?
    
    public var selectOptionalHandle: (()->())?
    
    var lastPriceLabel: UILabel?
    
    lazy var baseView: UIView = {
        let baseView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: COINExchangeViewUX.HeaderViewHeight - 10))
        baseView.backgroundColor = whiteColor
        baseView.addSubview(self.leftImageView)
        baseView.addSubview(self.nameLabel)
        baseView.addSubview(self.priceLabel)
        baseView.addSubview(self.pricePcntBtn)
        baseView.addSubview(self.hLine)
        
        baseView.addSubview(self.typeView)
        baseView.addSubview(self.leverageTextField)
        baseView.addSubview(self.priceTextField)
        self.priceTextField.leftView = self.leftLabel
        self.priceTextField.leftViewMode = .always
        baseView.addSubview(self.quickPriceView)
        baseView.addSubview(self.coinCountTextField)
        coinCountTextField.leftView = self.coinCountTextFieldLeftLabel
        coinCountTextField.leftViewMode = .always
        baseView.addSubview(self.buyBtn)
        baseView.addSubview(self.buyCanUseTitleLabel)
        baseView.addSubview(self.buyCanUseCountLabel)
        baseView.addSubview(self.sellBtn)
        baseView.addSubview(self.sellerCanUseTitleLabel)
        baseView.addSubview(self.sellerCanOpenModelTitleLabel)
        baseView.addSubview(self.canOpenMoreLabel)
        baseView.addSubview(self.canOpenMoreCountLabel)
        baseView.addSubview(self.sellerOpenMoreCountLabel)
        baseView.addSubview(self.sellerCanUseCountLabel)
        baseView.addSubview(self.vLine)
        baseView.addSubview(self.commissionListTableView)
        baseView.addSubview(self.priceDifferenceLabel)
        return baseView
    }()
    
    lazy var leftImageView: UIImageView = {
        let leftImageView = UIImageView.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: 20, width: 24, height: 24))
        leftImageView.image = UIImage.init(named: "trade_titleLeft")
        leftImageView.contentMode = .left
        leftImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selectOptionalAction))
        leftImageView.addGestureRecognizer(tap)
        return leftImageView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding + 24, y: 0, width: 150, height: COINExchangeViewUX.HeaderTopHeight))
        nameLabel.text = "BTC"
        nameLabel.textColor = titleBlackColor
        nameLabel.font = font16
        return nameLabel
    }()
    
//    lazy var priceIcon: UIImageView = {
//        let priceIcon = UIImageView.init(frame: CGRect.init(x: screenWidth - 200, y: 0, width: COINExchangeViewUX.HeaderTopHeight * 0.5, height: COINExchangeViewUX.HeaderTopHeight * 0.5))
//        priceLabel.textAlignment = .right
//        priceLabel.numberOfLines = 2
//        priceLabel.textColor = titleGreenColor
//        priceLabel.text = "$6340.00"
//        priceLabel.font = font16
//        return priceIcon
//    }()
    lazy var priceLabel: COINNotiLabel = {
        var width: CGFloat = 100.0
        if screenWidth < 350 {
            width = 70.0
        }
        let priceLabel = COINNotiLabel.init(frame: CGRect.init(x: screenWidth - 100 - width, y: 6, width: width, height: COINExchangeViewUX.HeaderTopHeight * 0.5))
        priceLabel.judgingBytIsGreen  = true
        priceLabel.textAlignment = .right
        priceLabel.textColor = titleGreenColor
        priceLabel.font = fontBold17
        
        return priceLabel
    }()
    
    lazy var priceDifferenceLabel: COINLabel = {
        var width: CGFloat = 100
        if screenWidth < 350 {
            width = 70
        }
        let priceDifferenceLabel = COINLabel.init(frame: CGRect.init(x: screenWidth - 100 - width, y: COINExchangeViewUX.HeaderTopHeight * 0.5, width: width, height: COINExchangeViewUX.HeaderTopHeight * 0.5))
        priceDifferenceLabel.textAlignment = .right
        priceDifferenceLabel.textColor = titleGrayColor
        priceDifferenceLabel.font = font12
        priceDifferenceLabel.verticalAlignment = VerticalAlignmentTop
        return priceDifferenceLabel
    }()
    
    lazy var pricePcntBtn: UIButton = {
        let pricePcntBtn = UIButton.init(type: .custom)
        pricePcntBtn.frame = CGRect.init(x: screenWidth - 70 - COINExchangeViewUX.HPadding, y: 20, width: 70, height: 24)
        pricePcntBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        pricePcntBtn.setTitleColor(whiteColor, for: .normal)
        pricePcntBtn.titleLabel?.font = font12
        pricePcntBtn.setImage(UIImage.init(named: "trade_pricePcnt"), for: .normal)
        pricePcntBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 0)
        pricePcntBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -28, bottom: 0, right: 0)
        pricePcntBtn.backgroundColor = COINUseHabitHelper.shared().bgRiseColor
        return pricePcntBtn
    }()
    
    lazy var hLine: UIView = {
        let hLine = UIView.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: COINExchangeViewUX.HeaderTopHeight, width: screenWidth - COINExchangeViewUX.HPadding * 2, height: 1))
        hLine.backgroundColor = lineGrayColor
        return hLine
    }()
    
    lazy var typeView: UIView = {
        let typeView = UIView.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: COINExchangeViewUX.HeaderTopHeight + COINExchangeViewUX.VPadding, width: screenWidth/2 - COINExchangeViewUX.HPadding, height: 38))
        typeView.backgroundColor = whiteColor
        typeView.layer.borderColor = lineBlueColor_Light.cgColor
        typeView.layer.borderWidth = 1
        for var i in 0..<2 {
            let btn = UIButton.init(type: .custom)
            let width = typeView.frame.size.width/2
            btn.titleLabel?.font = font15
            btn.frame = CGRect.init(x: CGFloat(i) * width, y: 0, width: width, height: typeView.frame.size.height)
            var title = ""
            if i == 0 {
                title = "开仓"
                btn.setTitleColor(whiteColor, for: .normal)
                btn.backgroundColor = bgBlueColor
            } else {
                title = "平仓"
                btn.setTitleColor(titleBlueColor_Light, for: .normal)
            }
            btn.tag = 100 + i
            btn.setTitle(title, for: .normal)
            btn.addTarget(self, action: #selector(changeType(btn:)), for: .touchUpInside)
            typeView.addSubview(btn)
        }
        return typeView
    }()
    
    var selectedType: Int = 0
    
    lazy var leverageTextField: UITextField = {
        let leverageTextField = UITextField.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.typeView.frame.maxY + COINExchangeViewUX.VPadding, width: screenWidth/2 - COINExchangeViewUX.HPadding, height: 28))
        leverageTextField.textAlignment = .right
        leverageTextField.layer.borderWidth = 1
        leverageTextField.layer.borderColor = lineBlueColor_Light.cgColor
        leverageTextField.delegate = self
        leverageTextField.font = font12
        
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: leverageTextField.frame.size.height))
        leftLabel.text = "杠杆"
        leftLabel.textAlignment = .center
        leftLabel.textColor = titleBlueColor_Light
        leftLabel.font = font12
        leverageTextField.leftView = leftLabel
        leverageTextField.leftViewMode = .always
        
        let rightBtn = UIButton.init(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 24, height: leverageTextField.frame.size.height)
        rightBtn.setImage(UIImage.init(named: "trade_downArrow"), for: .normal)
        rightBtn.addTarget(self, action: #selector(selectLeverage), for: .touchUpInside)
        leverageTextField.rightView = rightBtn
        leverageTextField.rightViewMode = .always
        
        return leverageTextField
    }()
    
    lazy var priceTextField: UITextField = {
        let priceTextField = UITextField.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.leverageTextField.frame.maxY + COINExchangeViewUX.VPadding, width: screenWidth/2 - COINExchangeViewUX.HPadding, height: 38))
        priceTextField.textAlignment = .right
        priceTextField.contentVerticalAlignment = .center
        priceTextField.clearButtonMode = .always
        if priceTextField.value(forKey: "_clearButton") != nil {
            let btn: UIButton = priceTextField.value(forKey: "_clearButton") as! UIButton
            btn.setImage(UIImage(named: "trade_clear"), for: .normal)
        }
        priceTextField.layer.borderWidth = 1
        priceTextField.layer.borderColor = lineBlueColor_Light.cgColor
        priceTextField.keyboardType = .decimalPad
        priceTextField.font = font12
        priceTextField.delegate = self
        return priceTextField
    }()
    
    lazy var leftLabel: UILabel = {
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: self.priceTextField.frame.size.height))
        leftLabel.text = "价格(USD)"
        leftLabel.textAlignment = .center
        leftLabel.textColor = titleBlueColor_Light
        leftLabel.font = font12
        
        return leftLabel
    }()
    
    lazy var quickPriceView: UIView = {
        let quickPriceView = UIView.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.priceTextField.frame.maxY + COINExchangeViewUX.VPadding, width: screenWidth/2 - COINExchangeViewUX.HPadding, height: 28))
        quickPriceView.backgroundColor = whiteColor
        let titleArray = ["市场价","买一价","卖一价"]
        for var i in 0..<3 {
            let btn = UIButton.init(type: .custom)
            let width = (quickPriceView.frame.size.width - 10)/3
            btn.titleLabel?.font = font12
            btn.frame = CGRect.init(x: CGFloat(i) * (width + 5), y: 0, width: width, height: quickPriceView.frame.size.height)
            btn.setTitle(titleArray[i], for: .normal)
            btn.setTitleColor(titleBlueColor_Light, for: .normal)
            btn.tag = 200 + i
            btn.layer.borderWidth = 1
            btn.layer.borderColor = lineBlueColor_Light.cgColor
            btn.addTarget(self, action: #selector(changePriceType(btn:)), for: .touchUpInside)
            quickPriceView.addSubview(btn)
        }
        return quickPriceView
    }()
    
    var selectedPriceType: Int = -1
    
    lazy var coinCountTextField: UITextField = {
        let coinCountTextField = UITextField.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.quickPriceView.frame.maxY + COINExchangeViewUX.VPadding, width: screenWidth/2 - COINExchangeViewUX.HPadding, height: 38))
        coinCountTextField.textAlignment = .right
        coinCountTextField.contentVerticalAlignment = .center
        coinCountTextField.clearButtonMode = .always
        if coinCountTextField.value(forKey: "_clearButton") != nil {
            let btn: UIButton = coinCountTextField.value(forKey: "_clearButton") as! UIButton
            btn.setImage(UIImage(named: "trade_clear"), for: .normal)
        }
        coinCountTextField.layer.borderWidth = 1
        coinCountTextField.layer.borderColor = lineBlueColor_Light.cgColor
        coinCountTextField.keyboardType = .numberPad
        coinCountTextField.font = font12
        coinCountTextField.delegate = self
        return coinCountTextField
    }()
    
    lazy var coinCountTextFieldLeftLabel: UILabel = {
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: coinCountTextField.frame.size.height))
        leftLabel.text = "数量(USD)"
        leftLabel.textAlignment = .center
        leftLabel.textColor = titleBlueColor_Light
        leftLabel.font = font12
        
        return leftLabel
    }()
    
    lazy var buyBtn: UIButton = {
        let buyBtn = UIButton.init(type: .custom)
        buyBtn.frame = CGRect.init(x: COINExchangeViewUX.HPadding, y: self.coinCountTextField.frame.maxY + COINExchangeViewUX.VPadding, width: screenWidth/2 - COINExchangeViewUX.HPadding, height: 38)
        buyBtn.setTitle("买入开多(看涨)", for: .normal)
        buyBtn.setTitleColor(whiteColor, for: .normal)
        buyBtn.titleLabel?.font = font15
        buyBtn.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
        buyBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        return buyBtn
    }()
    
    lazy var buyCanUseTitleLabel: UILabel = {
        let buyCanUseTitleLabel = UILabel.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.buyBtn.frame.maxY + 3, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        buyCanUseTitleLabel.numberOfLines = 2
        buyCanUseTitleLabel.text = "可用:"
        buyCanUseTitleLabel.font = font10
        buyCanUseTitleLabel.textColor = titleBlueColor_Light
        return buyCanUseTitleLabel
    }()
    lazy var canOpenMoreLabel : UILabel = {
        let buyCanUseTitleLabel = UILabel.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.buyCanUseTitleLabel.frame.maxY, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        buyCanUseTitleLabel.numberOfLines = 2
        buyCanUseTitleLabel.text = "可开多:"
        buyCanUseTitleLabel.font = font10
        buyCanUseTitleLabel.textColor = titleBlueColor_Light
        return buyCanUseTitleLabel
    }()
    
    lazy var buyCanUseCountLabel: UILabel = {
        let buyCanUseCountLabel = UILabel.init(frame: CGRect.init(x: screenWidth/4, y: self.buyBtn.frame.maxY + 3, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        buyCanUseCountLabel.numberOfLines = 2
        buyCanUseCountLabel.textAlignment = .right
        buyCanUseCountLabel.text = "0BTC"
        buyCanUseCountLabel.font = font10
        buyCanUseCountLabel.textColor = titleBlueColor_Light
        return buyCanUseCountLabel
    }()
    
    lazy var canOpenMoreCountLabel: UILabel = {
        let buyCanUseCountLabel = UILabel.init(frame: CGRect.init(x: screenWidth/4, y: self.buyCanUseCountLabel.frame.maxY, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        buyCanUseCountLabel.numberOfLines = 2
        buyCanUseCountLabel.textAlignment = .right
        buyCanUseCountLabel.text = "0USD"
        buyCanUseCountLabel.font = font10
        buyCanUseCountLabel.textColor = titleBlueColor_Light
        return buyCanUseCountLabel
    }()
    
    lazy var sellBtn: UIButton = {
        let sellBtn = UIButton.init(type: .custom)
        sellBtn.frame = CGRect.init(x: COINExchangeViewUX.HPadding, y: self.canOpenMoreLabel.frame.maxY + COINExchangeViewUX.VPadding, width: screenWidth/2 - COINExchangeViewUX.HPadding, height: 38)
        sellBtn.setTitle("卖出开空(看跌)", for: .normal)
        sellBtn.setTitleColor(whiteColor, for: .normal)
        sellBtn.titleLabel?.font = font15
        sellBtn.addTarget(self, action: #selector(sellAction), for: .touchUpInside)
        sellBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        return sellBtn
    }()
    
    lazy var sellerCanUseTitleLabel: UILabel = {
        let sellerCanUseTitleLabel = UILabel.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.sellBtn.frame.maxY + 3, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        sellerCanUseTitleLabel.numberOfLines = 2
        sellerCanUseTitleLabel.text = "可用:"
        sellerCanUseTitleLabel.font = font10
        sellerCanUseTitleLabel.textColor = titleBlueColor_Light
        return sellerCanUseTitleLabel
    }()
    lazy var sellerCanOpenModelTitleLabel: UILabel = {
        let sellerCanUseTitleLabel = UILabel.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: self.sellerCanUseTitleLabel.frame.maxY, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        sellerCanUseTitleLabel.numberOfLines = 2
        sellerCanUseTitleLabel.text = "可开空:"
        sellerCanUseTitleLabel.font = font10
        sellerCanUseTitleLabel.textColor = titleBlueColor_Light
        return sellerCanUseTitleLabel
    }()
    
    lazy var sellerCanUseCountLabel: UILabel = {
        let sellerCanUseCountLabel = UILabel.init(frame: CGRect.init(x: screenWidth/4, y: self.sellBtn.frame.maxY + 3, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        sellerCanUseCountLabel.numberOfLines = 2
        sellerCanUseCountLabel.textAlignment = .right
        sellerCanUseCountLabel.text = "0BTC"
        sellerCanUseCountLabel.font = font10
        sellerCanUseCountLabel.textColor = titleBlueColor_Light
        return sellerCanUseCountLabel
    }()
    lazy var sellerOpenMoreCountLabel: UILabel = {
        let sellerCanUseCountLabel = UILabel.init(frame: CGRect.init(x: screenWidth/4, y: self.sellerCanUseCountLabel.frame.maxY, width: screenWidth/4 - COINExchangeViewUX.HPadding, height: 17))
        sellerCanUseCountLabel.numberOfLines = 2
        sellerCanUseCountLabel.textAlignment = .right
        sellerCanUseCountLabel.text = "0USD"
        sellerCanUseCountLabel.font = font10
        sellerCanUseCountLabel.textColor = titleBlueColor_Light
        return sellerCanUseCountLabel
    }()
    
    lazy var vLine: UIView = {
        let vLine = UIView.init(frame: CGRect.init(x: screenWidth/2 + COINExchangeViewUX.HPadding, y: COINExchangeViewUX.HeaderTopHeight, width: 1, height: COINExchangeViewUX.HeaderViewHeight - COINExchangeViewUX.HeaderTopHeight - 10))
        vLine.backgroundColor = lineGrayColor
        return vLine
    }()
    
    lazy var commissionListTableView: UITableView = {
        let commissionListTableView = UITableView.init(frame: CGRect.init(x: screenWidth/2 + COINExchangeViewUX.HPadding + 1, y: COINExchangeViewUX.HeaderTopHeight + 1, width: screenWidth/2 - COINExchangeViewUX.HPadding * 2, height: COINExchangeViewUX.HeaderViewHeight - COINExchangeViewUX.HeaderTopHeight - 10 - 1), style: .grouped)
        commissionListTableView.backgroundColor = whiteColor
        commissionListTableView.register(CommissionListCell.self, forCellReuseIdentifier: "CommissionListCell")
        commissionListTableView.register(CommissionListHeaderFooter.self, forHeaderFooterViewReuseIdentifier: "CommissionListHeader")
        commissionListTableView.register(CommissionListHeaderFooter.self, forHeaderFooterViewReuseIdentifier: "CommissionListFooter")
        commissionListTableView.delegate = self
        commissionListTableView.dataSource = self
        commissionListTableView.rowHeight = 30
        commissionListTableView.isScrollEnabled = false
        commissionListTableView.separatorStyle = .none
        return commissionListTableView
    }()
    
    init(frame: CGRect, platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        self.backgroundColor = bgColor
        self.addSubview(self.baseView)
        self.changeBtnState(state: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeBtnState(state: Bool) {
        if state {
            self.buyBtn.backgroundColor = COINUseHabitHelper.shared().bgRiseColor
            self.sellBtn.backgroundColor = COINUseHabitHelper.shared().bgDropColor
        } else {
            self.buyBtn.backgroundColor = lineBlueColor_Light
            self.sellBtn.backgroundColor = lineBlueColor_Light
        }
    }
    
    @objc func selectLeverage() {
        if self.platform == .okex {
            self.showSelectedView()
            return
        }
        if self.instrumentModel?.underlying == "XBT" {
            if (self.instrumentModel?.symbol?.uppercased().contains("7D"))! {
                return
            }
        }
        let alert = UIAlertController.init(title: nil, message: "切换杠杆将同时调整该币种已有持仓的杠杆，请注意风险。", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "取消", style: .default, handler: { (cancel) in
        }))
        alert.addAction(UIAlertAction.init(title: "调整杠杆", style: .default, handler: { (cancel) in
            self.showSelectedView()
        }))
        self.viewController()?.present(alert, animated: true, completion: nil)
    }
    
    func showSelectedView() {
        self.endEditing(true)
        var data: [String]?
        if self.platform == .okex {
            data = ["10X","20X"]
        } else {
            if self.instrumentModel?.underlying == "XBT" { //xbtusd、xbt季度的杠杆最高为100
                data = ["全仓","1X","2X","3X","5X","10X","25X","50X","100X"]
            } else if self.instrumentModel?.underlying == "ETH" { //ETH系列最高为50
                data = ["全仓","1X","2X","3X","5X","10X","25X","35X","50X"]
            } else if self.instrumentModel?.underlying == "LTC" { //LTC系列最高为33.3
                data = ["全仓","1X","2X","3X","5X","10X","25X","33.3X"]
            } else { //其他最高为20
                data = ["全仓","1X","2X","3X","4X","5X","10X","15X","20X"]
            }
        }
        let view = COINSelectView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), data:data!)
        UIApplication.shared.keyWindow!.addSubview(view)
        view.showView()
        weak var weakSelf = self
        view.complectionHandle = { (selectIndex,text) in
            if weakSelf?.changeLeverageHandle != nil && text != nil {
                weakSelf?.leverageTextField.text = text
                weakSelf?.changeLeverageHandle!(text!)
            }
        }
    }
    
    @objc func changeType(btn: UIButton) {
        if self.selectedType == btn.tag - 100 {
            return
        }
        let btnOld: UIButton = btn.superview?.viewWithTag(100 + self.selectedType) as! UIButton
        btnOld.setTitleColor(titleBlueColor_Light, for: .normal)
        btnOld.backgroundColor = whiteColor
        self.selectedType = btn.tag - 100
        if self.selectedType == 0 {
            
            self.sellBtn.setTitle("卖出开空(看跌)", for: .normal)
            self.buyBtn.setTitle("买入开多(看涨)", for: .normal)
            self.buyCanUseTitleLabel.text          = "可用:"
            self.canOpenMoreLabel.text             = "可开多:"
            self.sellerCanUseTitleLabel.text       = "可用:"
            self.sellerCanOpenModelTitleLabel.text = "可开空:"
            if (self.positionCallBack != nil) {
                self.positionCallBack!(true)
            }
        }else{
            
            self.sellBtn.setTitle("卖出平多", for: .normal)
            self.buyBtn.setTitle("买入平空", for: .normal)
            self.buyCanUseTitleLabel.text          = "可平:"
            self.canOpenMoreLabel.text             = "持仓:"
            self.sellerCanUseTitleLabel.text       = "可平:"
            self.sellerCanOpenModelTitleLabel.text = "持仓:"
            if (self.positionCallBack != nil) {
                self.positionCallBack!(false)
            }
        }
        btn.setTitleColor(whiteColor, for: .normal)
        btn.backgroundColor = bgBlueColor
        
    }
    
    @objc func changePriceType(btn: UIButton) {
        if self.selectedPriceType == btn.tag - 200 {
            btn.setTitleColor(titleBlueColor_Light, for: .normal)
            btn.backgroundColor = whiteColor
            self.selectedPriceType = -1
            if (self.priceTypeCallback != nil) {
                self.priceTypeCallback!(ExchangeHeaderViewPriceType(rawValue: self.selectedPriceType + 1) ?? .customPrice)
            }
            return
        }
        if selectedPriceType != -1 {
            let btnOld: UIButton = btn.superview?.viewWithTag(200 + self.selectedPriceType) as! UIButton
            btnOld.setTitleColor(titleBlueColor_Light, for: .normal)
            btnOld.backgroundColor = whiteColor
        }
        btn.setTitleColor(whiteColor, for: .normal)
        btn.backgroundColor = bgBlueColor
        self.selectedPriceType = btn.tag - 200
        if (self.priceTypeCallback != nil) {
            self.priceTypeCallback!(ExchangeHeaderViewPriceType(rawValue: self.selectedPriceType + 1) ?? .customPrice)
        }
    }
    
    
    @objc  func buyAction() {
        self.endEditing(true)
        if (self.callBack != nil) {
            self.callBack!(self.selectedType == 1 ? .closePositionBuy : .openPositionsBuy)
        }
    }
    
    @objc func sellAction() {
        self.endEditing(true)
        if (self.callBack != nil) {
            self.callBack!(self.selectedType == 1 ? .closePositionSell : .openPositionsSell)
        }
    }
    
    @objc func selectOptionalAction() {
        if self.selectOptionalHandle != nil {
            self.selectOptionalHandle!()
        }
    }
    
    // MARK: ----UITableViewDataSource----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _platformOrderBookModel?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommissionListCell = tableView.dequeueReusableCell(withIdentifier: "CommissionListCell", for: indexPath) as! CommissionListCell
        if _platformOrderBookModel?.data?.count ?? 0 > indexPath.row {
            cell.setContent(itemModel: (_platformOrderBookModel?.data?[indexPath.row])!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: CommissionListHeaderFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommissionListHeader") as! CommissionListHeaderFooter
        view.priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        view.countLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-5)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        view.priceLabel.textColor = titleGrayColor
        view.countLabel.textColor = titleGrayColor
        let item = _platformOrderBookModel?.data?.first
        view.priceLabel.text = "价格(\(item?.currency?.uppercased() ?? "USD"))"
        view.countLabel.text = "数量(张)"
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view: CommissionListHeaderFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommissionListFooter") as! CommissionListHeaderFooter
        view.priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        view.countLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        view.priceLabel.textColor = titleBlackColor
        view.countLabel.textColor = titleBlackColor
        view.priceLabel.text = "最新指数:"
        self.lastPriceLabel = view.countLabel
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    // MARK: ----UITextFieldDelegate----
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.leverageTextField {
            return false
        } else {
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.coinCountTextField {
            if range.length > 0 { //删除的
                if (textField.text?.count ?? 0) - range.length > 0 {
                    self.changeBtnState(state: true)
                } else {
                    self.changeBtnState(state: false)
                }
            } else { //增加
                self.changeBtnState(state: true)
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.coinCountTextField {
            self.changeBtnState(state: false)
        }
        return true
    }
}

class CommissionListCell: UITableViewCell {
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.font = font12
        priceLabel.textColor = titleRedColor
        return priceLabel
    }()
    
    lazy var countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = font12
        countLabel.textColor = titleGrayColor
        return countLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.countLabel)
        self.priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        self.countLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setContent(itemModel: COINOrderBookItemModel) {
        if itemModel.side == "Sell" {
            self.priceLabel.textColor = COINUseHabitHelper.shared().bgDropColor
        } else {
            self.priceLabel.textColor = COINUseHabitHelper.shared().bgRiseColor
        }
        self.priceLabel.text = itemModel.price
        self.countLabel.text = itemModel.size
    }
}


class CommissionListHeaderFooter: UITableViewHeaderFooterView {
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.font = font12
        return priceLabel
    }()
    
    lazy var countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = font12
        return countLabel
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ExchangeHeaderFooter: UITableViewHeaderFooterView {
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: CGRect.init(x: COINExchangeViewUX.HPadding, y: COINExchangeViewUX.VPadding, width: 100, height: 28))
        titleLabel.font = fontBold17
        titleLabel.textColor = titleBlueColor
        return titleLabel
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = whiteColor
        self.contentView.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
