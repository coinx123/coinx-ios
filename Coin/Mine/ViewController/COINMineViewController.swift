//
//  COINMineViewController.swift
//  Coin
//
//  Created by dev6 on 2018/11/21.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit
import Social

class COINSettingItemModel: NSObject {
    
    var title: String
    var imageName: String
    var className: UIViewController?
    var cellStyle: [COINSettingTableViewCellStyle] = [.titleLabel,.iconView,.accessoryView]
    init(_ title: String,_ imageName: String) {
        self.title = title
        self.imageName = imageName
        super.init()
    }
    
    
}


private struct MineViewControllerStruct{
    
    static let CellId = "MineViewControllerCellId"
    
}

class COINMineViewController: UITableViewController {
    
    var marginModel: COINMarginModel? {
        
        didSet{
            let cardView: COINSetCardView = self.cardsScrollView.viewWithTag(1) as! COINSetCardView
            cardView.valueStr = marginModel?.walletBalance?.fourDecimalPlacesWithUnits() ?? ""
        }
    }
    
    lazy var  dispatchQueue = DispatchQueue.init(label: "MineViewControllerQueue")
    
    lazy var navImage = UIImage.init(named: "nav_wihte")
    
    var btc_usd: Float = -1
    
    var eth_btc: Float = -1
    
    var infoDict: [String: Any]?
    
    lazy var cardsScrollView: COINBaseScrollView = {
        let viewW: CGFloat = UIScreen.main.bounds.size.width
        let viewH: CGFloat = 165
        let cardsScrollView = COINBaseScrollView.init(frame: CGRect.init(x: 0, y: 0, width: viewW, height: viewH))
        let scrollView      = cardsScrollView.scrollView
        scrollView.frame    = cardsScrollView.bounds
        let coinNames = COINSettingCardViewModel.getCardViewModelArray()
        let cardHSpeingSupper: CGFloat  = 15
        let cardHSpeingCardView:CGFloat = 8
        let cardW: CGFloat = viewW - cardHSpeingCardView - cardHSpeingSupper * 2
        let cardY: CGFloat = 20
        let cardH: CGFloat = viewH - cardY * 2
        var lastCardView: COINSetCardView?
        for index in 0...(coinNames.count - 1) {
            let cardX = cardHSpeingSupper + (cardW + 7) * CGFloat(index)
            let cardView: COINSetCardView = COINSetCardView.init(frame: CGRect.init(
                x: cardX,
                y: 10,
                width: cardW,
                height: cardH),isFirstCardView: true, model: coinNames[index]
            )
            
            cardView.tag = index + 1
            cardViewSetBind(cardView: cardView)
            cardsScrollView.scrollViewAddSubView(scrollSubView: cardView)
            weak var weakSelf = self
            cardView.callBack = { (isJump,card) in
                if isJump {
                   let vc = COINCoinDetailTableViewController()
                    vc.model = coinNames[index]
                    vc.marginModel = card.cardViewModel
                    vc.hidesBottomBarWhenPushed = true
                    weakSelf?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let platform: Platform = index == 0 ? .bitmex : .okex
                    let vc = COINBindKeyViewController.init(platform: platform)
                    weakSelf?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            lastCardView = cardView
        }
        
        let contentSizeW = (lastCardView?.frame.maxX)! + cardHSpeingSupper + 3.5
        scrollView.contentSize = CGSize.init(width: contentSizeW, height: viewH)
        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        cardsScrollView.needPageView = true
        return cardsScrollView
    }()
    
    lazy var settingItemArray = self.getSettingItemModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 50
        self.tableView.tableFooterView = UIView()
        self.view.backgroundColor = bgColor
        self.tableView.separatorColor = lineGrayColor
        self.tableView.register(COINSettingTableViewCell.classForCoder(), forCellReuseIdentifier: MineViewControllerStruct.CellId)
        initTableHeaderView()
        
    }
    
    func initTableHeaderView(){
        let width = self.view.frame.size.width
        let headerView = UIView()
        headerView.addSubview(self.cardsScrollView)
        
        let lineView = UIView.init(frame: CGRect.init(
            x: 0,
            y: self.cardsScrollView.frame.maxY,
            width: width,
            height: 20))
        
        lineView.backgroundColor = lineGrayColor
        headerView.addSubview(lineView)
        headerView.frame = CGRect.init(
            x: 0,
            y: 0,
            width: width,
            height: lineView.frame.maxY)
        
        self.tableView.tableHeaderView = headerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(
            self.navImage,
            for: UIBarMetrics.default
        )

        self.navigationController!.navigationBar.shadowImage = UIImage()
        startRequestNetWork()
        for index in 1...2{
            let cardView = cardViewFromScrollView(index)
            cardViewSetBind(cardView: cardView)
        }
    }
    
    func cardViewSetBind(cardView: COINSetCardView){
        if cardView.tag == 1 {
            cardView.isBinding = COINKeyChainTool.shared().hasBind(platform: .bitmex)
        }else{
            cardView.isBinding = COINKeyChainTool.shared().hasBind(platform: .okex)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingItemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemModel = self.settingItemArray[indexPath.row]
        
        let cell: COINSettingTableViewCell = COINSettingTableViewCell.init(style: .default, reuseIdentifier: MineViewControllerStruct.CellId, cellStyle:itemModel.cellStyle)
        cell.titleLabel.text = itemModel.title
        cell.iconImageView.image = UIImage.init(named: itemModel.imageName)
        if indexPath.row == self.settingItemArray.count - 1 {
            cell.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let itemModel  = self.settingItemArray[indexPath.row]
        
        if (itemModel.className != nil) {//vc
            itemModel.className!.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(itemModel.className!, animated: true)
        }else{//非vc
            if itemModel.title == "分享此应用" {
                let vc = COINShareViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if itemModel.title == "关于我们" {
                let vc = COINAboutUSViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
       
    }
}


//MARK: 网络请余额数据bitMex
extension COINMineViewController {
    
    func startRequestNetWork(){
        
        weak var weakSelf = self
        self.dispatchQueue.async {
            weakSelf?.requestMargin_bitMex()
        }
        self.dispatchQueue.async {
            weakSelf?.requestMargin_okex()
        }
        self.dispatchQueue.async {
            weakSelf?.requesTheExchangeRate_ok()
        }
        self.dispatchQueue.async {
            weakSelf?.requesTheExchangeRateUSD_ok()
        }
    }
    
    func requestMargin_bitMex(){
        weak var weakSelf = self
        COINNetworkTool.request(path: "/api/v1/user/margin", platform: .bitmex, parameters: ["currency" : "XBt"], method: .get, responseClass: COINMarginModel.self, isArray: false, successHandler: { (marginModel) in
            let cardView = weakSelf?.cardViewFromScrollView(1)
            cardView?.cardViewModel = marginModel?.conversionSetCardViewModel()
        }) { (error) in
            debugPrint(error as Any)
        }
    }
    
    func requesTheExchangeRate_ok(){
        
        COINNetworkTool.requestOriginal(path: "/api/spot/v3/instruments/ETH-BTC/ticker", platform: .okex, parameters: nil) { (respond) in
            guard let dict: Dictionary<String, Any>  = respond.result.value as? Dictionary<String, Any> else{
                return
            }
        
            let exchangeRate: Float = Float(dict["last"] as? String ?? "0.0") ?? 0.0
            self.eth_btc = exchangeRate
            self.updateOkCardViewData()
        }
        
    }
    
    func requesTheExchangeRateUSD_ok(){
        COINNetworkTool.requestOriginal(path: "/api/spot/v3/instruments/BTC-USDT/ticker", platform: .okex, parameters: nil) { (respond) in
            guard let dict: Dictionary<String, Any>  = respond.result.value as? Dictionary<String, Any> else{
                return
            }
            
            let exchangeRate: Float = Float(dict["last"] as? String ?? "0.0") ?? 0.0
            self.btc_usd = exchangeRate
            self.updateOkCardViewData()
        }
    }
    
    func requestMargin_okex(){
        COINNetworkTool.requestOriginal(path: "/api/futures/v3/accounts", platform: .okex, parameters: nil) { (respond) in
            let respondDict: Dictionary<String, Any> = respond.result.value as? Dictionary<String, Any> ?? Dictionary()
            if respondDict.keys.contains("info"){
                let infoDict: Dictionary<String, Any> = respondDict["info"] as! Dictionary<String, Any>
                self.infoDict = infoDict
                self.updateOkCardViewData()
            }
        }
        
    }
    
    func updateOkCardViewData(){
        objc_sync_enter(self)
        if btc_usd < 0 || eth_btc < 0 || infoDict == nil {
            return
        }
        objc_sync_exit(self)
        let rootSymbolArray = ["btc","eth"]
        let okexcardViewModel     = COINSetCardViewModel()
        okexcardViewModel.accountModelArray.removeAll()
        for rootSymbol in rootSymbolArray {
            guard let itemDict: Dictionary<String, Any>  = infoDict?[rootSymbol] as? Dictionary<String, Any> else {
                return
            }
            
            let accountSymbol = COINAccountsItemModel_ok.deserialize(from: itemDict)
            accountSymbol?.eth_btc  = eth_btc
            accountSymbol?.btc_usdt = btc_usd
            okexcardViewModel.accountModelArray.append(accountSymbol ?? COINAccountsItemModel_ok())
            var equity    = accountSymbol?.equity ?? 0.0
            if rootSymbol == "eth" {
                equity = equity * eth_btc
            }
            okexcardViewModel.walletBalance += equity
            okexcardViewModel.maintMargin += equity
        }
        okexcardViewModel.legalCurrency = okexcardViewModel.walletBalance * btc_usd
        okexcardViewModel.legalCurrency *= 100000000
        okexcardViewModel.walletBalance *= 100000000
        okexcardViewModel.maintMargin   *= 100000000
        okexcardViewModel.platformType  = .okex
        let cardView = self.cardViewFromScrollView(2)
        cardView.cardViewModel = okexcardViewModel
    }
    
    func cardViewFromScrollView(_ tag: Int) -> COINSetCardView{
        let cardView: COINSetCardView = self.cardsScrollView.scrollView.viewWithTag(tag) as! COINSetCardView
        return cardView
    }
    
}

//MRAK: 设置icon title数据源
extension COINMineViewController {
    
    func getSettingItemModel() -> Array<COINSettingItemModel>{
        
       // let item1 = COINSettingItemModel.init("安全设置", "mine_ protect")
        
        let item2 = COINSettingItemModel.init("关于我们", "mine_aboutus")
        
//        let item3 = COINSettingItemModel.init("分享此应用", "mine_share")
        
        let item4 = COINSettingItemModel.init("设置", "mine_setting")
        item4.className = COINSettingTableViewController()

        return [item2,item4]
    }
}
