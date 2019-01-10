//
//  COINCommisionModel.swift
//  Coin
//
//  Created by dev6 on 2018/11/29.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINCommisionModel: COINBaseModel {
    var data: [String: COINCommisionItemModel]?
}

class COINCommisionItemModel: COINBaseModel {
    var maxFee: Float? //
    var makerFee: Float? //挂委托单的费用，通常为负的，就是平台补贴
    var takerFee: Float? //市价交易的费用，通常为正的，就是要给平台的
    var settlementFee: Float? //结算费用
    
    
}
