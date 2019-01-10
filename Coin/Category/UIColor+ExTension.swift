//
//  UIColor+ExTensions.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/12.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorWithRGB(_ red: CGFloat,_ green: CGFloat,_ blue: CGFloat) -> (UIColor) {
        let color = UIColor.init(red: (red/255), green: (green/255), blue: (blue/255), alpha: 1)
        return color
    }
    
    class func colorRGB(_ value:UInt32) -> (UIColor) {
        let color = UIColor.init(red: (((CGFloat)((value & 0xFF0000) >> 16)) / 255.0), green: (((CGFloat)((value & 0xFF00) >> 8)) / 255.0), blue: ((CGFloat)(value & 0xFF) / 255.0), alpha: 1)
        return color
    }
}
