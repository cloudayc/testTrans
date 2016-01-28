//
//  TranslateCenter.m
//  test
//
//  Created by cloudayc on 1/28/16.
//  Copyright © 2016 cloudayc. All rights reserved.
//



#import "TranslateCenter.h"

@interface TranslateCenter()<NSURLConnectionDelegate>

@property (nonatomic, strong) TranslateCompletion completion;

@end

@implementation TranslateCenter

static TranslateCenter *translateInstance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        translateInstance = [[TranslateCenter alloc] init];
    });
    return translateInstance;
}

- (void)translateString:(NSString *)str to:(NSInteger)country completion:(TranslateCompletion)completion
{
    if (str.length == 0) {
        NSLog(@"error! empty str");
        return;
    }
    self.completion = completion;
    
    NSString *host = @"http://fanyi.youdao.com/";
    NSString *path = @"openapi.do?keyfrom=xlsTranslate&key=554577905&type=data&doctype=json&version=1.1";
    
    NSString *encodeStr = [self URLEncodedString:str];
    path = [path stringByAppendingFormat:@"&q=%@", encodeStr];
    
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", host, path];
    NSMutableURLRequest *request = [ NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullPath]];
    
    __weak typeof(self) ws = self;
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
//            NSLog(@"%@", dict);
            NSString *result = dict[@"translation"][0];
//            NSLog(@"%@", result);
            ws.completion(str, result, nil);
        } else {
            ws.completion(nil, nil, error);
        }
    }];
    [task resume];
    
//    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
//    [connection start];
}


- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    
    return encodedStr;
}

@end
