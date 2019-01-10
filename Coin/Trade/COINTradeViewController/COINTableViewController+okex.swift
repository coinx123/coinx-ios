//
//  COINTableViewController+okex.swift
//  Coin
//
//  Created by gm on 2018/12/14.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

extension COINTradeViewController{
    
    //MARK: ----------------okex webSocket--------------------
    @objc override func receiveTickerNoti_ok(noti: Notification) {
        let dataDict: Dictionary<String, Any?> = noti.object as! Dictionary<String, Any?>
        let rootSymbol: String = dataDict["rootSymbol"] as! String
        let timeStr: String = dataDict["timeStr"] as! String
        let contain = self.detailArray_ok.contains { $0.rootSymbol?.lowercased() == rootSymbol.lowercased() && $0.timeStr.hasSuffix(timeStr)}
        if contain {
            let detailInfo = self.detailArray_ok.first {$0.rootSymbol?.lowercased() == rootSymbol.lowercased() && $0.timeStr.hasSuffix(timeStr)}
            let priceValue: Float  = Float(dataDict["last"] as! String) ?? 0
            let high: Float        = Float(dataDict["high"] as! String) ?? 0
            let low: Float         = Float(dataDict["low"] as! String) ?? 0
            let middle             = (high + low) * 0.5
            let lastPcnt           = (priceValue - middle) / middle
            detailInfo?.priceValue         = priceValue
            detailInfo?.foreignNotional24h = dataDict["vol"] as? String
            detailInfo?.lastPcnt           = lastPcnt
            if !self.tableView.isEditing && self.isOption && !self.isBitMex {
                self.getDisplayAray()
            }
        }
    }
    
    //MARK: ----------------okex netWork--------------------
    func getSelectionListFromNetWork_okex(){
        let requestPath = "/api/futures/v3/instruments/ticker"
        COINNetworkTool.request(path: requestPath, platform: .okex, parameters: nil, method: .get, responseClass: COINInstrumentModel_OK.self, isArray: true, successHandler: { (respond) in
            guard let itemArrayTemp: [COINInstrumentItemModel]  = respond?.toInstrumentModel() else {
                return
            }
            
            let symbolStrArray = ["btc","ltc","eth","etc","xrp","eos","btg","bch","bsv"]
            self.selectionListArray_ok.removeAll()
            
            for symbolStr in symbolStrArray {//这里是排序
                var symbolTypeArray = itemArrayTemp.filter({ $0.symbol!.lowercased().hasPrefix(symbolStr) })
                symbolTypeArray = symbolTypeArray.sorted(by: { $0.symbol! < $1.symbol!})
                if symbolTypeArray.count > 0 {
                    self.selectionListArray_ok.append(symbolTypeArray)
                }
            }
            self.getDisplayAray()
        }) { (error) in
            
        }
    }
}
