//
//  COINSelectionDetailCell.swift
//  Coin
//
//  Created by gm on 2018/11/6.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

fileprivate struct SymbolInfoCellStruct {
    
    static let  hSpacing: CGFloat             = 20.0
    static let  vSpacing: CGFloat             = 10.0
    static let  labelH: CGFloat               = 25.0
    static let  cellW: CGFloat                = UIScreen.main.bounds.size.width
    static let  cellH: CGFloat                = 60
    
    //serialNumberLabel
    static let  serialNumberLabelH: CGFloat   = 20
    static let  serialNumberLabelW: CGFloat   = 20
    static let  serialNumberLabelColors       = [
        UIColor.colorRGB(0xf57d57),
        UIColor.colorRGB(0xf5a957),
        UIColor.colorRGB(0xf5dd57),
        UIColor.colorRGB(0xcadaef)
    ]
    static let  cornerRadius:  CGFloat        = 4.0
    
    //symbolLabel
    static let  symbolLabelW: CGFloat         = 40.0
    
    //timeLabel
    static let  timeLabelW: CGFloat           = 80
    
    //lastChangePcntBtn
    static let  lastChangePcntBtnH: CGFloat   = 30
    static let  lastChangePcntBtnW: CGFloat   = 60
    
    //currencyImageView
    static let  currencyImageViewH: CGFloat   = 20
    
    //collectionBtn
    static let  collectionBtnW: CGFloat       = 40
    
    
}


typealias SelectionDetailCellCallBack = (_ btn: UIButton)->(Void)
class COINSymbolInfoCell: UITableViewCell {
    
    var callBack:SelectionDetailCellCallBack?
    
    private var needIcon    = false
    private var needSerialNumberLabel    = true
    var model: COINInstrumentItemModel? {
        
        didSet{
            self.lastPriceLabel.attributedText = createLastPrice()
            self.indicativeLabel.text = model!.indicativeSettlePrice?.turnPriceStr()
            self.lastChangePcntBtn.setTitle(model!.lastPcnt?.lastPecnStr(), for: .normal)
            self.currencyImageView.image = UIImage.init(named: "currency_" + model!.rootSymbol!.lowercased())
            self.turnoverLabel.text = model!.foreignNotional24h
            var timeStr = model!.timeStr
            
            var bigFontStr = model!.rootSymbol
            if !model!.needRootSymbol {
                let tempString: NSString = timeStr as NSString
                bigFontStr = tempString.substring(to: 2)
                timeStr    = tempString.substring(from: 2)
//                let tempString: Array<String> = timeStr.components(separatedBy: "-")
//                bigFontStr = tempString.first ?? ""
//                timeStr    = "-" + tempString.last!
            }
            let attratStrM = NSMutableAttributedString()
            let attratBigFont = NSAttributedString.init(string: bigFontStr!, attributes: [NSAttributedString.Key.font : font14,NSAttributedString.Key.foregroundColor: UIColor.black])
            let attratSmallFont = NSAttributedString.init(string: " \(timeStr)", attributes: [NSAttributedString.Key.font : font12,NSAttributedString.Key.foregroundColor: titleGrayColor])
            attratStrM.append(attratBigFont)
            attratStrM.append(attratSmallFont)
            self.symbolTimeLabel.attributedText = attratStrM
        }
    }
    
    func createLastPrice() ->NSAttributedString {
        var currency = "฿"
        if model?.quoteCurrency!.uppercased() == "USD" {
            currency = "$"
        }
        
        let attrM = NSMutableAttributedString()
        let currencyAttr =  NSMutableAttributedString.init(string: currency, attributes: [NSAttributedString.Key.font: font14,NSAttributedString.Key.foregroundColor: titleGrayColor])
        let priceAttr    = NSMutableAttributedString.init(string: (self.model?.priceValue?.turnPriceStr())!, attributes: [NSAttributedString.Key.font: font14])
        attrM.append(currencyAttr)
        attrM.append(priceAttr)
        return attrM
    }
    
    private var needCollect = false {
        didSet{
            if self.needSerialNumberLabel {
                self.addSubview(self.serialNumberLabel)
            }
            
            if self.needCollect {
                self.addSubview(self.collectionBtn)
            }
            
            if self.needIcon {
              self.addSubview(self.currencyImageView)
            }
            
            self.addSubview(self.lastChangePcntBtn)
            self.addSubview(self.symbolTimeLabel)
            //self.addSubview(self.timeLabel)
            self.addSubview(self.lastPriceLabel)
            self.addSubview(self.indicativeLabel)
            self.addSubview(self.turnoverLabel)
        }
    }
    
    /// 序列号
    lazy var serialNumberLabel: UILabel = {
        let serialNumberLabel = UILabel()
        serialNumberLabel.backgroundColor = UIColor.red
        serialNumberLabel.textColor       = UIColor.white
        serialNumberLabel.textAlignment   = .center
        serialNumberLabel.text = "1"
        serialNumberLabel.font = font14
        return serialNumberLabel
    }()
    
    /// 符号
    lazy var symbolTimeLabel: COINLabel = {
        let symbolLabelTemp = COINLabel()
        symbolLabelTemp.verticalAlignment = VerticalAlignmentBottom
        return symbolLabelTemp
    }()
    
    
    /// 交易量
    lazy var turnoverLabel: COINLabel = {
        let turnoverLabelTemp = COINLabel()
        turnoverLabelTemp.font = font12
        turnoverLabelTemp.textColor     = UIColor.lightGray
        turnoverLabelTemp.verticalAlignment = VerticalAlignmentTop
        return turnoverLabelTemp
    }()
    
    
//    /// 过期时间
//    lazy var timeLabel: COINLabel = {
//        let timeLabelTemp = COINLabel()
//        timeLabelTemp.font          = font12
//        timeLabelTemp.textAlignment = .left
//        timeLabelTemp.textColor     = UIColor.lightGray
//        timeLabelTemp.verticalAlignment = VerticalAlignmentBottom
//        return timeLabelTemp
//    }()
    
    /// 最新价格
    lazy var lastPriceLabel: COINLabel = {
        let lastPriceLabelTemp = COINLabel()
        lastPriceLabelTemp.verticalAlignment = VerticalAlignmentBottom
        lastPriceLabelTemp.textAlignment = .right
        lastPriceLabelTemp.font = font14
        lastPriceLabelTemp.adjustsFontSizeToFitWidth = true
        return lastPriceLabelTemp
    }()
    
    /// 指数价格label
    lazy var indicativeLabel: COINLabel = {
        let indicativeLabelTemp = COINLabel()
        indicativeLabelTemp.font          = font12
        indicativeLabelTemp.textColor     = UIColor.lightGray
        indicativeLabelTemp.textAlignment = .right
        indicativeLabelTemp.verticalAlignment = VerticalAlignmentTop
        return indicativeLabelTemp
    }()
    
    /// 百分比btn
    lazy var lastChangePcntBtn: COINNotiButton = {
        let lastChangePcntBtnTemp = COINNotiButton()
        lastChangePcntBtnTemp.titleLabel?.font = font12
        return lastChangePcntBtnTemp
    }()
    
    /// 货币图标
    lazy var currencyImageView: UIImageView = {
        let currencyImageViewTemp = UIImageView()
        return currencyImageViewTemp
    }()
    
    /// 收藏按钮
    lazy var collectionBtn: UIButton = {
        let collectionBtnTemp = UIButton()
        collectionBtnTemp.setImage(UIImage.init(named: "collection"), for: .normal)
        collectionBtnTemp.setImage(UIImage.init(named: "collection_sel"), for: .selected)
        collectionBtnTemp.addTarget(self, action: #selector(collectionBtnClick(btn:)), for: .touchUpInside)
        return collectionBtnTemp
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func selectionDetailCell(tableView: UITableView, cellId reuseIdentifier: String, needSerialNumberLabel: Bool, needIcon: Bool,collect: Bool)->COINSymbolInfoCell {
        let selectionDetailCell: COINSymbolInfoCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! COINSymbolInfoCell
        selectionDetailCell.needIcon    = needIcon
        selectionDetailCell.needCollect = collect
        selectionDetailCell.needSerialNumberLabel = needSerialNumberLabel
        return selectionDetailCell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewH = self.frame.size.height
        let viewW = self.frame.size.width
        if self.needSerialNumberLabel {
            let serialNumberLabelY = viewH * 0.5 - SymbolInfoCellStruct.serialNumberLabelH * 0.5
            self.serialNumberLabel.frame = CGRect.init(
                x: SymbolInfoCellStruct.hSpacing,
                y: serialNumberLabelY,
                width: SymbolInfoCellStruct.serialNumberLabelW,
                height: SymbolInfoCellStruct.serialNumberLabelH
            )
            self.serialNumberLabel.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: SymbolInfoCellStruct.cornerRadius, height: SymbolInfoCellStruct.cornerRadius))
        }else{
            self.serialNumberLabel.frame = CGRect.zero
        }
        
        if self.needCollect {
            let collectionBtnTempX = SymbolInfoCellStruct.cellW - SymbolInfoCellStruct.collectionBtnW - 5
            let collectionBtnTempY = viewH * 0.5 - SymbolInfoCellStruct.collectionBtnW * 0.5
            self.collectionBtn.frame = CGRect.init(
                x: collectionBtnTempX,
                y: collectionBtnTempY,
                width: SymbolInfoCellStruct.collectionBtnW,
                height: SymbolInfoCellStruct.collectionBtnW
            )
        }else{
            self.collectionBtn.frame = CGRect.zero
        }
        
        let rightSpacing: CGFloat = self.needCollect ? (self.collectionBtn.frame.minX + 15) : self.bounds.size.width
        let lastChangePcntBtnTempX = rightSpacing - SymbolInfoCellStruct.hSpacing - SymbolInfoCellStruct.lastChangePcntBtnW
        let lastChangePcntBtnTempY = SymbolInfoCellStruct.cellH * 0.5 - SymbolInfoCellStruct.lastChangePcntBtnH * 0.5
        self.lastChangePcntBtn.frame = CGRect.init(
            x: lastChangePcntBtnTempX,
            y: lastChangePcntBtnTempY,
            width: SymbolInfoCellStruct.lastChangePcntBtnW,
            height: SymbolInfoCellStruct.lastChangePcntBtnH
        )
        self.lastChangePcntBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: SymbolInfoCellStruct.cornerRadius, height: SymbolInfoCellStruct.cornerRadius))
        
        if self.needIcon {
            let currencyImageW        = SymbolInfoCellStruct.currencyImageViewH
            let currencyImageY        = SymbolInfoCellStruct.cellH * 0.5 - currencyImageW * 0.5
            let currencyImageX        = self.serialNumberLabel.frame.maxX + 10
            
            self.currencyImageView.frame = CGRect.init(
                x: currencyImageX,
                y: currencyImageY,
                width: currencyImageW,
                height: currencyImageW
            )
        }else{
            self.currencyImageView.frame = CGRect.zero
        }
        var  symbolLabelTempX: CGFloat = 0
        if self.needIcon {
            symbolLabelTempX = self.currencyImageView.frame.maxX + 10
        }else{
            if self.needSerialNumberLabel {
               symbolLabelTempX = self.serialNumberLabel.frame.maxX + 5
            } else {
                symbolLabelTempX = SymbolInfoCellStruct.hSpacing
            }
        }
        let symbolTimeLabelW = viewW * 0.5 - symbolLabelTempX
        self.symbolTimeLabel.frame = CGRect.init(
            x: symbolLabelTempX,
            y: SymbolInfoCellStruct.vSpacing-3,
            width: symbolTimeLabelW,
            height: SymbolInfoCellStruct.labelH
        )
        
        let turnoverLabelTempX = self.symbolTimeLabel.frame.minX
        let turnoverLabelTempY = self.symbolTimeLabel.frame.maxY
        self.turnoverLabel.frame = CGRect.init(
            x: turnoverLabelTempX,
            y: turnoverLabelTempY,
            width: SymbolInfoCellStruct.cellW - 100,
            height: SymbolInfoCellStruct.labelH
        )
        
        let lastPriceLabelX    = viewW * 0.45
        let normalW            = self.lastChangePcntBtn.frame.minX - lastPriceLabelX - SymbolInfoCellStruct.vSpacing
        let lastPriceLabelW    = self.needSerialNumberLabel ? viewW * 0.55 * 0.4 : normalW
        
        self.lastPriceLabel.frame = CGRect.init(
            x: lastPriceLabelX,
            y: SymbolInfoCellStruct.vSpacing-3,
            width: lastPriceLabelW,
            height: SymbolInfoCellStruct.labelH
        )
        
        let indicativeLabelX    = self.lastPriceLabel.frame.minX
        let indicativeLabelY    = self.lastPriceLabel.frame.maxY
        let indicativeLabelW    = self.lastPriceLabel.frame.size.width
        self.indicativeLabel.frame = CGRect.init(
            x: indicativeLabelX,
            y: indicativeLabelY,
            width: indicativeLabelW,
            height: SymbolInfoCellStruct.labelH
        )
    }
    
    @objc func collectionBtnClick(btn: UIButton){
        if (self.callBack != nil) {
            btn.isSelected = !btn.isSelected
            self.callBack!(btn)
        }
    }
    
    func updateSerialNumberLabel(_ index: Int) {
        if index < 1 {
            return
        }
        
        self.serialNumberLabel.text = "\(index)"
        if index > 4 {
            self.serialNumberLabel.backgroundColor = SymbolInfoCellStruct.serialNumberLabelColors[3]
        }else{
            self.serialNumberLabel.backgroundColor = SymbolInfoCellStruct.serialNumberLabelColors[index-1]
        }
    }
}
