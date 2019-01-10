//
//  COINUseHabitHelper.swift
//  Coin
//
//  Created by dev6 on 2018/11/27.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINUseHabitHelper: NSObject {
    var titleRiseColor: UIColor? //买涨或者买入或涨的文字颜色
    var titleDropColor: UIColor? //买跌或者卖出或跌的文字颜色
    var bgRiseColor: UIColor? //买涨或者买入或涨的背景颜色
    var bgDropColor: UIColor? //买跌或者卖出或跌的背景颜色
    
    static let instance: COINUseHabitHelper = COINUseHabitHelper.init()
    public class func shared() -> COINUseHabitHelper {
        return instance
    }
    
    override init() {
        super.init()
        self.update()
    }
    
    func update() {
        let percentageColor = COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.percentageColor)
        if percentageColor {
            self.titleRiseColor = titleRedColor
            self.titleDropColor = titleGreenColor
            self.bgRiseColor = titleRedColor
            self.bgDropColor = titleGreenColor
        } else {
            self.titleRiseColor = titleGreenColor
            self.titleDropColor = titleRedColor
            self.bgRiseColor = titleGreenColor
            self.bgDropColor = titleRedColor
        }
    }
}
