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

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic,strong) UIButton *mutilBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(refreshCurrentView)];
    self.navigationItem.rightBarButtonItem = rightBar;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self refreshCurrentView];
}

- (void)refreshCurrentView{
    
    //    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    //    NSURL *url = [NSURL URLWithString:@"https://www.gx.ac.10086.cn/shop"];
    NSURL *url = [NSURL URLWithString:@"http://www.gx.10086.cn/shop/indexmini?menuId=002100010001&menuName=shangpin&menuChannel=null"];
   
   //自动信任证书
    AKWebView *webView = [AKWebView shareWebView];
    [webView webViewWithLoadRequestWithURL:url Fram:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    
    //双向验证
    /*
     * Server_Cer 服务器证书
     * Client_P12 客户端证书
     * ClientPassword 客户端证书密码
     * ValidDomain 是否验证域名
     ////     */
    //    AKWebSSLTwo_Way *webView = [AKWebSSLTwo_Way shareWebViewTwoWay];
    //
    //    [webView webViewTwoWayWithLoadRequestWithURL:url Server_Cer:@"server" Client_P12:@"test" ClientPassword:@"123456" ValidDomain:NO Fram:self.view.bounds];
    
    [self.view addSubview:webView];
    
}
















@end
