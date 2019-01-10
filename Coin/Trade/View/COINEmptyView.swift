//
//  COINEmptyView.swift
//  Coin
//
//  Created by dev6 on 2018/12/3.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

public enum EmptyViewType: Int {
    case noData = 0
    case noNetwork = 1
}

class COINEmptyView: UIView {
    
    lazy var stateImageView: UIImageView = {
        let stateImageView = UIImageView()
        stateImageView.contentMode = .center
        return stateImageView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = font14
        titleLabel.textColor = titleGrayColor
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    init(frame: CGRect, type: EmptyViewType) {
        super.init(frame: frame)
        self.addSubview(self.stateImageView)
        self.stateImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(frame.size.width/2)
            make.centerY.equalTo(frame.size.height/2 - 40)
        }
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(self.stateImageView.snp.bottom).offset(20)
        }
        updateType(type: type)
    }
    
    func updateType( type:EmptyViewType){
        if type == .noData {
            self.stateImageView.image = UIImage.init(named: "empty_noData")
            self.titleLabel.text = "暂无数据"
        } else if type == .noNetwork {
            self.stateImageView.image = UIImage.init(named: "empty_noNetwork")
            self.titleLabel.text = "无网络链接"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
