//
//  COINImageAboveLabelButton.swift
//  Coin
//
//  Created by gm on 2018/11/13.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
struct ImageAboveLabelButtonStruct{
    static let percent:CGFloat = 0.5
}
class COINImageAboveLabelButton: UIButton {
    
    lazy var buttomLine: CALayer = {
        let buttomLineTemp = CALayer()
        self.layer.addSublayer(buttomLineTemp)
        buttomLineTemp.isHidden = true
        return buttomLineTemp
    }()
    
    
    override var isSelected: Bool{
        didSet{
            if isSelected {
                self.buttomLine.isHidden = false
            }else{
                self.buttomLine.isHidden = true
            }
        }
    }
    
    /// 重新布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewH = self.frame.size.height * ImageAboveLabelButtonStruct.percent
        self.imageView?.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: imageViewH)
        
        let titleH:CGFloat = imageViewH * 0.5
        self.titleLabel?.frame = CGRect.init(x: 0, y: imageViewH + 5, width: self.frame.size.width, height: titleH)
        
        let buttomLineTempX: CGFloat = self.frame.size.width * 0.25
        let buttomLineTempW: CGFloat = self.frame.size.width * 0.5
        let buttomLineTempH: CGFloat = 2.0
        let buttomLineTempY: CGFloat = self.frame.size.height - buttomLineTempH
        self.buttomLine.frame = CGRect.init(x: buttomLineTempX, y: buttomLineTempY, width: buttomLineTempW, height: buttomLineTempH)
        self.buttomLine.backgroundColor = bgBlueColor.cgColor
    }
    
    
}
