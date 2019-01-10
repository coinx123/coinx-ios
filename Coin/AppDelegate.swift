//
//  AppDelegate.swift
//  Coin
//
//  Created by gm on 2018/11/2.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
import Bugly


struct BuglyInfo {
    static let appID: String = "26bc87f463"
    static let appKey: String = "c2881838-cc65-4958-a2c4-d730f3a36735"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var allowRotate: Int = 0
    
    lazy var noNetworkView: COINNoNetworkViewController = {
        let noNetworkView = COINNoNetworkViewController()
        return noNetworkView
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.syncTimeOKEX()
        self.startBugly()
        self.initWindow()
        self.applicationApperance()
        self.defaultData()
        COINNetworkTool.startNetworkReachability()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowRotate == 1 {
            return .landscapeLeft
        } else {
            return .portrait
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.syncTimeOKEX()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.getAppInfoData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func initWindow(){
        let window  = UIWindow.init(frame: UIScreen.main.bounds)
        self.window = window;
        let tabBarVC = COINTabBarController()
        self.window?.rootViewController = tabBarVC;
        window.makeKeyAndVisible()
    }
    
    func applicationApperance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: fontBold10,NSAttributedString.Key.foregroundColor:titleGrayColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: fontBold10,NSAttributedString.Key.foregroundColor:titleBlueColor], for: .selected)
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset.init(horizontal: 0, vertical: -5)
        
//        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font16], for: .normal) // 设置返回按钮及文字颜色
        UINavigationBar.appearance().tintColor = titleBlackColor  //修改默认返回颜色
        
        // Push返回按钮名称的位置-60为隐藏
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: -200, vertical: 0),for: .default)
        //修改默认返回按钮
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "back")
    }
    
    /// 同步OKEX服务器时间，以免本地时间被修改
    func syncTimeOKEX() {
        COINNetworkTool.request(path: "/api/general/v3/time", platform: .okex, parameters: nil, responseClass: COINTimeModelOKEX.self, isArray: false, needPlatformKey: false, successHandler: { (response) in
            if response != nil && response?.epoch != nil {
                let timeChange = Int(String(format: "%.0f", response!.epoch! - Double(Date().timeIntervalSince1970)))
                COINUserDefaultsHelper.saveIntValue(value: timeChange ?? 0, forKey: UserDefaultsHelperKey.okexTimeKey, platformType: .okex)
            }
        })
    }

    func defaultData() {
         //第一次默认
        if COINUserDefaultsHelper.getObj(userdfalutKay: "HasDefault") == nil {
            COINUserDefaultsHelper.saveObj(obj: "1", userdfalutKay: "HasDefault")
            COINUserDefaultsHelper.saveBoolValue(value: true, forKey: UserDefaultsHelperKey.tradeSureKey)//默认需要交易确认提示
        }
    }
    
    func getAppInfoData() {
        COINNetworkTool.request(path: "https://www.coinx123.com/static/app/coinx-latest.json", platform: .other, parameters: nil, responseClass: COINAPPInfoModel.self, isArray: false, successHandler: { (response) in
            if response?.ios != nil {
                let localVersion = "v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
                if localVersion != response!.ios!.version?.lowercased() {
                    let alert = UIAlertController.init(title: nil, message: response?.ios?.description, preferredStyle: .alert)
                    if !(response!.ios?.force ?? false) {
                        alert.addAction(UIAlertAction.init(title: "取消", style: .default, handler: nil))
                    }
                    alert.addAction(UIAlertAction.init(title: "更新", style: .default, handler: { (cancel) in
                        if let url = URL.init(string: "itms-services://?action=download-manifest&url=" + (response!.ios?.source_url ?? "")) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.openURL(url)
                            }
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
        })
    }
    
    func startBugly() {
        Bugly.start(withAppId: BuglyInfo.appID)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let port: Int = change?[NSKeyValueChangeKey.newKey] as! Int
        let oldPort: Int = COINUserDefaultsHelper.getIntValue(forKey: UserDefaultsHelperKey.localPortKey)
        BitMexWebSocketFactory().connectAgain(true)
        OKEXWebSocketFactory().connectAgain(true)
        if port != oldPort {
            COINUserDefaultsHelper.saveIntValue(value: port, forKey: UserDefaultsHelperKey.localPortKey)
            COINNetworkTool.shared().sessionManager = COINNetworkTool.shared().createSessionManager()
        }
    }
}

