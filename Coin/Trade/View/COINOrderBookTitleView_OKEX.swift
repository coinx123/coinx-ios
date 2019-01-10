//
//  COINOrderBookTitleView_OKEX.swift
//  Coin
//
//  Created by dev6 on 2018/12/26.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINOrderBookTitleView_OKEX: UIView {

    var instrumentIDChangeAction: ((String)->())?
    
    var stateChangeAction: ((Int)->())?
    
    var selectedInstrumentID: String? {
        get {
            return _selectedInstrumentID
        }
        set {
            if _selectedInstrumentID == nil {
                var instrumentArray = ["BTC","USD","181228"]
                if newValue != nil {
                    instrumentArray = newValue!.components(separatedBy: "-")
                }
                let width = frame.size.width/3
                for i in 0..<3 {
                    let btn = UIButton.init(type: .custom)
                    btn.frame = CGRect.init(x: width * CGFloat(i), y: 0, width: width, height: frame.size.height)
                    btn.titleLabel?.font = font14
                    btn.setTitleColor(titleBlueColor_Light, for: .normal)
                    btn.setImage(UIImage.init(named: "trade_downArrow"), for: .normal)
                    btn.tag = 100 + i
                    btn.addTarget(self, action: #selector(titleAction(btn:)), for: .touchUpInside)
                    switch i {
                    case 0:
                        self.selectedCoinType = instrumentArray[0]
                        btn.setTitle(self.selectedCoinType, for: .normal)
                    case 1:
                        let time = instrumentArray[2]
                        let timeType = time.okexTime()
                        btn.setTitle(timeType, for: .normal)
                    case 2:
                        btn.setTitle("未成交", for: .normal)
                    default:
                        break
                    }
                    if i < 2 {
                        btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 44, bottom: 0, right: 0)
                        btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -34, bottom: 0, right: 0)
                    } else {
                        btn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 70, bottom: 0, right: 0)
                        btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -34, bottom: 0, right: 0)
                    }
                    self.addSubview(btn)
                }
            }
            _selectedInstrumentID = newValue
        }
    }
    
    var _selectedInstrumentID: String?
    
    var selectedCoinType: String?
    var selectedTimeType = 0 //0当周，1次周，2季度
    var selectedState = 0 //0未成交，1已成交，2已撤销
    
    var instrumentIDs: [String]? {
        didSet {
            if self.coinDict == nil {
                self.coinDict = [String:[String]]()
                if self.instrumentIDs != nil {
                    for instrumentID in self.instrumentIDs! {
                        let instrumentArray: [String] = instrumentID.components(separatedBy: "-")
                        let coin = instrumentArray[0]
                        if (self.coinDict?.keys.sorted().contains(coin))! {
                            var values = self.coinDict?[coin]
                            values?.append(instrumentID)
                            self.coinDict?[coin] = values
                        } else {
                            let values = [instrumentID]
                            self.coinDict?[coin] = values
                        }
                    }
                }
            }
        }
    }
    
    var coinDict: [String:[String]]?
    
    var selectedType = 0
    
    init(frame: CGRect, instrumentID: String?) {
        super.init(frame: frame)
        self.backgroundColor = whiteColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func titleAction(btn: UIButton) {
        self.selectedType = btn.tag - 100
        var data: [String]?
        var selectedIndex: Int?
        if self.selectedType == 0 {
            selectedIndex = 0
            data = self.coinDict?.keys.sorted()
            for (index,coin) in (data?.enumerated())! {
                if coin == self.selectedCoinType {
                    selectedIndex = index
                    break
                }
            }
        } else if self.selectedType == 1 {
            selectedIndex = self.selectedTimeType
            data = ["当周","次周","季度"]
        } else if self.selectedType == 2 {
            selectedIndex = self.selectedState
            data = ["未成交","已成交","已撤销"]
        }
        let view = COINSelectView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), data: data!)
        UIApplication.shared.keyWindow!.addSubview(view)
        view.showView()
        view.selectedIndex = selectedIndex
        weak var weakSelf = self
        view.complectionHandle = { (selectIndex,text) in
            btn.setTitle(text, for: .normal)
            if weakSelf?.selectedType == 0 {
                weakSelf?.selectedCoinType = text
                let values = weakSelf?.coinDict?[(weakSelf?.selectedCoinType)!]
                if weakSelf?.instrumentIDChangeAction != nil && values != nil {
                    weakSelf?.instrumentIDChangeAction!(values![(weakSelf?.selectedTimeType)!])
                }
            } else if weakSelf?.selectedType == 1 {
                weakSelf?.selectedTimeType = selectIndex
                let values = weakSelf?.coinDict?[(weakSelf?.selectedCoinType)!]
                if weakSelf?.instrumentIDChangeAction != nil && values != nil {
                    weakSelf?.instrumentIDChangeAction!(values![(weakSelf?.selectedTimeType)!])
                }
            } else if weakSelf?.selectedType == 2 {
                weakSelf?.selectedState = selectIndex
                if weakSelf?.stateChangeAction != nil {
                    weakSelf?.stateChangeAction!((weakSelf?.selectedState)!)
                }
            }
        }
    }

}
