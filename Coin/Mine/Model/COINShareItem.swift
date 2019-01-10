//
//  COINShareItem.swift
//  Coin
//
//  Created by dev6 on 2018/12/3.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINShareItem: NSObject, UIActivityItemSource {
    var shareImage: UIImage?
    init(shareImage: UIImage?) {
        if shareImage != nil {
            self.shareImage = shareImage ?? UIImage.init(named: "shareApp")!
        }
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareImage!
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return shareImage
    }
    

}
