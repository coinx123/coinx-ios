//
//  COINTradeViewController.swift
//  Coin
//
//  Created by gm on 2018/11/2.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
import Alamofire

private let cellId = "tradeViewControllercellID"
private let headerViewID = "tradeViewControllertableHeaderViewID"
private let numberOfCellsPerGroup = 3
class COINTradeViewController: COINBaseTableViewController {
    
    lazy var mainTableHeaderView: COINTradeMainTableHeaderVIew = {
       let mainTableHeaderVie = COINTradeMainTableHeaderVIew.init(frame: CGRect.zero)
        return mainTableHeaderVie
    }()
    
    var isBitMex = true
    
    var isOption   = true
    
    ///数据显示通过公共部分Array
    lazy var selectionListArray: Array = {
        return Array<Array<COINInstrumentItemModel>>.init()
    }()
    ///bitmex 数据刷新通过bitmex
    lazy var selectionListArray_bitMex: Array = {
        return Array<Array<COINInstrumentItemModel>>.init()
    }()
    /// ok数据刷新通过ok
    lazy var selectionListArray_ok: Array = {
        return Array<Array<COINInstrumentItemModel>>.init()
    }()
    
    ///自选数据显示通过公共部分Array
    lazy var detailArray: Array = {
        return Array<COINInstrumentItemModel>.init()
    }()
    ///自选ok数据刷新通过ok
    lazy var detailArray_ok: Array = {
        return Array<COINInstrumentItemModel>.init()
    }()
    ///自选bitmex数据刷新通过bitmex
    lazy var detailArray_bitMex: Array = {
        return Array<COINInstrumentItemModel>.init()
    }()
    
    var emptyView: COINEmptyView?
    
    lazy var collectArray: Array<Dictionary<String, Any>> = Array()
    
    lazy var optionFootView: COINOptionFootView = {
        let viewH = self.view.frame.size.height - self.mainTableHeaderView.frame.maxY - 49
        let frame          = CGRect.init(
            x: 0,
            y: 0,
            width: self.view.frame.width,
            height: viewH
        )
        
        weak var weakSelf =  self
        let optionFootView = COINOptionFootView.init(frame: frame, callBack: {
            weakSelf?.mainTableHeaderView.electedBtnClick()
        })
        
        return optionFootView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(
        UIImage.navImageUnderLine(),
        for: UIBarMetrics.default
        )
        
        self.tableView = UITableView.init(frame: self.tableView.frame, style: .grouped)
        self.tableView.backgroundColor = bgColor
        self.tableView.separatorColor  = lineGrayColor
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(COINSymbolInfoCell.classForCoder(), forCellReuseIdentifier: cellId)
        self.tableView.register(COINTradeTableHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: headerViewID)
        
        self.tableView.rowHeight = 60
        addHeaderView()
        addBitMex(subscribeTypeArray: [.instrument])
        addOkex(subscribeTypeArray: [.ticker_ok])
        for dict in self.collectArray {
            startSubscribe_bitMex(symbol: dict["symbol"] as! String, subscribeType: .instrument)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestNetWork()
    }
    
    func addHeaderView(){
        let width = self.view.frame.size.width
        let headerView = mainTableHeaderView
        self.tableView.tableHeaderView = headerView
        
        weak var weakSelf = self
        mainTableHeaderView.optionalCallBack = ({isOption in
            weakSelf?.isOption = isOption
            if(isOption){
                weakSelf!.updateOptionTypeTableView()
            }else{
               weakSelf?.requestNetWork()
            }
            
        })
        
        mainTableHeaderView.bitMexCallBack = ({isBitMex in
            weakSelf?.isBitMex = isBitMex
            weakSelf?.requestNetWork()
        })
        
        let emptyViewH     = self.view.frame.size.height - headerView.frame.maxY
        let emptyViewFrame = CGRect.init(x: 0, y: 0, width: width, height: emptyViewH)
        self.emptyView = COINEmptyView.init(frame: emptyViewFrame, type: .noData)
        updateTableViewFootView(self.detailArray)
    }
    
    func updateTableViewFootView_option(_ array: [Any]){
        self.tableView.tableFooterView = self.optionFootView
        if array.count >= 1 {
            if self.optionFootView.state != .add {
                self.optionFootView.state      = .add
            }
        }else{
            if self.optionFootView.state != .none {
                self.optionFootView.state      = .none
            }
        }
    }
    
    func updateTableViewFootView(_ array: [Any]) {
        if array.count >= 1 {
            self.tableView.tableFooterView = UIView()
        }else{
            self.tableView.tableFooterView = self.emptyView
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if  self.isOption {
            return self.detailArray.count / numberOfCellsPerGroup + 1
        }
        
        return self.selectionListArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isOption {
            if section == self.detailArray.count / numberOfCellsPerGroup{
                return self.detailArray.count % numberOfCellsPerGroup
            }else{
                return  numberOfCellsPerGroup
            }
        }else{
            return self.selectionListArray[section].count
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.isOption ? 0 : 45
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.isOption {
            if section == self.detailArray.count / numberOfCellsPerGroup {
                return 0
            }
        }
        
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !self.isOption {
            if self.selectionListArray.count > 0 {
                let detail = self.selectionListArray[section].first
                let headerView: COINTradeTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerViewID) as! COINTradeTableHeaderView
                headerView.rootSymbolLabel.text = detail?.rootSymbol
                headerView.iconView.image = UIImage.init(named: "currency_" + (detail?.rootSymbol?.lowercased())!)
                return headerView
            }
        }
        
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell   = COINSymbolInfoCell.selectionDetailCell(
            tableView: tableView,
            cellId: cellId,
            needSerialNumberLabel: false,
            needIcon: self.isOption,
            collect: !self.isOption
        )
        
        var detail: COINInstrumentItemModel?
        if self.isOption {
            let index = indexPath.row + indexPath.section * numberOfCellsPerGroup
            if self.detailArray.count > index {
                detail = self.detailArray[index]
                detail?.needRootSymbol = true
            }
        }else{
            if indexPath.row < self.selectionListArray.count{
                detail  = self.selectionListArray[indexPath.section][indexPath.row]
                detail?.needRootSymbol = false
            }
        }
        
        if (detail != nil) {
            cell.model    = detail
            cell.callBack = { btn in
                if(btn.isSelected){
                COINUserDefaultsHelper.saveObjToArray(detail?.toJSON() as Any, UserDefaultsHelperKey.collectionsKey, platformType: detail?.platformType ?? .bitmex)
                    self.collectArray.append((detail?.toJSON())!)
                }else{
                    self.collectArray.removeAll(where: { (dict) -> Bool in
                        let temp: String = dict["symbol"] as! String
                        return (detail?.symbol?.contains(temp))!
                    });
                    
                    COINUserDefaultsHelper.saveObj(obj: self.collectArray, userdfalutKay: UserDefaultsHelperKey.collectionsKey, platformType: detail?.platformType ?? .bitmex)
                }
            }
    
            cell.collectionBtn.isSelected = self.collectArray.contains(where: { (dict) -> Bool in
                let temp: String = dict["symbol"] as! String
                return (detail?.symbol?.contains(temp))!
            })
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        weak var weakSelf = self
        let placedAtTheTop = UITableViewRowAction.init(style: .normal, title: "置顶") { (action, indexPath) in
            let index  = indexPath.row + indexPath.section * numberOfCellsPerGroup
            let detail = weakSelf?.detailArray[index]
            let platformValueTemp = detail?.platformValue
            detail?.platformValue = platformValueTemp ?? 0
            if detail?.platformType == .bitmex {
                weakSelf?.detailArray_bitMex.remove(at: index)
                weakSelf?.detailArray_bitMex.insert(detail!, at: 0)
            }else{
                weakSelf?.detailArray_ok.remove(at: index)
                weakSelf?.detailArray_ok.insert(detail!, at: 0)
            }
            
            self.collectArray.removeAll(where: { (dict) -> Bool in
                let temp: String = dict["symbol"] as! String
                return (detail?.symbol?.contains(temp))!
            });
            
            self.collectArray.insert((detail?.toJSON())!, at: 0)
            COINUserDefaultsHelper.saveObj(obj: self.collectArray, userdfalutKay: UserDefaultsHelperKey.collectionsKey, platformType: detail?.platformType ?? .bitmex)
            weakSelf?.getDisplayAray()
        }
        
        placedAtTheTop.backgroundColor = bgBlueColor
        let delete = UITableViewRowAction.init(style: .default, title: "删除") { (action, indexPath) in
            let index  = indexPath.row + indexPath.section * numberOfCellsPerGroup
            let detail = weakSelf?.detailArray[index]
            weakSelf?.collectArray.removeAll(where: { (dict) -> Bool in
                let temp: String = dict["symbol"] as! String
                return (detail?.symbol?.contains(temp))!
            });
            
            let platformValueTemp = detail?.platformValue
            detail?.platformValue = platformValueTemp ?? 0
            COINUserDefaultsHelper.saveObj(obj: self.collectArray, userdfalutKay: UserDefaultsHelperKey.collectionsKey, platformType: detail?.platformType ?? .bitmex)
            if detail?.platformType == .bitmex {
                weakSelf?.detailArray_bitMex.remove(at: index)
                weakSelf?.startCancel_bitMex(symbol: (detail?.symbol)!, subscribeType: .instrument)
            }else{
                weakSelf?.detailArray_ok.remove(at: index)
                weakSelf?.startCancel_ok(
                    instrument_Id: detail?.symbol ?? "",
                    subscribeType: .ticker_ok
                )
            }
            
            self.getDisplayAray()
        }
        
        return [delete,placedAtTheTop]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.isOption
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = self.isOption ? self.detailArray[indexPath.row + indexPath.section * numberOfCellsPerGroup] : self.selectionListArray[indexPath.section][indexPath.row]
        let orderManegerViewController = COINOrderManageViewController.init(platform: detail.platformType, symbol: detail.symbol ?? "")
        orderManegerViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(orderManegerViewController, animated: true)
    }
    
    func updateOptionTypeTableView(){
        let localCollectArray = getLocalCollectArray()
        self.subscribeOrCancel(localCollectArray)
        self.getDisplayAray()
    }

    /// 获取本地缓存的自选合约
    ///
    /// - Returns:本地自选合约数组
    func getLocalCollectArray()-> Array<Dictionary<String, Any>>{
        let localCollectArray = COINUserDefaultsHelper.getObjArray(UserDefaultsHelperKey.collectionsKey, platformType: !self.isBitMex ? .okex : .bitmex)
        return  localCollectArray as! Array<Dictionary<String, Any>>
    }
    
}


extension COINTradeViewController {
    
    func requestNetWork(){
        getDisplayAray()
        self.collectArray = getLocalCollectArray()
        if self.isOption {
            updateOptionTypeTableView()
        }else{
            if self.isBitMex {
                getSelectionListFromNetWork_bitMex()
            }else{
                getSelectionListFromNetWork_okex()
            }
        }
    }

    /// 获取tradeView需要显示的数组
    func getDisplayAray(){
        if self.isOption{
            self.detailArray.removeAll()
            self.detailArray = self.isBitMex ? self.detailArray_bitMex :  self.detailArray_ok
            self.updateTableViewFootView_option(self.detailArray)
        }else{
            self.selectionListArray.removeAll()
            self.selectionListArray = self.isBitMex ? selectionListArray_bitMex : self.selectionListArray_ok
            self.updateTableViewFootView(self.selectionListArray)
        }
        self.tableView.reloadData()
    }
    
    func selectionAppenArray(_ array: Array<COINInstrumentItemModel>){
        if array.count > 0 {
            if !self.isBitMex {
                self.selectionListArray_ok.append(array)
            }else{
                self.selectionListArray_bitMex.append(array)
            }
        }
    }
    
}

// MARK: ------- webSocket -------
extension COINTradeViewController {
    
    func subscribeOrCancel(_ newCollectArray:Array<Dictionary<String, Any>>){
        for detail in self.detailArray {
            if !newCollectArray.contains(where: { (dict) -> Bool in
                let temp: String = dict["symbol"] as! String
                return (detail.symbol?.contains(temp) ?? false)
            }){
                if detail.platformType == .bitmex{
                    startCancel_bitMex(symbol: detail.symbol ?? "", subscribeType: .instrument)
                   self.detailArray_bitMex.removeAll {$0.symbol == detail.symbol}
                }else{
                    startCancel_ok(
                        instrument_Id: detail.symbol ?? "",
                        subscribeType: .ticker_ok
                    )
                    self.detailArray_ok.removeAll {$0.symbol == detail.symbol}
                }
            }
        }
        
        for dict in newCollectArray {//这里是新需要订阅的
            let temp: String = dict["symbol"] as! String
            let symbolInfoModel = COINInstrumentItemModel.deserialize(from: dict)!
            let platformValueTemp = symbolInfoModel.platformValue
            symbolInfoModel.platformValue = platformValueTemp
            if symbolInfoModel.platformType == .bitmex {
                startSubscribe_bitMex(symbol: temp, subscribeType: .instrument)
                if !self.detailArray_bitMex.contains(where: { $0.symbol == symbolInfoModel.symbol}){
                    if !symbolInfoModel.isBitMexExpiry() {
                      self.detailArray_bitMex.append(symbolInfoModel)
                    }
                }
            }else{
                startSubscribe_ok(instrument_Id: symbolInfoModel.symbol ?? "", subscribeType: .ticker_ok)
                if !self.detailArray_ok.contains(where: { $0.symbol == symbolInfoModel.symbol}){
                    if !symbolInfoModel.isOkexExpiry(){
                        self.detailArray_ok.append(symbolInfoModel)
                    }
                }
            }
        }
    }
}
