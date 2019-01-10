/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

extension UIView {
    /**
     * Takes a screenshot of the view with the given size.
     */
    func screenshot(_ size: CGSize, offset: CGPoint? = nil, quality: CGFloat = 1) -> UIImage? {
        assert(0...1 ~= quality)

        let offset = offset ?? .zero

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale * quality)
        drawHierarchy(in: CGRect(origin: offset, size: frame.size), afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    /**
     * Takes a screenshot of the view with the given aspect ratio.
     * An aspect ratio of 0 means capture the entire view.
     */
    func screenshot(_ aspectRatio: CGFloat = 0, offset: CGPoint? = nil, quality: CGFloat = 1) -> UIImage? {
        assert(aspectRatio >= 0)

        var size: CGSize
        if aspectRatio > 0 {
            size = CGSize()
            let viewAspectRatio = frame.width / frame.height
            if viewAspectRatio > aspectRatio {
                size.height = frame.height
                size.width = size.height * aspectRatio
            } else {
                size.width = frame.width
                size.height = size.width / aspectRatio
            }
        } else {
            size = frame.size
        }

        return screenshot(size, offset: offset, quality: quality)
    }

    /*
     * Performs a deep copy of the view. Does not copy constraints.
     */
    @objc func clone() -> UIView {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIView
    }

    /**
     * rounds the requested corners of a view with the provided radius
     */
    func addRoundedCorners(_ cornersToRound: UIRectCorner, cornerRadius: CGSize, color: UIColor) {
        let rect = bounds
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: cornersToRound, cornerRadii: cornerRadius)

        // Create the shape layer and set its path
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath

        let roundedLayer = CALayer()
        roundedLayer.backgroundColor = color.cgColor
        roundedLayer.frame = rect
        roundedLayer.mask = maskLayer

        layer.insertSublayer(roundedLayer, at: 0)
        backgroundColor = UIColor.clear
    }
    
    /**
     * rounds the requested corners of a view with the provided radius
     */
    func addRoundedCorners(_ cornersToRound: UIRectCorner, cornerRadius: CGSize) {
        let rect = bounds
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: cornersToRound, cornerRadii: cornerRadius)
        
        // Create the shape layer and set its path
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath
        
        layer.mask = maskLayer
    }

    /**
     This allows us to find the view in a current view hierarchy that is currently the first responder
     */
    static func findSubViewWithFirstResponder(_ view: UIView) -> UIView? {
        let subviews = view.subviews
        if subviews.count == 0 {
            return nil
        }
        for subview: UIView in subviews {
            if subview.isFirstResponder {
                return subview
            }
            return findSubViewWithFirstResponder(subview)
        }
        return nil
    }
    
    func addRounded(corners: UIRectCorner, radii: CGSize, borderWidth: CGFloat, borderColor: UIColor) {
        let rounded = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radii)
        rounded.lineWidth = borderWidth
        rounded.lineJoinStyle = .round
        borderColor.setStroke()
        rounded.stroke()
        let shape = CAShapeLayer.init()
        shape.path = rounded.cgPath
        self.layer.mask = shape
    }
    
    func viewController() -> UIViewController? {
        var view: UIView? = self
        while view != nil {
            view = view?.superview
            let nextResponder = view?.next
            if nextResponder?.isKind(of: UIViewController.self) ?? false {
                return (nextResponder as! UIViewController)
            }
        }
        return nil
    }
    /// 添加颜色渐变
    ///
    /// - Parameters:
    ///   - gradientColors: 颜色渐变数组
    ///   - gradientLocations: 颜色渐变的位置
    ///   - startPoint: 开始渐变点
    ///   - endPoint: 结束渐变点
    ///   - cornerRadius: 渐变颜色半径
    func addGradientColor( gradientColors: [CGColor], gradientLocations: [NSNumber], startPoint: CGPoint = CGPoint.init(x: 0, y: 0), endPoint: CGPoint = CGPoint.init(x: 0, y: 1), cornerRadius: CGFloat = 0)
    {
        //assert(gradientColors.count == gradientLocations.count, "颜色数组和颜色位置数组个数必须一致")
        let gradientColor = CAGradientLayer()
        gradientColor.frame = self.bounds
        gradientColor.colors    = gradientColors
        gradientColor.locations = gradientLocations
        gradientColor.startPoint = startPoint
        gradientColor.endPoint = endPoint
        gradientColor.cornerRadius = cornerRadius
        self.layer.addSublayer(gradientColor)
    }
}
