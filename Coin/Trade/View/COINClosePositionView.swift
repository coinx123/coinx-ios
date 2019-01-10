//
//  ClosePositionView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/9.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

private struct COINClosePositionViewUX {
    static let HPadding: CGFloat = 15
    static let VPadding: CGFloat = 15
    static let BaseViewHeight: CGFloat = 225
    static let BtnWidth: CGFloat = 60
    static let BtnHeight: CGFloat = 40
}


class COINClosePositionView: UIView {
    
    var platform: Platform
    
    var positionModel: COINPositionItemModel?
    
    var refreshHandle: (()->())?
    
    var priceLeftLabel: UILabel?
    
    lazy var baseView: UIView = {
        let baseView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINClosePositionViewUX.BaseViewHeight))
        baseView.backgroundColor = whiteColor
        
        baseView.addSubview(self.cancelBtn)
        baseView.addSubview(self.priceTextField)
        baseView.addSubview(self.sellCountTextField)
        baseView.addSubview(self.closeAllBtn)
        baseView.addSubview(self.closePositionBtn)
        return baseView
    }()
    
    lazy var cancelView: UIView = {
        let cancelView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINClosePositionViewUX.BaseViewHeight))
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideView))
        cancelView.addGestureRecognizer(tap)
        return cancelView
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel?.font = font15
        cancelBtn.setTitleColor(titleBlueColor, for: .normal)
        cancelBtn.frame = CGRect.init(x: 0, y: 0, width: COINClosePositionViewUX.BtnWidth, height: COINClosePositionViewUX.BtnHeight)
        cancelBtn.addTarget(self, action: #selector(hideView), for: .touchUpInside)
        return cancelBtn
    }()
    
    lazy var priceTextField: UITextField = {
        let priceTextField = UITextField.init(frame: CGRect.init(x: COINClosePositionViewUX.HPadding, y: self.cancelBtn.frame.maxY + COINClosePositionViewUX.VPadding, width: screenWidth - COINClosePositionViewUX.HPadding * 2, height: 40))
        priceTextField.textAlignment = .right
        priceTextField.clearButtonMode = .always
        if priceTextField.value(forKey: "_clearButton") != nil {
            let btn: UIButton = priceTextField.value(forKey: "_clearButton") as! UIButton
            btn.setImage(UIImage(named: "trade_clear"), for: .normal)
        }
        priceTextField.layer.borderColor = lineBlueColor_Light.cgColor
        priceTextField.layer.borderWidth = 1
        priceTextField.keyboardType = .decimalPad
        
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 90, height: priceTextField.frame.size.height))
        leftLabel.text = "价格(USD)"
        leftLabel.textAlignment = .center
        leftLabel.textColor = titleBlueColor_Light
        leftLabel.font = font13
        priceTextField.leftView = leftLabel
        priceTextField.leftViewMode = .always
        self.priceLeftLabel = leftLabel
        
        return priceTextField
    }()
    
    lazy var sellCountTextField: UITextField = {
        let sellCountTextField = UITextField.init(frame: CGRect.init(x: COINClosePositionViewUX.HPadding, y: self.priceTextField.frame.maxY + COINClosePositionViewUX.VPadding, width: screenWidth - COINClosePositionViewUX.HPadding * 2, height: 40))
        sellCountTextField.textAlignment = .right
        sellCountTextField.clearButtonMode = .always
        if sellCountTextField.value(forKey: "_clearButton") != nil {
            let btn: UIButton = sellCountTextField.value(forKey: "_clearButton") as! UIButton
            btn.setImage(UIImage(named: "trade_clear"), for: .normal)
        }
        sellCountTextField.layer.borderColor = lineBlueColor_Light.cgColor
        sellCountTextField.layer.borderWidth = 1
        sellCountTextField.keyboardType = .numberPad
        
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 90, height: sellCountTextField.frame.size.height))
        leftLabel.text = "平仓数量"
        leftLabel.textAlignment = .center
        leftLabel.textColor = titleBlueColor_Light
        leftLabel.font = font13
        sellCountTextField.leftView = leftLabel
        sellCountTextField.leftViewMode = .always
        return sellCountTextField
    }()
    
    lazy var closeAllBtn: UIButton = {
        let closeAllBtn = UIButton.init(type: .custom)
        closeAllBtn.frame = CGRect.init(x: COINClosePositionViewUX.HPadding, y: self.sellCountTextField.frame.maxY + COINClosePositionViewUX.VPadding, width: (screenWidth - COINClosePositionViewUX.HPadding * 3)/2, height: COINClosePositionViewUX.BtnHeight)
        closeAllBtn.setTitleColor(titleBlueColor, for: .normal)
        closeAllBtn.setTitle("市价全平", for: .normal)
        closeAllBtn.layer.borderColor = lineBlueColor.cgColor
        closeAllBtn.layer.borderWidth = 1
        closeAllBtn.layer.cornerRadius = 2
        closeAllBtn.titleLabel?.font = fontBold13
        closeAllBtn.addTarget(self, action: #selector(closeAllAction), for: .touchUpInside)
        return closeAllBtn
    }()
    
    lazy var closePositionBtn: UIButton = {
        let closePositionBtn = UIButton.init(type: .custom)
        closePositionBtn.frame = CGRect.init(x: self.closeAllBtn.frame.maxX + COINClosePositionViewUX.HPadding, y: self.sellCountTextField.frame.maxY + COINClosePositionViewUX.VPadding, width: (screenWidth - COINClosePositionViewUX.HPadding * 3)/2, height: COINClosePositionViewUX.BtnHeight)
        closePositionBtn.setTitleColor(whiteColor, for: .normal)
        closePositionBtn.setTitle("平仓", for: .normal)
        closePositionBtn.backgroundColor = bgBlueColor
        closePositionBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 2, height: 2))
        closePositionBtn.titleLabel?.font = fontBold13
        closePositionBtn.addTarget(self, action: #selector(closePositionAction), for: .touchUpInside)
        return closePositionBtn
    }()
    
    init(frame: CGRect, positionModel: COINPositionItemModel, platform: Platform) {
        self.platform = platform
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.addSubview(self.baseView)
        self.addSubview(self.cancelView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notif:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notif:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.positionModel = positionModel
        self.priceTextField.text = positionModel.lastPrice
        
        self.priceLeftLabel?.text = "价格(\(positionModel.quoteCurrency ?? ""))"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: ----键盘出现----
    @objc func keyboardWillShow(notif: Notification) {
        let kbFrame: CGRect = notif.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height - COINClosePositionViewUX.BaseViewHeight - kbFrame.size.height, width: self.frame.size.width, height: COINClosePositionViewUX.BaseViewHeight)
        }) { (finish) in
            self.cancelView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINClosePositionViewUX.BaseViewHeight - kbFrame.size.height)
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
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height - COINClosePositionViewUX.BaseViewHeight, width: self.frame.size.width, height: COINClosePositionViewUX.BaseViewHeight)
        }) { (finish) in
            self.sellCountTextField.becomeFirstResponder()
        }
        self.cancelView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - COINClosePositionViewUX.BaseViewHeight)
    }
    
    @objc func hideView() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            self.baseView.frame = CGRect.init(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: COINClosePositionViewUX.BaseViewHeight)
        }) { (finish) in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    @objc func closeAllAction() {
        self.endEditing(true)
        self.isHidden = true
        self.removeFromSuperview()
        
        let mode = Int(self.positionModel?.currentQty ?? "0")! > 0 ? "  多头  " : "  空头  "
        let rootSymbol = "\((self.positionModel?.underlying)!)  "
        let levarage = Bool(self.positionModel?.crossMargin ?? "0") ?? false ? "全仓" : "\(String(format: "%.0f", Float(self.positionModel?.leverage ?? "") ?? 0.0))x"
        let content = rootSymbol + (self.positionModel?.type ?? "永续")! + "-" + (self.positionModel?.symbol)! + mode + "\(levarage)  "
        let alert = UIAlertController.init(title: nil, message: "您确认对\(content) 仓位进行市价全平吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "取消", style: .default, handler: { (cancel) in
            
        }))
        alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (cancel) in
            self.submitOrders(Int(self.positionModel?.currentQty ?? "0")! > 0 ? "Sell" : "Buy", type: 1)
        }))
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.window?.rootViewController?.isKind(of: UITabBarController.self) ?? false {
            let tabbar: UITabBarController = delegate.window?.rootViewController as! UITabBarController
            tabbar.viewControllers?.first?.present(alert, animated: true, completion: nil)
        } else {
            delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func closePositionAction() {
        if self.sellCountTextField.text?.count ?? 0 <= 0 || self.priceTextField.text?.count ?? 0 <= 0 {
            self.makeToast("请输入价格和数量")
            return
        }
//        if Double(self.sellCountTextField.text ?? "")! > Double(self.positionModel?.openingQty ?? "")! {
//            self.makeToast("卖出数量不能大于可平仓量")
//            return
//        }
        self.submitOrders(Int(self.positionModel?.currentQty ?? "0")! > 0 ? "Sell" : "Buy", type: 0)
    }
    
    //多头的，side就是sell，空头的side就是buy
    func submitOrders(_ side: String, type: Int) {
        if self.positionModel == nil {
            return
        }
        if self.platform == .bitmex {
            self.submitOrders_bitmex(side, type: type)
        } else {
            self.submitOrders_okex(side, type: type)
        }
    }
    
    func submitOrders_bitmex(_ side: String, type: Int) {
        var orderQty: Int = 0
        if (self.sellCountTextField.text?.count)! > 0 {
            orderQty = Int(self.sellCountTextField.text!)!
        }
        //         * (Int(self.positionModel?.currentQty ?? "0")! > 0 ? 1 : -1)
        var parameters = [
            "side" : side,
            "symbol" : self.positionModel?.symbol! ?? String.self,
            "orderQty" : orderQty,
            ] as [String : Any]
        
        switch type {
        case 0:
            parameters["ordType"] = "Limit"
            var price: String?
            if self.positionModel?.underlying == "XBT" && !(self.positionModel?.symbol?.uppercased().contains("7D"))! {
                price = String(format: "%.0f", Float(self.priceTextField.text!)!) //xbtusd、xbt季度的价格必须是0.5的倍数
            } else {
                price = self.priceTextField.text
            }
            parameters["price"]   =  price //价格必须是0.5的倍数
            if orderQty == Int(self.positionModel?.currentQty ?? "0")! {
                parameters["execInst"] = "Close"
            }
        case 1:
            parameters["ordType"] = "Market"
            parameters["execInst"] = "Close"
            parameters["orderQty"] = nil
        default:
            break
        }
        
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/v1/order", platform: .bitmex, parameters: parameters, method: .post, responseClass: COINOrderBookItemModel.self, isArray: false, successHandler: { (bookModel) in
            debugPrint(bookModel?.orderID as Any)
            if weakSelf?.refreshHandle != nil {
                weakSelf?.refreshHandle!()
            }
            weakSelf?.hideView()
        }) { (error) in
            debugPrint(error as Any)
        }
    }
    func submitOrders_okex(_ side: String, type: Int) {
        var orderQty: Int = 0
        if (self.sellCountTextField.text?.count)! > 0 {
            orderQty = Int(self.sellCountTextField.text!)!
        }
        var typeSide = "3"
        if side == "Buy" {//type 1:开多2:开空3:平多4:平空
            typeSide = "4"
        } else {
            typeSide = "3"
        }
        let leverage = self.positionModel!.leverage!
        var parameters = [
            "type" : typeSide,
            "instrument_id" : self.positionModel?.symbol! ?? String.self,
            "size" : orderQty,
            "leverage" : leverage,
            ] as [String : Any]
        switch type {
        case 0:
            let price = self.priceTextField.text
            parameters["price"] = price
            break
        case 1:
            parameters["orderQty"] = self.positionModel?.currentQty
            parameters["match_price"] = "1"
            break
        default:
            break
        }
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/futures/v3/order", platform: self.platform, parameters: parameters, method: .post, responseClass: COINOKEXOrderBookItemModel.self, isArray: false, successHandler: { (bookModel) in
            if weakSelf?.refreshHandle != nil {
                weakSelf?.refreshHandle!()
            }
            weakSelf?.hideView()
        }) { (error) in
            debugPrint(error as Any)
        }
    }
}
