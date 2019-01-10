//
//  OrderManageView.swift
//  EXDemo
//
//  Created by dev6 on 2018/11/12.
//  Copyright © 2018 dev6. All rights reserved.
//

import UIKit

class COINOrderManageView: UIView, UIScrollViewDelegate {
    
    var platform: Platform?
    
    var changeIndexHandle: ((Int)->())?
    
    var changeOrderIndexHandle: ((Int)->())?
    
    var cancelHandle: ((COINOrderBookItemModel?)->())?
    
    var selectedIndex: Int{
        get {
            return _selectedIndex
        }
        set {
            self.changeView(newValue: newValue)
            _selectedIndex = newValue
        }
    }
    private var _selectedIndex = 0
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: self.bounds)
        scrollView.contentSize = CGSize.init(width: self.bounds.size.width * 3, height: self.bounds.size.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    lazy var exchanegView: COINExchangeView = {
        let exchanegView = COINExchangeView.init(frame: self.scrollView.bounds, platform: self.platform ?? .bitmex)
        exchanegView.cancelHandle = { orderModel in
            if self.cancelHandle != nil {
                self.cancelHandle!(orderModel)
            }
        }
        return exchanegView
    }()
    
    lazy var orderBookView: COINOrderBookView = {
        let orderBookView = COINOrderBookView.init(frame: CGRect.init(x: self.scrollView.bounds.size.width, y: 0, width: self.scrollView.bounds.size.width, height: self.scrollView.bounds.size.height), platform: self.platform ?? .bitmex)
        orderBookView.cancelHandle = { orderModel in
            if self.cancelHandle != nil {
                self.cancelHandle!(orderModel)
            }
        }
        orderBookView.changeOrderIndexHandle = { index in
            if self.changeOrderIndexHandle != nil {
                self.changeOrderIndexHandle!(index)
            }
        }
        return orderBookView
    }()
    
    lazy var positionView: COINPositionView = {
        let positionView = COINPositionView.init(frame: CGRect.init(x: self.scrollView.bounds.size.width * 2, y: 0, width: self.scrollView.bounds.size.width, height: self.scrollView.bounds.size.height), platform: self.platform ?? .bitmex)
        return positionView
    }()
    
    init(frame: CGRect, selectedIndex: Int, platform: Platform) {
        super.init(frame: frame)
        self.platform = platform
        self.addSubview(self.scrollView)
        self.selectedIndex = selectedIndex
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func changeView(newValue: Int) {
        if  self.selectedIndex == newValue && !(newValue == 0 && self.exchanegView.superview == nil) {
            return
        }
        switch newValue {
        case 0:
            if self.exchanegView.superview == nil {
                self.scrollView.addSubview(self.exchanegView)
            }
        case 1:
            if self.orderBookView.superview == nil {
                self.scrollView.addSubview(self.orderBookView)
            }
        case 2:
            if self.positionView.superview == nil {
                self.scrollView.addSubview(self.positionView)
            }
        default:
            break
        }
        self.scrollView.setContentOffset(CGPoint.init(x: self.scrollView.bounds.size.width * CGFloat(newValue), y: 0), animated: true)
    }
    
    // MARK: ----UIScrollViewDelegate----
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.selectedIndex = index
        if self.changeIndexHandle != nil {
            self.changeIndexHandle!(index)
        }
    }
}
