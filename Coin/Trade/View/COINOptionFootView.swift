//
//  COINOptionFootView.swift
//  Coin
//
//  Created by gm on 2018/12/26.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
enum  COINOptionFootViewTipsState{
    case none
    case add
    case extention
}
typealias  COINOptionFootViewCallBack = () -> ()
class COINOptionFootView: UIView {

   private lazy var tipsBtn: UIButton = {
        let tipsBtn  = UIButton()
        tipsBtn.titleLabel?.textAlignment = .center
        tipsBtn.addTarget(self,
                      action: #selector(tipsBtnClick),
                      for: .touchUpInside)
    
        changeFrame(0, btn: tipsBtn)
    
        tipsBtn.imageEdgeInsets = UIEdgeInsets.init(
            top: 0,
            left: -30,
            bottom: 0,
            right: 0
        )
    
        tipsBtn.imageView?.contentMode = .left
        tipsBtn.layer.cornerRadius  = 20
        return tipsBtn
    }()
    
    private var btnY: CGFloat = 0
    
    var state: COINOptionFootViewTipsState = .extention {
        didSet{
            if state == .none {
                tipsBtn.setTitle("添加自选", for: .normal)
                tipsBtn.setImage(UIImage.init(named: ""), for: .normal)
                tipsBtn.setTitleColor(UIColor.white, for: .normal)
                tipsBtn.titleLabel?.font    = font14
                tipsBtn.backgroundColor     = bgBlueColor_light
                changeFrame(btnY, btn: tipsBtn)
            }else{
                tipsBtn.setTitle("添加自选", for: .normal)
                tipsBtn.setTitleColor(bgBlueColor_light, for: .normal)
                tipsBtn.backgroundColor     = UIColor.clear
                changeFrame(0, btn: tipsBtn)
                tipsBtn.titleLabel?.font = font12
                tipsBtn.setImage(UIImage.init(named: "trade_option_add"),
                                 for: .normal)
            }
        }
    }
    
    let callBack: COINOptionFootViewCallBack
    
    init(frame: CGRect, callBack: @escaping COINOptionFootViewCallBack) {
        self.callBack = callBack
        super.init(frame: frame)
        self.btnY     =  (self.frame.size.height - 40) * 0.5
        self.addSubview(self.tipsBtn)
    }
    
    func changeFrame(_ btnY: CGFloat, btn: UIButton){
        let btnH: CGFloat     = 40
        let btnW: CGFloat     = 130
        let btnX: CGFloat     = (self.frame.size.width - btnW) * 0.5
        btn.frame         = CGRect.init(
            x: btnX,
            y: btnY,
            width: btnW,
            height: btnH
        )
        
        self.frame = CGRect.init(
            x: 0,
            y: 0,
            width: self.frame.size.width,
            height: btn.frame.maxY)
    }
    
    @objc func tipsBtnClick(){
        self.callBack()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
