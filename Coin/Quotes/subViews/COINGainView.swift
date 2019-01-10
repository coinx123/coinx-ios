//
//  COINGainView.swift
//  Coin
//
//  Created by gm on 2018/11/14.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

private struct GainViewStruct {
    
    static let  hSpacing: CGFloat                      = 20
    static let  vSpacing: CGFloat                      = 10
    
    //platformGrowthChartsLabel
    static let platformGrowthChartsLabelH: CGFloat     = 50
    
    //lineView
    static let lineViewH: CGFloat                      = 0.5
    
    //btn
    static let btnH: CGFloat                           = 60
    static let btnW: CGFloat                           = 60
    
    //label
    static let labelH: CGFloat                         = 45
}

typealias GainViewCallBack = (_ bitMexBtn: UIButton,_ okexBtn: UIButton)->()

class COINGainView: UIView {

    lazy var platformGrowthChartsLabel: UILabel = {
        let platformGrowthChartsLabel  = UILabel()
        platformGrowthChartsLabel.font = fontBold17
        platformGrowthChartsLabel.textColor = titleBlueColor
        platformGrowthChartsLabel.text = "平台涨幅榜"
        return platformGrowthChartsLabel
    }()
    
    lazy var lineView: UIView = {
        let lineView  = UIView()
        lineView.backgroundColor = lineGrayColor
        return lineView
    }()
    
    lazy var bitMexBtn: COINImageAboveLabelButton = {
        let bitMexBtn  = COINImageAboveLabelButton()
        bitMexBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        bitMexBtn.setTitleColor(titleBlueColor, for: .selected)
        bitMexBtn.setTitle("BITMEX", for: .normal)
        bitMexBtn.isSelected = true
        bitMexBtn.titleLabel?.textAlignment = .center
        bitMexBtn.titleLabel?.font = fontBold15
        bitMexBtn.imageView?.contentMode = .bottom
        bitMexBtn.setImage(UIImage.init(named: "bitmex"), for: .normal)
        bitMexBtn.addTarget(self,
                            action: #selector(bitMexBtnClick),
                            for: .touchUpInside)
        return bitMexBtn
    }()
    
    lazy var okexBtn: COINImageAboveLabelButton = {
        
        let okexBtn  = COINImageAboveLabelButton()
        okexBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        okexBtn.setTitleColor(titleBlueColor, for: .selected)
        okexBtn.setTitle("OKEX", for: .normal)
        okexBtn.titleLabel?.textAlignment = .center
        okexBtn.imageView?.contentMode = .bottom
        okexBtn.titleLabel?.font = fontBold15
        okexBtn.setImage(UIImage.init(named: "okex"), for: .normal)
        okexBtn.addTarget(self,
                          action: #selector(okexBtnClick),
                          for: .touchUpInside)
        
        return okexBtn
    }()

    lazy var lineAgain: UIView = {
        let lineAgain  = UIView()
        lineAgain.backgroundColor = lineGrayColor
        return lineAgain
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel           = UILabel()
        nameLabel.font          = font14
        if UIScreen.main.bounds.size.width <= 320 {
            nameLabel.font = font14
        }
        
        nameLabel.textColor     = titleBlueColor_Light
        nameLabel.text          = "排名|名称"
        return nameLabel
    }()
    
    lazy var lastPriceLabel: UILabel = {
        let lastPriceLabel           = UILabel()
        lastPriceLabel.font          = font14
        lastPriceLabel.textColor     = titleBlueColor_Light
        lastPriceLabel.text          = "最新价"
        if UIScreen.main.bounds.size.width <= 320 {
            lastPriceLabel.font = font14
        }
        
        lastPriceLabel.textAlignment = .right
        return lastPriceLabel
    }()
    
    lazy var quoteChangeLabel: UILabel = {
        let quoteChangeLabel           = UILabel()
        quoteChangeLabel.font          = font14
        if UIScreen.main.bounds.size.width <= 320 {
            quoteChangeLabel.font = font14
        }
        
        quoteChangeLabel.textColor     = titleBlueColor_Light
        quoteChangeLabel.text          = "涨跌幅"
        quoteChangeLabel.textAlignment = .center
        return quoteChangeLabel
    }()
    
    lazy var lineThird: UIView = {
        let lineThird  = UIView()
        lineThird.backgroundColor = lineGrayColor
        return lineThird
    }()
    
    var callBack: GainViewCallBack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.platformGrowthChartsLabel)
        self.addSubview(self.lineView)
        self.addSubview(self.bitMexBtn)
        self.addSubview(self.okexBtn)
        self.addSubview(self.lineAgain)
        self.addSubview(self.nameLabel)
        self.addSubview(self.lastPriceLabel)
        self.addSubview(self.quoteChangeLabel)
        self.addSubview(self.lineThird)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewW = self.frame.size.width
        self.platformGrowthChartsLabel.frame = CGRect.init(
            x: GainViewStruct.hSpacing,
            y: 0,
            width: viewW,
            height: GainViewStruct.platformGrowthChartsLabelH
        )
        
        let lineViewY = self.platformGrowthChartsLabel.frame.maxY
        self.lineView.frame = CGRect.init(
            x: 0,
            y: lineViewY,
            width: viewW,
            height: GainViewStruct.lineViewH
        )
        
        let btnY = self.lineView.frame.maxY
        self.bitMexBtn.frame = CGRect.init(
            x: GainViewStruct.hSpacing,
            y: btnY,
            width: GainViewStruct.btnW,
            height: GainViewStruct.btnH
        )
        
        let okexBtnX = self.bitMexBtn.frame.maxX + 30
        self.okexBtn.frame = CGRect.init(
            x: okexBtnX,
            y: btnY,
            width: GainViewStruct.btnW,
            height: GainViewStruct.btnH
        )
        
        let lineViewAgainY = self.bitMexBtn.frame.maxY
        self.lineAgain.frame = CGRect.init(
            x: 0,
            y: lineViewAgainY,
            width: viewW,
            height: GainViewStruct.lineViewH
        )
        
        let labelY = self.lineAgain.frame.maxY
        let nameLabelW = viewW * 0.5 - GainViewStruct.hSpacing
        self.nameLabel.frame = CGRect.init(
            x: GainViewStruct.hSpacing,
            y: labelY,
            width: nameLabelW,
            height: GainViewStruct.labelH
        )
        
        let lastPriceLabelX = viewW * 0.45
        let lastPriceLabelW = viewW * 0.55 * 0.4
        self.lastPriceLabel.frame = CGRect.init(
            x: lastPriceLabelX,
            y: labelY,
            width: lastPriceLabelW,
            height: GainViewStruct.labelH
        )
        
        let quoteChangeLabelX = viewW * 0.8
        let quoteChangeLabelW = viewW - quoteChangeLabelX - GainViewStruct.hSpacing
        self.quoteChangeLabel.frame = CGRect.init(
            x: quoteChangeLabelX,
            y: labelY,
            width: quoteChangeLabelW,
            height: GainViewStruct.labelH
        )
        
        let lineThirdY = self.quoteChangeLabel.frame.maxY
        self.lineThird.frame = CGRect.init(
            x: 0,
            y: lineThirdY,
            width: viewW,
            height: GainViewStruct.lineViewH
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension COINGainView {
    
    @objc func okexBtnClick(){
        self.bitMexBtn.isSelected = false
        self.okexBtn.isSelected   = true
        if (self.callBack != nil) {
            self.callBack!(self.bitMexBtn,self.okexBtn)
        }
    }
    
    @objc func bitMexBtnClick(){
        self.bitMexBtn.isSelected = true
        self.okexBtn.isSelected   = false
        if (self.callBack != nil) {
            self.callBack!(self.bitMexBtn,self.okexBtn)
        }
    }
    
}
