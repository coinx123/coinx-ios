//
//  COINCardView.swift
//  Coin
//
//  Created by gm on 2018/11/14.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
private struct CardViewStruct {
    //platformLabel
    static let  labelH: CGFloat               = 22.0
    static let  hSpacing: CGFloat             = 5
    static let  vSpacing: CGFloat             = 10.0
    
    static let colors = [
        UIColor.colorRGB(0xf64d5d),
        UIColor.colorRGB(0x2bb00c)
    ]
}
typealias CardViewCallBack = (_ cardView: COINCardView) -> ()
class COINCardView: UIView {
    
    var callBack: CardViewCallBack?
    
    var symbolInfoModel: COINInstrumentItemModel?{
        didSet{
            if (symbolInfoModel != nil) {
                let usd = symbolInfoModel!.symbol!.replacingOccurrences(of: symbolInfoModel!.rootSymbol!, with: "")
                let rootSymbol: String    = "\(symbolInfoModel!.rootSymbol!)/\(usd)"
                let lastPrice: String     = (symbolInfoModel!.priceValue?.turnPriceStr())!
                let lastPecn: String      = (symbolInfoModel!.lastPcnt?.lastPecnStr())!
                let lastPecnValue: Float  = symbolInfoModel!.lastPcnt!
                self.updateSubViews(rootSymbol: rootSymbol, lastPrice: lastPrice, lastPecn: lastPecn, lastPecnValue: lastPecnValue)
            }
        }
    }
    
    lazy var platformLabel: UILabel = {
        let platformLabel           = UILabel()
        platformLabel.textAlignment = .right
        platformLabel.font          = font10
        platformLabel.textColor     = UIColor.colorRGB(0x819af6)
        platformLabel.text          = "BitMex"
        return platformLabel
    }()
    
    lazy var coinTypesLebel: UILabel = {
        let coinTypesLebel = UILabel()
        coinTypesLebel.textAlignment = .center
        coinTypesLebel.font          = fontBold14
        coinTypesLebel.textColor     = UIColor.colorRGB(0x333333)
        //coinTypesLebel.text          = "TCB/USD"
        return coinTypesLebel
    }()
    
    /// 最新价格
    lazy var lastPriceLabel: COINNotiLabel = {
        let lastPriceLabel           = COINNotiLabel()
        lastPriceLabel.judgingBytIsGreen  = true
        lastPriceLabel.colors        = CardViewStruct.colors
        lastPriceLabel.textAlignment = .center
        lastPriceLabel.font          = fontBold18
        lastPriceLabel.textColor     = UIColor.colorRGB(0xf64d5d)
        //lastPriceLabel.text          = "6420.45"
        return lastPriceLabel
    }()
    
    /// 最新24小时百分比
    lazy var lastPecLabel: COINNotiLabel  = {
        let lastPecLabel = COINNotiLabel()
        lastPecLabel.colors         = CardViewStruct.colors
        lastPecLabel.textAlignment  = .center
        lastPecLabel.font           = fontBold12
        lastPecLabel.textColor      = UIColor.colorRGB(0xf64d5d)
        //lastPecLabel.text           = "-0.52%"
        return lastPecLabel
    }()
    
    lazy var cnyPriceLabel: UILabel = {
        let cnyPriceLabel           = UILabel()
        cnyPriceLabel.textAlignment = .center
        cnyPriceLabel.font          = font12
        cnyPriceLabel.textColor     = UIColor.colorRGB(0xffffff)
        cnyPriceLabel.text          = "BitMex"
        return cnyPriceLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.addSubview(self.platformLabel)
        let imageView = UIImageView.init(frame: self.bounds)
        imageView.image = UIImage.init(named: "quote_cardbg")
        self.addSubview(imageView)
        self.addSubview(self.coinTypesLebel)
        self.addSubview(self.lastPriceLabel)
        self.addSubview(self.lastPecLabel)
        self.addSubview(self.cnyPriceLabel)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cardViewClick(tap:)))
        self.addGestureRecognizer(tap)
        self.layer.cornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewW = self.frame.size.width
        let platformLabelW = viewW - CardViewStruct.hSpacing
        self.platformLabel.frame = CGRect.init(
            x: 0,
            y: 0,
            width: platformLabelW,
            height: CardViewStruct.labelH
        )
        
        let coinTypesLebelY: CGFloat       = 12
        self.coinTypesLebel.frame = CGRect.init(
            x: 0,
            y: coinTypesLebelY,
            width: viewW,
            height: CardViewStruct.labelH
        )
        
        let lastPriceLabelY       = self.coinTypesLebel.frame.maxY
        self.lastPriceLabel.frame = CGRect.init(
            x: 0,
            y: lastPriceLabelY,
            width: viewW,
            height: CardViewStruct.labelH
        )
        
        let lastPecLabelY       = self.lastPriceLabel.frame.maxY - 5
        self.lastPecLabel.frame = CGRect.init(
            x: 0,
            y: lastPecLabelY,
            width: viewW,
            height: CardViewStruct.labelH
        )
        
        let cnyPriceLabelY       = self.lastPecLabel.frame.maxY - 2
        self.cnyPriceLabel.frame = CGRect.init(
            x: 0,
            y: cnyPriceLabelY,
            width: viewW,
            height: CardViewStruct.labelH
        )
    }
    
    @objc func cardViewClick(tap: UITapGestureRecognizer){
        if (self.callBack != nil) {
            self.callBack!(tap.view as! COINCardView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension COINCardView{
    
    func updateSubViews( rootSymbol: String = "",
                         lastPrice: String = "",
                         lastPecn: String,
                         lastPecnValue: Float = 0.0){
        self.coinTypesLebel.text    = rootSymbol
        self.lastPriceLabel.text    = lastPrice
        self.lastPecLabel.text      = lastPecn
        self.lastPriceLabel.isGreen = lastPecnValue >= 0
        self.lastPecLabel.isGreen = lastPecnValue >= 0
    }
}
