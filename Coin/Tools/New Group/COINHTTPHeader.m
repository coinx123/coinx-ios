//
//  COINHTTPHeader.m
//  NSURLProtocolTest
//
//  Created by gm on 2018/6/11.
//  Copyright © 2018年 COIN. All rights reserved.
//

#import "COINHTTPHeader.h"
@implementation COINHTTPHeader
+ (NSData *)getUUIDHeaderFrom:(NSData *)headerData{
    NSString *headStr = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding];
    headStr = [headStr stringByReplacingOccurrencesOfString:@"Host: testnet.bitmex.com" withString:@"Host: 54.246.160.60"];
    return  [headStr dataUsingEncoding:NSUTF8StringEncoding];
}


+ (NSString *)getRemoteServerAndPort:(NSInteger *)port{
    *port                     = 28090;
    return @"www0.qqweb0.com";
}
@end
