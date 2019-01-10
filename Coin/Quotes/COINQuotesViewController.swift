//
//  COINQuotesViewController.swift
//  Coin
//
//  Created by gm on 2018/11/2.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh


class COINQuotesViewController: COINBaseTableViewController{
    
    lazy var tableHeaderView: COINQuotesTableHeaderView = {
        let tableHeaderView = COINQuotesTableHeaderView.init(frame: CGRect.zero)
        return tableHeaderView
    }()
    
   lazy var cardDetailS = Array<COINInstrumentItemModel>()
   
   ///列表数据
   lazy var symbolInfoModelArray: [COINInstrumentItemModel] = Array()
   lazy var symbolInfoModelArray_ok: [COINInstrumentItemModel] = Array()
   lazy var symbolInfoModelArray_bitMex: [COINInstrumentItemModel] = Array()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        self.tableView.rowHeight  = 60
        self.tableView.separatorColor = lineGrayColor
        addBitMex(subscribeTypeArray: [.instrument])
        addRefresh()
        addTableHeaderView()
        
        self.tableView.register(
            COINSymbolInfoCell.classForCoder(),
            forCellReuseIdentifier: "quotesViewControllerCellId"
        )
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.navImageUnderLine(),
            for: UIBarMetrics.default
        )
    }
    
    func addTableHeaderView(){
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
        
        let headerVeiw = self.tableHeaderView
        weak var weakSelf  = self
        headerVeiw.gainViewCallBack = ({ isBitMex in
            weakSelf?.requestNetWork(isBitMex)
        })
        
        headerVeiw.cardViewCallBack = ({ card in
            debugPrint("cardView click\(card.tag)")
            if card.symbolInfoModel != nil {
                let instrument = COINInstrumentItemModel.deserialize(from: card.symbolInfoModel!.toJSON())
                let vc = COINTradeBucketViewController.init(instrument: instrument, platform: card.symbolInfoModel!.platformType, needLoadData: true)
                vc.hidesBottomBarWhenPushed = true
                weakSelf?.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        self.tableView?.tableHeaderView = headerVeiw
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        requestNetWork(self.tableHeaderView.isBitMex)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.symbolInfoModelArray.count >= 10 ? 10 : self.symbolInfoModelArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  needIcon              = true
        if UIScreen.main.bounds.size.width <= 375 {
            needIcon               = false
        }
        
        let cell:COINSymbolInfoCell = COINSymbolInfoCell.selectionDetailCell(
            tableView: tableView,
            cellId: "quotesViewControllerCellId",
            needSerialNumberLabel: true,
            needIcon: needIcon,
            collect: false
        )
        
        cell.updateSerialNumberLabel(indexPath.row + 1)
        if indexPath.row < self.symbolInfoModelArray.count {
            let model  = self.symbolInfoModelArray[indexPath.row]
            model.needRootSymbol = true
            cell.model = model
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.symbolInfoModelArray.count > indexPath.row {
            let detail = self.symbolInfoModelArray[indexPath.row]
            let instrument = COINInstrumentItemModel.deserialize(from: detail.toJSON())
            let vc = COINTradeBucketViewController.init(instrument: instrument, platform: detail.platformType, needLoadData: true)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.layoutSubviews()
        let tableViewW = UIScreen.main.bounds.size.width
        let tableViewH = (self.navigationController?.tabBarController?.tabBar.frame.minY)!
        if #available(iOS 11.0, *) {
            self.tableView.frame = CGRect.init(x: 0.0, y: 0, width: tableViewW, height: tableViewH)
        }else{
            self.tableView.frame = CGRect.init(x: 0.0, y: -20, width: tableViewW, height: tableViewH + 20 + 44)
        }
    }
    
    // MARK: 刷新卡片数据
    func updateCardsInfo(){
        for (index,symbolInfoModel) in self.cardDetailS.enumerated() {
            let card = self.tableHeaderView.getCardView(index)
            card.symbolInfoModel = symbolInfoModel
        }
    }
    
    //MARK: 控制两个平台网络请求处
    func requestNetWork(_ isBitMex: Bool) {
        if isBitMex {
            getSelectionListFromNetWork_bitMex()
        } else {
            getSelectionListFromNetWork_okex()
        }
    }
}

// MARK: 打开webSocket 并且监听通知
extension COINQuotesViewController {
    
    @objc override func receiveInstrumentNoti(noti: Notification) {
        let tool = COINWebSocketInstrmentTool.parsingInstrmentModel(noti: noti, array: self.cardDetailS)
        if tool.0 {
            let card = self.tableHeaderView.getCardView(tool.1)
            card.symbolInfoModel = self.cardDetailS[tool.1]
        }
    }
}

//MARK: okex网络请求
extension COINQuotesViewController {
    
    func getSelectionListFromNetWork_okex() {
        self.symbolInfoModelArray = self.symbolInfoModelArray_ok
        self.tableView.reloadData()
        let requestPath = "/api/futures/v3/instruments/ticker"
        COINNetworkTool.request(path: requestPath, platform: .okex, parameters: nil, method: .get, responseClass: COINInstrumentModel_OK.self, isArray: true, successHandler: { (respond) in
            guard let itemArrayTemp: [COINInstrumentItemModel]  = respond?.toInstrumentModel(needRootSymbol: true) else {
                return
            }
            
            self.symbolInfoModelArray_ok = itemArrayTemp.sorted(by: { $0.lastPcnt! >= $1.lastPcnt!})
            self.stopRefresh()
            self.symbolInfoModelArray = self.symbolInfoModelArray_ok
            self.tableView.reloadData()
        }) { (error) in
            
        }
        
    }
}

//MARK: bitMex网络请求
extension COINQuotesViewController {
    
    func getSelectionListFromNetWork_bitMex() {
        self.symbolInfoModelArray = self.symbolInfoModelArray_bitMex
        self.tableView.reloadData()
        let requestPath = "/api/v1/instrument"
        let filter: [String: Any] = ["state":"Open"]
        let parameters: [String: Any] = ["filter":filter]
        COINNetworkTool.request(path: requestPath, platform: .bitmex, parameters: parameters, method: .get, responseClass: COINBitmexInstrumentModel.self, isArray: true, successHandler: { (response) in
            let tempArray = response?.toInstrumentModel().data
            //card只需要请求一次 后面通过websocket更新数据
            if self.cardDetailS.count < 1 {
                let btcDetail: COINInstrumentItemModel  = ((tempArray?.filter({($0.symbol == "XBTUSD" && $0.rootSymbol == "XBT")}).first)!)
                let ethDetail: COINInstrumentItemModel  = ((tempArray?.filter({($0.symbol == "ETHUSD" && $0.rootSymbol == "ETH")}).first)!)
                let bchDetail: COINInstrumentItemModel  = ((tempArray?.filter({($0.rootSymbol == "BCH")}).first)!)
                self.cardDetailS.append(btcDetail)
                self.cardDetailS.append(ethDetail)
                self.cardDetailS.append(bchDetail)
                self.startSubscribe_bitMex(symbol: btcDetail.symbol ?? "XBTUSD", subscribeType: .instrument, cancelState: .couldNot)
                self.startSubscribe_bitMex(symbol: ethDetail.symbol ?? "ETCUSD", subscribeType: .instrument, cancelState: .couldNot)
                self.startSubscribe_bitMex(symbol: bchDetail.symbol ?? "BTC", subscribeType: .instrument, cancelState: .couldNot)
                self.updateCardsInfo()
            }
            
            let usdAndXbtArray: [COINInstrumentItemModel] = tempArray?.filter({$0.quoteCurrency?.lowercased() == "xbt" || $0.quoteCurrency?.lowercased() == "usd"}) ?? [COINInstrumentItemModel]()
            
            self.symbolInfoModelArray_bitMex.removeAll()
            self.symbolInfoModelArray_bitMex.append(contentsOf: usdAndXbtArray)
            
            self.symbolInfoModelArray_bitMex = self.symbolInfoModelArray_bitMex.sorted(by: { $0.lastPcnt! >= $1.lastPcnt!})
            self.symbolInfoModelArray = self.symbolInfoModelArray_bitMex
            self.tableView.reloadData()
            self.stopRefresh()
        }) { (error) in
            self.stopRefresh()
        }
    
    }
}


// MARK: - 刷新界面
extension COINQuotesViewController {
    
    @objc override func startRefresh() {
        requestNetWork(self.tableHeaderView.isBitMex)
    }
}
