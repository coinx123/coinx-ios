//
//  COINNoNetworkViewController.swift
//  Coin
//
//  Created by dev6 on 2018/12/3.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINNoNetworkViewController: UIViewController {
    lazy var emptyView: COINEmptyView = {
        let emptyView = COINEmptyView.init(frame: CGRect.init(x: 0, y: navAndStatusHeight, width: self.view.bounds.size.width, height: self.view.bounds.size.height - navAndStatusHeight), type: .noNetwork)
        return emptyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = whiteColor
        self.view.addSubview(self.emptyView)
        self.title = "无网络"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: .plain, target: self, action: #selector(hide))
    }
    
    @objc func hide() {
        self.dismiss(animated: true, completion: nil)
    }
}
