//
//  COINCoinDetailTableViewController.swift
//  Coin
//
//  Created by gm on 2018/11/27.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
import MJRefresh

private struct CoinDetailTableViewControllerStruct {
    
    static let width              = UIScreen.main.bounds.size.width
    static let hSpacing: CGFloat  = 15
    static let cellID             = "COINCoinDetailTableViewControllerCellId"
    static let rowH: CGFloat      = 124
    static let symbolArray = ["xbt","eth","ada","bch","eos","ltc","trx","xpr"]
}

class COINCoinDetailTableViewController: UITableViewController {
    
    lazy var rootSymbolArray = ["xbt","btc","eth","ada","bch","eos","ltc","trx"]
    
    var emptyView: COINEmptyView?
    
    lazy var settingInfoModel = Array<Array<COINSettingInfoModel>>()
    lazy var lock = NSLock()
    var marginModel: COINSetCardViewModel?{
        didSet{
            self.cardView.cardViewModel = marginModel
            addRefresh()
            startNetWork()
        }
    }
    
    var model: COINSettingCardViewModel? {
       
        didSet{
            let titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 24))
            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
            imageView.contentMode = .center
            imageView.image = UIImage.init(named: model?.secondIconName ?? "mine_bitmex")
            titleView.addSubview(imageView)
            
            let titleLabel = UILabel.init(frame: CGRect.init(x: 30, y: 0, width: 80, height: 24))
            titleLabel.text = model?.coinName
            titleView.addSubview(titleLabel)
            self.navigationItem.titleView = titleView
            
            let rightItem = UIBarButtonItem.init(title: "解绑", style: .plain, target: self, action: #selector(unbindAction))
            self.navigationItem.rightBarButtonItem = rightItem
            addHeaderView()
        }
    }
    
    lazy var cardView: COINSetCardView = {
        let width = CoinDetailTableViewControllerStruct.width - CoinDetailTableViewControllerStruct.hSpacing * 2
        let cardView = COINSetCardView.init(frame: CGRect.init(
            x: CoinDetailTableViewControllerStruct.hSpacing,
            y: 30,
            width: width,
            height: 125), isFirstCardView: false, model: self.model!)
        return cardView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(COINSettingInfoTableViewCell.classForCoder(), forCellReuseIdentifier: CoinDetailTableViewControllerStruct.cellID)
        self.tableView.rowHeight = CoinDetailTableViewControllerStruct.rowH
    }

    func addHeaderView(){
        
        let headerView = UIView()
        let width = CoinDetailTableViewControllerStruct.width
        let hSpacing = CoinDetailTableViewControllerStruct.hSpacing
        headerView.addSubview(self.cardView)
        
        let lineView = UIView.init(frame: CGRect.init(x: 0, y: self.cardView.frame.maxY + hSpacing, width: width, height: 10))
        lineView.backgroundColor = lineGrayColor
        headerView.addSubview(lineView)
        
        let bpuntyY = lineView.frame.maxY + 10
        let bountyImageView = UIImageView.init(frame: CGRect.init(x: hSpacing, y: bpuntyY, width: 20, height: 20))
        bountyImageView.contentMode = .left
        bountyImageView.image = UIImage.init(named: "mine_ bounty")
        headerView.addSubview(bountyImageView)
        
        
        let titleLabel = UILabel.init(frame: CGRect.init(x: bountyImageView.frame.maxX, y: bpuntyY, width: 100, height: 20))
        titleLabel.font = font15
        titleLabel.text = "持有资产"
        headerView.addSubview(titleLabel)
    
        let lineEndView = UIView.init(frame: CGRect.init(x: 0, y: titleLabel.frame.maxY + 10, width: width, height: 0.5))
        lineEndView.backgroundColor = lineGrayColor_deep
        headerView.addSubview(lineEndView)
        
        headerView.frame = CGRect.init(
            x: 0,
            y: 0,
            width: width,
            height: lineEndView.frame.maxY
        )
        let emptyViewH     = self.view.frame.size.height - headerView.frame.maxY
        let emptyViewFrame = CGRect.init(x: 0, y: 0, width: width, height: emptyViewH)
        self.emptyView = COINEmptyView.init(frame: emptyViewFrame, type: .noData)
        self.tableView.tableFooterView = self.emptyView
        self.tableView.tableHeaderView = headerView
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.settingInfoModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> COINSettingInfoTableViewCell {
        
        let cell: COINSettingInfoTableViewCell = COINSettingInfoTableViewCell.init(style: .default, reuseIdentifier: CoinDetailTableViewControllerStruct.cellID)
        let possionItemModelArray:[COINSettingInfoModel] = self.settingInfoModel[indexPath.row]
        let itemModel = possionItemModelArray.first
        for index in 0...(possionItemModelArray.count-1) {
            if index != 0 {
                let lastModel = possionItemModelArray[index]
                itemModel?.initMargin   += lastModel.initMargin
                itemModel?.maintMargin  += lastModel.maintMargin
                itemModel?.realisedPnl  += lastModel.realisedPnl
                itemModel?.unrealisedPnl += lastModel.unrealisedPnl
            }
        }
        
        if marginModel?.platformType == .bitmex {
            itemModel?.availableMargin = self.marginModel?.avilableMargin ?? 0
          itemModel?.marginBalance = self.marginModel?.maintMargin ?? 0.0
        }
        
        cell.model = itemModel
        return cell
    }
    
    @objc func unbindAction() {
        if (self.model != nil) {
            if COINKeyChainTool.shared().hasBind(platform: (self.model?.platform)!) {
                let alert = UIAlertController.init(title: nil, message: "解除绑定后，将无法继续记录和统计资产，且该交易所记录数据将被清除。确定解绑？", preferredStyle: .alert)
                weak var weakSelf = self
                alert.addAction(UIAlertAction.init(title: "取消", style: .default, handler: { (cancel) in
                    
                }))
                alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (cancel) in
                    COINKeyChainTool.shared().delete(platform: self.model!.platform)
                    weakSelf?.navigationController?.popViewController(animated: true)
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension COINCoinDetailTableViewController {
    
    func startNetWork(){
       
        if self.marginModel?.platformType == .bitmex {
            getPosition()
        }else{
            getPosition_ok()
        }
        
        
    }
    
    func getPosition_ok(){
        self.settingInfoModel.removeAll()
        for account in (marginModel?.accountModelArray ?? [COINAccountsItemModel_ok]()) {
            let eth_btc = account.eth_btc
            let infoModel = COINSettingInfoModel()
            if account.margin_mode == "crossed" {
                let currency: String = account.currency ?? "BTC"
                infoModel.marginBalance = multipleValue(value: account.equity, currency: currency, eth_btc: eth_btc)
                infoModel.imageName = currency.lowercased()
                infoModel.symbol    = currency
                infoModel.unrealisedPnl = multipleValue(value: account.unrealized_pnl, currency: currency, eth_btc: eth_btc)
                infoModel.realisedPnl   = multipleValue(value: account.realized_pnl, currency: currency, eth_btc: eth_btc)
                infoModel.initMargin   = multipleValue(value: 0, currency: currency, eth_btc: eth_btc)
                infoModel.maintMargin  = multipleValue(value: account.margin, currency: currency, eth_btc: eth_btc)
                infoModel.availableMargin = multipleValue(value: account.total_avail_balance, currency: currency, eth_btc: eth_btc)
            }else{
                var initMargin: Float  = 0
                var maintMargin: Float = 0
                var currency = "BTC"
                for sub  in account.contracts! {
                    currency = sub.instrument_id?.components(separatedBy: "-").first ?? "BTC"
                    infoModel.marginBalance = multipleValue(value: account.equity, currency: currency, eth_btc: eth_btc)
                    infoModel.imageName = currency.lowercased()
                    infoModel.symbol    = currency
                    initMargin += sub.margin_for_unfilled ?? 0.0
                    maintMargin += sub.margin_frozen ?? 0.0
                    infoModel.unrealisedPnl += multipleValue(value: sub.unrealized_pnl, currency: currency, eth_btc: eth_btc)
                    infoModel.realisedPnl   += multipleValue(value: sub.realized_pnl, currency: currency, eth_btc: eth_btc)
                    
                }
                infoModel.availableMargin = multipleValue(value: account.total_avail_balance, currency: currency, eth_btc: eth_btc)
                infoModel.initMargin   = multipleValue(value: initMargin, currency: currency, eth_btc: eth_btc)
                infoModel.maintMargin  = multipleValue(value: maintMargin, currency: currency, eth_btc: eth_btc)
                
            }
            
            self.settingInfoModel.append([infoModel])
        }
        if self.settingInfoModel.count > 0 {
            self.tableView.tableFooterView = UIView()
        }else{
            self.tableView.tableFooterView = self.emptyView
        }
        self.tableView.reloadData()
        self.stopRefresh()
    }
    
    func multipleValue(value: Float?,currency:String, eth_btc: Float) ->Float{
        let multiple: Float  = 100000000
        let tempValue: Float = value ?? 0.0
        let multipleValue    = tempValue * multiple
        return multipleValue
    }
    
    func getPosition(){
        weak var weakSelf = self
        let requestPath = "/api/v1/position"
        let filter: [String: Any] = ["isOpen":true]
        let parameters: [String: Any] = ["count":100,"filter":filter]
        
        COINNetworkTool.request(path: requestPath, platform: .bitmex, parameters: parameters, method: .get, responseClass: COINPositionModel.self, isArray: true, successHandler: { (response) in
            
            let tempArray: [COINPositionItemModel] = response?.data?.filter({$0.quoteCurrency?.lowercased() == "xbt" || $0.quoteCurrency?.lowercased() == "usd"}) ?? [COINPositionItemModel()]
            
            self.settingInfoModel.removeAll()
            for symobol in CoinDetailTableViewControllerStruct.symbolArray {
                
                let symbolArray = tempArray.filter({$0.symbol?.lowercased().hasPrefix(symobol) ?? false})
                if symbolArray.count > 0 {
                    
                    var settingInfoModelArray = [COINSettingInfoModel]()
                    
                    for itemModel in symbolArray {
            
                        settingInfoModelArray.append(itemModel.conversionSettingInfoModel())
                    }
                    self.settingInfoModel.append(settingInfoModelArray)
                }
                
            }
            if self.settingInfoModel.count > 0 {
                self.tableView.tableFooterView = UIView()
            }else{
                self.tableView.tableFooterView = self.emptyView
            }
            weakSelf?.tableView.reloadData()
            weakSelf?.stopRefresh()
            
        }) { (error) in
            weakSelf?.stopRefresh()
        }
    }
    
}

extension COINCoinDetailTableViewController {
    
    @objc override func startRefresh() {
        self.startNetWork()
    }
    
}
