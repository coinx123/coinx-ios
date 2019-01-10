//
//  OrderManageTitleView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/12.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

class COINOrderManageTitleView: UIView {

    var changeIndexHandle: ((Int)->())?
    
    lazy var exchangeBtn: UIButton = {
        let exchangeBtn = UIButton.init(type: .custom)
        exchangeBtn.frame = CGRect.init(x: 0, y: 0, width: 60, height: self.frame.size.height)
        exchangeBtn.setTitle("交易", for: .normal)
        exchangeBtn.titleLabel?.font = fontBold16
        exchangeBtn.addTarget(self, action: #selector(exchangeAction), for: .touchUpInside)
        return exchangeBtn
    }()
    
    lazy var orderBookBtn: UIButton = {
        let orderBookBtn = UIButton.init(type: .custom)
        orderBookBtn.frame = CGRect.init(x: 60, y: 0, width: 60, height: self.frame.size.height)
        orderBookBtn.setTitle("委托", for: .normal)
        orderBookBtn.titleLabel?.font = fontBold16
        orderBookBtn.addTarget(self, action: #selector(orderBookAction), for: .touchUpInside)
        return orderBookBtn
    }()
    
    lazy var positionBtn: UIButton = {
        let positionBtn = UIButton.init(type: .custom)
        positionBtn.frame = CGRect.init(x: 60+60, y: 0, width: 60, height: self.frame.size.height)
        positionBtn.setTitle("持仓", for: .normal)
        positionBtn.titleLabel?.font = fontBold16
        positionBtn.addTarget(self, action: #selector(positionAction), for: .touchUpInside)
        return positionBtn
    }()
    
    lazy var line: UIView = {
        let line = UIView.init(frame: CGRect.init(x: 20, y: self.frame.size.height - 2, width: 20, height: 2))
        line.backgroundColor = lineBlueColor
        return line
    }()
    
    var selectedIndex: Int{
        get {
            return _selectedIndex
        }
        set {
            self.changeView(newValue: newValue)
            _selectedIndex = newValue
        }
    }
    
    private var _selectedIndex = 0
    
    init(frame: CGRect, selectedIndex: Int) {
        super.init(frame: frame)
        self.addSubview(self.exchangeBtn)
        self.addSubview(self.orderBookBtn)
        self.addSubview(self.positionBtn)
        self.addSubview(self.line)
        self.selectedIndex = selectedIndex
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeView(newValue: Int) {
        self.exchangeBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        self.orderBookBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        self.positionBtn.setTitleColor(titleBlueColor_Light, for: .normal)
        var selectedBtn: UIButton?
        switch newValue {
        case 0:
            self.exchangeBtn.setTitleColor(titleBlueColor, for: .normal)
            selectedBtn = exchangeBtn
        case 1:
            self.orderBookBtn.setTitleColor(titleBlueColor, for: .normal)
            selectedBtn = orderBookBtn
        case 2:
            self.positionBtn.setTitleColor(titleBlueColor, for: .normal)
            selectedBtn = positionBtn
        default:
            break
        }
        UIView.animate(withDuration: 0.25) {
            self.line.frame = CGRect.init(x: (selectedBtn?.center.x)! - 10, y: self.line.frame.origin.y, width: 20, height: 2)
        }
    }
    
    @objc func exchangeAction() {
        self.selectedIndex = 0
        if self.changeIndexHandle != nil {
            self.changeIndexHandle!(self.selectedIndex)
        }
    }
    
    @objc func orderBookAction() {
        self.selectedIndex = 1
        if self.changeIndexHandle != nil {
            self.changeIndexHandle!(self.selectedIndex)
        }
    }
    
    @objc func positionAction() {
        self.selectedIndex = 2
        if self.changeIndexHandle != nil {
            self.changeIndexHandle!(self.selectedIndex)
        }
    }
}
