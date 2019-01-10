//
//  COINAccountsModel_ok.swift
//  Coin
//
//  Created by gm on 2018/12/13.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINAccountsItemModel_ok: COINBaseModel {
    
    
    /// 币种，如：btc
    var currency: String?
    
    /// 账户类型：全仓 crossed
    var margin_mode: String?
    
    /// 账户权益
    var equity: Float = 0.0
    
    
    /// 账户余额
    var total_avail_balance: Float = 0.0
    
    
    /// 保证金（挂单冻结+持仓已用）
    var margin: Float?
    
    
    /// 已实现盈亏
    var realized_pnl: Float?
    
    /// 未实现盈亏
    var unrealized_pnl: Float?
    
    /// 保证金率
    var margin_ratio: Float?
    
    var contracts: [COINAccountsItemSubModel_ok]?
    
    var btc_usdt: Float = 0
    var eth_btc: Float  = 0
}

class COINAccountsItemSubModel_ok: COINBaseModel{
    /// instrument_id
    var instrument_id: String?
    /// 逐仓账户余额
    var fixed_balance: Float = 0.0
    
    /// 逐仓可用余额
    var available_qty: Float?
    
    ///持仓已用保证金
    var margin_frozen: Float?
    
    ///挂单冻结保证金
    var margin_for_unfilled: Float?
    
    /// 已实现盈亏
    var realized_pnl: Float?
    
    /// 未实现盈亏
    var unrealized_pnl: Float?
}
