//
//  AKWebSSLTwo-Way.m
//  AKWebViewSelfSignedHttps
//
//  Created by 李亚坤 on 2017/6/21.
//  Copyright © 2017年 Kuture. All rights reserved.
//

#import "AKWebSSLTwo-Way.h"

@interface AKWebSSLTwo_Way ()<UIWebViewDelegate,NSURLConnectionDataDelegate,NSURLSessionDelegate>

@property (nonatomic,strong) NSURLConnection *urlConnection;
@property (nonatomic,strong) NSURLRequest *requestW;
@property (nonatomic) SSLAuthenticate authenticated;
@property (nonatomic,copy) NSString *serverStr;
@property (nonatomic,copy) NSString *clientStr;
@property (nonatomic) BOOL validDomain;


@end

@implementation AKWebSSLTwo_Way

+ (instancetype)shareWebViewTwoWay{
    static dispatch_once_t onece = 0;
    static AKWebSSLTwo_Way *webView = nil;
    dispatch_once(&onece, ^(void){
        webView = [[self alloc]init];
    });
    return webView;
}

#pragma mark ***UIWebView 加载方法***
- (void)webViewTwoWayWithLoadRequestWithURL:(NSURL *)url
                                 Server_Cer:(NSString *)server
                                 Client_P12:(NSString *)client
                             ClientPassword:(NSString *)clientPassword
                                ValidDomain:(BOOL)validDomain
                                       Fram:(CGRect)fram{
    
    _serverStr = server;
    _clientStr = client;
    _clientPasswordStr = clientPassword;
    _validDomain = validDomain;
    
    self.frame = fram;
    
    self.delegate = self;
    _requestW = [NSURLRequest requestWithURL:url];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:_requestW completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"%s",__FUNCTION__);
        NSLog(@"RESPONSE:%@",response);
        NSLog(@"ERROR:%@",error);
        
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataString:%@",dataString);
        
        [self loadHTMLString:dataString baseURL:nil];
    }] resume];
    
    [self loadRequest:_requestW];
}

#pragma mark ***UIWebView 代理方法***
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *tmp = [request.URL absoluteString];
    
    NSLog(@"request url :%@",tmp);

    if ([request.URL.scheme rangeOfString:@"https"].location != NSNotFound) {
        
        //开启同步的请求去双向认证
        
        if (!_authenticated) {
            
//                        _requestW = request;
            request = _requestW;
            
            NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
            
            [conn start];
            
            [webView stopLoading];
            
            return false;
        }
    }
    
    return YES;
}

#pragma mark ***NSURLConnection代理方法***
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSURLCredential * credential;
    
    assert(challenge != nil);
    
    credential = nil;
    
    NSLog(@"----收到质询----");
    
    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSLog(@"----服务器验证客户端----");
        
        NSString *host = challenge.protectionSpace.host;
        
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    
        
        NSMutableArray *polices = [NSMutableArray array];
        
        if (_validDomain) {
            
            [polices addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)host)];
            
        }else{
            
            [polices addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
            
        }
        
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)polices);
        
        //导入证书
        NSString *path = [[NSBundle mainBundle] pathForResource:_serverStr ofType:@"cer"];
        
        NSData *certData = [NSData dataWithContentsOfFile:path];
        
        NSMutableArray *pinnedCerts = [NSMutableArray arrayWithObjects:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData), nil];
        
        SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCerts);
        
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
    } else {
        
        NSLog(@"----客户端验证服务端----");
        
        SecIdentityRef identity = NULL;
        
        SecTrustRef trust = NULL;
        
        NSString *p12 = [[NSBundle mainBundle] pathForResource:_clientStr ofType:@"p12"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:p12]) {
            
            NSLog(@"客户端.p12证书 不存在!");
            
        }else{
            
            NSData *pkcs12Data = [NSData dataWithContentsOfFile:p12];
            
            if ([self extractIdentity:&identity andTrust:&trust fromPKCS12Data:pkcs12Data]) {
                
                SecCertificateRef certificate = NULL;
                
                SecIdentityCopyCertificate(identity, &certificate);
                
                const void *certs[] = {certificate};
                
                CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
                
                credential = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray *)certArray persistence:NSURLCredentialPersistencePermanent];
            }
            
        }
        
    }
    
    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    
}

- (BOOL)extractIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    
    OSStatus securityErr = errSecSuccess;
    
    //输入客户端证书密码
    NSDictionary *optionsDic = [NSDictionary dictionaryWithObject:_clientPasswordStr  forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    securityErr = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data, (__bridge CFDictionaryRef)optionsDic, &items);
    
    if (securityErr == errSecSuccess) {
        
        CFDictionaryRef mineIdentAndTrust = CFArrayGetValueAtIndex(items, 0);
        
        const void *tmpIdentity = NULL;
        
        tmpIdentity = CFDictionaryGetValue(mineIdentAndTrust, kSecImportItemIdentity);
        
        *outIdentity = (SecIdentityRef)tmpIdentity;
        
        const void *tmpTrust = NULL;
        
        tmpTrust = CFDictionaryGetValue(mineIdentAndTrust, kSecImportItemTrust);
        
        *outTrust = (SecTrustRef)tmpTrust;
        
    }else{
        
        return false;
        
    }
    
    return true;
    
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)pResponse {
    
    _authenticated = YES;
    
    //webview 重新加载请求。
    
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
        [[session dataTaskWithRequest:_requestW completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
            NSLog(@"%s",__FUNCTION__);
            NSLog(@"RESPONSE:%@",response);
            NSLog(@"ERROR:%@",error);
    
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"dataString:%@",dataString);
    
            [self loadHTMLString:dataString baseURL:nil];
        }] resume];
    
    [self loadRequest:_requestW];
    
    [connection cancel];
    
}



@end
