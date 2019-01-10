//
//  COINTradeViewController+bitMex.swift
//  Coin
//
//  Created by gm on 2018/12/14.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

extension COINTradeViewController {
    
    //MARK: ----------------bitmex webSocket--------------------
    @objc override func receiveInstrumentNoti(noti: Notification){
        let tool = COINWebSocketInstrmentTool.parsingInstrmentModel(noti: noti, array: self.detailArray_bitMex)
        if !tool.0{
            return
        }
        
        if !self.tableView.isEditing && self.isOption && self.isBitMex{
            self.getDisplayAray()
        }
    }
    
    //MARK: ----------------bitmex network--------------------
    func getSelectionListFromNetWork_bitMex(){
        let requestPath = "/api/v1/instrument"
        let filter: [String: Any] = ["state":"Open"]
        let parameters: [String: Any] = ["filter":filter]
        COINNetworkTool.request(path: requestPath, platform: .bitmex, parameters: parameters, responseClass: COINBitmexInstrumentModel.self, successHandler:{ (response) in
            guard let tempArray: [COINInstrumentItemModel] = response?.toInstrumentModel().data else {
                return
            }
            let symbolStrArray = ["xbt","eth","ada","bch","eos","ltc","trx"]
            self.selectionListArray_bitMex.removeAll()
            for symbolStr in symbolStrArray {//遍历获取分组列表
                var symbolTypeArray = tempArray.filter({$0.rootSymbol!.lowercased() == symbolStr})
                symbolTypeArray.sort(by: { (item1, item2) -> Bool in
                    guard let item1Expiry = item1.expiry else {
                        return true
                    }
                    
                    guard let item2Expiry = item2.expiry else {
                        return false
                    }
                    
                    return item1Expiry < item2Expiry
                })
                self.selectionAppenArray(symbolTypeArray)
            }
            self.getDisplayAray()
        })
    }
    
}
