//
//  COINSettingInfoTableViewCell.swift
//  Coin
//
//  Created by gm on 2018/11/27.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
class COINSettingInfoModel: COINBaseModel {
    
    /// 图片名字 rootsymbol
    var imageName: String = ""
    /// 合约名称
    var symbol: String    = ""
    /// 权益保证金
    var marginBalance: Float = 1.0
    /// 委托保证金
    var initMargin: Float    = 0
    /// 仓位保证金
    var maintMargin: Float   = 0
    ///已实现盈亏
    var realisedPnl: Float   = 0
    /// 为实现盈亏
    var unrealisedPnl: Float = 0
    /// 可用保证金
    var availableMargin: Float = 0
    
}
class COINSettingInfoTableViewCell: UITableViewCell {

    lazy var currencyImageView: UIImageView = {
        let currencyImageView = UIImageView()
        currencyImageView.contentMode = .left
        return currencyImageView
    }()
    
    lazy var symbolLabel: UILabel = {
        let symbolLabel = UILabel()
        symbolLabel.text = "XBT"
        return symbolLabel
    }()
    
    ///"总权益"
    lazy var totalEquityValueLabel: UILabel = {
        let totalEquityLabel = UILabel()
        totalEquityLabel.textAlignment = .right
        totalEquityLabel.text = "6500.00"
        totalEquityLabel.font = font12
        return totalEquityLabel
    }()
    private lazy var totalEquityLabel: UILabel = {
        let totalEquityLabel = UILabel()
        totalEquityLabel.text = "总权益"
        totalEquityLabel.textAlignment = .right
        totalEquityLabel.textColor = titleGrayColor
        totalEquityLabel.font = font12
        return totalEquityLabel
    }()
    
    ///保证进率(%)
    lazy var progressValueLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.text = "50%"
        progressLabel.textAlignment = .left
        progressLabel.font = font12
        return progressLabel
    }()
    private lazy var progressLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.textAlignment = .left
        progressLabel.textColor = titleGrayColor
        progressLabel.text = "保证进率(%)"
        progressLabel.font = font12
        return progressLabel
    }()
    
    /// 已用保证金(BTC)
    lazy var marginPaidValueLabel: UILabel = {
        let marginPaidLabel = UILabel()
        marginPaidLabel.text = "0.004BTC"
        marginPaidLabel.font = font12
        return marginPaidLabel
    }()
    private lazy var marginPaidLabel: UILabel = {
        let marginPaidLabel = UILabel()
        marginPaidLabel.text = "已用保证金"
        marginPaidLabel.textColor = titleGrayColor
        marginPaidLabel.font = font12
        return marginPaidLabel
    }()
    
    
    /// 已实现盈亏
    lazy var realisedPnlValueLabel: UILabel = {
        let profitAndLossLabel = UILabel()
        profitAndLossLabel.text = "0.005BTC"
        profitAndLossLabel.textAlignment = .right
        profitAndLossLabel.font = font12
        return profitAndLossLabel
    }()
    private lazy var realisedPnlLabel: UILabel = {
        let profitAndLossLabel = UILabel()
        profitAndLossLabel.text = "已实现盈亏"
        profitAndLossLabel.textAlignment = .right
        profitAndLossLabel.textColor = titleGrayColor
        profitAndLossLabel.font = font12
        return profitAndLossLabel
    }()
    
    /// 未实现盈亏
    lazy var unrealisedPnlValueLabel: UILabel = {
        let unrealisedPnlLabel = UILabel()
        unrealisedPnlLabel.text = "0.006BTC"
        unrealisedPnlLabel.textAlignment = .right
        unrealisedPnlLabel.font = font12
        return unrealisedPnlLabel
    }()
    private lazy var unrealisedPnlLabel: UILabel = {
        let unrealisedPnlLabel = UILabel()
        unrealisedPnlLabel.text = "未实现盈亏"
        unrealisedPnlLabel.textAlignment = .right
        unrealisedPnlLabel.textColor = titleGrayColor
        unrealisedPnlLabel.font = font12
        return unrealisedPnlLabel
    }()
    
    /// 可用保证金lablel
    lazy var availableMarginValueLabel: UILabel = {
        let availableMarginValueLabel = UILabel()
        availableMarginValueLabel.text = "0.006BTC"
        availableMarginValueLabel.textAlignment = .right
        availableMarginValueLabel.font = font12
        return availableMarginValueLabel
    }()
    private lazy var availableMarginLabel: UILabel = {
        let availableMarginLabel  = UILabel()
        availableMarginLabel.text = "可用保证金"
        availableMarginLabel.textAlignment = .right
        availableMarginLabel.textColor = titleGrayColor
        availableMarginLabel.font = font12
        return availableMarginLabel
    }()
    
    
    /// 冻结保证金lablel
    lazy var freezeMarginValueLabel: UILabel = {
        let freezeMarginValueLabel = UILabel()
        freezeMarginValueLabel.text = "0.006BTC"
        freezeMarginValueLabel.textAlignment = .right
        freezeMarginValueLabel.font = font12
        return freezeMarginValueLabel
    }()
    
    private lazy var freezeMarginLabel: UILabel = {
        let freezeMarginLabel  = UILabel()
        freezeMarginLabel.text = "冻结保证金"
        freezeMarginLabel.textAlignment = .right
        freezeMarginLabel.textColor = titleGrayColor
        freezeMarginLabel.font = font12
        return freezeMarginLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addSubviews()
    }
    
    func addSubviews(){
        self.addSubview(self.currencyImageView)
        self.addSubview(self.symbolLabel)
        
        self.addSubview(self.totalEquityLabel)
        self.addSubview(self.totalEquityValueLabel)
        
        //        self.addSubview(self.progressLabel)
        //        self.addSubview(self.progressValueLabel)
        
        self.addSubview(self.marginPaidLabel)
        self.addSubview(self.marginPaidValueLabel)
        
        self.addSubview(self.realisedPnlLabel)
        self.addSubview(self.realisedPnlValueLabel)
        
        //        self.addSubview(self.unrealisedPnlLabel)
        //        self.addSubview(self.unrealisedPnlValueLabel)
        
        self.addSubview(self.availableMarginLabel)
        self.addSubview(self.availableMarginValueLabel)
        
        self.addSubview(self.freezeMarginLabel)
        self.addSubview(self.freezeMarginValueLabel)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let hSpeing: CGFloat = 20
        let labelH : CGFloat  = 20
        let width = UIScreen.main.bounds.size.width
        
        currencyImageView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(hSpeing)
            maker.left.equalToSuperview().offset(hSpeing)
            maker.width.equalTo(20)
            maker.height.equalTo(20)
        }
        
        let symbolLabelOffset = width * 2 / 3 * -1
        symbolLabel.snp.makeConstraints { (maker) in
           maker.left.equalTo(currencyImageView.snp.right).offset(10)
           maker.centerY.equalTo(currencyImageView.snp.centerY)
           maker.right.equalTo(self.snp.right).offset(symbolLabelOffset)
           maker.height.equalTo(labelH)
        }
        
        let middleOffset = width / 3 * -1
        realisedPnlLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(symbolLabel.snp.left)
            maker.top.equalTo(symbolLabel.snp.top)
            maker.right.equalTo(self.snp.right).offset(middleOffset)
            maker.height.equalTo(labelH)
        }
        realisedPnlValueLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(realisedPnlLabel.snp.left)
            maker.top.equalTo(realisedPnlLabel.snp.bottom).offset(-3)
            maker.right.equalTo(realisedPnlLabel.snp.right)
            maker.height.equalTo(labelH)
        }
        
        totalEquityLabel.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(hSpeing * -1)
            maker.centerY.equalTo(currencyImageView.snp.centerY)
            maker.height.equalTo(labelH)
        }
        totalEquityValueLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(totalEquityLabel.snp.right)
            maker.top.equalTo(totalEquityLabel.snp.bottom).offset(-3)
            maker.height.equalTo(labelH)
        }
        
        
//        unrealisedPnlLabel.snp.makeConstraints { (maker) in
//            maker.top.equalTo(totalEquityValueLabel.snp.bottom).offset(v)
//            maker.right.equalTo(totalEquityValueLabel.snp.right)
//            maker.height.equalTo(labelH)
//        }
//        unrealisedPnlValueLabel.snp.makeConstraints { (maker) in
//            maker.top.equalTo(marginPaidValueLabel.snp.top)
//            maker.right.equalTo(unrealisedPnlLabel.snp.right)
//            maker.height.equalTo(labelH)
//        }
        
        freezeMarginLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(totalEquityValueLabel.snp.right)
            maker.top.equalTo(totalEquityValueLabel.snp.bottom).offset(hSpeing * 0.5)
            maker.height.equalTo(labelH)
        }
        freezeMarginValueLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(freezeMarginLabel.snp.right)
            maker.top.equalTo(marginPaidValueLabel.snp.top)
            maker.height.equalTo(labelH)
        }
        
        marginPaidLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(currencyImageView.snp.left)
            maker.top.equalTo(freezeMarginLabel.snp.top)
            maker.right.equalTo(symbolLabel.snp.right)
            maker.height.equalTo(labelH)
        }
        marginPaidValueLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(marginPaidLabel.snp.left)
            maker.top.equalTo(marginPaidLabel.snp.bottom).offset(-3)
            maker.right.equalTo(marginPaidLabel.snp.right)
            maker.height.equalTo(labelH)
        }
        
        
        
//        progressLabel.snp.makeConstraints { (maker) in
//            maker.top.equalTo(marginPaidValueLabel.snp.bottom).offset(hSpeing)
//            maker.left.equalTo(marginPaidValueLabel.snp.left)
//            maker.width.equalTo(marginPaidValueLabel.snp.width)
//            maker.height.equalTo(labelH)
//        }
//        progressValueLabel.snp.makeConstraints { (maker) in
//            maker.right.equalTo(progressLabel.snp.right)
//            maker.top.equalTo(progressLabel.snp.bottom).offset(-3)
//            maker.width.equalTo(progressLabel.snp.width)
//            maker.height.equalTo(labelH)
//        }
        
        availableMarginLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(realisedPnlValueLabel.snp.right)
            maker.top.equalTo(marginPaidLabel.snp.top)
            maker.width.equalTo(realisedPnlValueLabel.snp.width)
            maker.height.equalTo(labelH)
        }
        availableMarginValueLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(availableMarginLabel.snp.right)
            maker.top.equalTo(marginPaidValueLabel.snp.top)
            maker.width.equalTo(availableMarginLabel.snp.width)
        }
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 给COINSettingInfoTableViewCell赋值
    var model: COINSettingInfoModel? {
        
        didSet{
            self.currencyImageView.image = UIImage.init(named:"currency_\(model?.imageName.lowercased() ?? "")")
            self.symbolLabel.text = model?.symbol

            //保证金余额
            let marginBalance: Float = model?.marginBalance ?? 0.0
            //MARK: 计算保证进率
            //委托保证金
            let initMargin: Float    = model?.initMargin ?? 0.0
            //仓位保证金
            let maintMargin: Float   = model?.maintMargin ?? 0.0
            //已实现盈亏
            let realisedPnl: Float   =  model?.realisedPnl ?? 0.0
            //未实现盈亏
            let unrealisedPnl: Float =  model?.unrealisedPnl ?? 0.0
            
            //计算保证进率 =（可用保证金） / 保证金余额
//            let progressValue = (maintMargin + initMargin) / marginBalance
//            self.progressValueLabel.text = progressValue.pecnStr()
            
            self.totalEquityValueLabel.text = marginBalance.eightDecimalPlacesWithUnits()
            
            self.marginPaidValueLabel.text      = (maintMargin + initMargin).eightDecimalPlacesWithUnits()
            self.availableMarginValueLabel.text = model?.availableMargin.eightDecimalPlacesWithUnits()
            self.freezeMarginValueLabel.text    = initMargin.eightDecimalPlacesWithUnits()
            
            self.unrealisedPnlValueLabel.text = unrealisedPnl.eightDecimalPlacesWithUnits()
            self.realisedPnlValueLabel.text = realisedPnl.eightDecimalPlacesWithUnits()
        }
    }
}
