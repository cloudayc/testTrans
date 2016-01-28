//
//  TranslateCenter.m
//  test
//
//  Created by cloudayc on 1/28/16.
//  Copyright © 2016 cloudayc. All rights reserved.
//

#import "TranslateCenter.h"

@interface TranslateCenter()

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
    self.completion = completion;
    
}

@end
