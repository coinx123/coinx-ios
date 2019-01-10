//
//  Float+Extension.swift
//  Coin
//
//  Created by gm on 2018/11/20.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

extension Float {
    
    /// 返回价格字符串
    ///
    /// - Returns: 返回价格字符串
    func turnPriceStr()-> String{
        var price = "\(self)"
        if price.lowercased().contains("e-") {
            price = String.init(format: "%.6f",self)
        }
        
        if price.lowercased().contains("e+") {
            price = "\(self/10000)万"
        }
        
        return price
    }
    
    func lastPecnStr()-> String {
        if self >= 0 {
            return String.init(format: "+%.2f%%", self * 100.0)
        }else{
            return String.init(format: "%.2f%%", self * 100.0)
        }
    }
    
    func pecnStr()-> String {
        
        return String.init(format: "%.2f%%", self * 100.0)
    }
    
   
    //四位小数点
    func fourDecimalPlacesWithUnits(btcStr: String = "XBT")-> String {
        
        return String.init(format: "%.4f%@", (self/100000000),btcStr)
    }
    
    //四位小数点
    func fourDecimalPlacesWithoutUnits()-> String {
        var string = String.init(format: "%.4f", (self/100000000) - 0.00005)
        if string.contains("0.0000") {
            string = "0"
        }
        
        return string
    }
    
    //八位小数点
    func eightDecimalPlacesWithUnits()-> String {
        return String.init(format: "%.8f", self/100000000)
    }
}
