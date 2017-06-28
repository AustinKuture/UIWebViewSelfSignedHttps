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
#import "AKWebSSLTwo-Way.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *mutilBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //http://www.gx.10086.cn/shop/indexmini?menuId=002100010001&menuName=shangpin&menuChannel=null
    //https://gx.ac.10086.cn/POST
   // http://www.gx.10086.cn/shop/indexmini?menuId=002100010001&menuName=shangpin&menuChannel=null
    
    NSURL *url = [NSURL URLWithString:@"http://www.gx.10086.cn/shop/indexmini?menuId=002100010001&menuName=shangpin&menuChannel=null"];

    
    //自动信任证书
        AKWebView *webView = [AKWebView shareWebView];
        [webView webViewWithLoadRequestWithURL:url Fram:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    //双向验证
    /*
     * Server_Cer 服务器证书
     * Client_P12 客户端证书
     * ClientPassword 客户端证书密码
     ////     */
//    AKWebSSLTwo_Way *webView = [AKWebSSLTwo_Way shareWebViewTwoWay];
//    [webView webViewTwoWayWithLoadRequestWithURL:url Server_Cer:@"server" Client_P12:@"test" ClientPassword:@"123456" Fram:self.view.bounds];
    
    [self.view addSubview:webView];

}


















@end
