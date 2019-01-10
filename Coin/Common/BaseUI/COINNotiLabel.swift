//
//  COINNotiLabel.swift
//  ColorTest
//
//  Created by gm on 2018/11/20.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
private let notiLabelColors = [titleRedColor,titleGreenColor]
class COINNotiLabel: UILabel {
    
    
    /// 是否通过IsGreen的值来判断 默认是否 否的话就通过label的text来判断
    var judgingBytIsGreen = false
    
    /// 颜色array 红色在前 绿色在后
    var colors:Array<UIColor>?
    
    var isGreen: Bool {
        didSet{
            updateBGFromRed()
        }
    }
    override init(frame: CGRect) {
        self.isGreen = false
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(reciveChange), name: COINNotificationKeys.percentageColor, object: nil)
        self.addObserver(self, forKeyPath: "text", options: .new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateBGFromValue()
    }
   
    func updateBGFromValue(){
        if judgingBytIsGreen {
            updateBGFromRed()
            return
        }
        
        guard var textStr: String = self.text else {
            return
        }
        
        if textStr.count > 0 {
            textStr = textStr.replacingOccurrences(of: "%", with: "")
            guard let value: Float = Float(textStr) else {
                      return
            }
            
            let colorsTemp      = (self.colors != nil) ? self.colors! : notiLabelColors
            let percentageColor = COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.percentageColor)
            if value >= 0 {
                self.textColor = percentageColor ? colorsTemp.first : colorsTemp.last
            }else{
                self.textColor = percentageColor ? colorsTemp.last : colorsTemp.first
            }
        }
        
    }
    
    func updateBGFromRed(){
        let percentageColor = COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.percentageColor)
        let colorsTemp      = (self.colors != nil) ? self.colors! : notiLabelColors
        if self.isGreen {
            self.textColor = percentageColor ? colorsTemp.first : colorsTemp.last
        }else{
           self.textColor = percentageColor ? colorsTemp.last : colorsTemp.first
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
