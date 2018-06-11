//
//  SFIAP.m
//  svnShanXueV2
//
//  Created by wangxiaomao on 2018/6/2.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "SFIAP.h"
#import <StoreKit/StoreKit.h>
@interface SFIAP()<SKPaymentTransactionObserver,SKProductsRequestDelegate>{
  paySuccess _sucBolock;
  payFail _failBlock;
  NSString *_productId;
}
@end
static SFIAP *_iap = NULL;
@implementation SFIAP
+(SFIAP *)share{
  if (!_iap){
    _iap = [SFIAP new];
  }
  return _iap;
}

-(void)pay:(NSString *)productId paySuc:(paySuccess)paySuc payFail:(payFail)payFail{
  _sucBolock = paySuc;
  _failBlock = payFail;
  _productId = productId;
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  if([SKPaymentQueue canMakePayments]){
    [self requestProductData:productId];
  }else{
    if (_failBlock){
      _failBlock(@"请先开启应用内付费购买功能。");
    }
  }
}
//请求商品
- (void)requestProductData:(NSString *)productId{
  NSLog(@"-------------请求对应的产品信息----------------");
  NSArray *product = [[NSArray alloc] initWithObjects:productId, nil];
  
  NSSet *nsset = [NSSet setWithArray:product];
  SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
  request.delegate = self;
  [request start];
}

#pragma mark 收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
  NSLog(@"--------------收到产品反馈消息---------------------");
  NSArray *product = response.products;
  if([product count] == 0){
    if (_failBlock){
      _failBlock(@"没有该商品");
    }
    NSLog(@"--------------没有商品------------------");
    return;
  }
  
  SKProduct *p = nil;
  for (SKProduct *pro in product) {
    NSLog(@"pro info");
    NSLog(@"SKProduct 描述信息：%@", [pro description]);
    NSLog(@"localizedTitle 产品标题：%@", [pro localizedTitle]);
    NSLog(@"localizedDescription 产品描述信息：%@", [pro localizedDescription]);
    NSLog(@"price 价格：%@", [pro price]);
    NSLog(@"productIdentifier Product id：%@", [pro productIdentifier]);

    if([pro.productIdentifier isEqualToString: _productId]){
      p = pro;
    }else{
      NSLog(@"不不不相同");
    }
  }
  if (!p){
    if (_failBlock){
      _failBlock(@"没有该商品");
    }
  }
  SKPayment *payment = [SKPayment paymentWithProduct:p];
  NSLog(@"发送购买请求");
  [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
  if (_failBlock){
    _failBlock([error localizedDescription]);
  }
}

- (void)requestDidFinish:(SKRequest *)request{
  
  NSLog(@"------------反馈信息结束-----------------");
}

#pragma mark 监听购买结果
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
  NSLog(@" 监听购买结果 -----paymentQueue--------");
  for (SKPaymentTransaction *transaction in transactions)
  {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:{
        NSLog(@"-----交易完成 --------");
        //交易完成
        [self commitSeversSucceeWithTransaction:transaction];
        
        
      }
        break;
      case SKPaymentTransactionStateFailed:{
        NSLog(@"-----交易失败 --------");
        //交易失败
        [self failedTransaction:transaction];
        
      }
        break;
      case SKPaymentTransactionStateRestored:{
        NSLog(@"-----已经购买过该商品(重复支付) --------");
        //已经购买过该商品
        [self restoreTransaction:transaction];
        //                 [self commitSeversSucceeWithTransaction:transaction];
        
        
      }
      case SKPaymentTransactionStatePurchasing:  {
        //商品添加进列表
        NSLog(@"-----商品添加进列表 --------");
      }
        break;
      default:
        break;
    }
  }
}

//交易结束
- (void)completeTransaction: (SKPaymentTransaction *)transaction
{
  NSLog(@" 交易结束 -----completeTransaction--------");
  
  // Remove the transaction from the payment queue.
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  
}

- (void)commitSeversSucceeWithTransaction:(SKPaymentTransaction *)transaction
{
  
  NSString * productIdentifier = transaction.payment.productIdentifier;
  NSLog(@"productIdentifier Product id：%@", productIdentifier);
  NSString *transactionReceiptString= nil;
  

  NSURLRequest * appstoreRequest = [NSURLRequest requestWithURL:[[NSBundle mainBundle]appStoreReceiptURL]];
  NSError *error = nil;
  NSData * receiptData = [NSURLConnection sendSynchronousRequest:appstoreRequest returningResponse:nil error:&error];
  
  transactionReceiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  
  if (_sucBolock){
    _sucBolock();
  }
}
//记录交易
-(void)recordTransaction:(NSString *)product{
  NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
  NSLog(@"-----下载--------");
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  if(transaction.error.code != SKErrorPaymentCancelled) {
    NSLog(@"购买失败");
    if (_failBlock){
      _failBlock(@"购买失败，请重新尝试购买");
    }
  } else {
    NSLog(@"用户取消交易");
    if (_failBlock){
      _failBlock(@"用户取消交易");
    }
  }
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
  
}


- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
  NSLog(@" 交易恢复处理");
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
  NSLog(@"-------paymentQueue----");
}

#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  NSLog(@"connection==%@",  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}
-(void)dealloc
{
  [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
}
@end
