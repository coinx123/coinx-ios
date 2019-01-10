//
//  COINTradeTableHeaderView.swift
//  Coin
//
//  Created by gm on 2018/11/14.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
private struct TradeTableHeaderViewStruct {
    static let  hSpacing: CGFloat             = 20.0
    static let  vSpacing: CGFloat             = 5.0
    
    //iconView
    static let  iconViewW: CGFloat             = 20
    
    //rootSymbol
    static let  rootSymbolW: CGFloat             = 200
    static let  rootSymbolH: CGFloat             = 35
}
class COINTradeTableHeaderView: UITableViewHeaderFooterView {

    lazy var iconView: UIImageView = {
        return UIImageView.init()
    }()
    
    lazy var rootSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = font17
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = whiteColor
        self.addSubview(self.iconView)
        self.addSubview(rootSymbolLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageViewY = self.frame.size.height * 0.5 - TradeTableHeaderViewStruct.iconViewW * 0.5
        self.iconView.frame = CGRect.init(
            x: TradeTableHeaderViewStruct.hSpacing,
            y: imageViewY,
            width: TradeTableHeaderViewStruct.iconViewW,
            height: TradeTableHeaderViewStruct.iconViewW
        )
        
        let rootSymbolLabelX = self.iconView.frame.maxX + 5
        self.rootSymbolLabel.frame = CGRect.init(
            x: rootSymbolLabelX,
            y: TradeTableHeaderViewStruct.vSpacing,
            width: TradeTableHeaderViewStruct.rootSymbolW,
            height: TradeTableHeaderViewStruct.rootSymbolH
        )
    }
}
