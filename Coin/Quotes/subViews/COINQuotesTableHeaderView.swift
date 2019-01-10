//
//  COINQuotesTableHeaderView.swift
//  Coin
//
//  Created by gm on 2018/12/26.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit
private struct QuotesViewControllerStruct{
    static let screanW    = UIScreen.main.bounds.size.width
    static let hSpacing: CGFloat             = 20.0
    static let vSpacing: CGFloat             = 10.0
    static let imageViewH: CGFloat =  160
    static let imageViewW: CGFloat = screanW
    //CycleView
    static let cycleViewImageArrays = [
        UIImage.init(named: "banner_00"),
        UIImage.init(named: "banner_01"),
        UIImage.init(named: "banner_02")
    ]
    
    //scrollVew
    static let scrollVewH: CGFloat = 114
    static let scrollVewW: CGFloat = screanW
    static let cardW: CGFloat      = 160
    static let cardH: CGFloat      = 100
    static let cardNum: Int      = 3
    static let cardColors = [
        UIColor.clear,
        UIColor.clear,
        UIColor.clear
    ]
    
    //gainView
    static let gainViewH: CGFloat      = 157
    
}
typealias CardViewClickCallBack = (_ cardView: COINCardView) -> ()
typealias GainViewClickCallBack = (_ isBitMex: Bool) -> ()
class COINQuotesTableHeaderView: UIView, ZCycleViewProtocol {
    
    var cardViewCallBack: CardViewClickCallBack?
    
    var gainViewCallBack: GainViewClickCallBack?
    
    var isBitMex: Bool = true
    
    private lazy var cycleView: ZCycleView = {
        let imageViewH = UIApplication.shared.statusBarFrame.size.height + QuotesViewControllerStruct.imageViewH
        let frame      = CGRect.init(
            x: 0,
            y: 0,
            width: QuotesViewControllerStruct.imageViewW,
            height: imageViewH
        )
        
        let cycleView =  ZCycleView.init(frame: frame)
        let imageArray = QuotesViewControllerStruct.cycleViewImageArrays
        cycleView.setImagesGroup(imageArray)
        cycleView.isInfinite = imageArray.count > 1 ? true : false
        cycleView.pageControlIndictirColor = UIColor.colorRGB(0xdbeafc)
        cycleView.pageControlItemSize      = CGSize.init(width: 5, height: 5)
        cycleView.pageControlCurrentIndictirColor = UIColor.colorRGB(0x4b94ee)
        cycleView.delegate = self
        return cycleView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollViewY: CGFloat = self.cycleView.frame.maxY
        let scrollView =  UIScrollView.init(frame: CGRect.init(
            x: 0,
            y: scrollViewY,
            width: QuotesViewControllerStruct.scrollVewW,
            height: QuotesViewControllerStruct.scrollVewH
        ))
        
        var contentSizeX = (QuotesViewControllerStruct.hSpacing + QuotesViewControllerStruct.cardW) * CGFloat(QuotesViewControllerStruct.cardNum) +  QuotesViewControllerStruct.hSpacing
        if contentSizeX  < QuotesViewControllerStruct.scrollVewW {
            contentSizeX = QuotesViewControllerStruct.scrollVewW
        }
        
        scrollView.contentSize = CGSize.init(width: contentSizeX, height: QuotesViewControllerStruct.scrollVewH)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator   = false
        scrollView.backgroundColor                = UIColor.white
        let cardY = (QuotesViewControllerStruct.scrollVewH - QuotesViewControllerStruct.cardH)
        // MARK: 添加卡片
        weak var weakSelf = self
        for index in 0...(QuotesViewControllerStruct.cardNum - 1) {
            let cardX = QuotesViewControllerStruct.hSpacing + (QuotesViewControllerStruct.cardW + 10) * CGFloat(index)
            let coinCard: COINCardView = COINCardView.init(frame: CGRect.init(
                x: cardX,
                y: cardY,
                width: QuotesViewControllerStruct.cardW,
                height: QuotesViewControllerStruct.cardH
            ))
            
            coinCard.tag = index
            //cardView 点击事件
            coinCard.callBack = { cardView in
                if ((weakSelf?.cardViewCallBack) != nil) {
                    weakSelf?.cardViewCallBack!(cardView)
                }
            }
            
            coinCard.tag = index + 1
            coinCard.backgroundColor = QuotesViewControllerStruct.cardColors[index]
            scrollView.addSubview(coinCard)
        }
        
        return scrollView
    }()
    
    private lazy var gainView: COINGainView = {
        let gainView = COINGainView.init(frame: CGRect.init(
            x: 0,
            y: self.scrollView.frame.maxY,
            width: QuotesViewControllerStruct.screanW,
            height: QuotesViewControllerStruct.gainViewH
        ))
        
        return gainView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(cycleView)
        self.addSubview(scrollView)
        self.addSubview(gainView)
        self.frame = CGRect.init(
            x: 0,
            y: 0,
            width: QuotesViewControllerStruct.screanW,
            height: gainView.frame.maxY
        )
        
        addCallBack()
    }
    
    
    func addCallBack(){
        weak var weakSelf = self
        gainView.callBack = { (bitxBtn,okexBtn) in
            weakSelf?.isBitMex = bitxBtn.isSelected
            if ((weakSelf?.gainViewCallBack) != nil) {
                weakSelf?.gainViewCallBack!(bitxBtn.isSelected)
            }
        }
    }
    
    func getCardView(_ index: Int) -> COINCardView {
       let card: COINCardView = self.scrollView.viewWithTag(index + 1) as! COINCardView
        return card
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK:cycleView delegate
extension COINQuotesTableHeaderView{
    
    func cycleViewDidScrollToIndex(_ index: Int) {
        
    }
    
    func cycleViewDidSelectedIndex(_ index: Int) {
        
    }

}
