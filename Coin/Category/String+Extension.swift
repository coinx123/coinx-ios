//
//  String+Extension.swift
//  Coin
//
//  Created by gm on 2018/11/7.
//  Copyright © 2018年 COIN. All rights reserved.
//

import Foundation
private var _toDateFmt:DateFormatter?
private var _utcDateFormat: DateFormatter?
private var _toStringFmtBitmex:DateFormatter?

extension String {
    
    
    /// utc时间转date
    ///
    /// - Returns: utc 时间
    func utcConvertedToDate()-> Date{
        objc_sync_enter(self)
        if (_utcDateFormat == nil) {
            _utcDateFormat        = DateFormatter()
            _utcDateFormat!.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        }
        
        objc_sync_exit(self)
        let date              = _utcDateFormat?.date(from: self)
        if (date == nil) {
            return Date()
        }
        
        return date!
    }
    
    func jsonStringToDict()-> NSDictionary{
        let jsonData:Data = self.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        
        return NSDictionary()
    }
    func jsonStringToArray()-> Array<Any>{
        let jsonData:Data = self.data(using: .utf8)!
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! Array<Any>
        }
        
        return Array()
    }
    
    func maxWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let att = [NSAttributedString.Key.font: font]
        let rect: CGRect = NSString(string: self).boundingRect(with: CGSize.init(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: att, context: nil)
        return rect.size.height + 6
    }
    
    func maxHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let att = [NSAttributedString.Key.font: font]
        let rect: CGRect = NSString(string: self).boundingRect(with: CGSize.init(width: screenWidth, height: height), options: .usesLineFragmentOrigin, attributes: att, context: nil)
        return rect.size.width + 6
    }
    
    //4位小数点
    func fourDecimalPlacesWithoutUnits()-> String {
        var string = String.init(format: "%.4f", ((Double(self) ?? 0.0)/100000000) - 0.00005)
        if string.contains("0.0000") {
            string = "0"
        }
        return string
    }
    
    func okexTime() -> String {
        if (_toDateFmt == nil) {
            _toDateFmt = DateFormatter.init()
            _toDateFmt!.dateFormat = "yyMMdd"
        }
        if self.count < 1 {
            return ""
        }
        let date = _toDateFmt!.date(from: self)
        var timeStr = "当周"
        if date != nil {
            if date!.timeIntervalSince1970 + 60 * 60 * 16 - Date().timeIntervalSince1970 < 0 {
                return "过期"
            }
            if date!.timeIntervalSince1970 - Date().timeIntervalSince1970 > 60 * 60 * (24 * 7 -  16) {
                if date!.timeIntervalSince1970 - Date().timeIntervalSince1970 < 60 * 60 * (24 * 14 - 16) {
                    timeStr = "次周"
                } else {
                    timeStr = "季度"
                }
            }
        }
        return timeStr
    }
    
    
    func parsingInstrument_Id() ->( rootSymol:String,timeStr:String){
        let instrumentArray = self.components(separatedBy: "-")
        let rootSymbol: String      = instrumentArray.first?.lowercased() ?? ""
        if rootSymbol.count < 1 {
            return ("","")
        }
        
        let timeStr: String         = instrumentArray.last?.lowercased() ?? ""
        if timeStr.count < 1 {
            return ("","")
        }
        
        return (rootSymbol, timeStr)
    }
    
    func bitmexTimeType() -> (String, NSMutableAttributedString) {
        var type = "永续"
        let months = ["F","G","H","J","K","M","N","Q","U","V","X","Z"]
        var month: Int? = nil
        if self.count == 6 {
            if Int(self[self.index(self.startIndex, offsetBy: 4)..<self.endIndex]) ?? 0 > 0 {
                for (index,string) in months.enumerated() {
                    if string == String.init(self[self.index(self.startIndex, offsetBy: 3)]) {
                        month = index
                        break
                    }
                }
            }
        }
        if self.lowercased().contains("7d") {
            type = "当周"
        } else if self.hasSuffix("USD") {
            type = "永续"
        } else if month != nil {
            if _toStringFmtBitmex == nil {
                _toStringFmtBitmex = DateFormatter.init()
                _toStringFmtBitmex!.dateFormat = "MM"
            }
            let currentMonth = _toStringFmtBitmex!.string(from: Date.init())
            if (Int(currentMonth)! - 1)/3 == month!/3 {
                type = "当季"
            } else {
                type = "次季"
            }
        }
        let string = self[self.startIndex..<self.index(self.startIndex, offsetBy: 3)] + type + "-" + self
        let attr = NSMutableAttributedString.init(string: string)
        attr.addAttributes([NSAttributedString.Key.font: fontBold16], range: NSMakeRange(0, 3))
        attr.addAttributes([NSAttributedString.Key.font: font12], range: NSMakeRange(3, attr.length - 3))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: titleBlackColor], range: NSMakeRange(0, 3))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: titleGrayColor], range: NSMakeRange(3, attr.length - 3))
        return (type,attr)
    }
}
