//
//  UIImage+Extension.swift
//  Coin
//
//  Created by dev6 on 2018/11/22.
//  Copyright © 2018 COIN. All rights reserved.
//

import Foundation

extension UIImage {
    
    func resize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(toSize)
        self.draw(in: CGRect.init(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func createByTintColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect.init(origin: CGPoint.zero, size: self.size)
        color.set()
        UIRectFill(rect)
        self.draw(at: CGPoint.init(x: 0, y: 0), blendMode: .destinationIn, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func navImageUnderLine()-> UIImage {
        
        return (UIImage.init(named: "nav_wihte_line")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0.1), resizingMode: .stretch))!
    }
}
