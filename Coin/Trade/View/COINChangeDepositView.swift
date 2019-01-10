//
//  ChangeDepositView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/9.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

private struct COINChangeDepositViewUX {
    static let HPadding: CGFloat = 15
    static let VPadding: CGFloat = 12
    static let BaseViewHeight: CGFloat = 276
    static let BtnWidth: CGFloat = 60
    static let BtnHeight: CGFloat = 40
}

class COINChangeDepositView: UIView {

    var selectedIndex = 0
    
    var positionModel: COINPositionItemModel?
    
    var marginModel: COINMarginModel?
    
    var mainMargin: String?
    
    var depositChangeHandle: (()->())?
    
    lazy var baseView: UIView = {
        let baseView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINChangeDepositViewUX.BaseViewHeight))
        baseView.backgroundColor = whiteColor
        
        baseView.addSubview(self.cancelBtn)
        baseView.addSubview(self.increaseDepositBtn)
        baseView.addSubview(self.reduceDepositBtn)
        baseView.addSubview(self.depositTextField)
        baseView.addSubview(self.titleLabel)
        baseView.addSubview(self.countLabel)
        baseView.addSubview(self.sureBtn)
        return baseView
    }()
    
    lazy var cancelView: UIView = {
        let cancelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINChangeDepositViewUX.BaseViewHeight))
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideView))
        cancelView.addGestureRecognizer(tap)
        return cancelView
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel?.font = font15
        cancelBtn.setTitleColor(titleBlueColor, for: .normal)
        cancelBtn.frame = CGRect.init(x: 0, y: 0, width: COINChangeDepositViewUX.BtnWidth, height: COINChangeDepositViewUX.BtnHeight)
        cancelBtn.addTarget(self, action: #selector(hideView), for: .touchUpInside)
        return cancelBtn
    }()

    lazy var increaseDepositBtn: DespositButton = {
        let increaseDepositBtn = DespositButton.init(frame: CGRect.init(x: COINChangeDepositViewUX.HPadding, y: self.cancelBtn.frame.maxY + COINChangeDepositViewUX.VPadding, width: (screenWidth - COINChangeDepositViewUX.HPadding * 2)/2, height: COINChangeDepositViewUX.BtnHeight))
        increaseDepositBtn.setTitle("增加保证金")
        increaseDepositBtn.setTitleColor(whiteColor)
        increaseDepositBtn.setImage(UIImage(named: "trade_position_lefthightlight")!)
        increaseDepositBtn.addTarget(self, action: #selector(increaseAction))
        return increaseDepositBtn
    }()
    
    lazy var reduceDepositBtn: DespositButton = {
        let reduceDepositBtn = DespositButton.init(frame: CGRect.init(x: screenWidth/2, y: self.cancelBtn.frame.maxY + COINChangeDepositViewUX.VPadding, width: (screenWidth - COINChangeDepositViewUX.HPadding * 2)/2, height: COINChangeDepositViewUX.BtnHeight))
        reduceDepositBtn.setTitle("减少保证金")
        reduceDepositBtn.setTitleColor(titleBlueColor_Light)
        reduceDepositBtn.addTarget(self, action: #selector(reduceAction))
        reduceDepositBtn.setImage(UIImage.init(named: "trade_position_right")!)
        return reduceDepositBtn
    }()
    
    var leftLabel: UILabel?
    
    lazy var depositTextField: UITextField = {
        let depositTextField = UITextField.init(frame: CGRect.init(x: COINChangeDepositViewUX.HPadding, y: self.increaseDepositBtn.frame.maxY + COINChangeDepositViewUX.VPadding, width: screenWidth - COINChangeDepositViewUX.HPadding * 2, height: 40))
        depositTextField.textAlignment = .right
        depositTextField.contentVerticalAlignment = .center
        depositTextField.clearButtonMode = .always
        if depositTextField.value(forKey: "_clearButton") != nil {
            let btn: UIButton = depositTextField.value(forKey: "_clearButton") as! UIButton
            btn.setImage(UIImage(named: "trade_clear"), for: .normal)
        }
        depositTextField.layer.borderColor = lineBlueColor_Light.cgColor
        depositTextField.layer.borderWidth = 1
        depositTextField.keyboardType = .decimalPad
        depositTextField.placeholder = "输入数量"
        
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 110, height: depositTextField.frame.size.height))
        leftLabel.text = "保证金(BTC)"
        leftLabel.textAlignment = .center
        leftLabel.textColor = titleBlueColor_Light
        leftLabel.font = font13
        self.leftLabel = leftLabel
        depositTextField.leftView = leftLabel
        depositTextField.leftViewMode = .always
        
        return depositTextField
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: CGRect.init(x: COINChangeDepositViewUX.HPadding, y: self.depositTextField.frame.maxY, width: (screenWidth - COINChangeDepositViewUX.HPadding * 2)/2 , height: 82))
        titleLabel.numberOfLines = 3
        titleLabel.text = "当前仓位\n已分配保证金\n可追加保证金"
        titleLabel.font = font12
        titleLabel.textColor = titleGrayColor
        return titleLabel
    }()
    
    lazy var countLabel: UILabel = {
        let countLabel = UILabel.init(frame: CGRect.init(x: screenWidth/2, y: self.depositTextField.frame.maxY, width: (screenWidth - COINChangeDepositViewUX.HPadding * 2)/2 , height: 82))
        countLabel.textAlignment = .right
        countLabel.numberOfLines = 3
        countLabel.text = "1张 多头 1x\n0.00015BTC\n0.00085BTC"
        countLabel.font = font12
        countLabel.textColor = titleGrayColor
        return countLabel
    }()
    
    lazy var sureBtn: UIButton = {
        let sureBtn = UIButton.init(type: .custom)
        sureBtn.frame = CGRect.init(x: COINChangeDepositViewUX.HPadding, y: self.titleLabel.frame.maxY, width: screenWidth - COINChangeDepositViewUX.HPadding * 2, height: COINChangeDepositViewUX.BtnHeight)
        sureBtn.setTitle("增加保证金", for: .normal)
        sureBtn.setTitleColor(whiteColor, for: .normal)
        sureBtn.backgroundColor = bgBlueColor
        sureBtn.titleLabel?.font = fontBold15
        sureBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        sureBtn.addTarget(self, action: #selector(changeDepositAction), for: .touchUpInside)
        return sureBtn
    }()
    
    init(frame: CGRect, positionModel: COINPositionItemModel, marginModel: COINMarginModel) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.addSubview(self.baseView)
        self.addSubview(self.cancelView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notif:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notif:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.positionModel = positionModel
        self.marginModel = marginModel
        
        self.mainMargin = (positionModel.maintMargin ?? "0").fourDecimalPlacesWithoutUnits()
        
        let availableMargin = (marginModel.availableMargin ?? 0.0).fourDecimalPlacesWithoutUnits()
        
        self.countLabel.text = "\(positionModel.currentQty ?? "")张 \(Int(positionModel.currentQty ?? "0")! > 0 ? "多头" : "空头") \(positionModel.leverage ?? "")x\n\(self.mainMargin!)\(positionModel.currency?.uppercased() ?? "")\n\(availableMargin)\(positionModel.currency?.uppercased() ?? "")"
        self.leftLabel?.text = "保证金(\(positionModel.currency?.uppercased() ?? ""))"
        
        self.lineSpace(lineSpace: 6, text: self.titleLabel.text!, label: self.titleLabel)
        self.lineSpace(lineSpace: 6, text: self.countLabel.text!, label: self.countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func lineSpace(lineSpace: Float, text: String, label: UILabel) {
        if text.count == 0 {
            return;
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineSpace)
        paragraphStyle.lineBreakMode = label.lineBreakMode
        paragraphStyle.alignment = label.textAlignment
        let att = NSMutableAttributedString.init(string: text)
        att.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange.init(location: 0, length: text.count))
        label.attributedText = att
    }
    
    // MARK: ----键盘出现----
    @objc func keyboardWillShow(notif: Notification) {
        let kbFrame: CGRect = notif.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height - COINChangeDepositViewUX.BaseViewHeight - kbFrame.size.height, width: self.frame.size.width, height: COINChangeDepositViewUX.BaseViewHeight)
        }) { (finish) in
            self.cancelView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINChangeDepositViewUX.BaseViewHeight - kbFrame.size.height)
        }
    }
    // MARK: ----键盘隐藏----
    @objc func keyboardWillHide(notif: Notification) {
        self.showView()
    }
    
    func showView() {
        self.isHidden = false
        if self.superview == nil {
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height - COINChangeDepositViewUX.BaseViewHeight, width: self.frame.size.width, height: COINChangeDepositViewUX.BaseViewHeight)
        }) { (finish) in
            self.depositTextField.becomeFirstResponder()
        }
        self.cancelView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINChangeDepositViewUX.BaseViewHeight)
    }
    
    @objc func hideView() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINChangeDepositViewUX.BaseViewHeight)
        }) { (finish) in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    @objc func increaseAction() {
        if self.selectedIndex == 0 {
            return
        }
        self.selectedIndex = 0
        self.increaseDepositBtn.setImage(UIImage.init(named: "trade_position_lefthightlight")!)
        self.increaseDepositBtn.setTitleColor(whiteColor)
        self.reduceDepositBtn.setImage(UIImage.init(named: "trade_position_right")!)
        self.reduceDepositBtn.setTitleColor(titleBlueColor_Light)
        self.titleLabel.text = "当前仓位\n已分配保证金\n可追加保证金"
        self.sureBtn.setTitle("增加保证金", for: .normal)
        let availableMargin = (self.marginModel!.availableMargin ?? 0.0).fourDecimalPlacesWithoutUnits()
        self.countLabel.text = "\(self.positionModel!.currentQty ?? "")张 \(Int(self.positionModel!.currentQty ?? "0")! > 0 ? "多头" : "空头") \(self.positionModel!.leverage ?? "")x\n\(self.mainMargin!)\(self.positionModel!.currency?.uppercased() ?? "")\n\(availableMargin)\(self.self.positionModel!.currency?.uppercased() ?? "")"
        
        self.lineSpace(lineSpace: 6, text: self.titleLabel.text!, label: self.titleLabel)
        self.lineSpace(lineSpace: 6, text: self.countLabel.text!, label: self.countLabel)
    }
    
    @objc func reduceAction() {
        if self.selectedIndex == 1 {
            return
        }
        self.selectedIndex = 1
        self.increaseDepositBtn.setImage(UIImage.init(named: "trade_position_left")!)
        self.increaseDepositBtn.setTitleColor(titleBlueColor_Light)
        self.reduceDepositBtn.setImage(UIImage.init(named: "trade_position_righthightlight")!)
        self.reduceDepositBtn.setTitleColor(whiteColor)
        self.titleLabel.text = "当前仓位\n已分配保证金\n可减少保证金"
        self.sureBtn.setTitle("减少保证金", for: .normal)
        
        let canReduce = fabs(Double(self.positionModel!.maintMargin ?? "0")! - Double(self.positionModel!.posMaint ?? "0")! - Double(self.positionModel!.posInit ?? "0")!)
        let posMargin = Float(canReduce).fourDecimalPlacesWithoutUnits()
        
        self.countLabel.text = "\(self.positionModel!.currentQty ?? "")张 \(Int(self.positionModel!.currentQty ?? "0")! > 0 ? "多头" : "空头") \(self.positionModel!.leverage ?? "")x\n\(self.mainMargin!)\(self.positionModel!.currency?.uppercased() ?? "")\n\(posMargin)\(self.self.positionModel!.currency?.uppercased() ?? "")"
        
        self.lineSpace(lineSpace: 6, text: self.titleLabel.text!, label: self.titleLabel)
        self.lineSpace(lineSpace: 6, text: self.countLabel.text!, label: self.countLabel)
    }
    
    @objc func changeDepositAction() {
        if self.depositTextField.text?.count ?? 0 <= 0 {
            return
        }
        let requestPath = "/api/v1/position/transferMargin"
        //        ,"filter":["symbol":symbol]
        let amount: Double?
        if self.selectedIndex == 0 {
            if Double(self.depositTextField.text ?? "")! > Double(self.marginModel!.availableMargin ?? 0.0) {
                print("输入大于可增加量")
                return
            }
            amount = Double(self.depositTextField.text ?? "")
        } else {
            let canReduce = fabs(Double(self.positionModel!.maintMargin ?? "0")! - Double(self.positionModel!.posMaint ?? "0")! - Double(self.positionModel!.posInit ?? "0")!)
            let posMargin = Double(Float(canReduce).fourDecimalPlacesWithoutUnits())!
            if Double(self.depositTextField.text ?? "")! > posMargin {
                print("输入大于可减少量")
                return
            }
            amount = -Double(self.depositTextField.text ?? "")!
        }
        let parameters: [String: Any] = ["symbol":self.positionModel?.symbol ?? "","amount":amount!*100000000]
        weak var weakSelf = self
        COINNetworkTool.request(path: requestPath, platform: .bitmex, parameters: parameters, method: .post, responseClass: COINPositionModel.self,successHandler: { (response) in
            print(response?.data?.toJSON())
            weakSelf?.hideView()
            if weakSelf?.depositChangeHandle != nil {
                weakSelf?.depositChangeHandle!()
            }
        })
    }
    
}


class DespositButton: UIView {
    lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        return backgroundImageView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = fontBold16
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundImageView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.addSubview(self.backgroundImageView)
        self.titleLabel.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(_ target: Any?, action: Selector) {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: target, action: action)
        self.addGestureRecognizer(tap)
    }
    
    func setImage(_ image: UIImage) {
        self.backgroundImageView.image = image
    }
    
    func setTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    func setTitleColor(_ color: UIColor) {
        self.titleLabel.textColor = color
    }
}
