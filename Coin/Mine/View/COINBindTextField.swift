//
//  COINBindTextField.swift
//  Coin
//
//  Created by dev6 on 2018/11/21.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

typealias TextFieldCallBack = (String)->()
class COINBindTextField: UITextField, UITextFieldDelegate{

    var callBack: TextFieldCallBack?
    
    var line: UIView = UIView.init()
    
    init(_ frame:CGRect,_ callBack:@escaping TextFieldCallBack) {
        super.init(frame: frame)
        self.delegate = self
        self.returnKeyType = .done
        self.callBack = callBack
        self.textAlignment = .left
        self.clearButtonMode = .always
        self.font = font14
        self.text = ""
        self.addTarget(self, action: #selector(valueChanged(tf:)), for: .editingChanged)
        self.line.backgroundColor = lineGrayColor
        self.line.frame = CGRect.init(x: 0, y: frame.size.height - 1, width: frame.size.width, height: 1)
        self.addSubview(self.line)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func valueChanged(tf:COINBindTextField){
        if (callBack != nil) {
            callBack!(tf.text!)
        }
        if !(tf.text == nil || (tf.text?.isEmpty)!) {
            self.line.backgroundColor = lineBlueColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (callBack != nil) {
            callBack!(textField.text!)
        }
        if (textField.text == nil || (textField.text?.isEmpty)!) {
            self.line.backgroundColor = lineGrayColor
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.line.backgroundColor = lineBlueColor
        return true
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
