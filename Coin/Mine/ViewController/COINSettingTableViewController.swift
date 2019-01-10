//
//  COINSettingTableViewController.swift
//  Coin
//
//  Created by gm on 2018/11/26.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

private struct SettingTableViewControllerStruct{
    
    static let CellId = "SettingTableViewControllerCellId"
    
}



class COINSettingTableViewController: UITableViewController {

    lazy var settingItemArray = self.getSettingItemModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView(){
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
        
        headerView.backgroundColor = bgColor
        self.tableView.tableHeaderView = headerView
        self.tableView.backgroundColor  = bgColor
        self.navigationItem.title = "设置"
        self.tableView.rowHeight = 50
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: SettingTableViewControllerStruct.CellId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.navImageUnderLine(),
            for: UIBarMetrics.default
        )
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  self.settingItemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemModel = self.settingItemArray[indexPath.row]
        
        let cell: COINSettingTableViewCell = COINSettingTableViewCell.init(style: .default, reuseIdentifier: SettingTableViewControllerStruct.CellId, cellStyle:itemModel.cellStyle)
        cell.titleLabel.text      = itemModel.title
        cell.iconImageView.image  = UIImage.init(named: itemModel.imageName)
        cell.titleLabel.textColor = UIColor.colorRGB(0x666666)
        weak var weakSelf = self
        cell.callBack = { switchView in
            //debugPrint("tag = ",switchView.tag,"isOn = ",switchView.isOn)
            let tag = switchView.tag - 100
            if tag == 0 {
                weakSelf?.redRose(switchView.isOn)
            } else if tag == 1 {
                weakSelf?.tradeSureAction(switchView.isOn)
            }
        }
        cell.switchBtn.tag = 100 + indexPath.row
        if indexPath.row == 0 {
            cell.switchBtn.isOn =  COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.percentageColor)
        } else if indexPath.row == 1 {
            cell.switchBtn.isOn =  COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.tradeSureKey)
        }
        
        return cell
    }

    func redRose(_ isRedRose: Bool){
        
        COINUserDefaultsHelper.saveBoolValue(value: isRedRose, forKey: UserDefaultsHelperKey.percentageColor)
        COINUseHabitHelper.shared().update()
        NotificationCenter.default.post(name: COINNotificationKeys.percentageColor, object: nil)
    }
    
    func tradeSureAction(_ tradeSureRemind: Bool) {
        COINUserDefaultsHelper.saveBoolValue(value: tradeSureRemind, forKey: UserDefaultsHelperKey.tradeSureKey)
    }
    
}


extension COINSettingTableViewController {
    
    func getSettingItemModel()-> Array<COINSettingItemModel>{
        
        let item1 = COINSettingItemModel.init("红涨绿跌", "")
        item1.cellStyle = [.titleLabel,.switchView]
        
        let item4 = COINSettingItemModel.init("交易确认提示", "")
        item4.className = COINSettingTableViewController()
        item4.cellStyle = [.titleLabel,.switchView]
        
        return [item1,item4]
    }
    

}
