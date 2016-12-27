//
//  AKWebView.m
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2016/12/27.
//  Copyright © 2016年 Kuture. All rights reserved.
//

#import "AKWebView.h"

@interface AKWebView ()<UIWebViewDelegate,NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSURLConnection *urlConnection;
@property (nonatomic,strong) NSURLRequest *requestW;
@property (nonatomic) SSLAuthenticate authenticated;

@end

@implementation AKWebView

+(instancetype)shareWebView{
    static dispatch_once_t onece = 0;
    static AKWebView *webView = nil;
    dispatch_once(&onece, ^(void){
        webView = [[self alloc]init];
    });
    return webView;
}

#pragma mark ***UIWebView 加载方法***
- (void)webViewWithLoadRequestWithURL:(NSURL *)url Fram:(CGRect)fram{
    
    self.frame = fram;
    self.delegate = self;
    _requestW = [NSURLRequest requestWithURL:url];
    [self loadRequest:_requestW];
}

#pragma mark ***UIWebView 代理方法***
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"开始加载: %@ 授权:%d", [[request URL] absoluteString], _authenticated);
    
    if (!_authenticated) {
        _authenticated = kNeverAuthenticate;
        
        _urlConnection = [[NSURLConnection alloc] initWithRequest:_requestW delegate:self];
        
        [_urlConnection start];
        
        return NO;
    }
    
    return YES;
}


#pragma mark ***NURLConnection 代理方法***
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSLog(@"WebController 已经得到授权正在请求 NSURLConnection");
    
    if ([challenge previousFailureCount] == 0){
        _authenticated = kTryAuthenticate;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
    } else{
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"WebController 已经收到响应并通过了 NSURLConnection请求");
    
    _authenticated = kTryAuthenticate;
    [self loadRequest:_requestW];
    [_urlConnection cancel];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}




@end
