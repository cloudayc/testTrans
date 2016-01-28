//
//  TranslateCenter.h
//  test
//
//  Created by cloudayc on 1/28/16.
//  Copyright © 2016 cloudayc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TranslateCompletion)(NSString *resultString, NSError *error);
@interface TranslateCenter : NSObject

+ (instancetype)sharedInstance;

- (void)translateString:(NSString *)str to:(NSInteger)country completion:(TranslateCompletion)completion;

@end
