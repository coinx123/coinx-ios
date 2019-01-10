//
//  COINAPPInfoModel.swift
//  Coin
//
//  Created by dev6 on 2019/1/9.
//  Copyright © 2019 COIN. All rights reserved.
//

import UIKit
import HandyJSON

struct COINAPPInfoModel: HandyJSON {
    var ios: COINAPPInfoDataModel?
}
struct COINAPPInfoDataModel: HandyJSON {
    var version: String?
    var client: String?
    var force: Bool?
    var description: String?
    var source_url: String?
}
