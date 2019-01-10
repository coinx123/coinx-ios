//
//  ConfirmOrderView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/7.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

private struct COINConfirmOrderViewUX {
    static let HPadding: CGFloat = 15
    static let VPadding: CGFloat = 15
    static let BaseViewHeight: CGFloat = 400
    static let BtnWidth: CGFloat = 60
    static let BtnHeight: CGFloat = 40
    static let TitleTop: CGFloat = 135
    static let LineWidth: CGFloat = 125
    
    static let RoundWidth: CGFloat = 175
    static let RoundTop: CGFloat = 100
}

class COINConfirmOrderView: UIView {
    
    lazy var baseView: UIView = {
        let baseView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINConfirmOrderViewUX.BaseViewHeight))
        baseView.backgroundColor = whiteColor
        
        baseView.addSubview(self.cancelBtn)
        baseView.addSubview(self.nameLabel)
        baseView.addSubview(self.typeLabel)
        baseView.addSubview(self.roundView)
        baseView.addSubview(self.titleLabel)
        baseView.addSubview(self.priceLabel)
        baseView.addSubview(self.line)
        baseView.addSubview(self.modeLabel)
        baseView.addSubview(self.remindBtn)
        baseView.addSubview(self.finishBtn)
        return baseView
    }()
    
    lazy var cancelView: UIView = {
        let cancelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINConfirmOrderViewUX.BaseViewHeight))
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideView))
        cancelView.addGestureRecognizer(tap)
        return cancelView
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel?.font = fontBold14
        cancelBtn.setTitleColor(titleBlueColor, for: .normal)
        cancelBtn.frame = CGRect.init(x: 0, y: 0, width: COINConfirmOrderViewUX.BtnWidth, height: COINConfirmOrderViewUX.BtnHeight)
        cancelBtn.addTarget(self, action: #selector(hideView), for: .touchUpInside)
        return cancelBtn
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel.init(frame: CGRect.init(x: COINConfirmOrderViewUX.HPadding, y: 60, width: self.frame.size.width/2, height: 20))
        nameLabel.text = "BTC"
        nameLabel.textColor = titleBlueColor_Light
        return nameLabel
    }()
    
    lazy var typeLabel: UILabel = {
        let typeLabel = UILabel.init(frame: CGRect.init(x: COINConfirmOrderViewUX.HPadding + self.frame.size.width/2, y: 60, width: self.frame.size.width/2 - COINConfirmOrderViewUX.HPadding * 2, height: 20))
        typeLabel.text = "限价/普通委托"
        typeLabel.font = font12
        typeLabel.textAlignment = .right
        typeLabel.textColor = titleBlueColor_Light
        return typeLabel
    }()
    
    lazy var roundView: UIImageView = {
        let roundView = UIImageView.init(frame: CGRect.init(x: (self.frame.size.width - COINConfirmOrderViewUX.RoundWidth)/2, y: COINConfirmOrderViewUX.RoundTop, width: COINConfirmOrderViewUX.RoundWidth, height: COINConfirmOrderViewUX.RoundWidth))
        roundView.backgroundColor = whiteColor
        return roundView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: COINConfirmOrderViewUX.TitleTop, width: self.frame.size.width, height: 14))
        titleLabel.text = "委托价(USD)"
        titleLabel.font = fontBold12
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleBlueColor_Light
        return titleLabel
    }()
    
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel.init(frame: CGRect.init(x: 0, y: self.titleLabel.frame.maxY + 10, width: self.frame.size.width, height: 20))
        priceLabel.text = "6400"
        priceLabel.font = fontBold20
        priceLabel.textAlignment = .center
        priceLabel.textColor = titleGreenColor
        return priceLabel
    }()
    
    lazy var line: UIView = {
        let line = UIView.init(frame: CGRect.init(x: (self.frame.size.width - COINConfirmOrderViewUX.LineWidth)/2, y: self.priceLabel.frame.maxY, width: COINConfirmOrderViewUX.LineWidth, height: 1))
        line.backgroundColor = lineGrayColor
        return line
    }()
    
    lazy var modeLabel: UILabel = {
        let modeLabel = UILabel.init(frame: CGRect.init(x: 0, y: self.priceLabel.frame.maxY + 15, width: self.frame.size.width, height: 20))
        modeLabel.text = "买入开多"
        modeLabel.font = fontBold20
        modeLabel.textAlignment = .center
        modeLabel.textColor = titleGreenColor
        return modeLabel
    }()
    
    lazy var remindBtn: UIButton = {
        let remindBtn = UIButton.init(type: .custom)
        remindBtn.setTitle("下次不再显示", for: .normal)
        remindBtn.setImage(UIImage(named: "trade_unselected"), for: .normal)
        remindBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
        remindBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        remindBtn.titleLabel?.font = font11
        remindBtn.frame = CGRect.init(x: COINConfirmOrderViewUX.HPadding, y: COINConfirmOrderViewUX.BaseViewHeight - COINConfirmOrderViewUX.BtnHeight * 2 - COINConfirmOrderViewUX.VPadding, width: 120, height: COINConfirmOrderViewUX.BtnHeight)
        remindBtn.addTarget(self, action: #selector(remindAction), for: .touchUpInside)
        return remindBtn
    }()
    
    lazy var finishBtn: UIButton = {
        let finishBtn = UIButton.init(type: .custom)
        finishBtn.setTitle("确定", for: .normal)
        finishBtn.titleLabel?.font = font16
        finishBtn.setTitleColor(whiteColor, for: .normal)
        finishBtn.backgroundColor = bgBlueColor
        finishBtn.layer.cornerRadius = COINConfirmOrderViewUX.BtnHeight/2
        finishBtn.layer.masksToBounds = true
        finishBtn.frame = CGRect.init(x: COINConfirmOrderViewUX.HPadding, y: COINConfirmOrderViewUX.BaseViewHeight - COINConfirmOrderViewUX.BtnHeight - COINConfirmOrderViewUX.VPadding, width: self.frame.size.width - COINConfirmOrderViewUX.HPadding * 2, height: COINConfirmOrderViewUX.BtnHeight)
        finishBtn.addTarget(self, action: #selector(finishAction), for: .touchUpInside)
        return finishBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.addSubview(self.baseView)
        self.addSubview(self.cancelView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showView() {
        self.isHidden = false
        if self.superview == nil {
            return
        }
//        self.perform(Selector.init("setA"))
        UIView.animate(withDuration: 0.25) {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height - COINConfirmOrderViewUX.BaseViewHeight, width: self.frame.size.width, height: COINConfirmOrderViewUX.BaseViewHeight)
        }
    }
    
    @objc func hideView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINConfirmOrderViewUX.BaseViewHeight)
        }) { (finish) in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    @objc func remindAction() {
        if self.remindBtn.isSelected {
            self.remindBtn.setImage(UIImage(named: "trade_unselected"), for: .normal)
            self.remindBtn.isSelected = false
        } else {
            self.remindBtn.setImage(UIImage(named: "trade_selected"), for: .normal)
            self.remindBtn.isSelected = true
        }
    }
    
    @objc func finishAction() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            COINUserDefaultsHelper.saveBoolValue(value: !self.remindBtn.isSelected, forKey: UserDefaultsHelperKey.tradeSureKey)
        }
    }
    
}
