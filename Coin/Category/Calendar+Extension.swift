//
//  Calendar+Extension.swift
//  Coin
//
//  Created by gm on 2018/11/7.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

extension Calendar {
    
    
    
    /// 判断是否是同一个季节
    ///
    /// - Parameters:
    ///   - identifier: TimeZone identifier (eg."UTC")
    ///   - currentDate: 比较date
    ///   - date: 比较date
    /// - Returns: true 是同一个季节 不是同一个季节
    func isDateInQuarter(_ identifier: String, _ currentDate: Date, _ date: Date)->Bool{
        
        let utcZone          = TimeZone.init(identifier: identifier)!
        let dateComponentNow = self.dateComponents(in: utcZone, from: currentDate)
        let dataComponentCompare = self.dateComponents(in: utcZone, from:date)
        
        //如果不在同一年 则不在同一个季节
        if dateComponentNow.year != dataComponentCompare.year {
            return false
        }
        
        //判断两个时间在不在同一个季节
        let num:Int = 1
        if (dateComponentNow.month! - num)/3 != (dataComponentCompare.month! - num)/3 {
            return false
        }
        
        return true
    }
    
    
    /// 判断是否同周
    ///
    /// - Parameters:
    ///   - identifier: TimeZone identifier (eg."UTC")
    ///   - currentDate: 比较date
    ///   - date: 比较date
    /// - Returns: true 是同一周 不是同一周
    func isDateInWeek(_ identifier: String, _ currentDate: Date, _ date: Date)->Bool{
        
        let utcZone          = TimeZone.init(identifier: identifier)!
        let dateComponentNow = self.dateComponents(in: utcZone, from: currentDate)
        let dataComponentCompare = self.dateComponents(in: utcZone, from:date)
        
        //判断两个时间在不在同一个周
        if dateComponentNow.weekOfYear != dataComponentCompare.weekOfYear {
            return false
        }
        
        return true
    }
}
