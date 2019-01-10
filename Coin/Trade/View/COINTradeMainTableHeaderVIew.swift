//
//  COINTradeMainTableHeaderVIew.swift
//  Coin
//
//  Created by gm on 2018/12/26.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
private struct TradeViewControllerStruct {
    
    static let  hSpacing: CGFloat             = 20.0
    static let  vSpacing: CGFloat             = 10.0
    //imageAboveOnTitle btn
    static let btnW: CGFloat                  = 50.0
    static let btnH: CGFloat                  = 80.0
    
    //lineView
    static let lineViewH: CGFloat              = 0.5
    //normal btn
    static let btnNW: CGFloat                  = 60.0
    static let btnNH: CGFloat                  = 25.0
    
}

typealias BitMexBtnCallBack = (_ isBitMex: Bool)->()
typealias OptionBtnCallBack = (_ isOption: Bool)->()
class COINTradeMainTableHeaderVIew: UIView {
    
    var bitMexCallBack: BitMexBtnCallBack?
    var optionalCallBack: OptionBtnCallBack?
    
    private lazy var bitMexBtn: COINImageAboveLabelButton = {
        let bitMexBtn  = COINImageAboveLabelButton.init(frame: CGRect.init(
            x: TradeViewControllerStruct.hSpacing,
            y: 0,
            width: TradeViewControllerStruct.btnW,
            height: TradeViewControllerStruct.btnH
        ))
        
        bitMexBtn.setTitle("BitMex", for: .normal)
        bitMexBtn.titleLabel?.textColor = UIColor.black
        bitMexBtn.titleLabel?.textAlignment = .center
        bitMexBtn.imageView?.contentMode    = .bottom
        bitMexBtn.titleLabel?.font          = fontBold15
        bitMexBtn.setImage(UIImage.init(named: "trade_bitmex"), for: .normal)
        bitMexBtn.setTitleColor(titleBlueColor, for: .selected)
        bitMexBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        bitMexBtn.addTarget(self, action: #selector(bitMexBtnClick), for: .touchUpInside)
        return bitMexBtn
    }()
    
    private lazy var okexBtn: COINImageAboveLabelButton = {
        let okexBtnX = self.bitMexBtn.frame.maxX + 20
        let okexBtn  = COINImageAboveLabelButton.init(frame: CGRect.init(
            x: okexBtnX,
            y: 0,
            width: TradeViewControllerStruct.btnW,
            height: TradeViewControllerStruct.btnH
        ))
        
        okexBtn.setImage(UIImage.init(named: "trade_okex"), for: .normal)
        okexBtn.setTitle("OKEX", for: .normal)
        okexBtn.titleLabel?.textColor = UIColor.black
        okexBtn.titleLabel?.textAlignment = .center
        okexBtn.imageView?.contentMode    = .bottom
        okexBtn.titleLabel?.font          = fontBold15
        okexBtn.setTitleColor(titleBlueColor, for: .selected)
        okexBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        okexBtn.addTarget(self, action: #selector(okexBtnClick), for: .touchUpInside)
        return okexBtn
    }()
    
    private lazy var optionalBtn: UIButton = {
        let optionalBtnY = self.okexBtn.frame.maxY + TradeViewControllerStruct.vSpacing  + 0.7
        let optionalBtn = UIButton.init(frame: CGRect.init(
            x: TradeViewControllerStruct.hSpacing - 5,
            y: optionalBtnY,
            width: TradeViewControllerStruct.btnNW,
            height: TradeViewControllerStruct.btnNH
        ))
        
        optionalBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        optionalBtn.setTitleColor(titleBlueColor, for: .selected)
        optionalBtn.setTitle("自选", for: .normal)
        optionalBtn.titleLabel?.font = font15
        optionalBtn.addTarget(self, action: #selector(optionBtnClick), for: .touchUpInside)
        return optionalBtn
    }()
    
    private lazy var electedBtn: UIButton = {
        
        let electedBtnX = self.optionalBtn.frame.maxX + TradeViewControllerStruct.hSpacing - 10
        let electedBtn  = UIButton.init(frame: CGRect.init(
            x: electedBtnX,
            y: self.optionalBtn.frame.origin.y,
            width: TradeViewControllerStruct.btnNW,
            height: TradeViewControllerStruct.btnNH
        ))
        
        electedBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        electedBtn.setTitleColor(titleBlueColor, for: .selected)
        electedBtn.setTitle("全部", for: .normal)
        electedBtn.titleLabel?.font = font15
        electedBtn.addTarget(self, action: #selector(electedBtnClick), for: .touchUpInside)
        
        return electedBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(bitMexBtn)
        self.addSubview(okexBtn)
        bitMexBtnClick()
        let width = UIScreen.main.bounds.size.width
        let lineViewY = okexBtn.frame.maxY
        let lineView = UIView.init(frame: CGRect.init(
            x: 0,
            y: lineViewY,
            width: width,
            height: TradeViewControllerStruct.lineViewH
        ))
        
        lineView.backgroundColor = lineGrayColor
        self.addSubview(lineView)
        self.addSubview(optionalBtn)
        self.addSubview(electedBtn)
        optionBtnClick()
        let lineEndViewY = electedBtn.frame.maxY + TradeViewControllerStruct.vSpacing
        let lineEndView = UIView.init(frame: CGRect.init(
            x: 0,
            y: lineEndViewY,
            width: width,
            height: TradeViewControllerStruct.lineViewH
        ))
        
        lineEndView.backgroundColor = lineGrayColor
        self.addSubview(lineEndView)
        self.frame = CGRect.init(
            x: 0,
            y: 0,
            width: width,
            height: lineEndView.frame.maxY
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func bitMexBtnClick(){
        okexBtn.isSelected    = false
        bitMexBtn.isSelected  = true
        if (self.bitMexCallBack != nil) {
            self.bitMexCallBack!(true)
        }
    }
    
    @objc func okexBtnClick(){
        okexBtn.isSelected   = true
        bitMexBtn.isSelected = false
        if (self.bitMexCallBack != nil) {
            self.bitMexCallBack!(false)
        }
    }
    
    @objc func optionBtnClick(){
        if self.optionalBtn.isSelected {
            return
        }
        optionalBtn.isSelected = true
        electedBtn.isSelected  = false
        if (self.optionalCallBack != nil) {
            self.optionalCallBack!(true)
        }
    }
    
    @objc func electedBtnClick(){
        if self.electedBtn.isSelected {
            return
        }
        optionalBtn.isSelected = false
        electedBtn.isSelected  = true
        if (self.optionalCallBack != nil) {
            self.optionalCallBack!(false)
        }
    }
}
