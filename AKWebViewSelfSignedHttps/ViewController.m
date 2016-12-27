//
//  ViewController.m
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2016/12/27.
//  Copyright © 2016年 Kuture. All rights reserved.
//

#import "ViewController.h"
#import "AKWebView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"你要加载的拥有自签名证书的URL"];
    AKWebView *webView = [AKWebView shareWebView];
    [webView webViewWithLoadRequestWithURL:url Fram:CGRectMake(0, 0, 500, 500)];
    [self.view addSubview:webView];
}


@end
