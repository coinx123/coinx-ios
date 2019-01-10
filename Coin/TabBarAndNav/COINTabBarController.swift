//
//  COINTabBarController.swift
//  Coin
//
//  Created by gm on 2018/11/2.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINTabBarController: UITabBarController {
    
    lazy var selectedAttributes: [NSAttributedString.Key : Any] = {
        let selectedAttributes = [
            NSAttributedString.Key.foregroundColor:UIColor.blue,
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18)
        ]
        return selectedAttributes
    }()
    
    lazy var normalAttributes: [NSAttributedString.Key : Any] = {
        let normalAttributes = [
            NSAttributedString.Key.foregroundColor:UIColor.lightGray,
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18)
        ]
        return normalAttributes
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarItem = UITabBarItem.appearance()
        tabBarItem.setTitleTextAttributes(self.normalAttributes, for: .normal)
        tabBarItem.setTitleTextAttributes(self.selectedAttributes, for: .selected)
        
        let homeVC   = COINQuotesViewController()
        let homeNav  = UINavigationController.init(rootViewController: homeVC)
        self.addChild(homeNav)
        addSubVC(homeVC, tabbarItem: "行情", "quote", "quote_highlight")
        
        let tradeVC   = COINTradeViewController()
        let tradeNav  = UINavigationController.init(rootViewController: tradeVC)
        self.addChild(tradeNav)
        addSubVC(tradeVC, tabbarItem: "交易", "trade", "trade_highlight")
        
        let mineVC   = COINMineViewController()
        let mineNav  = UINavigationController.init(rootViewController: mineVC)
        self.addChild(mineNav)
        addSubVC(mineVC, tabbarItem: "我的", "mine", "mine_highlight")
       
        self.selectedIndex = 0
    }
    
    func addSubVC(_ childVC:UIViewController,tabbarItem title:String,_ imageName:String,_ selectedImageName:String){
        childVC.title = title
        childVC.tabBarItem.image = UIImage.init(named: imageName)
        childVC.tabBarItem.selectedImage = UIImage.init(named: selectedImageName)
        childVC.tabBarController?.tabBar.barTintColor = UIColor.white
        childVC.tabBarController?.tabBar.backgroundColor = UIColor.white
    }
    
}
