//
//  COINNotiButton.swift
//  Coin
//
//  Created by gm on 2018/11/22.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit


/// 背景颜色
private let notiButtonBGColors = [titleRedColor,titleGreenColor]

class COINNotiButton: UIButton {
   
    /// 颜色array 红色在前 绿色在后
    var colors:Array<UIColor>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(reciveChange), name: COINNotificationKeys.percentageColor, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        updateBGFromValue()
    }
    
    func updateBGFromValue(){
        guard var textStr: String = self.titleLabel?.text else {
            return
        }
        
        if textStr.count >= 0 {
            textStr = textStr.replacingOccurrences(of: "%", with: "")
            guard let value: Float = Float(textStr) else {
                return
            }
            
            let colorsTemp      = (self.colors != nil) ? self.colors! : notiButtonBGColors
            let percentageColor = COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.percentageColor)
            if value >= 0 {
                self.backgroundColor = percentageColor ? colorsTemp.first : colorsTemp.last
            }else{
                self.backgroundColor = percentageColor ? colorsTemp.last : colorsTemp.first
            }
        }
    }
    
    @objc func reciveChange(){
        
        DispatchQueue.main.async {
            self.updateBGFromValue()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

}
