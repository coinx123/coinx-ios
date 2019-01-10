//
//  COINBaseTableViewController.swift
//  Coin
//
//  Created by gm on 2018/12/3.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
import MJRefresh


extension UITableViewController {
    
   final func addRefresh(){
        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(startRefresh))
        
    }
    
   final func stopRefresh(){
        self.tableView.mj_header.endRefreshing()
    }
    
    @objc func startRefresh(){
        
    }
    
}
