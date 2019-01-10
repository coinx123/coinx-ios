//
//  SelectLeverageView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/7.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

private struct COINSelectViewUX {
    static let BaseViewHeight: CGFloat = 280
    static let BtnWidth: CGFloat = 80
    static let BtnHeight: CGFloat = 40
}

class COINSelectView: UIView, UIPickerViewDelegate,UIPickerViewDataSource {
    
    var complectionHandle: ((Int,String?)->())?
    
    var dataArray: [String]?
    
    var selectedIndex: Int? {
        didSet {
            if selectedIndex! < self.pickView.numberOfRows(inComponent: 0) {
                self.pickView.selectRow(selectedIndex!, inComponent: 0, animated: false)
            }
        }
    }
    
    lazy var baseView: UIView = {
        let baseView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINSelectViewUX.BaseViewHeight))
        baseView.backgroundColor = whiteColor
        
        baseView.addSubview(self.cancelBtn)
        baseView.addSubview(self.finishBtn)
        baseView.addSubview(self.pickView)
        return baseView
    }()
    
    lazy var cancelView: UIView = {
        let cancelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINSelectViewUX.BaseViewHeight))
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideView))
        cancelView.addGestureRecognizer(tap)
        return cancelView
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel?.font = fontBold14
        cancelBtn.setTitleColor(titleBlueColor, for: .normal)
        cancelBtn.frame = CGRect.init(x: 0, y: 0, width: COINSelectViewUX.BtnWidth, height: COINSelectViewUX.BtnHeight)
        cancelBtn.addTarget(self, action: #selector(hideView), for: .touchUpInside)
        return cancelBtn
    }()
    
    lazy var finishBtn: UIButton = {
        let finishBtn = UIButton.init(type: .custom)
        finishBtn.setTitle("完成", for: .normal)
        finishBtn.titleLabel?.font = fontBold14
        finishBtn.setTitleColor(titleBlueColor, for: .normal)
        finishBtn.frame = CGRect.init(x: self.frame.size.width - COINSelectViewUX.BtnWidth, y: 0, width: COINSelectViewUX.BtnWidth, height: COINSelectViewUX.BtnHeight)
        finishBtn.addTarget(self, action: #selector(finishAction), for: .touchUpInside)
        return finishBtn
    }()
    
    lazy var pickView: UIPickerView = {
        let pickView = UIPickerView.init(frame: CGRect.init(x: 0, y: COINSelectViewUX.BtnHeight, width: self.frame.size.width, height: COINSelectViewUX.BaseViewHeight - COINSelectViewUX.BtnHeight))
        pickView.delegate = self
        pickView.dataSource = self
        pickView.showsSelectionIndicator = true
        let view = UIView.init(frame: CGRect.init(x: -1, y: (pickView.frame.size.height - 32)/2, width: self.frame.size.width+2, height: 32))
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = lineGrayColor.cgColor
        view.layer.borderWidth = 1
        pickView.addSubview(view)
        return pickView
    }()
    
    init(frame: CGRect,data: [String]) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.dataArray = data
        self.addSubview(self.baseView)
        self.addSubview(self.cancelView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showView() {
        self.isHidden = false
        if self.superview == nil {
            return
        }
        UIView.animate(withDuration: 0.25) {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height - COINSelectViewUX.BaseViewHeight, width: self.frame.size.width, height: COINSelectViewUX.BaseViewHeight)
        }
    }
    
    @objc func hideView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINSelectViewUX.BaseViewHeight)
        }) { (finish) in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    @objc func finishAction() {
        if self.complectionHandle != nil {
            if self.dataArray != nil {
                let row = self.pickView.selectedRow(inComponent: 0)
                self.complectionHandle!(row,self.dataArray![row])
            }
        }
        self.hideView()
    }
    
    // MARK: ----UIPickerViewDataSource----
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataArray?.count ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var baseView = view
        if baseView == nil {
            baseView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: pickerView.frame.size.width, height: 30))
        }
        let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: pickerView.frame.size.width, height: 30))
        if row < self.dataArray?.count ?? 0 {
            titleLabel.text = self.dataArray![row]
        }
        titleLabel.font = font16
        titleLabel.textAlignment = .center
        baseView?.addSubview(titleLabel)
        return baseView!
    }
    
}
