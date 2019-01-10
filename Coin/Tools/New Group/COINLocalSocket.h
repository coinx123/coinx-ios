//
//  COINLocalSocket.h
//  NSURLProtocolTest
//
//  Created by gm on 2018/6/8.
//  Copyright © 2018年 COIN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
@interface COINLocalSocket : NSObject
+ (instancetype)shareInstance;
- (void)disconnect;
- (void)createLocalSocket;
@property (nonatomic, strong) GCDAsyncSocket *localSocket;
@property (nonatomic, assign) NSInteger localPort;
@end
