//
//  COINLabel.h
//  Coin
//
//  Created by gm on 2018/11/8.
//  Copyright © 2018年 COIN. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    VerticalAlignmentMiddle = 0, // default
    VerticalAlignmentTop,
    VerticalAlignmentBottom,
} VerticalAlignment;

NS_ASSUME_NONNULL_BEGIN

@interface COINLabel : UILabel
@property (nonatomic) VerticalAlignment verticalAlignment;
@end

NS_ASSUME_NONNULL_END
