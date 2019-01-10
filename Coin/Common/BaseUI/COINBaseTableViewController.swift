//
//  COINBaseTableViewController.swift
//  Coin
//
//  Created by gm on 2018/12/5.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit



class COINBaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        self.tableView.tableFooterView = UIView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


