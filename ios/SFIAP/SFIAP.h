//
//  SFIAP.h
//  svnShanXueV2
//
//  Created by wangxiaomao on 2018/6/2.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^paySuccess)();
typedef void (^payFail)(NSString *message);
@interface SFIAP : NSObject
+(SFIAP *)share;
-(void)pay:(NSString *)productId paySuc:(paySuccess)paySuc payFail:(payFail)payFail;
@end
