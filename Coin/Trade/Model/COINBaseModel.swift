//
//  BaseModel.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/14.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit
import HandyJSON

class COINBaseModel: HandyJSON {
    public var platformType: Platform = .bitmex
    required init() {}
}
