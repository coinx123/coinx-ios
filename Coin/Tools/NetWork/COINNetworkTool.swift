//
//  COINNetworkTool.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/2.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON
import Toast_Swift

/// 请求平台类型
///
/// - bitmex: Bitmex 线上 https://www.bitmex.com 测试 https://testnet.bitmex.com
/// - okex: OKEX 线上 https://www.okex.com/
public enum Platform: String {
    case bitmex = "BitMEX"
    case okex   = "OKEX"
    case other  = "other"
}

class COINNetworkTool: NSObject {
    static let instance: COINNetworkTool = COINNetworkTool()
    var repeatCount = 0
    public class func shared() -> COINNetworkTool {
        return instance
    }
    lazy var sessionManager: SessionManager = {
        return self.createSessionManager()
    }()
    
    func createSessionManager() -> SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let sessionManager = SessionManager(configuration: configuration)
        sessionManager.delegate.sessionDidReceiveChallenge = {
            session,challenge in
            return  (URLSession.AuthChallengeDisposition.useCredential,
                       URLCredential(trust:challenge.protectionSpace.serverTrust!))
        }
        return sessionManager
    }
    
    var network: NetworkReachabilityManager?
    /// 网络请求，返回数据不处理
    ///
    /// - Parameters:
    ///   - path: 请求路径
    ///   - platform: 请求t平台
    ///   - parameters: 请求参数
    ///   - method: 请求方法。默认get
    ///   - completeHandler: 请求返回回调
    public class func requestOriginal(path: String, platform: Platform, parameters: [String: Any]?, method: HTTPMethod = .get, needPlatformKey :Bool = true, completeHandler: ((DataResponse<Any>)->())?) {
        let requestData = self.getHeader(path: path, platform: platform, parameters: parameters, method: method, needPlatformKey: needPlatformKey)
        if requestData.header == nil || requestData.requestPath == nil {
            return
        }
        COINNetworkTool.shared().sessionManager.request(URL.init(string: requestData.requestPath!)!, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: requestData.header!).responseJSON { (response) in
            let result = self.dealResponse(response: response)
            if result.1 {
                COINNetworkTool.shared().repeatCount += 1
                if COINNetworkTool.shared().repeatCount < 5 { //最多5个，超过先不处理
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        COINNetworkTool.requestOriginal(path: path, platform: platform, parameters: parameters, method: method, completeHandler: completeHandler)
                    }
                    return
                }
            }
            if completeHandler != nil {
                completeHandler!(response)
            }
        }
    }
    
    /// 网络请求，返回数据统一处理
    ///
    /// - Parameters:
    ///   - path: 请求路径
    ///   - platform: 请求平台
    ///   - parameters: 请求参数
    ///   - method: 请求方法。默认get
    ///   - responseClass: 请求返回数据的模型
    ///   - isArray: 返回的数据是不是数组，默认true，模型必须是["data",[Any]]类型，any为数组中的数据模型
    ///   - successHandler: 请求成功回调
    ///   - failureHandler: 请求失败回调
    public class func request<T: HandyJSON>(path: String, platform: Platform, parameters: [String: Any]?, method: HTTPMethod = .get ,responseClass: T.Type, isArray: Bool = true, needPlatformKey :Bool = true, successHandler: ((T?)->())?, failureHandler: ((Any)->())? = nil) {
        let requestData = self.getHeader(path: path, platform: platform, parameters: parameters, method: method, needPlatformKey: needPlatformKey)
        if requestData.header == nil || requestData.requestPath == nil {
            if failureHandler != nil {
                failureHandler!("unbind")
            }
            return
        }
        
        COINNetworkTool.shared().sessionManager.request(URL.init(string: requestData.requestPath!)!, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: requestData.header!).responseJSON { (response) in
            let result = self.dealResponse(response: response)
            if result.0 {
                if successHandler != nil {
                    var model: T?
                    if isArray == true {
                        model = responseClass.deserialize(from: ["data":response.result.value!])
                    } else {
                        model = responseClass.deserialize(from: (response.result.value! as! Dictionary))
                    }
                    successHandler!(model)
                }
            } else {
                if failureHandler != nil {
                    failureHandler!(response.result.value as Any)
                }
                if result.1 {
                    COINNetworkTool.shared().repeatCount += 1
                    if COINNetworkTool.shared().repeatCount < 5 { //最多5个，超过先不处理
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            COINNetworkTool.request(path: path, platform: platform, parameters: parameters, method: method, responseClass: responseClass, isArray: isArray, successHandler: successHandler, failureHandler: failureHandler)
                        }
                    }
                }
            }
        }
    }
    
    /// 获取请求头
    ///
    /// - Parameters:
    ///   - path: 请求路径
    ///   - platform: 请求平台
    ///   - parameters: 请求参数
    ///   - method: 请求方法
    /// - Returns: 返回请求头和请求链接的元组
    class func getHeader(path: String, platform: Platform, parameters: [String: Any]?, method: HTTPMethod, needPlatformKey :Bool) -> (header: [String: String]?,requestPath: String?) {
        var requestPath: String = ""
        var sign: String = ""
        var header = [String: String]()
        switch platform {
        case .bitmex:
            if COINKeyChainTool.instance.keychain[PlistKey.BitMEXSecretKey] == nil || COINKeyChainTool.instance.keychain[PlistKey.BitMEXAPIKey] == nil {
                self.showAlert(platform: platform)
                return (nil,nil)
            }
            let secretKey: String = COINKeyChainTool.instance.keychain[PlistKey.BitMEXSecretKey] ?? ""
            let apiKey: String  = COINKeyChainTool.instance.keychain[PlistKey.BitMEXAPIKey] ?? ""
            requestPath = COINIPSwitchingTool.getRequestApi(platform: .bitmex) + path
            let timeChange = COINUserDefaultsHelper.getIntValue(forKey: UserDefaultsHelperKey.okexTimeKey, platformType: .okex) //bitmex没有获取服务器时间的接口，先用okex的
            let time = String(format: "%.0f", Date.init().timeIntervalSince1970 + Double(timeChange) + 5)
            sign = method.rawValue + path + time + self.tojsonString(dict: parameters)
            sign = NSString.hmacBitMEX(sign, withKey: secretKey)
            header["api-expires"] = time
            header["api-key"] = apiKey
            header["api-signature"] = sign
            header["Host"] = "www.bitmex.com"
        case .okex:
            if needPlatformKey && (COINKeyChainTool.instance.keychain[PlistKey.OKEXAPIKey] == nil || COINKeyChainTool.instance.keychain[PlistKey.OKEXSecretKey] == nil || COINKeyChainTool.instance.keychain[PlistKey.OKEXPassphrase] == nil) {
                self.showAlert(platform: platform)
                return (nil,nil)
            }
            let secretKey: String = COINKeyChainTool.instance.keychain[PlistKey.OKEXSecretKey] ?? ""
            let apiKey: String = COINKeyChainTool.instance.keychain[PlistKey.OKEXAPIKey] ?? ""
            let passWord: String = COINKeyChainTool.instance.keychain[PlistKey.OKEXPassphrase] ?? ""
            requestPath = "https://" + COINIPSwitchingTool.getRequestApi(platform: .okex) + path
            let dateFormat = DateFormatter.init()
            dateFormat.timeZone = TimeZone.init(identifier: "Europe/London")//要0时区，即伦敦时区
            dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let timeChange = COINUserDefaultsHelper.getIntValue(forKey: UserDefaultsHelperKey.okexTimeKey, platformType: .okex)
            let date = Date.init(timeIntervalSince1970: Date().timeIntervalSince1970 + Double(timeChange))
            let time = dateFormat.string(from: date)
            sign = time + method.rawValue + path + self.tojsonString(dict: parameters)
            sign = NSString.hmacOKEX(sign, withKey: secretKey)
            header["Host"] = "www.okex.com"
            header["OK-ACCESS-TIMESTAMP"] = time
            header["OK-ACCESS-PASSPHRASE"] = passWord
            header["OK-ACCESS-KEY"] = apiKey
            header["OK-ACCESS-SIGN"] = sign
        case .other:
            requestPath = path
            break
        }
        return (header,requestPath)
    }
    
    /// 处理请求结果，提示错误信息
    ///
    /// - Parameter response: 请求结果
    /// - Returns: (返回请求成功与否,失败的q请求是否自动再请求)
    class func dealResponse(response: DataResponse<Any>) -> (Bool,Bool) {
        if response.result.isSuccess && response.result.value != nil {
            let dict = response.result.value as? [String: Any]
            if dict?["error"] != nil { //bitmex
                let error = dict!["error"] as! [String: String]
                let errorMessage = error["message"]
                if errorMessage != nil {
                    if errorMessage!.contains("Signature") || errorMessage!.contains("API Key") {
                        UIApplication.shared.keyWindow?.makeToast("绑定的账号APIKEY相关信息可能有误，请确认后到”我的“重新绑定。", duration: 3, position: .center)
                    } else if errorMessage!.contains("Account has insufficient Available Balance") {
                        UIApplication.shared.keyWindow?.makeToast("账户余额不足", duration: 3, position: .center)
                    } else if errorMessage!.contains("Access Denied") {
                        UIApplication.shared.keyWindow?.makeToast("授权APIKEY被拒绝访问，请重新绑定正确的APIKEY", duration: 3, position: .center)
                    } else if errorMessage!.contains("This request has expired") {
                        debugPrint(errorMessage!)
                        return (false,true)
                    } else {
                        UIApplication.shared.keyWindow?.makeToast(errorMessage, duration: 3, position: .center)
                    }
                }
                return (false,false)
            } else if dict?["message"] != nil { //okex
                let error = dict!["message"] as! String
                if !error.contains("Too Many Requests") {
                    if error.contains("OK-ACCESS-KEY") || error.contains("OK_ACCESS_KEY") || error.contains("OK-ACCESS-PASSPHRASE") || error.contains("OK_ACCESS_PASSPHRASE") || error.contains("Sign") {
                        UIApplication.shared.keyWindow?.makeToast("绑定的账号APIKEY相关信息可能有误，请确认后到”我的“重新绑定。", duration: 3, position: .center)
                    } else if error.contains("Risk rate lower than 100%") {
                        UIApplication.shared.keyWindow?.makeToast("账户余额不足", duration: 3, position: .center)
                    } else if error.contains("The request timed out") {
                        return (false,true)
                    } else if error.contains("Invalid Authority") {
                        UIApplication.shared.keyWindow?.makeToast("APIKEY信息错误，请检查后重新绑定新的APIKEY", duration: 3, position: .center)
                    } else {
                        UIApplication.shared.keyWindow?.makeToast(error, duration: 3, position: .center)
                    }
                }
                return (false,false)
            } else {
                COINNetworkTool.shared().repeatCount = 0
                return (true,false)
            }
        } else {
            if response.error != nil {
                let err: NSError = response.error! as NSError
                if !(err.code == 310 || err.code == -999) {//httpsproxy校验问题或请求被取消,可能是端口变化问题，重新设置proxy
                    if response.response?.statusCode == 403 {
                        UIApplication.shared.keyWindow?.makeToast("被拒绝访问，请尝试修改IP或更换网络代理", duration: 3, position: .center)
                    } else {
                        UIApplication.shared.keyWindow?.makeToast(err.localizedDescription, duration: 3, position: .center)
                    }
                } else {
                    debugPrint(err)
                    return (false,true)
                }
            }
            return (false,false)
        }
    }
    
    /// 字典转成json字符串
    ///
    /// - Parameter dict: 要转换的字典
    /// - Returns: json字符串
    class func tojsonString(dict: [String: Any]?) -> String {
        if dict == nil {
            return ""
        }
        let data = try? JSONSerialization.data(withJSONObject: dict!, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        return str!
    }
    
    /// 提示未绑定交易所
    ///
    /// - Parameter platform: 平台
    class func showAlert(platform: Platform) {
        DispatchQueue.main.async {
            var platformStr = "BitMEX"
            if platform == .okex {
                platformStr = "OKEX"
            }
            let alert = UIAlertController.init(title: nil, message: "您还没有绑定\(platformStr)交易所，请先去绑定交易所", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "取消", style: .default, handler: { (cancel) in
                
            }))
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (cancel) in
                let vc = COINBindKeyViewController.init(platform: platform)
                vc.navigationController?.isNavigationBarHidden = false
                vc.hidesBottomBarWhenPushed = true
                let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                if delegate.window?.rootViewController?.isKind(of: UITabBarController.self) ?? false {
                    let tabbar: UITabBarController = delegate.window?.rootViewController as! UITabBarController
                    let nav = tabbar.selectedViewController as! UINavigationController
                    nav.pushViewController(vc, animated: true)
                }
            }))
            let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if delegate.window?.rootViewController?.isKind(of: UITabBarController.self) ?? false {
                let tabbar: UITabBarController = delegate.window?.rootViewController as! UITabBarController
                tabbar.viewControllers?.first?.present(alert, animated: true, completion: nil)
            } else {
                delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    class func startNetworkReachability() {
        COINNetworkTool.shared().network = NetworkReachabilityManager.init()
        COINNetworkTool.shared().network?.listener = { status in
            switch status {
            case .unknown:
                self.showNoNetworkView()
            case .notReachable:
                self.showNoNetworkView()
            case .reachable(.ethernetOrWiFi):
                self.hideNoNetworkView()
            case .reachable(.wwan):
                self.hideNoNetworkView()
            }
        }
        COINNetworkTool.shared().network?.startListening()
    }
    
    class func showNoNetworkView() {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let nav = UINavigationController.init(rootViewController: delegate.noNetworkView)
        if delegate.window?.rootViewController?.isKind(of: UITabBarController.self) ?? false {
            let tabbar: UITabBarController = delegate.window?.rootViewController as! UITabBarController
            tabbar.viewControllers?.first?.present(nav, animated: true, completion: nil)
        } else {
            delegate.window?.rootViewController?.present(nav, animated: true, completion: nil)
        }
    }
    
    class func hideNoNetworkView() {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.noNetworkView.dismiss(animated: true, completion: nil)
    }
}


class COINTimeModelOKEX: COINBaseModel {
    var iso: String? //    ISO8601标准的时间格式"2015-01-07T23:47:25.201Z"
    var epoch: Double? //    UTC时区Unix时间戳的十进制秒数格式 1420674445.201
}
