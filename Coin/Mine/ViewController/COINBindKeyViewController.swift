//
//  COINBindKeyViewController.swift
//  Coin
//
//  Created by dev6 on 2018/11/21.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINBindKeyViewController: UIViewController {
    
    var platform: Platform = .bitmex
    
    lazy var bindKeyView: COINBindKeyView = {
        let bindKeyView = COINBindKeyView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight - navAndStatusHeight), platform: self.platform)
        bindKeyView.completeHandle = {
            self.navigationController?.popViewController(animated: true)
        }
        return bindKeyView
    }()
    
    init(platform: Platform) {
        
        super.init(nibName: nil, bundle: nil)
        self.platform = platform
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = self.platform == .bitmex ? "BitMEX" : "OKEX"
        self.view.backgroundColor = whiteColor
        self.view.addSubview(self.bindKeyView)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
