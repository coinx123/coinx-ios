//
//  PositionView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/8.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit
import MJRefresh

struct COINPositionViewUX {
    static let HPadding: CGFloat = 15
    static let VPadding: CGFloat = 12
    
    static let TopHeight: CGFloat = 45
    static let CenterHeight: CGFloat = 64
    static let BottomHeight: CGFloat = 154
    
    static let CellHeight: CGFloat = 268
    static let CellName = "PositionCell"
}

class COINPositionView: UIView, UITableViewDelegate,UITableViewDataSource {
    
    var platform: Platform?
    
    var positionModel: COINPositionModel?{
        get {
            return _positionModel
        }
        set {
            _positionModel = newValue
            if _positionModel?.data?.count == 0 {
                self.addSubview(self.emptyView)
            } else if self.emptyView.superview != nil {
                self.emptyView.removeFromSuperview()
            }
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    private var _positionModel: COINPositionModel?
    
    var marginModel: COINMarginModel?
    
    var symbolsArr: [String]?
    
    var selectedSymbol = "全部"
    
    var changeSymbolHandle: ((String)->())?
    
    lazy var emptyView: COINEmptyView = {
        let emptyView = COINEmptyView.init(frame: CGRect.init(x: 0, y: COINPositionViewUX.TopHeight, width: self.bounds.size.width, height: self.bounds.size.height - COINPositionViewUX.TopHeight), type: .noData)
        return emptyView
    }()
    
    lazy var titleBtn: UIButton = {
        let titleBtn = UIButton.init(type: .custom)
        titleBtn.backgroundColor = whiteColor
        titleBtn.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: COINPositionViewUX.TopHeight)
        titleBtn.setTitle(self.selectedSymbol, for: .normal)
        titleBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        titleBtn.setImage(UIImage.init(named: "trade_downArrow")?.createByTintColor(titleBlueColor_Light), for: .normal)
        titleBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 44, bottom: 0, right: 0)
        titleBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -30, bottom: 0, right: 0)
        titleBtn.titleLabel?.font = fontBold13
        titleBtn.addTarget(self, action: #selector(titleAction), for: .touchUpInside)
        return titleBtn
    }()
    
    var selectedIndex: Int = 0
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: COINPositionViewUX.TopHeight, width: self.bounds.size.width, height: self.bounds.size.height - COINPositionViewUX.TopHeight), style: .grouped)
        tableView.register(COINPositionCell.self, forCellReuseIdentifier: COINPositionViewUX.CellName)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = COINPositionViewUX.CellHeight
        tableView.backgroundColor = bgColor
        weak var weakSelf = self
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            if weakSelf?.changeSymbolHandle != nil {
                weakSelf?.changeSymbolHandle!(weakSelf!.selectedSymbol)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                    if weakSelf?.tableView.mj_header.isRefreshing ?? false {
                        self.tableView.mj_header.endRefreshing()
                    }
                }
            }
        })
        return tableView
    }()
    
    init(frame: CGRect, platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        if platform == .bitmex {
            self.symbolsArr = ["全部","XBT","ETH","ADA","BCH","EOS","LTC","TRX","XRP"]
        }
        self.addSubview(self.titleBtn)
        self.addSubview(self.tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func titleAction() {
        if self.symbolsArr == nil {
            return
        }
        let view = COINSelectView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), data: self.symbolsArr!)
        UIApplication.shared.keyWindow!.addSubview(view)
        view.showView()
        weak var weakSelf = self
        view.complectionHandle = { (selectIndex,text) in
            if weakSelf?.changeSymbolHandle != nil && text != nil {
                weakSelf?.selectedSymbol = text!
                weakSelf?.titleBtn.setTitle(weakSelf?.selectedSymbol, for: .normal)
                let width = (weakSelf?.selectedSymbol.maxHeight(height: (weakSelf?.titleBtn.frame.size.height)!, font: fontBold13))! * (text!.count > 3 ? 1.85 : 1.4)
                weakSelf?.titleBtn.imageEdgeInsets = UIEdgeInsets.init(top: CGFloat(0.0), left: width, bottom: CGFloat(0.0), right: CGFloat(0.0))
                weakSelf?.changeSymbolHandle!(text!)
            }
        }
    }
    
    // MARK: ----UITableViewDataSource----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _positionModel?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: COINPositionCell = tableView.dequeueReusableCell(withIdentifier: COINPositionViewUX.CellName, for: indexPath) as! COINPositionCell
        if _positionModel?.data?.count ?? 0 > indexPath.section {
            let model = _positionModel?.data![indexPath.section]
            cell.marginModel = self.marginModel
            cell.platform = self.platform
            cell.setContent(positionModel: model!)
            if self.platform == .okex {
                cell.changeDepositBtn.isHidden = true
            }
            cell.depositLabel.isHidden = (self.platform == .okex && Bool((model?.crossMargin)!)!)
            weak var weakSelf = self
            cell.refreshHandle = {
                if weakSelf?.changeSymbolHandle != nil {
                    weakSelf?.changeSymbolHandle!((weakSelf?.selectedSymbol)!)
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

class COINPositionCell: UITableViewCell {
    
    var platform: Platform?
    
    var positionModel: COINPositionItemModel?
    
    var marginModel: COINMarginModel?
    
    var refreshHandle: (()->())?
    
    lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView.init(frame: CGRect.init(x: COINPositionViewUX.HPadding, y: COINPositionViewUX.VPadding, width: 20, height: 20))
        return logoImageView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: CGRect.init(x: self.logoImageView.frame.maxX + 5, y: 0, width: 100, height: COINPositionViewUX.TopHeight))
        titleLabel.text = "BTC"
        titleLabel.font = fontBold14
        titleLabel.textColor = titleBlackColor
        return titleLabel
    }()
    lazy var lineOne: UIView = {
        let lineOne = UIView.init(frame: CGRect.init(x: COINPositionViewUX.HPadding, y: COINPositionViewUX.TopHeight, width: screenWidth - COINPositionViewUX.HPadding * 2, height: 1))
        lineOne.backgroundColor = lineGrayColor
        return lineOne
    }()
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel.init(frame: CGRect.init(x: COINPositionViewUX.HPadding, y: self.lineOne.frame.maxY + COINPositionViewUX.VPadding, width: 140, height: 20))
        nameLabel.text = "BTC"
        nameLabel.font = font14
        nameLabel.textColor = titleBlackColor
        return nameLabel
    }()
    lazy var modeLabel: UILabel = {
        let modeLabel = UILabel.init(frame: CGRect.init(x: COINPositionViewUX.HPadding, y: self.nameLabel.frame.maxY + 2, width: 64, height: 20))
        modeLabel.text = "多头 10X"
        modeLabel.textColor = whiteColor
        modeLabel.backgroundColor = bgGreenColor
        modeLabel.textAlignment = .center
        modeLabel.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        modeLabel.font = font10
        return modeLabel
    }()
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 200 - COINPositionViewUX.HPadding, y: self.lineOne.frame.maxY, width: 100, height: COINPositionViewUX.CenterHeight))
        priceLabel.font = font14
        priceLabel.textAlignment = .right
        priceLabel.numberOfLines = 2
        return priceLabel
    }()
    lazy var earningsPcntLabel: UILabel = {
        let earningsPcntLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 100 - COINPositionViewUX.HPadding, y: self.lineOne.frame.maxY, width: 100, height: COINPositionViewUX.CenterHeight))
        earningsPcntLabel.font = font14
        earningsPcntLabel.numberOfLines = 2
        earningsPcntLabel.textAlignment = .right
        return earningsPcntLabel
    }()
    lazy var lineTwo: UIView = {
        let lineTwo = UIView.init(frame: CGRect.init(x: COINPositionViewUX.HPadding, y: COINPositionViewUX.TopHeight + COINPositionViewUX.CenterHeight, width: screenWidth - COINPositionViewUX.HPadding * 2, height: 1))
        lineTwo.backgroundColor = lineGrayColor
        return lineTwo
    }()
    lazy var earningsLabel: UILabel = {
        let earningsLabel = UILabel.init(frame: CGRect.init(x: COINPositionViewUX.HPadding, y: self.lineTwo.frame.maxY + COINPositionViewUX.VPadding, width: 100, height: 40))
        earningsLabel.font = font10
        earningsLabel.numberOfLines = 2
        return earningsLabel
    }()
    lazy var positionCountLabel: UILabel = {
        let positionCountLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 200 - COINPositionViewUX.HPadding, y: self.lineTwo.frame.maxY + COINPositionViewUX.VPadding, width: 100, height: 40))
        positionCountLabel.font = font10
        positionCountLabel.numberOfLines = 2
        positionCountLabel.textAlignment = .right
        return positionCountLabel
    }()
    lazy var closePositionCountLabel: UILabel = {
        let closePositionCountLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 100 - COINPositionViewUX.HPadding, y: self.lineTwo.frame.maxY + COINPositionViewUX.VPadding, width: 100, height: 40))
        closePositionCountLabel.font = font10
        closePositionCountLabel.numberOfLines = 2
        closePositionCountLabel.textAlignment = .right
        return closePositionCountLabel
    }()
    lazy var depositLabel: UILabel = {
        let depositLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 200 - COINPositionViewUX.HPadding, y: self.positionCountLabel.frame.maxY + COINPositionViewUX.VPadding, width: 100, height: 40))
        depositLabel.font = font10
        depositLabel.numberOfLines = 2
        depositLabel.textAlignment = .right
        return depositLabel
    }()
    lazy var closePriceLabel: UILabel = {
        let closePriceLabel = UILabel.init(frame: CGRect.init(x: screenWidth - 100 - COINPositionViewUX.HPadding, y: self.positionCountLabel.frame.maxY + COINPositionViewUX.VPadding, width: 100, height: 40))
        closePriceLabel.font = font10
        closePriceLabel.numberOfLines = 2
        closePriceLabel.textAlignment = .right
        return closePriceLabel
    }()
    lazy var changeDepositBtn: UIButton = {
        let changeDepositBtn = UIButton.init(type: .custom)
        changeDepositBtn.frame = CGRect.init(x: screenWidth - 210 - COINPositionViewUX.HPadding, y: self.depositLabel.frame.maxY + COINPositionViewUX.VPadding, width: 90, height: 30)
        changeDepositBtn.setTitle("调整保证金", for: .normal)
        changeDepositBtn.titleLabel?.font = font12
        changeDepositBtn.setTitleColor(titleBlueColor, for: .normal)
        changeDepositBtn.layer.borderColor = lineBlueColor.cgColor
        changeDepositBtn.layer.borderWidth = 1
        changeDepositBtn.layer.cornerRadius = 15
        changeDepositBtn.addTarget(self, action: #selector(changeDepositAction), for: .touchUpInside)
        return changeDepositBtn
    }()
    lazy var closePositionBtn: UIButton = {
        let closePositionBtn = UIButton.init(type: .custom)
        closePositionBtn.frame = CGRect.init(x: screenWidth - 90 - COINPositionViewUX.HPadding, y: self.depositLabel.frame.maxY + COINPositionViewUX.VPadding, width: 90, height: 30)
        closePositionBtn.setTitle("平仓", for: .normal)
        closePositionBtn.setTitleColor(whiteColor, for: .normal)
        closePositionBtn.backgroundColor = bgBlueColor
        closePositionBtn.titleLabel?.font = font12
        closePositionBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 30, height: 30))
        closePositionBtn.addTarget(self, action: #selector(closePositionAction), for: .touchUpInside)
        return closePositionBtn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.logoImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.lineOne)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.modeLabel)
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.earningsPcntLabel)
        self.contentView.addSubview(self.lineTwo)
        self.contentView.addSubview(self.earningsLabel)
        self.contentView.addSubview(self.positionCountLabel)
        self.contentView.addSubview(self.closePositionCountLabel)
        self.contentView.addSubview(self.depositLabel)
        self.contentView.addSubview(self.closePriceLabel)
        self.contentView.addSubview(self.changeDepositBtn)
        self.contentView.addSubview(self.closePositionBtn)
    }
    
    func setContent(positionModel: COINPositionItemModel) {
        self.positionModel = positionModel
        
        self.logoImageView.image = UIImage.init(named: "currency_\(positionModel.underlying?.lowercased() ?? "XBT")")
        
        self.setAttributeString(label: self.priceLabel, name: nil, string: "开仓价格", content: positionModel.avgCostPrice ?? "", alignment: .right, downFont: fontBold14)
        var color: UIColor?
        if Double(positionModel.unrealisedPnlPcnt ?? "0")! > 0 {
            color = COINUseHabitHelper.shared().bgRiseColor
        } else {
            color = COINUseHabitHelper.shared().bgDropColor
        }
        let leverageCount = Double(positionModel.leverage ?? "1")!
        self.setAttributeString(label: self.earningsPcntLabel, name: nil, string: "收益率", content: String(format: "%.2f", Double(positionModel.unrealisedPnlPcnt ?? "0")! * 100.0 * leverageCount) + "%", alignment: .right, downFont: fontBold14, downColor: color!)
        var count = 1.0
        if positionModel.symbol == "XBTJPY" {
            count = 100.0
        } else if positionModel.symbol == "XBTKRW" {
            count = 1000.0
        }
        var earnings: String?
        var earningsCurrency: String?
        if positionModel.foreignNotional != nil { //
            let foreignNotional = fabs(Double(positionModel.foreignNotional ?? "1.0")!) //Value of position in units of quoteCurrency.
            earnings = String(format: "%.4f", Double(positionModel.unrealisedPnlPcnt ?? "0")! * foreignNotional)
            earningsCurrency = positionModel.quoteCurrency
        } else {
            earnings = String(format: "%.4f", Double(positionModel.unrealisedPnlPcnt ?? "0")! * fabs(Double(positionModel.currentQty ?? "0")!) * leverageCount * count)
            earningsCurrency = "张"
        }

        self.setAttributeString(label: self.earningsLabel, name: earningsCurrency ?? "", string: "收益", content: earnings!, alignment: .left)
        self.setAttributeString(label: self.positionCountLabel, name: "张", string: "持仓量", content: positionModel.currentQty ?? "", alignment: .right)
        var canUseCount = Int(positionModel.currentQty ?? "0")!
        if canUseCount > 0 {
            canUseCount = canUseCount - Int(positionModel.openOrderSellQty ?? "0")!
            if canUseCount < 0 {
                canUseCount = 0
            }
        } else {
            canUseCount = canUseCount + Int(positionModel.openOrderBuyQty ?? "0")!
            if canUseCount > 0 {
                canUseCount = 0
            }
        }
        self.setAttributeString(label: self.closePositionCountLabel, name: "张", string: "可平仓量", content: "\(canUseCount)", alignment: .right)
        
        self.setAttributeString(label: self.depositLabel, name: positionModel.currency?.uppercased() ?? "", string: "保证金", content: (positionModel.maintMargin ?? "0").fourDecimalPlacesWithoutUnits(), alignment: .right)
        self.setAttributeString(label: self.closePriceLabel, name: positionModel.quoteCurrency ?? "", string: "强平价格", content: positionModel.liquidationPrice ?? "", alignment: .right)
        
        self.titleLabel.text = positionModel.underlying
        self.nameLabel.attributedText = positionModel.titleAttr
        
        self.changeDepositBtn.isHidden = Bool(positionModel.crossMargin!)!
        let leverage = (Bool(positionModel.crossMargin!)! ? "全仓" : String(format: "%.0fX", Float(positionModel.leverage ?? "") ?? 0.0))
        self.modeLabel.text = "\(Int(positionModel.currentQty ?? "0")! > 0 ? "多头" : "空头")  \(leverage)"
        
        if Int(positionModel.currentQty ?? "0")! > 0 {
            self.modeLabel.backgroundColor = COINUseHabitHelper.shared().bgRiseColor
        } else {
            self.modeLabel.backgroundColor = COINUseHabitHelper.shared().bgDropColor
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAttributeString(label: UILabel, name: String?, string: String, content: String, alignment: NSTextAlignment, upFont: UIFont = font12, downFont: UIFont = fontBold10, upColor: UIColor = titleGrayColor, downColor: UIColor = titleBlackColor) {
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
        attr!.addAttribute(.font, value: upFont, range: NSMakeRange(0, upLenght))
        attr!.addAttribute(.font, value: downFont, range: NSMakeRange(upLenght, downLenght))
        attr!.addAttribute(.foregroundColor, value: upColor, range: NSMakeRange(0, upLenght))
        attr!.addAttribute(.foregroundColor, value: downColor, range: NSMakeRange(upLenght, downLenght))
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = alignment
        attr!.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr!.length))
        label.attributedText = attr
    }
    
    @objc func closePositionAction() {
        if self.positionModel == nil {
            return
        }
        let view = COINClosePositionView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), positionModel: self.positionModel!, platform: self.platform!)
        UIApplication.shared.keyWindow!.addSubview(view)
        weak var weakSelf = self
        view.refreshHandle = {
            if weakSelf?.refreshHandle != nil {
                weakSelf?.refreshHandle!()
            }
        }
        view.showView()
    }
    
    @objc func changeDepositAction() {
        if self.positionModel == nil || self.marginModel == nil {
            return
        }
        let view = COINChangeDepositView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), positionModel: self.positionModel!, marginModel: self.marginModel!)
        UIApplication.shared.keyWindow!.addSubview(view)
        view.showView()
        weak var weakSelf = self
        view.depositChangeHandle = {
            if weakSelf?.refreshHandle != nil {
                weakSelf?.refreshHandle!()
            }
        }
    }
}
