//
//  AKWebView.h
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2016/12/27.
//  Copyright © 2016年 Kuture. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKWebView : UIWebView

+(instancetype)shareWebView;
- (void)webViewWithLoadRequestWithURL:(NSURL *)url Fram:(CGRect)fram;

@end
