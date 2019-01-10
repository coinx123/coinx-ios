//
//  CalendarTests.swift
//  CoinTests
//
//  Created by gm on 2018/11/7.
//  Copyright © 2018年 COIN. All rights reserved.
//

import XCTest
@testable import Coin
class CalendarTests: XCTestCase {
    
    func testCalendar(){
        
        let dateFromat = DateFormatter.init()
        dateFromat.dateFormat = "yyyy-MM-dd"
        let dateStr1   = "2018-6-5"
        let date1      = dateFromat.date(from: dateStr1)
        
        let dateStr2   = "2018-12-2"
        let date2      = dateFromat.date(from: dateStr2)
        if Calendar.current.isDateInQuarter("UTC", date1!, date2!) {
            print("同一个季节")
        }else{
            print("不同一个季节")
        }
        if Calendar.current.isDateInWeek("UTC", date1!, date2!) {
            print("同一个星期")
        }else{
            print("不同一个星期")
        }
        XCTAssert(Calendar.current.isDateInQuarter("UTC", date1!, date2!), "不是同一季节")
        XCTAssert(Calendar.current.isDateInWeek("UTC", date1!, date2!), "不是同一星期份")
        
        
    }
}
