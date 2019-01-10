//
//  COINBindKeyView.swift
//  Coin
//
//  Created by dev6 on 2018/11/21.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit
import swiftScan
import Photos

struct COINBindKeyViewUX {
    static let HPadding: CGFloat = 30
    static let VPadding: CGFloat = 12
}

class COINBindKeyView: UIView, LBXScanViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var platform: Platform?
    var completeHandle: (()->())?
    var scanVC = LBXScanViewController()
    
    lazy var oneLabel: UILabel = {
        let oneLabel = UILabel.init(frame: CGRect.init(x: COINBindKeyViewUX.HPadding, y: 25, width: 18, height: 18))
        oneLabel.text = "1"
        oneLabel.backgroundColor = bgBlueColor
        oneLabel.font = font12
        oneLabel.textAlignment = .center
        oneLabel.textColor = whiteColor
        return oneLabel
    }()
    
    lazy var twoLabel: UILabel = {
        let twoLabel = UILabel.init(frame: CGRect.init(x: COINBindKeyViewUX.HPadding, y: 58, width: 18, height: 18))
        twoLabel.text = "2"
        twoLabel.backgroundColor = bgBlueColor
        twoLabel.font = font12
        twoLabel.textAlignment = .center
        twoLabel.textColor = whiteColor
        return twoLabel
    }()
    
    lazy var oneContentLabel: UILabel = {
        let oneContentLabel = UILabel.init(frame: CGRect.init(x: self.oneLabel.frame.maxX + 5, y: 25, width: 250, height: 18))
        oneContentLabel.text = "获取交易所API KEY"
        oneContentLabel.font = font14
        oneContentLabel.textColor = titleGrayColor
        return oneContentLabel
    }()
    
    lazy var twoContentLabel: UILabel = {
        let twoContentLabel = UILabel.init(frame: CGRect.init(x: self.twoLabel.frame.maxX + 5, y: 58, width: 260, height: 18))
        twoContentLabel.text = "在下方填写你的交易所账号API授权信息"
        twoContentLabel.font = font14
        twoContentLabel.textColor = titleGrayColor
        return twoContentLabel
    }()
    
    lazy var apiKeyTextField: COINBindTextField = {
        let apiKeyTextField = COINBindTextField.init(CGRect.init(x: COINBindKeyViewUX.HPadding, y: self.twoLabel.frame.maxY + 30, width: self.frame.size.width - COINBindKeyViewUX.HPadding * 2, height: 60), { (text) in
            
        })
        apiKeyTextField.placeholder = "请输入API KEY"
        return apiKeyTextField
    }()
    
    lazy var secretKeyTextField: COINBindTextField = {
        let secretKeyTextField = COINBindTextField.init(CGRect.init(x: COINBindKeyViewUX.HPadding, y: self.apiKeyTextField.frame.maxY + 18, width: self.frame.size.width - COINBindKeyViewUX.HPadding * 2, height: 60), { (text) in
            
        })
        secretKeyTextField.placeholder = "请输入SECRET KEY"
        return secretKeyTextField
    }()
    
    lazy var passphraseTextField: COINBindTextField = {
        let passphraseTextField = COINBindTextField.init(CGRect.init(x: COINBindKeyViewUX.HPadding, y: self.secretKeyTextField.frame.maxY + 18, width: self.frame.size.width - COINBindKeyViewUX.HPadding * 2, height: 60), { (text) in
            
        })
        passphraseTextField.placeholder = "请输入Passphrase"
        return passphraseTextField
    }()
    
    lazy var scanBtn: UIButton = {
        let scanBtn = UIButton.init(type: .custom)
        scanBtn.frame = CGRect.init(x: self.frame.size.width - COINBindKeyViewUX.HPadding - 110, y: 15, width: 110, height: 35)
        scanBtn.setTitle("扫描二维码", for: .normal)
        scanBtn.titleLabel?.font = font12
        scanBtn.setTitleColor(titleBlueColor, for: .normal)
        scanBtn.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        return scanBtn
    }()
    
    lazy var bindBtn: UIButton = {
        let bindBtn = UIButton.init(type: .custom)
        bindBtn.frame = CGRect.init(x: COINBindKeyViewUX.HPadding, y: 370, width: self.frame.size.width - COINBindKeyViewUX.HPadding * 2, height: 50)
        bindBtn.setTitle("绑定", for: .normal)
        bindBtn.titleLabel?.font = font14
        bindBtn.backgroundColor = bgBlueColor
        bindBtn.setTitleColor(whiteColor, for: .normal)
        bindBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: 50, height: 50))
        bindBtn.addTarget(self, action: #selector(bindAction), for: .touchUpInside)
        return bindBtn
    }()
    
    init(frame: CGRect, platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        self.backgroundColor = whiteColor
        self.addSubview(self.oneLabel)
        self.addSubview(self.twoLabel)
        self.addSubview(self.oneContentLabel)
        self.addSubview(self.twoContentLabel)
        self.addSubview(self.apiKeyTextField)
        self.addSubview(self.secretKeyTextField)
        if platform == .okex {
            self.addSubview(scanBtn)
            self.addSubview(self.passphraseTextField)
            self.scanBtn.frame = CGRect.init(x: self.scanBtn.frame.origin.x, y: self.passphraseTextField.frame.maxY + 15, width: self.scanBtn.frame.size.width, height: self.scanBtn.frame.size.height)
        }
        self.addSubview(bindBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func bindAction() {
        if self.apiKeyTextField.text == nil || self.apiKeyTextField.text?.count == 0  {
            return
        } else if self.secretKeyTextField.text == nil || self.secretKeyTextField.text?.count == 0 {
            return
        } else if self.platform == .okex && (self.secretKeyTextField.text == nil || self.secretKeyTextField.text?.count == 0) {
            return
        }
        weak var weakSelf = self
        COINKeyChainTool.shared().save(platform: self.platform!, apiKey: self.apiKeyTextField.text!, secretKey: self.secretKeyTextField.text!, passphrase: self.passphraseTextField.text)
        if self.platform == .bitmex {
            COINNetworkTool.requestOriginal(path: "/api/v1/user", platform: .bitmex, parameters: nil) { (response) in
                if response.result.isSuccess && response.result.value != nil {
                    let dict = response.result.value as? [String: Any]
                    if dict?["error"] != nil {
                        let error = dict!["error"] as! [String: String]
                        UIApplication.shared.keyWindow?.makeToast(error["message"], duration: 2, position: .center)
                        COINKeyChainTool.shared().delete(platform: .bitmex)
                    } else {
                        if weakSelf?.completeHandle != nil {
                            weakSelf?.completeHandle!()
                        }
                    }
                } else {
                    if response.error != nil {
                        let err: NSError = response.error! as NSError
                        UIApplication.shared.keyWindow?.makeToast(err.localizedDescription, duration: 2, position: .center)
                        COINKeyChainTool.shared().delete(platform: .bitmex)
                    }
                }
            }
        } else {
            COINNetworkTool.requestOriginal(path: "/api/account/v3/wallet", platform: .okex, parameters: nil) { (response) in
                if response.result.isSuccess && response.result.value != nil {
                    let dict = response.result.value as? [String: Any]
                    if dict?["message"] != nil {
                        let error = dict!["message"] as! String
                        UIApplication.shared.keyWindow?.makeToast(error, duration: 2, position: .center)
                        COINKeyChainTool.shared().delete(platform: .okex)
                    } else {
                        if weakSelf?.completeHandle != nil {
                            weakSelf?.completeHandle!()
                        }
                    }
                } else {
                    if response.error != nil {
                        let err: NSError = response.error! as NSError
                        UIApplication.shared.keyWindow?.makeToast(err.localizedDescription, duration: 2, position: .center)
                        COINKeyChainTool.shared().delete(platform: .okex)
                    }
                }
            }
        }
    }
    
    @objc func scanAction() {
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        style.animationImage = UIImage(named: "qrcode_Scan_weixin_Line")
        
        scanVC.navigationController?.isNavigationBarHidden = false
        scanVC.title = "扫描二维码"
        scanVC.hidesBottomBarWhenPushed = true
        scanVC.scanStyle = style
        scanVC.scanResultDelegate = self
        scanVC.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "相册", style: .plain, target: self, action: #selector(openPhotoAlbum))
        self.viewController()?.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    @objc func openPhotoAlbum() {
        self.authorizePhotoWith { (guard) in
            let picker = UIImagePickerController()
            
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            picker.delegate = self
            
            picker.allowsEditing = true
            
            self.viewController()?.present(picker, animated: true, completion: nil)
        }
    }
    
    func authorizePhotoWith(comletion:@escaping (Bool) -> Void) {
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case PHAuthorizationStatus.authorized:
            comletion(true)
        case PHAuthorizationStatus.denied, PHAuthorizationStatus.restricted:
            comletion(false)
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    comletion(status == PHAuthorizationStatus.authorized ? true:false)
                }
            })
        }
    }
    
    // MARK: - ----相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image: UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if (image == nil ) {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        if(image != nil) {
            let arrayResult = LBXScanWrapper.recognizeQRImage(image: image!)
            if arrayResult.count > 0 {
                scanVC.handleCodeResult(arrayResult: arrayResult)
                return
            }
        }
        
    }
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        print("scanResult:\(scanResult.strScanned)")
        if scanResult.strScanned?.contains("apiKey") ?? false && scanResult.strScanned?.contains("secretKey") ?? false {
            let dict: [String: String]? = scanResult.strScanned?.jsonStringToDict() as? [String : String]
            if dict != nil {
                self.apiKeyTextField.text = dict!["apiKey"]
                self.secretKeyTextField.text = dict!["secretKey"]
            }
        }
    }
}
