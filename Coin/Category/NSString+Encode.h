//
//  NSString+Encode.h
//  EXDemo
//
//  Created by dev6 on 2018/11/2.
//  Copyright © 2018 dev6. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Encode)
/**
 *  加密方式,MAC算法: HmacSHA256
 *
 *  @param plaintext 要加密的文本
 *  @param key       秘钥
 *
 *  @return 加密后的字符串
 */
+ (NSString *)hmacOKEX:(NSString *)plaintext withKey:(NSString *)key;

+ (NSString *)hmacBitMEX:(NSString *)plaintext withKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
