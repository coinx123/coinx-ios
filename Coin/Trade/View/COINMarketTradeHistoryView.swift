//
//  COINMarketTradeHistoryView.swift
//  Coin
//
//  Created by dev6 on 2018/11/21.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

private struct COINMarketTradeHistoryViewUX {
    static let HPadding: CGFloat = 12
    static let VPadding: CGFloat = 12
    
    static let CellHeight: CGFloat = 30
    static let CellName: String = "COINMarketTradeHistoryCell"
    static let HeaderName: String = "COINMarketTradeHistorySectionHeaderView"
}

class COINMarketTradeHistoryView: UIView, UITableViewDelegate,UITableViewDataSource {

    var tradeHistoryModel: COINOrderBookModel? {
        get {
            return _tradeHistoryModel
        }
        set {
            _tradeHistoryModel = newValue
            if _tradeHistoryModel?.data?.count ?? 0 > 0 {
                for item in (_tradeHistoryModel?.data)! {
                    let toDateFmt = DateFormatter.init()
                    toDateFmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    let toStringFmt = DateFormatter.init()
                    toStringFmt.dateFormat = "HH:mm:ss"
                    let toDate = toDateFmt.date(from: item.timestamp ?? "")
                    if toDate != nil {
                        var time: Date = toDate!
                        time = Date.init(timeIntervalSince1970: time.timeIntervalSince1970 + 60 * 60 * 8)
                        let timestamp = toStringFmt.string(from: time)
                        item.timestamp = timestamp
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private var _tradeHistoryModel: COINOrderBookModel?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), style: .plain)
        tableView.bounces = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = COINMarketTradeHistoryViewUX.CellHeight
        tableView.register(COINMarketTradeHistoryCell.self, forCellReuseIdentifier: COINMarketTradeHistoryViewUX.CellName)
        tableView.register(COINMarketTradeHistorySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: COINMarketTradeHistoryViewUX.HeaderName)
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ----UITableViewDataSource----
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: COINMarketTradeHistoryCell = tableView.dequeueReusableCell(withIdentifier: COINMarketTradeHistoryViewUX.CellName, for: indexPath) as! COINMarketTradeHistoryCell
        if indexPath.row < _tradeHistoryModel?.data?.count ?? 0 {
            cell.setContent(model: (_tradeHistoryModel?.data![indexPath.row])!)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tradeHistoryModel?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return COINMarketTradeHistoryViewUX.CellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: COINMarketTradeHistorySectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: COINMarketTradeHistoryViewUX.HeaderName) as! COINMarketTradeHistorySectionHeaderView
        header.setContent()
        return header
    }
}

class COINMarketTradeHistoryCell: UITableViewCell {
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel.init(frame: CGRect.init(x: COINMarketTradeHistoryViewUX.HPadding, y: 0, width: screenWidth/4 - COINMarketTradeHistoryViewUX.HPadding, height: COINMarketTradeHistoryViewUX.CellHeight))
        timeLabel.font = font12
        timeLabel.textColor = titleGrayColor
        return timeLabel
    }()
    
    lazy var sideLabel: UILabel = {
        let sideLabel = UILabel.init(frame: CGRect.init(x: screenWidth/4, y: 0, width: screenWidth/4, height: COINMarketTradeHistoryViewUX.CellHeight))
        sideLabel.font = font12
        return sideLabel
    }()
    
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel.init(frame: CGRect.init(x: screenWidth/2, y: 0, width: screenWidth/4, height: COINMarketTradeHistoryViewUX.CellHeight))
        priceLabel.font = font12
        priceLabel.textColor = titleGrayColor
        return priceLabel
    }()
    
    lazy var countLabel: UILabel = {
        let countLabel = UILabel.init(frame: CGRect.init(x: screenWidth*3/4, y: 0, width: screenWidth/4 - COINMarketTradeHistoryViewUX.HPadding, height: COINMarketTradeHistoryViewUX.CellHeight))
        countLabel.font = font12
        countLabel.textAlignment = .right
        countLabel.textColor = titleGrayColor
        return countLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.sideLabel)
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(model: COINOrderBookItemModel) {
        self.timeLabel.text = model.timestamp
        if model.side?.lowercased() == "buy" {
            self.sideLabel.text = "买入"
            self.sideLabel.textColor = COINUseHabitHelper.shared().titleRiseColor
        } else {
            self.sideLabel.text = "卖出"
            self.sideLabel.textColor = COINUseHabitHelper.shared().titleDropColor
        }
        self.priceLabel.text = model.price
        self.countLabel.text = model.size
    }
}

class COINMarketTradeHistorySectionHeaderView: UITableViewHeaderFooterView {
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel.init(frame: CGRect.init(x: COINMarketTradeHistoryViewUX.HPadding, y: 0, width: screenWidth/4 - COINMarketTradeHistoryViewUX.HPadding, height: COINMarketTradeHistoryViewUX.CellHeight))
        timeLabel.font = font12
        timeLabel.textColor = titleGrayColor
        return timeLabel
    }()
    
    lazy var sideLabel: UILabel = {
        let sideLabel = UILabel.init(frame: CGRect.init(x: screenWidth/4, y: 0, width: screenWidth/4, height: COINMarketTradeHistoryViewUX.CellHeight))
        sideLabel.font = font12
        sideLabel.textColor = titleGrayColor
        return sideLabel
    }()
    
    lazy var priceLabel: UILabel = {
        let priceLabel = UILabel.init(frame: CGRect.init(x: screenWidth/2, y: 0, width: screenWidth/4, height: COINMarketTradeHistoryViewUX.CellHeight))
        priceLabel.font = font12
        priceLabel.textColor = titleGrayColor
        return priceLabel
    }()
    
    lazy var countLabel: UILabel = {
        let countLabel = UILabel.init(frame: CGRect.init(x: screenWidth*3/4, y: 0, width: screenWidth/4 - COINMarketTradeHistoryViewUX.HPadding, height: COINMarketTradeHistoryViewUX.CellHeight))
        countLabel.font = font12
        countLabel.textAlignment = .right
        countLabel.textColor = titleGrayColor
        return countLabel
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.sideLabel)
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setContent() {
        self.timeLabel.text = "时间"
        self.sideLabel.text = "方向"
        self.priceLabel.text = "价格"
        self.countLabel.text = "数量"
    }
}
