//
//  COINShareViewController.swift
//  Coin
//
//  Created by dev6 on 2018/12/27.
//  Copyright © 2018 COIN. All rights reserved.
//

import UIKit

class COINShareViewController: UIViewController {

    lazy var upImageView: UIImageView = {
        let upImageView = UIImageView()
        upImageView.image = UIImage.init(named: "mine_share_up")
        return upImageView
    }()
    
    lazy var qrcodeImageView: UIImageView = {
        let qrcodeImageView = UIImageView()
        qrcodeImageView.image = UIImage.init(named: "mine_share_qrcode")
        return qrcodeImageView
    }()
    
    lazy var downImageView: UIImageView = {
        let downImageView = UIImageView()
        downImageView.image = UIImage.init(named: "mine_share_down")
        return downImageView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        scrollView.contentSize = CGSize.init(width: screenWidth, height: 740)
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "分享应用"
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        scrollView.addSubview(upImageView)
        scrollView.addSubview(qrcodeImageView)
        scrollView.addSubview(downImageView)
        initSubViews()
        let rightItem = UIBarButtonItem.init(title: "分享", style: .plain, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func initSubViews(){
        let navH               = (self.navigationController?.navigationBar.frame.maxY ?? 0)!
        scrollView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(screenWidth)
            make.height.equalTo(screenHeight - navH)
        })
        
        upImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(screenWidth)
            make.height.equalTo(480)
        }
        
        qrcodeImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(upImageView.snp.centerX)
            make.top.equalTo(upImageView.snp.bottom).offset(40)
            make.width.equalTo(130)
            make.height.equalTo(130)
        }
        
        downImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(screenWidth)
            make.top.equalTo(qrcodeImageView.snp.bottom).offset(40)
            make.height.equalTo(50)
        }
    }
    @objc func share() {
        if let image = self.getShareImage() {
            let item: COINShareItem = COINShareItem.init(shareImage: image)
            let activity: UIActivityViewController = UIActivityViewController.init(activityItems: [item], applicationActivities: nil)
            activity.excludedActivityTypes = [.print,.postToFlickr,.assignToContact,.mail,.message,.addToReadingList,.postToVimeo,.openInIBooks,UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
            activity.isModalInPopover = true
            let popover = activity.popoverPresentationController
            if popover != nil {
                popover?.sourceView = self.view.superview
                popover?.permittedArrowDirections = .up
            }
            self.present(activity, animated: true, completion: nil)
            weak var weakSelf = self
            activity.completionWithItemsHandler = { (type,finish,items,error) in
                if finish {
                    if type?.rawValue.contains("Save") ?? false {
                        weakSelf?.view.makeToast("保存成功", duration: 2, position: .center)
                    } else {
                        weakSelf?.view.makeToast("分享成功", duration: 2, position: .center)
                    }
                } else if error != nil {
                    weakSelf?.view.makeToast("分享失败", duration: 2, position: .center)
                }
            }
        }
    }
    
    /// 生成分享图片
    ///
    /// - Returns: 分享图
    func getShareImage() -> UIImage? {
        let width = self.scrollView.contentSize.width
        let height = self.scrollView.contentSize.height
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        UIColor.white.set()
        context?.addRect(CGRect.init(x: 0, y: 0, width: width, height: height))
        context?.fillPath()
        
        self.upImageView.image?.draw(in: CGRect.init(x: 0, y: 0, width: width, height: 480))
        self.qrcodeImageView.image?.draw(in: CGRect.init(x: (width - 130)/2, y: 480 + 40, width: 130, height: 130))
        self.downImageView.image?.draw(in: CGRect.init(x: 0, y: 480 + 40 + 130 + 40, width: width, height: 50))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
