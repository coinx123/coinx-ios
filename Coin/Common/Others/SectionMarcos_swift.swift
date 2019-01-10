//
//  SectionMarcos_swift.swift
//  WebBrowser
//
//  Created by dev6 on 2018/8/21.
//  Copyright © 2018年 钟武. All rights reserved.
//

import Foundation
import UIKit

//MARK: - 通用尺寸

//屏幕长宽
public let screenWidth: CGFloat = UIScreen.main.bounds.width
public let screenHeight: CGFloat = UIScreen.main.bounds.height
//view距离顶部状态栏、导航栏的距离
public let navAndStatusHeight: CGFloat = (UIApplication.shared.statusBarFrame.height+44)
public let statusHeight: CGFloat = UIApplication.shared.statusBarFrame.height

public let tabbarHeight: CGFloat = ((UIApplication.shared.statusBarFrame.height > 20) ? 83 : 49)

//MARK: - 通用字体
public let font10: UIFont = UIFont.systemFont(ofSize: 10)
public let font11: UIFont = UIFont.systemFont(ofSize: 11)
public let font12: UIFont = UIFont.systemFont(ofSize: 12)
public let font13: UIFont = UIFont.systemFont(ofSize: 13)
public let font14: UIFont = UIFont.systemFont(ofSize: 14)
public let font15: UIFont = UIFont.systemFont(ofSize: 15)
public let font16: UIFont = UIFont.systemFont(ofSize: 16)
public let font17: UIFont = UIFont.systemFont(ofSize: 17)
public let font18: UIFont = UIFont.systemFont(ofSize: 18)
public let font20: UIFont = UIFont.systemFont(ofSize: 20)
public let font25: UIFont = UIFont.systemFont(ofSize: 25)


public let fontBold10: UIFont = UIFont.boldSystemFont(ofSize: 10)
public let fontBold12: UIFont = UIFont.boldSystemFont(ofSize: 12)
public let fontBold13: UIFont = UIFont.boldSystemFont(ofSize: 13)
public let fontBold14: UIFont = UIFont.boldSystemFont(ofSize: 14)
public let fontBold15: UIFont = UIFont.boldSystemFont(ofSize: 15)
public let fontBold16: UIFont = UIFont.boldSystemFont(ofSize: 16)
public let fontBold17: UIFont = UIFont.boldSystemFont(ofSize: 17)
public let fontBold18: UIFont = UIFont.boldSystemFont(ofSize: 18)
public let fontBold20: UIFont = UIFont.boldSystemFont(ofSize: 20)
public let fontBold25: UIFont = UIFont.boldSystemFont(ofSize: 25)


//MARK: - 通用颜色
public let bgColor: UIColor = UIColor.colorRGB(0xf4f4f4)
public let bgBlueColor: UIColor = UIColor.colorRGB(0x4a94ed)
public let bgBlueColor_light: UIColor = UIColor.colorRGB(0x4b94ee)
public let bgRedColor: UIColor = UIColor.colorRGB(0xf54d5e)
public let bgGreenColor: UIColor = UIColor.colorRGB(0x2ab20a)

public let whiteColor: UIColor = UIColor.colorRGB(0xffffff)

public let titleBlackColor: UIColor = UIColor.colorRGB(0x2d2d2d)
public let titleGrayColor: UIColor = UIColor.colorRGB(0xa4a4a4)
public let titleGreenColor: UIColor = UIColor.colorRGB(0x34ae1f)
public let titleRedColor: UIColor = UIColor.colorRGB(0xf54d5e)
public let titleBlueColor: UIColor = UIColor.colorRGB(0x4a94ed)
public let titleBlueColor_Light: UIColor = UIColor.colorWithRGB(178, 193, 216)

public let lineBlueColor_Light: UIColor = UIColor.colorRGB(0xd0ddee)
public let lineBlueColor: UIColor = UIColor.colorRGB(0x5091ef)
public let lineGrayColor: UIColor = UIColor.colorRGB(0xdddddd)
public let lineGrayColor_deep: UIColor = UIColor.colorRGB(0xa4a4a4)
public let lineGreenColor: UIColor = UIColor.colorRGB(0x34ae1f)
public let linePurpleColor: UIColor = UIColor.purple
public let lineOrangeColor: UIColor = UIColor.orange
public let lineYellowColor: UIColor = UIColor.colorWithRGB(239.0, 204.0, 88.0)
