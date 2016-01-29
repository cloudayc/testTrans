//
//  TranslateCenter.m
//  test
//
//  Created by cloudayc on 1/28/16.
//  Copyright © 2016 cloudayc. All rights reserved.
//

//#define Key @"554577905"
//#define KeyFrom @"xlsTranslate"

#define Key @"866595117"
#define KeyFrom @"clouday"



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

- (void)translateData:(TransData *)tData to:(NSInteger)country completion:(TranslateCompletion)completion
{
    if (tData.origin.length == 0) {
        NSLog(@"error! empty str");
        return;
    }
    self.completion = completion;
    
    NSString *host = @"http://fanyi.youdao.com/";
    NSString *path = [NSString stringWithFormat:@"openapi.do?keyfrom=%@&key=%@&type=data&doctype=json&version=1.1", KeyFrom, Key];
    
    NSString *encodeStr = [self URLEncodedString:tData.origin];
    path = [path stringByAppendingFormat:@"&q=%@", encodeStr];
    
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", host, path];
    NSMutableURLRequest *request = [ NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullPath]];
    
    __weak typeof(self) ws = self;

    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            
            NSError *jsonError = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            NSString *result = dict[@"translation"][0];
            tData.translate = result;
            
            ws.completion(tData, nil);
        } else {
            ws.completion(nil, error);
        }
    }];
    [task resume];
    
}


- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    
    return encodedStr;
}

@end
