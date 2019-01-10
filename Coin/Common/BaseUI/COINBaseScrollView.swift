//
//  COINBaseScrollView.swift
//  Coin
//
//  Created by gm on 2018/12/19.
//  Copyright © 2018年 COIN. All rights reserved.
//

import UIKit

class COINBaseScrollView: UIView, UIScrollViewDelegate{
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init()
        self.addSubview(scrollView)
        return scrollView
    }()
    
    lazy var scrollSubviewArray = [UIView]()
    
    lazy var pageView: UIPageControl = {
        let pageView = UIPageControl()
        self.addSubview(pageView)
        return pageView
    }()
    var needPageView:Bool = false{
        didSet{
            if needPageView {
                let pageViewW: CGFloat = CGFloat(self.scrollSubviewArray.count * 5)
                let pageViewH: CGFloat      = 30
                let pageViewX      = (self.frame.width - pageViewW) * 0.5
                let pageViewY      = self.frame.height * 0.825
                self.pageView.frame = CGRect.init(x: pageViewX, y: pageViewY, width: pageViewW, height: pageViewH)
                self.pageView.numberOfPages = self.scrollSubviewArray.count
                self.pageView.currentPage   = 0
                self.scrollView.delegate    = self
                pageView.setValue(UIImage.init(named: "mine_page_sel"), forKey: "_currentPageImage")
                pageView.setValue(UIImage.init(named: "mine_page"), forKey: "_pageImage")
                pageView.hidesForSinglePage = true
                pageView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func scrollAddSubViews(subViews:[UIView], itemSize: CGSize,scrollViewFrame: CGRect = CGRect.zero, subViewMargin: Float = -1,needPageView: Bool = false){
        var scrollViewFrameTemp = self.bounds
        if scrollViewFrame != CGRect.zero{
            scrollViewFrameTemp = scrollViewFrame
        }
        
        self.scrollView.frame       = scrollViewFrameTemp
        self.scrollView.contentSize = scrollViewFrame.size
        self.scrollView.backgroundColor = UIColor.white
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.isPagingEnabled = true
        self.addSubview(self.scrollView)
        let imageViewX     = (self.frame.size.width - itemSize.width) * 0.5
        let imageViewY     = (self.frame.size.height - itemSize.height) * 0.5
        var itemFrameTemp  = CGRect.init(
            x: imageViewX,
            y: imageViewY,
            width: itemSize.width,
            height: itemSize.height
        )
        
        for subView in subViews{
            subView.frame = itemFrameTemp
            var margin = imageViewX
            if subViewMargin > 0 {
                margin = CGFloat(subViewMargin)
            }
            
            let itemFrameTempX = margin + itemFrameTemp.maxX
            itemFrameTemp = CGRect.init(x: itemFrameTempX, y: imageViewY, width: itemSize.width, height: itemSize.height)
            scrollViewAddSubView(scrollSubView: subView)
        }
        
        self.needPageView = needPageView
    }
    
    func scrollViewAddSubView(scrollSubView: UIView){
        self.scrollView.addSubview(scrollSubView)
        self.scrollSubviewArray.append(scrollSubView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x/300)
        self.pageView.currentPage = page
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
