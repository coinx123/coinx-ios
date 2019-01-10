//
//  COINKLineView.swift
//  Coin
//
//  Created by dev6 on 2018/11/24.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit
import SnapKit
import Charts

private struct COINKLineViewUX {
    static let HPadding: CGFloat = 12
    static let VPadding: CGFloat = 12
    
    static let CellName: String = "TradeBucketCell"
}

class COINKLineView: UIView, ChartViewDelegate,UITableViewDelegate,UITableViewDataSource {
    var selectedMainType = 1 //1.MA 2.BOLL
    var selectedAuxiliaryType = 1 //1.成交量 2.MACD 3.KDJ 4.RSI
    var kLineType: KLineType = .MinuteLine
    var viewWidth = screenWidth
    
    var _kLineModel: COINKLineModel?
    
    var selectedKLineItemModel: COINKLineItemModel?
    
    lazy var dataContentLabel: UILabel = {
        let dataContentLabel = UILabel()
        dataContentLabel.font = font10
        return dataContentLabel
    }()
    
    lazy var masterChartView: CombinedChartView = { //主图
        let masterChartView = CombinedChartView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 214))
        masterChartView.delegate = self
        masterChartView.noDataText = "暂无数据"
        masterChartView.doubleTapToZoomEnabled = false
        masterChartView.autoScaleMinMaxEnabled = true
        masterChartView.legend.enabled = false
        masterChartView.chartDescription?.enabled = false
        masterChartView.maxVisibleCount = 0
        masterChartView.scaleXEnabled = true
        masterChartView.scaleYEnabled = false
        masterChartView.pinchZoomEnabled = false
        masterChartView.drawGridBackgroundEnabled = false
        
        masterChartView.drawOrder = [DrawOrder.bar.rawValue,
                                     DrawOrder.bubble.rawValue,
                                     DrawOrder.candle.rawValue,
                                     DrawOrder.line.rawValue,
                                     DrawOrder.scatter.rawValue]
        
        let xAxis = masterChartView.xAxis
        xAxis.labelPosition = .bottomInside
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.labelCount = 5
        xAxis.axisLineWidth = 1.1/UIScreen.main.scale
        xAxis.labelTextColor = UIColor.colorWithRGB(135, 135, 135)
        xAxis.valueFormatter = KLineXAxisFormatter.init()
        xAxis.spaceMax = 0.5
        xAxis.spaceMin = 0.5
        
        let leftAxis = masterChartView.leftAxis
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        
        let rightAxis = masterChartView.rightAxis
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        
        return masterChartView
    }()
    lazy var subDataContentLabel: UILabel = {
        let subDataContentLabel = UILabel()
        subDataContentLabel.font = font10
        subDataContentLabel.textColor = titleBlackColor
        return subDataContentLabel
    }()
    lazy var auxiliaryChartView: CombinedChartView = { //副图
        let auxiliaryChartView = CombinedChartView.init(frame: CGRect.init(x: 0, y: self.masterChartView.frame.maxY + 6, width: screenWidth, height: 100))
        auxiliaryChartView.delegate = self
        auxiliaryChartView.noDataText = "暂无数据"
        auxiliaryChartView.doubleTapToZoomEnabled = false
        auxiliaryChartView.autoScaleMinMaxEnabled = true
        auxiliaryChartView.legend.enabled = false
        auxiliaryChartView.chartDescription?.enabled = false
        auxiliaryChartView.maxVisibleCount = 0
        auxiliaryChartView.scaleXEnabled = true
        auxiliaryChartView.scaleYEnabled = false
        auxiliaryChartView.pinchZoomEnabled = false
        auxiliaryChartView.drawGridBackgroundEnabled = false
        
        
        let xAxis = auxiliaryChartView.xAxis
        xAxis.drawLabelsEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.labelCount = 5
        xAxis.axisLineColor = UIColor.clear
        xAxis.axisLineWidth = 1.1/UIScreen.main.scale
        xAxis.spaceMax = 0.5
        xAxis.spaceMin = 0.5
        
        let leftAxis = auxiliaryChartView.leftAxis
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelCount = 5
        
        let rightAxis = auxiliaryChartView.rightAxis
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.labelCount = 5
        return auxiliaryChartView
    }()
    
    lazy var vSelectedLine: UIView = {
        let vSelectedLine = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: self.frame.size.height - 18))
        vSelectedLine.backgroundColor = lineGrayColor
        vSelectedLine.isHidden = true
        return vSelectedLine
    }()
    
    lazy var hSelectedLine: UIView = {
        let hSelectedLine = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 1))
        hSelectedLine.backgroundColor = lineGrayColor
        hSelectedLine.isHidden = true
        return hSelectedLine
    }()
    
    lazy var vSelectedLabel: UILabel = {
        let vSelectedLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 13))
        vSelectedLabel.isHidden = true
        vSelectedLabel.backgroundColor = UIColor.colorWithRGB(101, 112, 124)
        vSelectedLabel.textColor = whiteColor
        vSelectedLabel.font = font10
        vSelectedLabel.textAlignment = .center
        return vSelectedLabel
    }()
    
    lazy var hSelectedLabel: UILabel = {
        let hSelectedLabel = UILabel.init(frame: CGRect.init(x: 0, y: 175, width: 100, height: 13))
        hSelectedLabel.backgroundColor = UIColor.colorWithRGB(101, 112, 124)
        hSelectedLabel.isHidden = true
        hSelectedLabel.textColor = whiteColor
        hSelectedLabel.font = font10
        hSelectedLabel.textAlignment = .center
        return hSelectedLabel
    }()
    
    lazy var selectedView: UITableView = {
        let selectedView = UITableView.init(frame: CGRect.init(x: 11, y: 15, width: 130, height: 140), style: .plain)
        selectedView.layer.borderColor = lineGrayColor.cgColor
        selectedView.layer.borderWidth = 1
        selectedView.backgroundColor = bgColor
        selectedView.bounces = true
        selectedView.isHidden = true
        selectedView.rowHeight = 140 / 8
        selectedView.isScrollEnabled = false
        selectedView.delegate = self
        selectedView.dataSource = self
        selectedView.register(TradeBucketCell.self, forCellReuseIdentifier: COINKLineViewUX.CellName)
        selectedView.separatorStyle = .none
        return selectedView
    }()
    
    var selectedPoint: CGPoint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.masterChartView)
        self.addSubview(self.dataContentLabel)
        self.addSubview(self.auxiliaryChartView)
        self.addSubview(self.subDataContentLabel)
        self.addSubview(self.vSelectedLine)
        self.addSubview(self.hSelectedLine)
        self.addSubview(self.vSelectedLabel)
        self.addSubview(self.hSelectedLabel)
        self.addSubview(self.selectedView)
        
        self.masterChartView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(self.auxiliaryChartView.snp.height).multipliedBy(2)
        }
        
        self.dataContentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(0)
        }
        
        self.auxiliaryChartView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(self.masterChartView.snp.bottom)
            make.bottom.equalTo(0)
        }
        
        self.subDataContentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(self.masterChartView.snp.bottom)
        }
        
        self.vSelectedLine.snp.makeConstraints { (make) in
            make.centerX.equalTo(0)
            make.width.equalTo(1)
            make.top.equalTo(0)
            make.bottom.equalTo(18)
        }
        
        self.hSelectedLine.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.centerY.equalTo(0)
            make.height.equalTo(1)
        }
        self.vSelectedLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(13)
        }
        
        self.hSelectedLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(0)
            make.bottom.equalTo(self.masterChartView.snp.bottom).offset(-25)
            make.height.equalTo(13)
        }
        
        self.selectedView.snp.makeConstraints { (make) in
            make.left.equalTo(11)
            make.top.equalTo(15)
            make.width.equalTo(130)
            make.height.equalTo(140)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func synView(chartView: ChartViewBase) {
        self.hideSelectedView()
        let scrMatrix = chartView.viewPortHandler.touchMatrix
        if chartView == self.masterChartView {
            self.auxiliaryChartView.viewPortHandler.refresh(newMatrix: scrMatrix, chart: self.auxiliaryChartView, invalidate: true)
        } else {
            self.masterChartView.viewPortHandler.refresh(newMatrix: scrMatrix, chart: self.masterChartView, invalidate: true)
        }
    }
    
    func hideSelectedView() {
        self.selectedKLineItemModel = nil
        if !self.vSelectedLine.isHidden {
            self.vSelectedLine.isHidden = true
            self.hSelectedLine.isHidden = true
            self.vSelectedLabel.isHidden = true
            self.hSelectedLabel.isHidden = true
            self.selectedView.isHidden = true
        }
    }
    
    func showSelectedView(kLineItemModel: COINKLineItemModel?) {
        if kLineItemModel == nil {
            return
        }
        if self.vSelectedLine.isHidden {
            self.vSelectedLine.isHidden = false
            self.hSelectedLine.isHidden = false
            self.vSelectedLabel.isHidden = false
            self.hSelectedLabel.isHidden = false
            self.selectedView.isHidden = false
        }
        if self.selectedKLineItemModel?.timestamp == kLineItemModel?.timestamp {
            self.hideSelectedView()
            return
        }
        self.selectedKLineItemModel = kLineItemModel
        
        self.vSelectedLine.snp.updateConstraints { (make) in
            make.centerX.equalTo(self.selectedPoint!.x)
        }
        self.hSelectedLine.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.selectedPoint!.y)
        }
        
        self.hSelectedLabel.text = " \(kLineItemModel?.timestamp ?? "") "
        self.vSelectedLabel.text = " \(kLineItemModel?.close ?? "") "
        
        if self.selectedPoint!.x > self.viewWidth/2 {
            self.vSelectedLabel.snp.remakeConstraints { (make) in
                if self.viewWidth > screenWidth {
                    if #available(iOS 11.0, *) {
                        make.right.equalTo(self.safeAreaLayoutGuide.snp.right)
                    } else {
                        // Fallback on earlier versions
                        make.right.equalTo(0)
                    }
                } else {
                    make.right.equalTo(0)
                }
                make.centerY.equalTo(self.selectedPoint!.y)
            }
            self.selectedView.snp.remakeConstraints { (make) in
                if self.viewWidth > screenWidth {
                    if #available(iOS 11.0, *) {
                        make.left.equalTo(self.safeAreaLayoutGuide.snp.left)
                    } else {
                        // Fallback on earlier versions
                        make.left.equalTo(11)
                    }
                } else {
                    make.left.equalTo(11)
                }
                make.top.equalTo(15)
                make.width.equalTo(130)
                make.height.equalTo(140)
            }
        } else {
            self.vSelectedLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(0)
                make.centerY.equalTo(self.selectedPoint!.y)
            }
            self.selectedView.snp.remakeConstraints { (make) in
                if self.viewWidth > screenWidth {
                    if #available(iOS 11.0, *) {
                        make.right.equalTo(self.safeAreaLayoutGuide.snp.right)
                    } else {
                        // Fallback on earlier versions
                        make.right.equalTo(-11)
                    }
                } else {
                    make.right.equalTo(-11)
                }
                make.top.equalTo(15)
                make.width.equalTo(130)
                make.height.equalTo(140)
            }
        }
        self.hSelectedLabel.snp.updateConstraints { (make) in
            make.centerX.equalTo(self.selectedPoint!.x)
        }
        self.selectedView.reloadData()
    }
    
    public func setContent(kLineModel: COINKLineModel?, kLineType: KLineType, selectedMainType: Int , selectedAuxiliaryType: Int) {
        _kLineModel = kLineModel
        self.kLineType = kLineType
        self.selectedMainType = selectedMainType
        self.selectedAuxiliaryType = selectedAuxiliaryType
        let formatter: KLineXAxisFormatter = self.masterChartView.xAxis.valueFormatter as! KLineXAxisFormatter
        formatter.kLineList = _kLineModel?.data
        formatter.klineType = self.kLineType
        
        let combineData = CombinedChartData()
        if self.selectedMainType == 1 {
            combineData.lineData = self.getLineMAData()
            self.dataContentLabel.attributedText = self.getMAAttr()
        } else {
            combineData.lineData = self.getLineBOLLData()
            self.dataContentLabel.attributedText = self.getBOLLAttr()
        }
        if self.kLineType != .MinuteLine {
            combineData.candleData = self.getCandleData()
        }
        self.masterChartView.data = combineData
//        print("width == \(self.viewWidth)")
        self.masterChartView.setVisibleXRangeMaximum(Double(self.viewWidth/6) - 15)
        self.masterChartView.setVisibleXRangeMinimum(Double(self.viewWidth/6) - 15)
        
        let combineData1 = CombinedChartData()
        switch self.selectedAuxiliaryType {
        case 1:
            combineData1.barData = self.getBarData()
            self.subDataContentLabel.attributedText = self.getBarAttr()
        case 2:
            combineData1.barData = self.getBarMACDData()
            combineData1.lineData = self.getLineMACDData()
            self.subDataContentLabel.attributedText = getMACDAttr()
        case 3:
            combineData1.lineData = self.getLineKDJData()
            self.subDataContentLabel.attributedText = self.getKDJAttr()
        case 4:
            combineData1.lineData = self.getLineRSIData()
            self.subDataContentLabel.attributedText = self.getRSIAttr()
        default:
            break
        }
        self.auxiliaryChartView.data = combineData1
        if combineData1.barData != nil || combineData1.lineData != nil {
            self.auxiliaryChartView.setVisibleXRangeMaximum(Double(self.viewWidth/6) - 15)
            self.auxiliaryChartView.setVisibleXRangeMinimum(Double(self.viewWidth/6) - 15)
        }
        
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.masterChartView.moveViewToX(Double((weakSelf?._kLineModel?.data!.count)! - 1))
            if combineData1.barData != nil || combineData1.lineData != nil {
                self.auxiliaryChartView.moveViewToX(Double((weakSelf?._kLineModel?.data!.count)! - 1))
            }
        }
        
        self.hideSelectedView()
    }
    
    // MARK: ----ChartViewDelegate----
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //        print(entry)
        if chartView == self.masterChartView {
            self.selectedPoint = self.masterChartView.getPosition(entry: entry, axis: .left)
        } else {
            let point = self.auxiliaryChartView.getPosition(entry: entry, axis: .left)
            let masterEntry = self.masterChartView.getEntryByTouchPoint(point: point)
            if masterEntry != nil {
                self.selectedPoint = self.masterChartView.getPosition(entry: masterEntry!, axis: .left)
            } else {
                self.selectedPoint = point
            }
        }
        self.showSelectedView(kLineItemModel: entry.data as? COINKLineItemModel)
    }
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        self.synView(chartView: chartView)
    }
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        self.synView(chartView: chartView)
    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        self.hideSelectedView()
    }
    
    // MARK: ----UITableViewDelegate----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TradeBucketCell = tableView.dequeueReusableCell(withIdentifier: COINKLineViewUX.CellName, for: indexPath) as! TradeBucketCell
        if self.selectedKLineItemModel != nil {
            cell.setContent(index: indexPath.row,itemModel: self.selectedKLineItemModel!)
        }
        return cell
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
class TradeBucketCell: UITableViewCell {
    lazy var leftLabel: UILabel = {
        let leftLabel = UILabel()
        leftLabel.font = font10
        leftLabel.textColor = titleGrayColor
        return leftLabel
    }()
    
    lazy var rightLabel: UILabel = {
        let rightLabel = UILabel()
        rightLabel.font = font10
        rightLabel.textColor = titleGrayColor
        rightLabel.textAlignment = .right
        return rightLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.colorWithRGB(243, 244, 248)
        self.contentView.addSubview(self.leftLabel)
        self.contentView.addSubview(self.rightLabel)
        self.leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(4)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        self.rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-4)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setContent(index: Int,itemModel: COINKLineItemModel) {
        var title = ""
        var subTitle = ""
        switch index {
        case 0:
            title = "时间"
            subTitle = itemModel.timestamp!
        case 1:
            title = "开"
            subTitle = itemModel.open!
        case 2:
            title = "高"
            subTitle = itemModel.high!
        case 3:
            title = "低"
            subTitle = itemModel.low!
        case 4:
            title = "收"
            subTitle = itemModel.close!
        case 5:
            title = "涨跌额"
            subTitle = String(format: "%.2f", Double(itemModel.close!)!-Double(itemModel.open!)!)
        case 6:
            title = "涨跌幅"
            subTitle = "\(String(format: "%.2f", (Double(itemModel.close!)!-Double(itemModel.open!)!)*100.0/Double(itemModel.open!)!))%"
        case 7:
            title = "成交量"
            subTitle = itemModel.volume!
        default:
            break
        }
        self.leftLabel.text = title
        self.rightLabel.text = subTitle
    }
}
class KLineXAxisFormatter: NSObject, IAxisValueFormatter {
    var kLineList: [COINKLineItemModel]?
    var klineType: KLineType = .MinuteLine
    
    let toDateFmt = DateFormatter.init()
    let toStringFmt = DateFormatter.init()
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if self.kLineList == nil {
            return ""
        }
        if Int(value) >= (self.kLineList?.count)! {
            return ""
        }
        let itemModel = self.kLineList![Int(value)]
        toDateFmt.dateFormat = "yyyy-MM-dd HH:mm"
        var dateFormat = "HH:mm"
        switch self.klineType {
        case .MinuteLine:
            dateFormat = "HH:mm"
        case .FiveMinuteLine:
            dateFormat = "HH:mm"
        case .FifteenMinuteLine:
            dateFormat = "HH:mm"
        case .ThirtyMinuteLine:
            dateFormat = "MM-dd"
        case .HourLine:
            dateFormat = "MM-dd"
        case .FourHourLine:
            dateFormat = "MM-dd"
        case .DayLine:
            dateFormat = "yyyy-MM"
        case .WeekLine:
            dateFormat = "yyyy-MM"
        case .MonthLine:
            dateFormat = "yyyy-MM"
        }
        toStringFmt.dateFormat = dateFormat
        var time: Date = toDateFmt.date(from: itemModel.timestamp ?? "") ?? Date.init()
        time = Date.init(timeIntervalSince1970: time.timeIntervalSince1970)
        return toStringFmt.string(from: time)
    }
}
// MARK: ----MA----
extension COINKLineView {
    func getCandleData() -> CandleChartData {
        var yVals = [CandleChartDataEntry]()
        var colors = [NSUIColor]()
        for index in 0..<(_kLineModel?.data?.count)! {
            let item = _kLineModel?.data![index]
            let model: CandleChartDataEntry = CandleChartDataEntry.init(x: Double(index), shadowH: Double(item!.high!)!, shadowL: Double(item!.low!)!, open: Double(item!.open!)!, close: Double(item!.close!)!, data: item)
            yVals.append(model)
            if Double(item!.open!)! >= Double(item!.close!)! {
                colors.append(COINUseHabitHelper.shared().bgDropColor! as NSUIColor)
            } else {
                colors.append(COINUseHabitHelper.shared().bgRiseColor! as NSUIColor)
            }
        }
        let set = CandleChartDataSet.init(values: yVals, label: "KLINE")
        set.setColors(colors, alpha: 1)
        set.shadowWidth = 1
        set.drawIconsEnabled = false
        set.decreasingColor = COINUseHabitHelper.shared().bgDropColor
        set.decreasingFilled = true
        set.increasingColor = COINUseHabitHelper.shared().bgRiseColor
        set.increasingFilled = true
        set.neutralColor = COINUseHabitHelper.shared().bgRiseColor
        set.highlightColor = UIColor.clear
        return CandleChartData(dataSet: set)
    }
    
    func getLineMAData() -> LineChartData {
        if self.kLineType == .MinuteLine {
            let set_M = self.getMData()
            return LineChartData.init(dataSets: [set_M])
        } else {
            let set_M5 = self.getM5Data()
            let set_M10 = self.getM10Data()
            let set_M30 = self.getM30Data()
            return LineChartData.init(dataSets: [set_M5,set_M10,set_M30])
        }
    }
    
    func getMData() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        for i in 0..<(_kLineModel?.data!.count ?? 0) {
            let item = _kLineModel?.data![i]
            let y: Double = Double(item!.close!)!
            let model = _kLineModel?.data![i]
            let dataEntry = [ChartDataEntry.init(x: Double(i), y: y, data: model)]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "M5")
        self.configLineSets(set: set)
        set.setColor(lineBlueColor)
        set.fillColor = lineBlueColor
        return set
    }
    
    func getM5Data() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var closePriceM5List = self.getClosePriceList(days: 5)
        for i in 0..<closePriceM5List.count {
            let y: Double = Double(closePriceM5List[i])
            let index = i + 4
            let model = _kLineModel?.data![index]
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: model)]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "M5")
        self.configLineSets(set: set)
        set.setColor(lineYellowColor)
        set.fillColor = lineYellowColor
        return set
    }
    
    func getM10Data() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var closePriceM5List = self.getClosePriceList(days: 10)
        for i in 0..<closePriceM5List.count {
            let y: Double = Double(closePriceM5List[i])
            let index = i + 9
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "M10")
        self.configLineSets(set: set)
        set.setColor(lineGreenColor)
        set.fillColor = lineGreenColor
        return set
    }
    
    func getM30Data() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var closePriceM5List = self.getClosePriceList(days: 30)
        for i in 0..<closePriceM5List.count {
            let y: Double = Double(closePriceM5List[i])
            let index = i + 29
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "M30")
        self.configLineSets(set: set)
        set.setColor(lineBlueColor)
        set.fillColor = lineBlueColor
        return set
    }
    
    func getClosePriceList(days: Int) -> [CGFloat] {
        let dayValue = days - 1
        var closePriceList = [CGFloat]()
        var arr = _kLineModel?.data
        var i = arr!.count - 1
        while i >= dayValue && i >= 0 {
            var allClosePriceDouble: Double = 0.0
            var j = i - dayValue
            while j <= i {
                allClosePriceDouble += Double(arr![j].close!)!
                j += 1
            }
            closePriceList.insert(CGFloat(allClosePriceDouble/Double(days)), at: 0)
            i -= 1
        }
        return closePriceList
    }
    
    func configLineSets(set: LineChartDataSet) {
        set.lineWidth = 1.0
        set.highlightColor = UIColor.clear
        set.mode = .cubicBezier
        set.drawValuesEnabled = false
        set.axisDependency = .left
        set.drawCirclesEnabled = false
        set.setColor(UIColor(white: 80/255, alpha: 1))
        //        set.fillAlpha = 0.6
        //        set.drawFilledEnabled = true
    }
    
    func getMAAttr() -> NSMutableAttributedString {
        let ma5 = String(format: "MA5:%.2f", self.getM5Data().values.last?.y ?? 0.0)
        let ma10 = String(format: "MA10:%.2f", self.getM10Data().values.last?.y ?? 0.0)
        let ma30 = String(format: "MA30:%.2f", self.getM30Data().values.last?.y ?? 0.0)
        let string = "\(ma5)  \(ma10)  \(ma30)"
        let attr = NSMutableAttributedString.init(string: string)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineYellowColor], range: NSMakeRange(0, ma5.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineGreenColor], range: NSMakeRange(ma5.count + 2, ma10.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineBlueColor], range: NSMakeRange(attr.length - ma30.count, ma30.count))
        return attr
    }
}

// MARK: ----BOLL----
extension COINKLineView {
    
    func getLineBOLLData() -> LineChartData {
        if _kLineModel == nil {
            return LineChartData.init()
        }
        if self.kLineType == .MinuteLine {
            let set_M = self.getMData()
            let set_MB = self.getMBData()
            let set_UP = self.getUPData()
            let set_DN = self.getDNData()
            return LineChartData.init(dataSets: [set_M,set_MB,set_UP,set_DN])
        } else {
            let set_MB = self.getMBData()
            let set_UP = self.getUPData()
            let set_DN = self.getDNData()
            return LineChartData.init(dataSets: [set_MB,set_UP,set_DN])
        }
    }
    
    func getMBData() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var bollList = _kLineModel!.fetchDrawBOLLData()
        for i in 0..<bollList.count {
            let y: Double = bollList[i].BOLL_MB!
            let index = i + 19
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "MB")
        self.configLineSets(set: set)
        set.setColor(lineYellowColor)
        set.fillColor = lineYellowColor
        return set
    }
    func getUPData() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var bollList = _kLineModel!.fetchDrawBOLLData()
        for i in 0..<bollList.count {
            let y: Double = bollList[i].BOLL_UP!
            let index = i + 19
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "UP")
        self.configLineSets(set: set)
        set.setColor(lineGreenColor)
        set.fillColor = lineGreenColor
        return set
    }
    func getDNData() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var bollList = _kLineModel!.fetchDrawBOLLData()
        for i in 0..<bollList.count {
            let y: Double = bollList[i].BOLL_DN!
            let index = i + 19
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "DN")
        self.configLineSets(set: set)
        set.setColor(linePurpleColor)
        set.fillColor = linePurpleColor
        return set
    }
    
    func getBOLLAttr() -> NSMutableAttributedString {
        let mb = String(format: "MB:%.2f", self.getMBData().values.last?.y ?? 0.0)
        let up = String(format: "UP:%.2f", self.getUPData().values.last?.y ?? 0.0)
        let dn = String(format: "DN:%.2f", self.getDNData().values.last?.y ?? 0.0)
        let string = "\(mb)  \(up)  \(dn)"
        let attr = NSMutableAttributedString.init(string: string)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineYellowColor], range: NSMakeRange(0, mb.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineGreenColor], range: NSMakeRange(mb.count + 2, up.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: linePurpleColor], range: NSMakeRange(attr.length - dn.count, dn.count))
        return attr
    }
}
// MARK: ----成交量----
extension COINKLineView {
    func getBarData() -> BarChartData {
        let arr = _kLineModel?.data!
        var yVals = [BarChartDataEntry]()
        var colorList = [NSUIColor]()
        for i in 0..<arr!.count {
            let barChartDataEntry = BarChartDataEntry.init(x: Double(i), y: Double(arr![i].volume!)!, data: _kLineModel?.data![i])
            yVals.append(barChartDataEntry)
            if Double(arr![i].close!)! - Double(arr![i].open!)! >= 0 {
                colorList.append(COINUseHabitHelper.shared().bgRiseColor!)
            } else {
                colorList.append(COINUseHabitHelper.shared().bgDropColor!)
            }
        }
        let set = BarChartDataSet.init(values: yVals, label: nil)
        set.drawValuesEnabled = true
        set.setColors(colorList, alpha: 1.0)
        set.axisDependency = .right
        set.highlightColor = COINUseHabitHelper.shared().bgRiseColor!
        return BarChartData.init(dataSets: [set])
    }
    
    func getBarAttr() -> NSMutableAttributedString {
        let ma5 = String(format: "MA5:%.2f", self.getM5Data().values.last?.y ?? 0.0)
        let ma30 = String(format: "MA30:%.2f", self.getM30Data().values.last?.y ?? 0.0)
        let string = "成交量(7,30):  \(ma5)  \(ma30)"
        let attr = NSMutableAttributedString.init(string: string)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineYellowColor], range: NSMakeRange(attr.length - ma30.count - 2 - ma5.count, ma5.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineBlueColor], range: NSMakeRange(attr.length - ma30.count, ma30.count))
        return attr
    }
}
// MARK: ----MACD----
extension COINKLineView {
    func getLineMACDData() -> LineChartData? {
        if _kLineModel == nil {
            return LineChartData.init()
        }
        let set_DIF = self.getDIFData()
        let set_DEA = self.getDEAData()
        if set_DEA != nil && set_DIF != nil {
            return LineChartData.init(dataSets: [set_DIF!,set_DEA!])
        } else {
            return nil
        }
    }
    
    func getDIFData() -> LineChartDataSet? {
        var yVals = [ChartDataEntry]()
        var macdList = _kLineModel!.fetchDrawMACDData()
        for i in 0..<macdList.count {
            let y: Double = macdList[i].DIF!
            let index = i + 25
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        if yVals.count > 0 {
            let set = LineChartDataSet.init(values: yVals, label: "DIF")
            self.configLineSets(set: set)
            set.setColor(lineYellowColor)
            set.fillColor = lineYellowColor
            return set
        } else {
            return nil
        }
    }
    func getDEAData() -> LineChartDataSet? {
        var yVals = [ChartDataEntry]()
        var macdList = _kLineModel!.fetchDrawMACDData()
        for i in 0..<macdList.count {
            let y: Double = macdList[i].DEA!
            let index = i + 25
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        if yVals.count > 0 {
            let set = LineChartDataSet.init(values: yVals, label: "DEA")
            self.configLineSets(set: set)
            set.setColor(lineBlueColor)
            set.fillColor = lineBlueColor
            return set
        } else {
            return nil
        }
    }
    
    func getBarMACDData() -> BarChartData? {
        var macdList = _kLineModel!.fetchDrawMACDData()
        var yVals = [BarChartDataEntry]()
        var colorList = [NSUIColor]()
        for i in 0..<macdList.count {
            let index = i + 25
            let barChartDataEntry = BarChartDataEntry.init(x: Double(index), y: macdList[i].MACD!, data: _kLineModel?.data![index])
            yVals.append(barChartDataEntry)
            if macdList[i].MACD! >= 0 {
                colorList.append(COINUseHabitHelper.shared().bgRiseColor!)
            } else {
                colorList.append(COINUseHabitHelper.shared().bgDropColor!)
            }
        }
        if yVals.count > 0 {
            let set = BarChartDataSet.init(values: yVals, label: nil)
            set.drawValuesEnabled = true
            set.setColors(colorList, alpha: 1.0)
            set.axisDependency = .right
            set.highlightColor = COINUseHabitHelper.shared().bgRiseColor!
            return BarChartData.init(dataSets: [set])
        } else {
            return nil
        }
    }
    
    func getMACDAttr() -> NSMutableAttributedString {
        let dif = String(format: "DIF:%.2f", self.getDIFData()?.values.last?.y ?? 0.0)
        let dea = String(format: "DEA:%.2f", self.getDEAData()?.values.last?.y ?? 0.0)
        let stick = String(format: "STICK:%.2f", _kLineModel!.fetchDrawMACDData().last?.MACD ?? 0.0)
        let string = "MACD(12,26,9)  \(dif)  \(dea)  \(stick)"
        let attr = NSMutableAttributedString.init(string: string)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineYellowColor], range: NSMakeRange(attr.length - dif.count - 2 - stick.count - 2 - dea.count, dif.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineBlueColor], range: NSMakeRange(attr.length - stick.count - 2 - dea.count, dea.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineOrangeColor], range: NSMakeRange(attr.length - stick.count, stick.count))
        return attr
    }
}
// MARK: ----KDJ----
extension COINKLineView {
    func getLineKDJData() -> LineChartData {
        if _kLineModel == nil {
            return LineChartData.init()
        }
        let set_K = self.getKData()
        let set_D = self.getDData()
        let set_J = self.getJData()
        return LineChartData.init(dataSets: [set_K,set_D,set_J])
    }
    func getKData() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var kdjList = _kLineModel!.fetchDrawKDJData()
        for i in 0..<kdjList.count {
            let y: Double = kdjList[i].KDJ_K!
            let index = i
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "K")
        self.configLineSets(set: set)
        set.setColor(lineYellowColor)
        set.fillColor = lineYellowColor
        return set
    }
    func getDData() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var kdjList = _kLineModel!.fetchDrawKDJData()
        for i in 0..<kdjList.count {
            let y: Double = kdjList[i].KDJ_D!
            let index = i
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "D")
        self.configLineSets(set: set)
        set.setColor(lineBlueColor)
        set.fillColor = lineBlueColor
        return set
    }
    func getJData() -> LineChartDataSet {
        var yVals = [ChartDataEntry]()
        var kdjList = _kLineModel!.fetchDrawKDJData()
        for i in 0..<kdjList.count {
            let y: Double = kdjList[i].KDJ_J!
            let index = i
            let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
            yVals.append(contentsOf: dataEntry)
        }
        let set = LineChartDataSet.init(values: yVals, label: "J")
        self.configLineSets(set: set)
        set.setColor(lineOrangeColor)
        set.fillColor = lineOrangeColor
        return set
    }
    
    func getKDJAttr() -> NSMutableAttributedString {
        let k = String(format: "K:%.2f", self.getKData().values.last?.y ?? 0.0)
        let d = String(format: "D:%.2f", self.getDData().values.last?.y ?? 0.0)
        let j = String(format: "J:%.2f", self.getJData().values.last?.y ?? 0.0)
        let string = "KDJ(9,3,3)  \(k)  \(d)  \(j)"
        let attr = NSMutableAttributedString.init(string: string)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineYellowColor], range: NSMakeRange(attr.length - k.count - 2 - d.count - 2 - j.count, k.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineBlueColor], range: NSMakeRange(attr.length - j.count - 2 - d.count, d.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineOrangeColor], range: NSMakeRange(attr.length - j.count, j.count))
        return attr
    }
}
// MARK: ----RSI----
extension COINKLineView {
    func getLineRSIData() -> LineChartData? {
        if _kLineModel == nil {
            return LineChartData.init()
        }
        let set_RSI6 = self.getRSI6Data()
        let set_RSI12 = self.getRSI12Data()
        let set_RSI24 = self.getRSI24Data()
        if set_RSI6 != nil && set_RSI12 != nil && set_RSI24 != nil {
            return LineChartData.init(dataSets: [set_RSI6!,set_RSI12!,set_RSI24!])
        } else {
            return nil
        }
    }
    
    func getRSI6Data() -> LineChartDataSet? {
        var yVals = [ChartDataEntry]()
        var rsiList = _kLineModel!.fetchDrawRSIData()
        for i in 0..<rsiList.count {
            if fabs(rsiList[i].RSI6!) > 0.001 {
                let y: Double = rsiList[i].RSI6!
                let index = i
                let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
                yVals.append(contentsOf: dataEntry)
            }
        }
        if yVals.count > 0 {
            let set = LineChartDataSet.init(values: yVals, label: "RSI6")
            self.configLineSets(set: set)
            set.setColor(lineYellowColor)
            set.fillColor = lineYellowColor
            return set
        } else {
            return nil
        }
    }
    func getRSI12Data() -> LineChartDataSet? {
        var yVals = [ChartDataEntry]()
        var rsiList = _kLineModel!.fetchDrawKDJData()
        for i in 0..<rsiList.count {
            if fabs(rsiList[i].RSI12!) > 0.001 {
                let y: Double = rsiList[i].RSI12!
                let index = i
                let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
                yVals.append(contentsOf: dataEntry)
            }
        }
        if yVals.count > 0 {
            let set = LineChartDataSet.init(values: yVals, label: "RSI12")
            self.configLineSets(set: set)
            set.setColor(lineBlueColor)
            set.fillColor = lineBlueColor
            return set
        } else {
            return nil
        }
    }
    func getRSI24Data() -> LineChartDataSet? {
        var yVals = [ChartDataEntry]()
        var rsiList = _kLineModel!.fetchDrawKDJData()
        for i in 0..<rsiList.count {
            if fabs(rsiList[i].RSI24!) > 0.001 {
                let y: Double = rsiList[i].RSI24!
                let index = i
                let dataEntry = [ChartDataEntry.init(x: Double(index), y: y, data: _kLineModel?.data![index])]
                yVals.append(contentsOf: dataEntry)
            }
        }
        if yVals.count > 0 {
            let set = LineChartDataSet.init(values: yVals, label: "RSI24")
            self.configLineSets(set: set)
            set.setColor(lineOrangeColor)
            set.fillColor = lineOrangeColor
            return set
        } else {
            return nil
        }
    }
    
    func getRSIAttr() -> NSMutableAttributedString {
        let rsi6 = String(format: "RSI6:%.2f", self.getRSI6Data()?.values.last?.y ?? 0.0)
        let rsi12 = String(format: "RSI12:%.2f", self.getRSI12Data()?.values.last?.y ?? 0.0)
        let rsi24 = String(format: "RSI24:%.2f", self.getRSI24Data()?.values.last?.y ?? 0.0)
        let string = "RSI(6,12,24)  \(rsi6)  \(rsi12)  \(rsi24)"
        let attr = NSMutableAttributedString.init(string: string)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineYellowColor], range: NSMakeRange(attr.length - rsi6.count - 2 - rsi12.count - 2 - rsi24.count, rsi6.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineBlueColor], range: NSMakeRange(attr.length - rsi12.count - 2 - rsi24.count, rsi12.count))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: lineOrangeColor], range: NSMakeRange(attr.length - rsi24.count, rsi24.count))
        return attr
    }
}
