//
//  COINWebSocketInstrmentTool.swift
//  Coin
//
//  Created by gm on 2018/12/24.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINWebSocketInstrmentTool: NSObject {
   class func parsingInstrmentModel(noti: Notification,
                                array: [COINInstrumentItemModel]) -> (Bool, Int){
        let dataArray: Array< Dictionary<String, Any?> > = noti.object as! Array
        let dataDict: [String: Any?] = dataArray.first!
        let symbol: String = dataDict["symbol"] as! String
        if (array.contains(where: {$0.symbol == symbol})){
            let detailInfo  = array.first {$0.symbol == symbol}
            var needUpdate = false
            if dataDict.keys.contains("lastPrice"){
                let numBer:NSNumber = dataDict["lastPrice"] as! NSNumber
                detailInfo?.priceValue = numBer.floatValue
                needUpdate = true
            }
            
            if dataDict.keys.contains("indicativeSettlePrice"){
                let numBer:NSNumber = dataDict["indicativeSettlePrice"] as! NSNumber
                detailInfo?.indicativeSettlePrice = numBer.floatValue
                needUpdate = true
            }
            
            if dataDict.keys.contains("foreignNotional24h"){
                let numBer:NSNumber = dataDict["foreignNotional24h"] as! NSNumber
                detailInfo?.foreignNotional24h = numBer.floatValue.turnPriceStr()
                needUpdate = true
            }
            
            if dataDict.keys.contains("lastChangePcnt"){
                let numBer:NSNumber = dataDict["lastChangePcnt"] as! NSNumber
                detailInfo?.lastPcnt = numBer.floatValue
                needUpdate = true
            }
            
            if !needUpdate { //不需要频繁刷新label
                return (false,-1)
            }
            
            let index = array.firstIndex {$0.symbol == detailInfo?.symbol}
            return (true,index ?? 0)
    }
           return (false,-1)
    }
}

