//
//  COINWalletHistoryItemModel.swift
//  Coin
//
//  Created by gm on 2018/11/28.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINWalletHistoryModel: COINBaseModel{
    
    var data: [COINWalletHistoryItemModel]?
    
}

class COINWalletHistoryItemModel: COINBaseModel {
    var transactID: String?
    var account: Float?
    var currency: String?
    var transactType: String?
    var amount: Float?
    var fee: Float?
    var transactStatus: String?
    var address: String?
    var tx: String?
    var text: String?
    var transactTime: String?
    var walletBalance: Float?
    var marginBalance: Float?
    var timestamp: String?
}
