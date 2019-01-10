//
//  YCTCHTTPHeader.h
//  NSURLProtocolTest
//
//  Created by gm on 2018/6/11.
//  Copyright © 2018年 COIN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COINHTTPHeader : NSObject
+ (NSData *)getUUIDHeaderFrom:(NSData *)headerData;
+ (NSString *)getRemoteServerAndPort:(NSInteger *)port;
@end
