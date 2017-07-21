//
//  AKWebSSLTwo-Way.h
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2017/6/21.
//  Copyright © 2017年 Kuture. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKWebSSLTwo_Way : UIWebView

@property (nonatomic,copy) NSString *clientPasswordStr;

+ (instancetype)shareWebViewTwoWay;

- (void)webViewTwoWayWithLoadRequestWithURL:(NSURL *)url
                                 Server_Cer:(NSString *)server
                                 Client_P12:(NSString *)client
                             ClientPassword:(NSString *)clientPassword
                                ValidDomain:(BOOL)validDomain
                                       Fram:(CGRect)fram;

@end
