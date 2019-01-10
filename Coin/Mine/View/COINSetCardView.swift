//
//  COINSetCardView.swift
//  Coin
//
//  Created by gm on 2018/11/26.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINSettingCardViewModel: NSObject {
    
    var iconName: String?
    var coinName: String?
    var isSecret: Bool = false
    ///渐变颜色数组
    var gradientColors: [CGColor]?
    var isBinding: Bool = false
    var secondIconName: String?
    var platform: Platform = .bitmex
    class func getCardViewModelArray() -> Array<COINSettingCardViewModel> {
        
        let item1 = COINSettingCardViewModel()
        item1.platform = .bitmex
        item1.iconName = "mine_bitmex"
        item1.secondIconName = "mine_bitmex"
        item1.coinName = "BITMEX"
        item1.gradientColors  = [UIColor.colorRGB(0x3b4551).cgColor,
                                 UIColor.colorRGB(0x2a3034).cgColor]
       
        let item2 = COINSettingCardViewModel()
        item2.platform = .okex
        item2.iconName = "mine_okex_1"
        item2.secondIconName = "mine_okex_1"
        item2.coinName = "OKEX"
        item2.gradientColors = [UIColor.colorRGB(0xf85366).cgColor,
                                UIColor.colorRGB(0xe43f4e).cgColor]
        
        return [item1,item2]
    }
}

private struct SetCardViewStruct {
    static let  hSpacing: CGFloat             = 20.0
    static let  hMargin: CGFloat              = 10.0
    static let  vSpacing: CGFloat             = 10.0
    
    //iconImage
    static let  iconImageH: CGFloat             = 30
    static let  iconImageW: CGFloat             = 30
    
    //coinNameLabel
    static let  coinNameLabelH: CGFloat             = 30
    static let  coinNameLabelW: CGFloat             = 100
    
    //bindBtn
    static let  bindBtnH: CGFloat             = 25
    static let  bindBtnW: CGFloat             = 60
    
    //tipsLabel
    static let  tipsLabelH: CGFloat             = 30
    static let  tipsLabelW: CGFloat             = 80
    
    //valueLabel
    static let  valueLabelH: CGFloat             = 30
    static let  valueLabelW: CGFloat             = 150
    
    //btcValueLabel
    static let  btcValueLabelH: CGFloat           = 30
    static let  btcValueLabelW: CGFloat           = 100
    
    //detailBtn
    static let detailBtnH: CGFloat             = 30
    static let detailBtnW: CGFloat             = 80
    
    //secretBtn
    static let secretBtnH: CGFloat             = 30
    static let secretBtnW: CGFloat             = 30
    //半径
    static let cornerRadius: CGFloat           = 10
    
    static let secretStr: String = "****"
}
typealias COINSetCardViewCallBack = (_ isJumpBtn:Bool,_ cardView: COINSetCardView) -> ()

class COINSetCardViewModel: COINBaseModel {
    
    /// 权益保证金
    var maintMargin: Float = 0.0
    /// 钱包余额
    var walletBalance: Float = 0.0
    ///可用余额
    var avilableMargin: Float = 0.0
    /// 法币
    var legalCurrency: Float = -1
    /// 处理ok数据
    lazy var accountModelArray = [COINAccountsItemModel_ok]()
}
class COINSetCardView: UIView {
   
    var callBack: COINSetCardViewCallBack?
    
    lazy var bgImageViewUp: UIImageView = {
        let bgImageViewUp = UIImageView()
        bgImageViewUp.image = UIImage.init(named: "mine_bg_up")
        return bgImageViewUp
    }()
    
    lazy var bgImageViewDown: UIImageView = {
        let bgImageViewDown = UIImageView()
        bgImageViewDown.image = UIImage.init(named: "mine_bg_down")
        //bgImageViewDown.backgroundColor = UIColor.red
        return bgImageViewDown
    }()
    
    lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.backgroundColor = UIColor.white
        iconImageView.contentMode = .center
        return iconImageView
    }()
    
    lazy var coinNameLabel: UILabel = {
        let coinNameLabel = UILabel()
        coinNameLabel.text = "Bitmex"
        coinNameLabel.textColor = UIColor.white
        return coinNameLabel
    }()
    
    lazy var bindingBtn: UIButton = {
        let bindingBtn = UIButton()
        bindingBtn.backgroundColor = UIColor.white
        bindingBtn.addTarget(self, action: #selector(bindBtnClick), for: .touchUpInside)
        return bindingBtn
    }()
    
    lazy var secretBtn: UIButton = {
        let secretBtn = UIButton()
        secretBtn.imageView?.contentMode = .right
        secretBtn.setImage(UIImage.init(named: "mine_ secret"), for: .normal)
        secretBtn.setImage(UIImage.init(named: "mine_ secret_sel"), for: .selected)
        secretBtn.addTarget(self, action: #selector(secretBtnClick(secretBtn:)), for: .touchUpInside)
        return secretBtn
    }()
    
    lazy var detailBtn: UIButton = {
        let detailBtn = UIButton()
        var attributeStrM = NSMutableAttributedString.init()
        let titleStr = NSAttributedString.init(string: "去持仓看看  ", attributes: [
            NSAttributedString.Key.font : font12,
            NSAttributedString.Key.foregroundColor : UIColor.white
            ])
        let arrowStr = NSAttributedString.init(string: ">", attributes: [
            NSAttributedString.Key.font : font18,
            NSAttributedString.Key.foregroundColor : UIColor.white
            ])
        attributeStrM.append(titleStr)
        attributeStrM.append(arrowStr)
        detailBtn.setAttributedTitle(attributeStrM, for: .normal)
        detailBtn.addTarget(self, action: #selector(jumpBtnClick), for: .touchUpInside)
        
        return detailBtn
    }()
    
    lazy var tipsLabel: UILabel = {
        let tipsLabel = UILabel()
        tipsLabel.text = "资产估值"
        tipsLabel.textColor = UIColor.white
        tipsLabel.font = font12
        return tipsLabel
    }()
    
    lazy var btcValueLabel: UILabel = {
        let btcValueLabel = UILabel()
        btcValueLabel.text = ""
        btcValueLabel.textColor = UIColor.white
        btcValueLabel.font = font12
        btcValueLabel.textAlignment = .center
        return btcValueLabel
    }()
    
    var btcValueStr: String = ""{
        didSet{
            if !self.secretBtn.isSelected {
                self.btcValueLabel.text = btcValueStr
            }
        }
    }
    
  private  lazy var valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.text = "5000"
        valueLabel.font = font15
        valueLabel.textColor = UIColor.white
        return valueLabel
    }()
    
    var valueStr: String = ""{
        didSet{
            if !self.secretBtn.isSelected {
                self.valueLabel.text = valueStr
            }
        }
    }
    
    var isBinding: Bool? {
        didSet{
            if self.isFirstCardView {
                self.bindingBtn.isHidden = isBinding!
                self.tipsLabel.isHidden  = !isBinding!
                self.valueLabel.isHidden = !isBinding!
                self.secretBtn.isHidden  = !isBinding!
                self.detailBtn.isHidden  = !isBinding!
            }
        }
    }
    
    var model: COINSettingCardViewModel
    
    var  isFirstCardView: Bool
    
    init(frame: CGRect,isFirstCardView: Bool, model: COINSettingCardViewModel) {
        self.model = model
        self.isFirstCardView = isFirstCardView
        super.init(frame: frame)
        addGradientColor()
        if self.isFirstCardView{
            initFirstCardView()
        }else{
            initSecondCardView()
        }
        
        self.addSubview(self.bgImageViewDown)
        self.addSubview(self.bgImageViewUp)
        self.layer.cornerRadius  = SetCardViewStruct.cornerRadius
        initSubViews()
        addNoti()
    }
    
    func addGradientColor(){
        self.addGradientColor(gradientColors: model.gradientColors!, gradientLocations: [(0),(1)], startPoint: CGPoint.zero, endPoint: CGPoint.init(x: 0, y: 1), cornerRadius: SetCardViewStruct.cornerRadius)
    }
    
    func initSubViews(){
        self.iconImageView.image = UIImage.init(named: (model.iconName)!)
        self.coinNameLabel.text  = model.coinName
        self.layer.shadowColor   = model.gradientColors?.last
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset  = CGSize(width: -1, height: 4)
        self.layer.shadowRadius  = 5
        let attributeStrM        = NSMutableAttributedString.init()
        let color: UIColor       = UIColor.init(cgColor: (model.gradientColors?.last)!)
        let titleStr = NSAttributedString.init(
            string: "+",
            attributes: [
                NSAttributedString.Key.font : font18,
                NSAttributedString.Key.foregroundColor : color
            ]
        )
        
        let arrowStr = NSAttributedString.init(
            string: " 绑定",
            attributes: [NSAttributedString.Key.font : font12,
                         NSAttributedString.Key.foregroundColor : color
            ]
        )
        
        attributeStrM.append(titleStr)
        attributeStrM.append(arrowStr)
        self.bindingBtn.setAttributedTitle(attributeStrM, for: .normal)
        secretNoti()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let hSpacing = SetCardViewStruct.hSpacing
        bgImageViewUp.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.width.equalTo(131)
            maker.height.equalTo(95.5)
        }
        
        bgImageViewDown.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview()
            maker.right.equalToSuperview()
            maker.width.equalTo(97.5)
            maker.height.equalTo(125)
        }
        
        secretBtn.snp.makeConstraints { (maker) in
            maker.top.equalTo(SetCardViewStruct.vSpacing)
            maker.right.equalTo(hSpacing * -1)
            maker.width.equalTo(SetCardViewStruct.secretBtnW)
            maker.height.equalTo(SetCardViewStruct.secretBtnH)
        }
        
        if self.isFirstCardView {
            layoutFirstCardView()
        }else{
           layoutSecondCardView()
        }
        
    }
    
    
    
    var cardViewModel: COINSetCardViewModel?{
        
        didSet{
            if cardViewModel?.platformType == .okex {
                self.valueStr = cardViewModel?.walletBalance.fourDecimalPlacesWithUnits(btcStr: "BTC") ?? ""
            }else{
                self.valueStr = cardViewModel?.walletBalance.fourDecimalPlacesWithUnits() ?? ""
            }
            
            if cardViewModel?.legalCurrency ?? -1 < Float(0.0) {
                self.btcValueLabel.isHidden = true
            }else{
               self.btcValueLabel.isHidden = false
               self.btcValueStr = approximatelyEqualToTheUSD()
            }
            
        }
        
    }
    
    func approximatelyEqualToTheUSD()->String{
        let legalCurrency = (cardViewModel?.legalCurrency)! / 100000000
        return String.init(format: "≈%.2f USD", legalCurrency)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension COINSetCardView {
    
    //MARK: 隐藏按钮点击事件 发出更改隐藏状态通知
    @objc func secretBtnClick(secretBtn:UIButton){
        secretBtn.isSelected = !secretBtn.isSelected
        secretBtnStateChange(secretBtn.isSelected)
        COINUserDefaultsHelper.saveBoolValue(value: secretBtn.isSelected, forKey: UserDefaultsHelperKey.ud_secret_key)
        NotificationCenter.default.post(name: COINNotificationKeys.secretNoti, object: nil)
    }
    
    func secretBtnStateChange(_ isSelected: Bool){
        if isSelected {
            self.valueLabel.text = SetCardViewStruct.secretStr
            self.btcValueLabel.text = SetCardViewStruct.secretStr
        }else{
            self.valueLabel.text = valueStr
            self.btcValueLabel.text = btcValueStr
        }
    }
    
    @objc func jumpBtnClick(){
        if (self.callBack != nil) {
            self.callBack!(true,self)
        }
    }
    
    @objc func bindBtnClick(){
        if (self.callBack != nil) {
            self.callBack!(false,self)
        }
    }
}
//MARK: 次页的cardView
extension COINSetCardView {
    
    func initSecondCardView(){
        self.addSubview(self.secretBtn)
        self.addSubview(self.tipsLabel)
        self.addSubview(self.valueLabel)
        self.addSubview(self.btcValueLabel)
        valueLabel.font = font20
        valueLabel.textAlignment = .center
        tipsLabel.textAlignment  = .center
    }
    
    func layoutSecondCardView(){
        valueLabel.snp.makeConstraints { (maker) in
            maker.center.equalTo(self.snp.center)
            maker.width.equalTo(SetCardViewStruct.valueLabelW)
            maker.height.equalTo(SetCardViewStruct.valueLabelH)
        }
        
        tipsLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(valueLabel.snp.centerX)
            maker.bottom.equalTo(valueLabel.snp.top).offset(5)
            maker.width.equalTo(SetCardViewStruct.tipsLabelW)
            maker.height.equalTo(SetCardViewStruct.tipsLabelH)
        }
        
        btcValueLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(valueLabel.snp.centerX)
            maker.top.equalTo(valueLabel.snp.bottom).offset(-10)
            maker.width.equalTo(SetCardViewStruct.btcValueLabelW)
            maker.height.equalTo(SetCardViewStruct.btcValueLabelH)
        }
        
    }
}

//MARK: 首页的cardView
extension COINSetCardView {
    
    func initFirstCardView(){
        self.addSubview(self.iconImageView)
        self.addSubview(self.coinNameLabel)
        self.addSubview(self.bindingBtn)
        self.addSubview(self.secretBtn)
        self.addSubview(self.detailBtn)
        self.addSubview(self.tipsLabel)
        self.addSubview(self.valueLabel)
    }
    
    func layoutFirstCardView(){
        let hSpacing = SetCardViewStruct.hSpacing
        iconImageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(hSpacing)
            maker.top.equalTo(SetCardViewStruct.vSpacing)
            maker.width.equalTo(SetCardViewStruct.iconImageW)
            maker.height.equalTo(SetCardViewStruct.iconImageH)
        }
        
        coinNameLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(iconImageView.snp.centerY)
            maker.width.equalTo(SetCardViewStruct.coinNameLabelW)
            maker.height.equalTo(SetCardViewStruct.coinNameLabelH)
            maker.left.equalTo(iconImageView.snp.right)
                .offset(SetCardViewStruct.hMargin)
            
        }
        
        bindingBtn.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(SetCardViewStruct.vSpacing * -1)
            maker.width.equalTo(SetCardViewStruct.bindBtnW)
            maker.height.equalTo(SetCardViewStruct.bindBtnH)
            maker.right.equalTo(self.snp.right).offset(hSpacing * -1)
        }
        
        tipsLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(iconImageView.snp.left)
            maker.width.equalTo(SetCardViewStruct.tipsLabelW)
            maker.height.equalTo(SetCardViewStruct.tipsLabelH)
            maker.top.equalTo(iconImageView.snp.bottom).offset(hSpacing)
        }
        
        valueLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(iconImageView.snp.left)
            maker.width.equalTo(SetCardViewStruct.valueLabelW)
            maker.height.equalTo(SetCardViewStruct.valueLabelH)
            maker.top.equalTo(tipsLabel.snp.bottom).offset(-10)
        }
        
        detailBtn.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.snp.right).offset(hSpacing * -1)
            maker.centerY.equalTo(valueLabel.snp.centerY)
            maker.width.equalTo(SetCardViewStruct.detailBtnW)
            maker.height.equalTo(SetCardViewStruct.detailBtnH)
        }
        
        self.layoutIfNeeded()
        iconImageView.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: SetCardViewStruct.iconImageW * 0.5, height: SetCardViewStruct.iconImageW * 0.5))
        bindingBtn.addRoundedCorners(.allCorners, cornerRadius: CGSize.init(width: SetCardViewStruct.bindBtnH * 0.5, height: SetCardViewStruct.bindBtnH * 0.5))
        
    }
    
}

//MARK: 监听隐藏通知 因为需要控制所有的卡片金钱数目的隐藏状态
extension COINSetCardView {
    
    func addNoti(){
        NotificationCenter.default.addObserver(self, selector: #selector(secretNoti), name: COINNotificationKeys.secretNoti, object: nil)
    }
    
    @objc func secretNoti(){
        self.secretBtn.isSelected = COINUserDefaultsHelper.getBoolValue(forKey: UserDefaultsHelperKey.ud_secret_key)
        secretBtnStateChange(self.secretBtn.isSelected)
    }
}
