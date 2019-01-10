//
//  COINAboutUSView.swift
//  Coin
//
//  Created by dev6 on 2018/12/28.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit
private struct COINAboutUSViewUX {
    static let VPadding: CGFloat = 20;
    static let HPadding: CGFloat = 20;
    static let CellHeight: CGFloat = 64
    static let CellLabelHeight: CGFloat = 36
    static let HeaderHeight: CGFloat = 220
    static let LogoHeight: CGFloat = 78
    static let CellName = "COINAboutUSViewCell"
}

class COINAboutUSView: UIView, UITableViewDelegate,UITableViewDataSource {
    static let coinURL = "https://www.coinx123.com"
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height), style: .plain)
        tableView.backgroundColor = bgColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(COINAboutUSViewCell.self, forCellReuseIdentifier: COINAboutUSViewUX.CellName)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: COINAboutUSViewUX.HeaderHeight))
        view.backgroundColor = bgColor
        
        let imageView = UIImageView.init(frame: CGRect.init(x: (screenWidth - COINAboutUSViewUX.LogoHeight)/2, y: 50, width: COINAboutUSViewUX.LogoHeight, height: COINAboutUSViewUX.LogoHeight))
        imageView.image = UIImage.init(named: "mine_setting_icon")
        view.addSubview(imageView)
        
        let name = UILabel.init(frame: CGRect.init(x: 0, y: imageView.frame.maxY + COINAboutUSViewUX.VPadding, width: screenWidth, height: 20))
        name.text = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String)
        name.textColor = titleBlackColor
        name.font = fontBold16
        name.textAlignment = .center
        view.addSubview(name)
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = bgColor
        self.addSubview(self.tableView)
        self.tableView.tableHeaderView = self.headerView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ----UITableViewDataSource----
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: COINAboutUSViewUX.CellName, for: indexPath) as! COINAboutUSViewCell
        if indexPath.row == 0 {
            cell.titleLabel.text = "版本"
            cell.contentLabel.text = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        } else {
            cell.titleLabel.text = "官网"
            cell.contentLabel.text = COINAboutUSView.coinURL
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return COINAboutUSViewUX.CellHeight
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        return view
    }
    // MARK: ----UITableViewDelegate----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1{
            let url = URL.init(string: COINAboutUSView.coinURL)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.openURL(url!)
            }
        }
    }

}
private class COINAboutUSViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = fontBold14
        label.textColor = titleBlackColor
        label.textAlignment = .left
        label.frame = CGRect.init(x: COINAboutUSViewUX.HPadding, y: COINAboutUSViewUX.CellHeight - COINAboutUSViewUX.CellLabelHeight, width: screenWidth/2, height: COINAboutUSViewUX.CellLabelHeight)
        return label
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = font12
        label.textColor = titleBlueColor_Light
        label.textAlignment = .right
        label.frame = CGRect.init(x: screenWidth/2 - COINAboutUSViewUX.HPadding, y: COINAboutUSViewUX.CellHeight - COINAboutUSViewUX.CellLabelHeight, width: screenWidth/2, height: COINAboutUSViewUX.CellLabelHeight)
        return label
    }()
    
    lazy var line: UIView = {
        let line = UIView.init(frame: CGRect.init(x: 0, y: COINAboutUSViewUX.CellHeight - 0.5, width: screenWidth, height: 0.5))
        line.backgroundColor = lineBlueColor_Light
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = bgColor
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.line)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
