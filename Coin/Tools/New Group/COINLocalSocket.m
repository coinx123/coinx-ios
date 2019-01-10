//
//  COINLocalSocket.m
//  NSURLProtocolTest
//
//  Created by gm on 2018/6/8.
//  Copyright © 2018年 COIN. All rights reserved.
//

#import "COINLocalSocket.h"
#import "COINHTTPHeader.h"
static NSString *Local_Host_Servier = @"127.0.0.1";
@class COINLocalSocketData;

typedef NS_ENUM(NSInteger,SOCKETEvent){
    SOCKETEventConnectRemote,
    SOCKETEventLocalRead,
    SOCKETEventLocalWrite,
    SOCKETEventRemoteRead,
    SOCKETEventRemoteWrite
} ;

typedef void (^ COINLocalSocketCallBack)(COINLocalSocketData *socketData,GCDAsyncSocket *socket);

static COINLocalSocket *_localSocketTool = nil;


/**
 处理socket数据
 */
@interface COINLocalSocketData:NSObject
@property (nonatomic, strong) GCDAsyncSocket *localSocket;
@property (nonatomic, strong) GCDAsyncSocket *remoteSocket;
@property (nonatomic, strong) NSData         *requestData;
@end
@implementation COINLocalSocketData

@end

@interface COINLocalSocket ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableArray  *socketDatas;
@property (nonatomic, strong) NSMutableArray *remoteSockets;
@end

@implementation COINLocalSocket

+(instancetype)shareInstance{
    
    if (!_localSocketTool) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _localSocketTool = [[self alloc] init];
            
        });
    }
    
    return _localSocketTool;
}
- (NSMutableArray *)remoteSockets{
    if (!_remoteSockets) {
        _remoteSockets = [[NSMutableArray alloc] init];
    }
    return _remoteSockets;
}
- (dispatch_queue_t)queue{
    if (!_queue) {
        _queue = dispatch_queue_create("queue.socket", DISPATCH_QUEUE_CONCURRENT);
    }
    return _queue;
}

- (void)createLocalSocket{
    
    NSInteger localPort   = self.localPort;
    self.localSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue socketQueue:self.queue];
    self.localSocket.IPv4PreferredOverIPv6 = YES;
    NSError *error = nil;
    while (true) {
        BOOL isSuccess =  [self.localSocket acceptOnInterface:Local_Host_Servier port:localPort error:&error];
        
        if (isSuccess) {
            Local_Host_Servier = self.localSocket.localHost;
            self.localPort     = localPort;
            break;
        }else{
            localPort += 1;
            if (localPort > 10000) {
                localPort = 8887;
            }
        }
        
        if (error) {
            ////NSLog(@"creat local error %@",error);
        }
    }
    
    
}


- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    
    NSLog(@"收到newsocket %@",newSocket);
    
    if (!_socketDatas) {
        _socketDatas = [[NSMutableArray alloc] init];
    }
    COINLocalSocketData *socketData = [[COINLocalSocketData alloc] init];
    socketData.localSocket = newSocket;
    
    [_socketDatas addObject:socketData];
    
    [newSocket readDataWithTimeout:-1 tag:SOCKETEventConnectRemote];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    //YCTCLocalSocketData *socketData = [self socketDataOfRemoteSocket:sock];
    [sock startTLS:@{@"GCDAsyncSocketManuallyEvaluateTrust":@(1)}];
    
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    COINLocalSocketData *socketData =
    [self socketDatasOfLocalSocket:sock] ?: [self socketDataOfRemoteSocket:sock];
    if (!socketData) {
        return;
    }
    
    if (data.length < 1) {
        ////NSLog(@"没有data");
        return;
    }
    
    [self messageTips:tag];
    switch (tag) {
        case SOCKETEventConnectRemote:
        {
            NSInteger port         = 0;
            NSString *remoteServer = [COINHTTPHeader getRemoteServerAndPort:&port];
            socketData.requestData     = [COINHTTPHeader getUUIDHeaderFrom:data];
            if (self.remoteSockets.count > 0) {
                GCDAsyncSocket *prepareSocket = [self.remoteSockets firstObject];
                if (prepareSocket.isSecure) {
                    NSLog(@"缓存remotesocket");
                    NSMutableArray *arraymTemp = self.remoteSockets.mutableCopy;
                    [arraymTemp removeObject:prepareSocket];
                    self.remoteSockets = arraymTemp;
                    socketData.remoteSocket = prepareSocket;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), self.queue, ^{
                        NSLog(@"缓存我开始加速了哦");
                        [socketData.remoteSocket writeData:socketData.requestData withTimeout:-1 tag:SOCKETEventRemoteRead];
                        
                    });
                }else{
                    GCDAsyncSocket *remoteSocket = [self createRemoteSocket];
                    socketData.remoteSocket = remoteSocket;
                    [remoteSocket connectToHost:remoteServer onPort:port error:nil];
                }
                [self parpareRemoteSockets:remoteServer port:port];
            }else{
                GCDAsyncSocket *remoteSocket = [self createRemoteSocket];
                socketData.remoteSocket = remoteSocket;
                [remoteSocket connectToHost:remoteServer onPort:port error:nil];
                [self parpareRemoteSockets:remoteServer port:port];
            }
            
        }
            break;
        case SOCKETEventLocalRead:
            
            break;
        case SOCKETEventLocalWrite:
            [socketData.localSocket writeData:data withTimeout:-1 tag:SOCKETEventLocalRead];
            [socketData.remoteSocket readDataWithTimeout:-1 tag:(long)SOCKETEventLocalWrite];
            break;
        case SOCKETEventRemoteRead:
            
            break;
        case SOCKETEventRemoteWrite:
            ////NSLog(@"remoteWriteDate %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            [socketData.remoteSocket writeData:data withTimeout:-1 tag:SOCKETEventRemoteRead];
            [socketData.localSocket readDataWithTimeout:-1 tag:(long)SOCKETEventRemoteWrite];
            break;
        default:
            break;
    }
}

- (void)parpareRemoteSockets:(NSString *)remoteServer port:(NSInteger)port{
    static NSLock *remoteLock = nil;
    if (!remoteLock) {
        remoteLock = [[NSLock alloc] init];
    }
    
    [remoteLock lock];
    for (NSInteger index =  self.remoteSockets.count;index < 1;index ++){
        GCDAsyncSocket *remoteSocket = [self createRemoteSocket];
        [self.remoteSockets addObject:remoteSocket];
        [remoteSocket connectToHost:remoteServer onPort:port error:nil];
    }
    
    [remoteLock unlock];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    if ([self.remoteSockets containsObject:sock]) {
        NSMutableArray *tempArray = self.remoteSockets.mutableCopy;
        [tempArray  removeObject:sock];
        self.remoteSockets = tempArray;
        return;
    }
    
    COINLocalSocketData *socket = [self socketDatasOfLocalSocket:sock] ?: [self socketDataOfRemoteSocket:sock];
    if ([self.socketDatas containsObject:socket]) {
        NSMutableArray *tempArrayM = self.socketDatas.mutableCopy;
        [socket.remoteSocket disconnect];
        [socket.localSocket disconnect];
        [tempArrayM removeObject:socket];
        self.socketDatas = tempArrayM;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    COINLocalSocketData *socketData =
    [self socketDatasOfLocalSocket:sock] ?: [self socketDataOfRemoteSocket:sock];
    if (!socketData) {
        return;
    }
    
    [self messageTips:tag];
    switch (tag) {
        case SOCKETEventLocalRead:
            [socketData.localSocket readDataWithTimeout:-1 tag:SOCKETEventRemoteWrite];
            break;
        case SOCKETEventLocalWrite:
            
            break;
        case SOCKETEventRemoteRead:
            [socketData.remoteSocket readDataWithTimeout:-1 tag:SOCKETEventLocalWrite];
            break;
        case SOCKETEventRemoteWrite:
            
            break;
        default:
            break;
    }
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock{
    COINLocalSocketData *socketData = [self socketDataOfRemoteSocket:sock];
    if ([self.remoteSockets containsObject:sock]) {
        //NSLog(@"我是预备的远程连接");
    }else{
        [socketData.remoteSocket writeData:socketData.requestData withTimeout:-1 tag:SOCKETEventRemoteRead];
    }
    
}
- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    completionHandler(YES);
}


- (GCDAsyncSocket *)createRemoteSocket{
    GCDAsyncSocket *remoteSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue];
    return remoteSocket;
}



- (COINLocalSocketData *)socketDatasOfLocalSocket:(GCDAsyncSocket *)localSocket {
    COINLocalSocketData *ret;
    NSMutableArray *arrayTemp = self.socketDatas.mutableCopy;
    for (NSInteger i = 0;i < arrayTemp.count; i ++){
        COINLocalSocketData *socketData = arrayTemp[i];
        if (socketData.localSocket == localSocket) {
            if (i < self.socketDatas.count) {
               ret = self.socketDatas[i];
                break;
            }
        }
    }
    
    return ret;
}


- (COINLocalSocketData *)socketDataOfRemoteSocket:(GCDAsyncSocket *)remoteSocket {
    COINLocalSocketData *ret;
    NSMutableArray *arrayTemp = self.socketDatas.mutableCopy;
    for (NSInteger i = 0;i < arrayTemp.count; i ++){
        COINLocalSocketData *socketData = arrayTemp[i];
        if (socketData.remoteSocket == remoteSocket) {
            if (i < self.socketDatas.count) {
                ret = self.socketDatas[i];
                break;
            }
        }
    }
    
    return ret;
}

- (void)messageTips:(NSInteger)tag{
    switch (tag) {
        case SOCKETEventRemoteWrite:
            break;
        case SOCKETEventRemoteRead:
            break;
        case SOCKETEventLocalWrite:
            break;
        case SOCKETEventLocalRead:
            break;
        case SOCKETEventConnectRemote:
            break;
    }
}

- (void)disconnect{
    [self.localSocket setDelegate:nil delegateQueue:nil];
    [self.localSocket disconnect];
}

@end
