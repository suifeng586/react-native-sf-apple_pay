//
//  SFIAPBridge.m
//  svnShanXueV2
//
//  Created by wangxiaomao on 2018/6/2.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "SFIAPBridge.h"
#import "SFIAP.h"
@implementation SFIAPBridge

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(pay:(NSString *)productId callBack:(RCTResponseSenderBlock)callBack)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[SFIAP share] pay:productId paySuc:^{
      callBack(@[[NSNull null]]);
    } payFail:^(NSString *message) {
      callBack(@[@"-1",message]);
    }];
  });
}

@end
