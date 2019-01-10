//
//  COINOptionalListView.swift
//  Coin
//
//  Created by dev6 on 2018/11/28.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

private struct COINOptionalListViewUX {
    static let HPadding: CGFloat = 12
    static let VPadding: CGFloat = 15
    
    static let CellHeight: CGFloat = 60
    
    static let HeaderName: String = "COINOptionalTableSectionHeader"
    static let CellName: String = "COINOptionalTableViewCell"
}

class COINOptionalListView: UIView, UITableViewDataSource,UITableViewDelegate {

    var platform: Platform = .bitmex
    
    var optionalModel: COINInstrumentModel?{
        get {
            return _optionalModel
        }
        set {
            if self.selectedType == 0 {
                _optionalModel = newValue
            } else if self.selectedType == 1 && newValue?.data != nil {
                if self.dataDict.count == 0 {
                    for model in newValue!.data! {
                        if self.symbolArr!.contains(model.rootSymbol!) {
                            if self.dataDict[model.rootSymbol!] != nil {
                                var arr = (self.dataDict[model.rootSymbol!])!
                                arr.append(model)
                                self.dataDict[model.rootSymbol!] = arr
                            } else {
                                self.dataDict[model.rootSymbol!] = [model]
                            }
                        }
                    }
                }
            }
            self.optionalTableView.reloadData()
        }
    }
    lazy var dataDict = [String: [COINInstrumentItemModel]]()
    
    var symbolArr: [String]?
    
    private var _optionalModel: COINInstrumentModel?
    
    var changeTypeHandle: ((Int)->())?
    
    var selectedSymbolHandle: ((COINInstrumentItemModel)->())?
    
    lazy var titleView: UIView = {
        let titleView = UIView()
        let optionalBtn = UIButton.init(type: .custom)
        optionalBtn.setTitle("自选", for: .normal)
        optionalBtn.titleLabel?.font = font14
        optionalBtn.setTitleColor(titleBlueColor, for: .normal)
        optionalBtn.frame = CGRect.init(x: 0, y: 0, width: 64, height: 60)
        optionalBtn.addTarget(self, action: #selector(optionalAction), for: .touchUpInside)
        titleView.addSubview(optionalBtn)
        self.optionalBtn = optionalBtn
        self.selectedLine.center = CGPoint.init(x: optionalBtn.center.x, y: self.selectedLine.center.y)
        
        let allBtn = UIButton.init(type: .custom)
        allBtn.setTitle("全部", for: .normal)
        allBtn.titleLabel?.font = font14
        allBtn.setTitleColor(titleGrayColor, for: .normal)
        allBtn.frame = CGRect.init(x: 64, y: 0, width: 64, height: 60)
        allBtn.addTarget(self, action: #selector(allAction), for: .touchUpInside)
        self.allBtn = allBtn
        titleView.addSubview(allBtn)
        
        titleView.addSubview(self.selectedLine)
        
        let line = UIView()
        line.backgroundColor = lineGrayColor
        titleView.addSubview(line)
        line.snp.makeConstraints({ (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        })
        return titleView
    }()
    
    var selectedType: Int = 0 //0是自选，1是全部
    
    var optionalBtn: UIButton?
    
    var allBtn: UIButton?
    
    lazy var selectedLine: UIView = {
        let selectedLine = UIView.init(frame: CGRect.init(x: 0, y: 42, width: 18, height: 2))
        selectedLine.backgroundColor = lineBlueColor
        return selectedLine
    }()
    
    lazy var optionalTableView: UITableView = {
        let optionalTableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        optionalTableView.rowHeight = COINOptionalListViewUX.CellHeight
        optionalTableView.delegate = self
        optionalTableView.dataSource = self
        optionalTableView.separatorStyle = .none
        optionalTableView.register(COINOptionalTableViewCell.self, forCellReuseIdentifier: COINOptionalListViewUX.CellName)
        optionalTableView.register(COINOptionalTableSectionHeader.self, forHeaderFooterViewReuseIdentifier: COINOptionalListViewUX.HeaderName)
        return optionalTableView
    }()
    
    lazy var rightView: UIView = {
        let rightView = UIView()
        rightView.backgroundColor = titleBlackColor
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(removeView))
        rightView.addGestureRecognizer(tap)
        
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 10, width: 48, height: 48)
        btn.setImage(UIImage(named: "trade_titleLeft")?.createByTintColor(whiteColor), for: .normal)
        btn.imageView?.contentMode = .center
        btn.isUserInteractionEnabled = false
        rightView.addSubview(btn)
        
        return rightView
    }()
    
    init(frame: CGRect, platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        if platform == .bitmex {
            self.symbolArr = ["XBT","ETH","ADA","BCH","EOS","LTC","TRX","XRP"]
        } else {
            self.symbolArr = ["BTC","LTC","ETH","ETC","XRP","EOS","BTG","BCH","BSV"]
        }
        
        self.backgroundColor = whiteColor
        self.addSubview(self.titleView)
        self.titleView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(-48)
            make.height.equalTo(60)
        }
        
        self.addSubview(self.optionalTableView)
        self.optionalTableView.snp.makeConstraints { (make) in
            make.top.equalTo(60)
            make.left.equalTo(0)
            make.right.equalTo(-48)
            make.bottom.equalTo(0)
        }
        
        self.addSubview(self.rightView)
        self.rightView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.width.equalTo(48)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ----UITableViewDataSource----
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: COINOptionalTableViewCell = tableView.dequeueReusableCell(withIdentifier: COINOptionalListViewUX.CellName, for: indexPath) as! COINOptionalTableViewCell
        if self.selectedType == 0 {
            if _optionalModel?.data?.count ?? 0 > indexPath.row {
                let model = _optionalModel?.data![indexPath.row]
                cell.setContent(model!)
                cell.line.isHidden = false
                cell.logoImageView.isHidden = false
                cell.logoImageView.snp.updateConstraints { (make) in
                    make.width.equalTo(20)
                }
            }
        } else {
            if self.symbolArr!.count > indexPath.section && self.dataDict.count > 0 {
                cell.logoImageView.isHidden = true
                cell.logoImageView.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                let arr = self.dataDict[self.symbolArr![indexPath.section]]
                if arr!.count > indexPath.row {
                    let model = arr![indexPath.row]
                    cell.setContent(model)
                    if indexPath.row == arr!.count - 1 {
                        cell.line.isHidden = true
                    } else {
                        cell.line.isHidden = false
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedType == 0 {
            return _optionalModel?.data?.count ?? 0
        } else {
            if section < self.symbolArr!.count && self.dataDict.count > 0 {
                return self.dataDict[self.symbolArr![section]]?.count ?? 0
            }
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.selectedType == 0 {
            return 1
        } else {
            return self.symbolArr!.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.selectedType == 0 {
            return 0.001
        } else {
            return 49
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.selectedType == 0 {
            return nil
        } else {
            let view: COINOptionalTableSectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: COINOptionalListViewUX.HeaderName) as! COINOptionalTableSectionHeader
            if section < self.symbolArr!.count {
                view.setContent(self.symbolArr![section])
            }
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.selectedType == 0 {
            return 0.001
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selectedType == 0 {
            if _optionalModel?.data?.count ?? 0 > indexPath.row {
                let model = _optionalModel?.data![indexPath.row]
                if self.selectedSymbolHandle != nil {
                    self.selectedSymbolHandle!(model!)
                }
            }
        } else {
            if self.symbolArr!.count > indexPath.section && self.dataDict.count > 0 {
                let arr = self.dataDict[self.symbolArr![indexPath.section]]
                if arr!.count > indexPath.row {
                    let model = arr![indexPath.row]
                    if self.selectedSymbolHandle != nil {
                        self.selectedSymbolHandle!(model)
                    }
                }
            }
        }
        self.removeView()
    }
    
    @objc func removeView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect.init(x: -screenWidth, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    @objc func optionalAction() {
        self.optionalBtn?.setTitleColor(titleBlueColor, for: .normal)
        self.allBtn?.setTitleColor(titleGrayColor, for: .normal)
        UIView.animate(withDuration: 0.25) {
            self.selectedLine.center.x = self.optionalBtn!.center.x
        }
        self.selectedType = 0
        self.optionalTableView.reloadData()
        if _optionalModel?.data?.count ?? 0 > 0 {
            return
        }
        if self.changeTypeHandle != nil {
            self.changeTypeHandle!(0)
        }
    }
    
    @objc func allAction() {
        self.optionalBtn?.setTitleColor(titleGrayColor, for: .normal)
        self.allBtn?.setTitleColor(titleBlueColor, for: .normal)
        UIView.animate(withDuration: 0.25) {
            self.selectedLine.center.x = self.allBtn!.center.x
        }
        self.selectedType = 1
        self.optionalTableView.reloadData()
        if self.dataDict.count > 0 {
            return
        }
        if self.changeTypeHandle != nil {
            self.changeTypeHandle!(1)
        }
    }
}

class COINOptionalTableViewCell: UITableViewCell {
    lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.contentMode = .center
        return logoImageView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = font14
        return nameLabel
    }()
    
    lazy var marketValueLabel: UILabel = {
        let marketValueLabel = UILabel()
        marketValueLabel.font = font10
        marketValueLabel.textColor = titleGrayColor
        return marketValueLabel
    }()
    
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.font = font14
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.textAlignment = .right
        priceLabel.textColor = titleBlackColor
        return priceLabel
    }()
    
    lazy var markPriceLabel: UILabel = {
        let markPriceLabel = UILabel()
        markPriceLabel.font = font10
        markPriceLabel.textAlignment = .right
        markPriceLabel.textColor = titleGrayColor
        return markPriceLabel
    }()
    
    lazy var priceChangePcntLabel: UILabel = {
        let priceChangePcntLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 28))
        priceChangePcntLabel.font = font12
        priceChangePcntLabel.textColor = whiteColor
        priceChangePcntLabel.textAlignment = .center
        priceChangePcntLabel.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        return priceChangePcntLabel
    }()
    
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = lineGrayColor
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.logoImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.marketValueLabel)
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.markPriceLabel)
        self.contentView.addSubview(self.priceChangePcntLabel)
        self.contentView.addSubview(self.line)
        self.logoImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(COINOptionalListViewUX.CellHeight/2)
            make.left.equalTo(COINOptionalListViewUX.HPadding)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(COINOptionalListViewUX.VPadding)
            make.left.equalTo(self.logoImageView.snp.right).offset(4)
            make.right.equalTo(self.priceLabel.snp.left)
        }
        self.marketValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(2)
            make.left.equalTo(self.logoImageView.snp.right).offset(4)
            make.right.equalTo(self.markPriceLabel.snp.left)
        }
        self.priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(COINOptionalListViewUX.VPadding)
            make.left.equalTo(self.nameLabel.snp.right)
            make.right.equalTo(self.priceChangePcntLabel.snp.left).offset(-10)
        }
        self.markPriceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.priceLabel.snp.bottom).offset(2)
            make.left.equalTo(self.marketValueLabel.snp.right)
            make.right.equalTo(self.priceChangePcntLabel.snp.left).offset(-10)
        }
        self.priceChangePcntLabel.snp.makeConstraints { (make) in
            make.top.equalTo(COINOptionalListViewUX.VPadding)
            make.right.equalTo(-COINOptionalListViewUX.HPadding)
            make.size.equalTo(CGSize.init(width: 60, height: 28))
        }
        self.line.snp.makeConstraints { (make) in
            make.left.equalTo(COINOptionalListViewUX.HPadding)
            make.right.equalTo(COINOptionalListViewUX.HPadding)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(_ model: COINInstrumentItemModel) {
        if (model.priceValue == nil || model.lastPcnt == nil) {
            return
        }
        self.priceLabel.text  = model.priceValue?.turnPriceStr()
        self.markPriceLabel.text = model.indicativeSettlePrice?.turnPriceStr()
        self.priceChangePcntLabel.text = model.lastPcnt?.lastPecnStr()
        if model.lastPcnt ?? 0.0 > 0.0 {
            self.priceChangePcntLabel.backgroundColor = COINUseHabitHelper.shared().bgRiseColor
        } else {
            self.priceChangePcntLabel.backgroundColor = COINUseHabitHelper.shared().bgDropColor
        }
        self.logoImageView.image = UIImage.init(named: "currency_" + (model.rootSymbol?.lowercased())!)
        self.marketValueLabel.text = model.foreignNotional24h
        
        var timeStr = model.timeStr
        var bigFontStr = model.rootSymbol
        if !model.needRootSymbol {
            let tempString: NSString = timeStr as NSString
            bigFontStr = tempString.substring(to: 2)
            timeStr    = tempString.substring(from: 2)
        }
        let attratStrM = NSMutableAttributedString()
        let attratBigFont = NSAttributedString.init(string: bigFontStr ?? "", attributes: [NSAttributedString.Key.font : font15,NSAttributedString.Key.foregroundColor: UIColor.black])
        let attratSmallFont = NSAttributedString.init(string: " \(timeStr)", attributes: [NSAttributedString.Key.font : font12,NSAttributedString.Key.foregroundColor: titleGrayColor])
        attratStrM.append(attratBigFont)
        attratStrM.append(attratSmallFont)
        self.nameLabel.attributedText = attratStrM
    }
    
    func timeLabelTitle(_ detail: COINInstrumentItemModel)->String{
        
        let expiryDate = detail.expiry?.utcConvertedToDate()
        var timeLabelTitle: String = ""
        let yyyyMMdd   = detail.expiry?.components(separatedBy: "T").first
        let yyyyMMdds  = yyyyMMdd?.components(separatedBy: "-")
        let mmddStr       = "-\(yyyyMMdds![1])\(yyyyMMdds![2])"
        //判断是不是周
        if (detail.symbol?.lowercased().contains("7d"))!{
            //判断是不是本周
            if Calendar.current.isDateInWeek("UTC", Date(), expiryDate!){
                timeLabelTitle.append("当周")
            }else{
                timeLabelTitle.append(contentsOf: "次周")
            }
        }else{
            //判断是不是本季度
            if Calendar.current.isDateInQuarter("UTC", Date(), expiryDate!){
                timeLabelTitle.append(contentsOf: "当季")
            }else{
                timeLabelTitle.append(contentsOf: "次季")
            }
        }
        return timeLabelTitle + mmddStr
    }
}


class COINOptionalTableSectionHeader: UITableViewHeaderFooterView {
    lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.contentMode = .center
        return logoImageView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = font15
        return nameLabel
    }()
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = lineGrayColor
        return line
    }()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = whiteColor
        self.contentView.addSubview(self.logoImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.line)
        self.logoImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(25)
            make.left.equalTo(COINOptionalListViewUX.HPadding)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(25)
            make.left.equalTo(self.logoImageView.snp.right).offset(4)
        }
        self.line.snp.makeConstraints { (make) in
            make.left.equalTo(COINOptionalListViewUX.HPadding)
            make.right.equalTo(COINOptionalListViewUX.HPadding)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(_ symbol: String) {
        self.logoImageView.image = UIImage.init(named: "currency_" + symbol.lowercased())
        self.nameLabel.text = symbol
    }
}
