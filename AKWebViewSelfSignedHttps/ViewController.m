//
//  ViewController.m
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2016/12/27.
//  Copyright © 2016年 Kuture. All rights reserved.
//

#import "ViewController.h"
#import "AKWebView.h"
#import "WebKit/WebKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //http://www.gx.10086.cn/shop/indexmini?menuId=002100010001&menuName=shangpin&menuChannel=null
    //https://gx.ac.10086.cn/POST
   // http://www.gx.10086.cn/shop/indexmini?menuId=002100010001&menuName=shangpin&menuChannel=null
    
    NSURL *url = [NSURL URLWithString:@"http://www.gx.10086.cn/shop/indexmini?menuId=002100010001&menuName=shangpin&menuChannel=null"];
    
    AKWebView *webView = [AKWebView shareWebView];
    [webView webViewWithLoadRequestWithURL:url Fram:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:webView];
    

}


@end
