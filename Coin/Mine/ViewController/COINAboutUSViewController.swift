//
//  COINAboutUSViewController.swift
//  Coin
//
//  Created by dev6 on 2018/12/27.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINAboutUSViewController: UIViewController {

    lazy var aboutUSView: COINAboutUSView = {
        let aboutUSView = COINAboutUSView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight - navAndStatusHeight))
        return aboutUSView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "关于我们"
        self.view.backgroundColor = bgColor
        self.view.addSubview(self.aboutUSView)
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
