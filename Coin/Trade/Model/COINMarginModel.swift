//
//  COINMarginModel.swift
//  Coin
//
//  Created by gm on 2018/11/22.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINMarginModel: COINBaseModel {
    var currency: String?
    var state: String?
    var initMargin: Float?
    var maintMargin: Float?
    var realisedPnl: Float?
    var unrealisedPnl: Float?
    var marginBalance: Float?
    var walletBalance: Float?
    var availableMargin: Float? //可用保证金
}


class COINBitmexMarginModel: COINBaseModel {
    var account: String?
    var currency: String?
    var riskLimit: Float?
    var prevState: String?
    var state: String?
    var action: String?
    var amount: Float?
    var pendingCredit: Float?
    var pendingDebit: Float?
    var confirmedDebit: Float?
    var prevRealisedPnl: Float?
    var prevUnrealisedPnl: Float?
    var grossComm: Float?
    var grossOpenCost: Float?
    var grossOpenPremium: Float?
    var grossExecCost: Float?
    var grossMarkValue: Float?
    var riskValue: Float?
    var taxableMargin: Float?
    var initMargin: Float?
    var maintMargin: Float?
    var sessionMargin: Float?
    var targetExcessMargin: Float?
    var varMargin: Float?
    var realisedPnl: Float?
    var unrealisedPnl: Float?
    var indicativeTax: Float?
    var unrealisedProfit: Float?
    var syntheticMargin: Float?
    var walletBalance: Float?
    var marginBalance: Float?
    var marginBalancePcnt: Float?
    var marginLeverage: Float?
    var marginUsedPcnt: Float?
    var excessMargin: Float?
    var excessMarginPcnt: Float?
    var availableMargin: Float?
    var withdrawableMargin: Float?
    var timestamp: String?
    var grossLastValue: Float?
    var commission: Float?
    
    func toMarginModel() -> COINMarginModel {
        let margin = COINMarginModel()
        margin.currency = self.currency
        margin.state = self.state
        margin.initMargin = self.initMargin
        margin.maintMargin = self.maintMargin
        margin.realisedPnl = self.realisedPnl
        margin.unrealisedPnl = self.unrealisedPnl
        margin.marginBalance = self.marginBalance
        margin.walletBalance = self.walletBalance
        margin.availableMargin = self.availableMargin
        return margin
    }
}

extension COINMarginModel {
    
    func conversionSetCardViewModel() -> COINSetCardViewModel {
        
        let model = COINSetCardViewModel()
        model.walletBalance = self.walletBalance ?? 0.0
        model.maintMargin   = self.marginBalance ?? 0.0
        model.avilableMargin = self.availableMargin ?? 0
        model.legalCurrency = -1
        return model
    }
    
}
