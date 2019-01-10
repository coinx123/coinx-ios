//
//  RoundView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/7.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

class COINRoundView: UIView {

    public var roundColor: UIColor = whiteColor
    public var borderWidth: CGFloat = 10
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.addRounded(corners: .allCorners, radii: self.frame.size, borderWidth: self.borderWidth, borderColor: self.roundColor)
    }
 

}
