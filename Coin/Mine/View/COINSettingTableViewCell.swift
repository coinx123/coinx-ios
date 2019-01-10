//
//  COINSettingTableViewCell.swift
//  Coin
//
//  Created by gm on 2018/11/26.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
import Foundation

import SnapKit

struct COINSettingTableViewCellStyle: OptionSet {
    
    let rawValue: Int
    static let titleLabel = COINSettingTableViewCellStyle(rawValue: 0x01 << 0)
    static let iconView   = COINSettingTableViewCellStyle(rawValue: 0x01 << 1)
    static let switchView  = COINSettingTableViewCellStyle(rawValue: 0x01 << 2)
    static let valueLabel = COINSettingTableViewCellStyle(rawValue: 0x01 << 3)
    static let accessoryView = COINSettingTableViewCellStyle(rawValue: 0x01 << 4)
}


private struct SettingTableViewCellStruct {
    
    static let iconW: CGFloat = 28
    static let iconH: CGFloat = 28
    
    static let  hSpacing: CGFloat             = 20.0
    static let  hMargin: CGFloat              = 10.0
    static let  vSpacing: CGFloat             = 10.0
    
    static let  titleW: CGFloat               = 200.0
    static let  titleH: CGFloat               = 30.0
    
    static let  switchW: CGFloat               = 35
    static let  switchH: CGFloat               = 20
    
    //accessoryImageView
    static let  accessoryW: CGFloat               = 15
    static let  accessoryH: CGFloat               = 15
    
    //value
    static let  valueW: CGFloat               = 100
    static let  valueH: CGFloat               = 30
}
typealias SettingTableViewCellCallBack = (_ switchView: UISwitch)->()
class COINSettingTableViewCell: UITableViewCell {
    
    lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .left
        return iconImageView
    }()
    
    lazy var titleLabel: UILabel = {
        
        let titleLabel = UILabel.init()
        titleLabel.font = font15
        return titleLabel
    }()
    
    lazy var valueLabel: UILabel = {
        let valueLabel = UILabel()
        return valueLabel
    }()
    
    lazy var switchBtn: UISwitch = {
        let switchBtn = UISwitch()
        switchBtn.tag = self.tag
        switchBtn.addTarget(self, action: #selector(switchValueChange(_:)), for: .valueChanged)
        return switchBtn
    }()
    
    lazy var accessoryImageView: UIImageView = {
        let accessoryImageView = UIImageView()
        return accessoryImageView
    }()
    
    var cellStyle: [COINSettingTableViewCellStyle]
    
    var callBack: SettingTableViewCellCallBack?
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?,cellStyle: [COINSettingTableViewCellStyle]) {
        self.cellStyle = cellStyle
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        if  cellStyle.contains(.titleLabel)  {
           self.addSubview(self.titleLabel)
        }
        if cellStyle.contains(.iconView){
            self.addSubview(self.iconImageView)
        }
        if cellStyle.contains(.switchView){
            self.addSubview(self.switchBtn)
        }
        if cellStyle.contains(.valueLabel){
            self.addSubview(self.valueLabel)
        }
        if cellStyle.contains(.accessoryView){
            self.addSubview(self.accessoryImageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchValueChange(_ switchView: UISwitch){
        
        if (self.callBack != nil) {
            self.callBack!(switchView)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let hSpacing = SettingTableViewCellStruct.hSpacing
        let hMargin = SettingTableViewCellStruct.hMargin
        
        
        //weak var weakSelf = self
        if self.cellStyle.contains(.iconView){
            iconImageView.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(self.snp.centerY)
                maker.left.equalTo(hSpacing)
                maker.height.equalTo(SettingTableViewCellStruct.iconW)
                maker.width.equalTo(SettingTableViewCellStruct.iconH)
            }
        }
        
        if self.cellStyle.contains(.titleLabel){
            
            titleLabel.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(self.snp.centerY)
                maker.height.equalTo(SettingTableViewCellStruct.titleH)
                maker.width.equalTo(SettingTableViewCellStruct.titleW)
                if self.cellStyle.contains(.iconView){
                    maker.left.equalTo(iconImageView.snp.right)
                }else{
                    maker.left.equalTo(hSpacing)
                }
                
            }
            
        }
        
        if self.cellStyle.contains(.switchView){
            
            switchBtn.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(self.snp.centerY)
                maker.right.equalTo((hSpacing * -1))
                maker.height.equalTo(SettingTableViewCellStruct.switchH)
                maker.width.equalTo(SettingTableViewCellStruct.switchW)
            }
            switchBtn.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        }

        if self.cellStyle.contains(.accessoryView) {

            accessoryImageView.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(self.snp.centerY)
                maker.right.equalTo(hSpacing)
                maker.height.equalTo(SettingTableViewCellStruct.accessoryH)
                maker.width.equalTo(SettingTableViewCellStruct.accessoryW)
            }
            
        }
        
        if self.cellStyle.contains(.valueLabel){
            
            valueLabel.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(self.snp.centerY)
                maker.right.equalTo(accessoryImageView.snp.left).offset(hMargin)
                maker.height.equalTo(SettingTableViewCellStruct.valueH)
                maker.width.equalTo(SettingTableViewCellStruct.valueW)
            }
            
        }
        
    }
}
