//
//  OrderBookView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/7.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

struct COINOrderBookViewUX {
    static let HPadding: CGFloat = 15
    static let VPadding: CGFloat = 15
    
    static let TopHeight: CGFloat = 44
    
    static let CellHeight: CGFloat = 165
    static let CellName = "OrderBookCell"
}

class COINOrderBookView: UIView, UITableViewDelegate,UITableViewDataSource {
    
    var platform: Platform?
    
    var cancelHandle: ((COINOrderBookItemModel?)->())?
    
    var changeOrderIndexHandle: ((Int)->())?
    
    var orderBookModel: COINOrderBookModel?{
        get {
            return _orderBookModel
        }
        set {
            _orderBookModel = newValue
            if _orderBookModel?.data?.count == 0 {
                self.addSubview(self.emptyView)
            } else if self.emptyView.superview != nil {
                self.emptyView.removeFromSuperview()
            }
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
            if newValue != nil {
                self.contentDict?[self.selectedIndex] = _orderBookModel
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
    
    //okex才有的
    var symbolsArr: [String]?{
        didSet {
            self.titleViewOKEX.instrumentIDs = symbolsArr
        }
    }
    var selectedSymbol: String? {
        didSet {
            if self.platform == .okex {
                self.titleViewOKEX.selectedInstrumentID = selectedSymbol
            }
        }
    }
    var changeSymbolHandle: ((String)->())?
    lazy var titleViewOKEX: COINOrderBookTitleView_OKEX = {
        let titleViewOKEX = COINOrderBookTitleView_OKEX.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: COINOrderBookViewUX.TopHeight), instrumentID: self.selectedSymbol)
        weak var weakSelf = self
        titleViewOKEX.instrumentIDChangeAction = { instrumentID in
            weakSelf?.changeSymbolHandle!(instrumentID)
        }
        titleViewOKEX.stateChangeAction = { state in
            weakSelf?.selectedIndex = state
            if weakSelf?.changeOrderIndexHandle != nil {
                weakSelf?.changeOrderIndexHandle!((weakSelf?.selectedIndex)!)
            }
        }
        return titleViewOKEX
    }()
    //
    
    lazy var emptyView: COINEmptyView = {
        let emptyView = COINEmptyView.init(frame: CGRect.init(x: 0, y: self.titleView.frame.maxY, width: self.bounds.size.width, height: self.bounds.size.height - self.titleView.frame.maxY), type: .noData)
        return emptyView
    }()
    
    lazy var titleView: UIView = {
        let titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: COINOrderBookViewUX.TopHeight))
        titleView.backgroundColor = whiteColor
        let baseView = UIView.init(frame: CGRect.init(x: (self.bounds.size.width - 230)/2, y: 0, width: 230, height: 44))
        titleView.addSubview(baseView)
        for var i in 0..<3 {
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect.init(x: 85 * i, y: 0, width: 60, height: 44)
            btn.titleLabel?.font = fontBold14
            switch i {
            case 0:
                btn.setTitle("未成交", for: .normal)
                btn.setTitleColor(titleBlueColor, for: .normal)
            case 1:
                btn.setTitle("已成交", for: .normal)
                btn.setTitleColor(titleBlueColor_Light, for: .normal)
            case 2:
                btn.setTitle("已撤销", for: .normal)
                btn.setTitleColor(titleBlueColor_Light, for: .normal)
            default:
                break
            }
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(changeView(btn:)), for: .touchUpInside)
            baseView.addSubview(btn)
        }
        return titleView
    }()
    
    var selectedIndex: Int = 0
    
    var contentDict: [Int: COINOrderBookModel]?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: COINOrderBookViewUX.TopHeight, width: self.bounds.size.width, height: self.bounds.size.height - COINOrderBookViewUX.TopHeight), style: .grouped)
        tableView.register(COINOrderBookCell.self, forCellReuseIdentifier: COINOrderBookViewUX.CellName)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = COINOrderBookViewUX.CellHeight
        tableView.backgroundColor = bgColor
        return tableView
    }()
    
    init(frame: CGRect, platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        self.backgroundColor = bgColor
        if platform == .okex {
            self.addSubview(self.titleViewOKEX)
        } else {
            self.addSubview(self.titleView)
        }
        self.tableView.frame = CGRect.init(x: 0, y: COINOrderBookViewUX.TopHeight, width: self.bounds.size.width, height: self.bounds.size.height - COINOrderBookViewUX.TopHeight)
        self.addSubview(self.tableView)
        self.contentDict = [Int: COINOrderBookModel]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if self.changeOrderIndexHandle != nil {
            self.changeOrderIndexHandle!(self.selectedIndex)
        }
    }
    
    @objc func changeView(btn: UIButton) {
        if self.selectedIndex == btn.tag - 100 {
            return
        }
        let btnOld: UIButton = btn.superview?.viewWithTag(100 + self.selectedIndex) as! UIButton
        btnOld.setTitleColor(titleBlueColor_Light, for: .normal)
        btn.setTitleColor(titleBlueColor, for: .normal)
        self.selectedIndex = btn.tag - 100
        
        if self.emptyView.superview != nil {
            self.emptyView.removeFromSuperview()
        }
        if let orderBookModel = self.contentDict?[self.selectedIndex] {
            _orderBookModel = orderBookModel
            self.tableView.reloadData()
        } else {
            self.orderBookModel = nil
        }
        if self.changeOrderIndexHandle != nil {
            self.changeOrderIndexHandle!(self.selectedIndex)
        }
    }
    
    // MARK: ----UITableViewDataSource----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _orderBookModel?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: COINOrderBookCell = tableView.dequeueReusableCell(withIdentifier: COINExchangeViewUX.CellName, for: indexPath) as! COINOrderBookCell
        if _orderBookModel?.data?.count ?? 0 > indexPath.section {
            let model = _orderBookModel?.data![indexPath.section]
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 10))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 0.001))
    }
}

class COINOrderBookCell: UITableViewCell {
    
    var cancelHandle: ((COINOrderBookItemModel?)->())?
    
    var orderModel: COINOrderBookItemModel?
    
    var commisionModel: COINCommisionModel?
    
    lazy var nameLabel: UILabel = { //币种名称
        let nameLabel = UILabel.init(frame: CGRect.init(x: COINOrderBookViewUX.HPadding, y: COINOrderBookViewUX.VPadding, width: screenWidth/2, height: 18))
        nameLabel.text = "BTC"
        nameLabel.font = font16
        nameLabel.textColor = titleBlackColor
        return nameLabel
    }()
    
    lazy var modeLabel: UILabel = { //购买模式
        let modeLabel = UILabel.init(frame: CGRect.init(x: COINOrderBookViewUX.HPadding, y: 40, width: 86, height: 20))
        modeLabel.backgroundColor = bgGreenColor
        modeLabel.textColor = whiteColor
        modeLabel.text = "买入开多 10X"
        modeLabel.font = font12
        modeLabel.textAlignment = .center
        modeLabel.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        return modeLabel
    }()
    
    lazy var timeLabel: UILabel = { //时间
        let timeLabel = UILabel.init(frame: CGRect.init(x: 110, y: 40, width: 150, height: 20))
        timeLabel.font = font12
        timeLabel.textColor = titleGrayColor
        return timeLabel
    }()
    
    lazy var cancelBtn: UIButton = { //撤销按钮，未成交的才有
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.frame = CGRect.init(x: screenWidth - 50 - COINOrderBookViewUX.HPadding, y: COINOrderBookViewUX.VPadding, width: 50, height: 22)
        cancelBtn.backgroundColor = bgBlueColor
        cancelBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 22, height: 22))
        cancelBtn.setTitleColor(whiteColor, for: .normal)
        cancelBtn.setTitle("撤销", for: .normal)
        cancelBtn.titleLabel?.font = font11
        cancelBtn.addTarget(self, action: #selector(cancelOrder), for: .touchUpInside)
        return cancelBtn
    }()
    
    lazy var stateImageView: UIImageView = { //状态图标，成交了的才有
        let stateImageView = UIImageView.init(frame: CGRect.init(x: screenWidth - 36, y: 0, width: 36, height: 36))
        stateImageView.isHidden = true
        return stateImageView
    }()
    
    lazy var depositLabel: UILabel = { //保证金
        let depositLabel = UILabel.init(frame: CGRect.init(x: COINOrderBookViewUX.HPadding, y: 115, width: 100, height: 32))
        depositLabel.numberOfLines = 2
        depositLabel.font = font12
        return depositLabel
    }()
    lazy var chargeLabel: UILabel = { //手续费
        let chargeLabel = UILabel.init(frame: CGRect.init(x: COINOrderBookViewUX.HPadding, y: 70, width: 100, height: 32))
        chargeLabel.numberOfLines = 2
        chargeLabel.font = font12
        return chargeLabel
    }()
    lazy var averagePriceLabel: UILabel = { //成交均价
        let averagePriceLabel = UILabel.init(frame: CGRect.init(x: screenWidth - COINOrderBookViewUX.HPadding - 200, y: 115, width: 100, height: 32))
        averagePriceLabel.textAlignment = .right
        averagePriceLabel.numberOfLines = 2
        averagePriceLabel.font = font12
        return averagePriceLabel
    }()
    lazy var turnoverLabel: UILabel = { //成交量
        let turnoverLabel = UILabel.init(frame: CGRect.init(x: screenWidth - COINOrderBookViewUX.HPadding - 200, y: 70, width: 100, height: 32))
        turnoverLabel.textAlignment = .right
        turnoverLabel.numberOfLines = 2
        turnoverLabel.font = font12
        return turnoverLabel
    }()
    lazy var commissionPriceLabel: UILabel = { //委托价
        let commissionPriceLabel = UILabel.init(frame: CGRect.init(x: screenWidth - COINOrderBookViewUX.HPadding - 100, y: 115, width: 100, height: 32))
        commissionPriceLabel.textAlignment = .right
        commissionPriceLabel.numberOfLines = 2
        commissionPriceLabel.font = font12
        return commissionPriceLabel
    }()
    lazy var commissionCountLabel: UILabel = { //委托量
        let commissionCountLabel = UILabel.init(frame: CGRect.init(x: screenWidth - COINOrderBookViewUX.HPadding - 100, y: 70, width: 100, height: 32))
        commissionCountLabel.textAlignment = .right
        commissionCountLabel.numberOfLines = 2
        commissionCountLabel.font = font12
        return commissionCountLabel
    }()
    
    lazy var line: UIView = {
        let line = UIView.init(frame: CGRect.init(x: COINOrderBookViewUX.HPadding, y: COINOrderBookViewUX.CellHeight - 0.5, width: screenWidth - COINOrderBookViewUX.HPadding * 2, height: 0.5))
        line.backgroundColor = lineGrayColor
        line.isHidden = true
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.modeLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.cancelBtn)
        self.contentView.addSubview(self.stateImageView)
        self.contentView.addSubview(self.depositLabel)
        self.contentView.addSubview(self.chargeLabel)
        self.contentView.addSubview(self.averagePriceLabel)
        self.contentView.addSubview(self.turnoverLabel)
        self.contentView.addSubview(self.commissionPriceLabel)
        self.contentView.addSubview(self.commissionCountLabel)
        self.contentView.addSubview(self.line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(orderModel: COINOrderBookItemModel) {
        self.orderModel = orderModel
//        print("orderModel+++\(orderModel.toJSON())")
        self.nameLabel.attributedText = orderModel.titleAttr
        if orderModel.side == "Sell" {
            self.modeLabel.backgroundColor = COINUseHabitHelper.shared().bgDropColor
            self.modeLabel.text = "卖出开空"
        } else if orderModel.side == "Buy"  {
            self.modeLabel.backgroundColor = COINUseHabitHelper.shared().bgRiseColor
            self.modeLabel.text = "买入开多"
        } else {
            if orderModel.side != nil {
                var side: String?
                var color: UIColor?
                switch Int(orderModel.side!) { //(1:开多 2:开空 3:平多 4:平空)
                case 1:
                    side = "买入开多"
                    color = COINUseHabitHelper.shared().bgRiseColor
                case 2:
                    side = "卖出开空"
                    color = COINUseHabitHelper.shared().bgDropColor
                case 3:
                    side = "卖出平多"
                    color = COINUseHabitHelper.shared().bgDropColor
                case 4:
                    side = "买入平空"
                    color = COINUseHabitHelper.shared().bgRiseColor
                default:
                    break
                }
                self.modeLabel.backgroundColor = color
                self.modeLabel.text = side
            }
        }
        self.timeLabel.text = orderModel.timestamp
 
        if orderModel.avgPx == nil || orderModel.avgPx == "" {
            self.averagePriceLabel.isHidden = true
        } else {
            self.averagePriceLabel.isHidden = false
            self.setAttributeString(label: self.averagePriceLabel, name: orderModel.currency ?? "", string: "成交均价", content: orderModel.avgPx ?? "", alignment: .right)
        }
        self.setAttributeString(label: self.turnoverLabel, name: "张", string: "成交量", content: orderModel.cumQty ?? "", alignment: .right)
        self.setAttributeString(label: self.commissionPriceLabel, name: orderModel.currency ?? "", string: "委托价", content: orderModel.price ?? "", alignment: .right)
        self.setAttributeString(label: self.commissionCountLabel, name: "张", string: "委托量", content: orderModel.orderQty ?? "", alignment: .right)

        self.depositLabel.isHidden = true
        if orderModel.ordStatus == "New" {
            self.cancelBtn.isHidden = false
            self.stateImageView.isHidden = true
            
//            var deposit: String?
            //起始保证金=总合约价值=单份合约价值*合约数/杠杆 //暂时无法拿到该币的杠杆
//            if orderModel.currency?.uppercased() == orderModel.settlCurrency?.uppercased() {
//                deposit = String(format: "%.4f", Double(orderModel.orderQty ?? "0")!*Double(orderModel.price ?? "1")!)
//            } else {
//                deposit = String(format: "%.4f", Double(orderModel.orderQty ?? "0")!/Double(orderModel.price ?? "1")!)
//            }
//            self.setAttributeString(label: self.depositLabel, name: orderModel.settlCurrency?.uppercased() ?? "", string: "保证金", content: deposit!, alignment: .left)
        } else {
            self.cancelBtn.isHidden = true
            self.stateImageView.isHidden = false
            if orderModel.ordStatus == "Filled" {
                self.stateImageView.image = UIImage.init(named: "trade_success")
            } else {
                self.stateImageView.image = UIImage.init(named: "trade_cancelled")
            }
        }
        if orderModel.fee == nil {
            if self.commisionModel != nil && self.commisionModel?.data != nil {
                self.chargeLabel.isHidden = false
                let model = self.commisionModel!.data![orderModel.symbol!]
                var fee: String?
                var value: Float?
                if orderModel.currency?.uppercased() == orderModel.settlCurrency?.uppercased() {
                    value = Float(orderModel.orderQty ?? "0")! * Float(orderModel.price ?? "1")!
                } else {
                    value = Float(orderModel.orderQty ?? "0")! / Float(orderModel.price ?? "1")!
                }
                if (orderModel.ordType?.contains("Market"))! {
                    fee = String(format: "%f", (model?.takerFee ?? 0.0) * value!)
                } else {
                    fee = String(format: "%f", (model?.makerFee ?? 0.0) * value!)
                }
                if fee!.hasSuffix("0.000000") {
                    fee = "0"
                }
                self.setAttributeString(label: self.chargeLabel, name: orderModel.settlCurrency?.uppercased() ?? "", string: "手续费", content: fee!, alignment: .left)
            } else {
                self.chargeLabel.isHidden = true
            }
        } else {
            self.chargeLabel.isHidden = false
            self.setAttributeString(label: self.chargeLabel, name: orderModel.settlCurrency?.uppercased() ?? "", string: "手续费", content: orderModel.fee!, alignment: .left)
        }
    }
    
    func setAttributeString(label: UILabel, name: String?, string: String, content: String, alignment: NSTextAlignment) {
        var attr: NSMutableAttributedString?
        var upLenght: Int
        if name == nil {
            attr = NSMutableAttributedString.init(string: "\(string)\n\(content)")
            upLenght = string.count
        } else {
            attr = NSMutableAttributedString.init(string: "\(string)(\(name ?? ""))\n\(content)")
            upLenght = name!.count + string.count + 2
        }
        let downLenght = attr!.length - upLenght
        attr!.addAttribute(.font, value: font12, range: NSMakeRange(0, upLenght))
        attr!.addAttribute(.font, value: fontBold10, range: NSMakeRange(upLenght, downLenght))
        attr!.addAttribute(.foregroundColor, value: titleGrayColor, range: NSMakeRange(0, upLenght))
        attr!.addAttribute(.foregroundColor, value: titleBlackColor, range: NSMakeRange(upLenght, downLenght))
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = alignment
        attr!.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr!.length))
        label.attributedText = attr
    }
    
    @objc func cancelOrder() {
        let content = self.orderModel?.titleAttr!.string
        let alert = UIAlertController.init(title: nil, message: "是否撤销\(content!) 委托单", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "取消", style: .default, handler: { (cancel) in
            
        }))
        alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (cancel) in
            if self.cancelHandle != nil {
                self.cancelHandle!(self.orderModel)
            }
        }))
        self.viewController()?.present(alert, animated: true, completion: nil)
    }
}
