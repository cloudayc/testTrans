//
//  TranslateCenter.h
//  test
//
//  Created by cloudayc on 1/28/16.
//  Copyright © 2016 cloudayc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TransData.h"

typedef void (^TranslateCompletion)(TransData *data, NSError *error);
@interface TranslateCenter : NSObject

+ (instancetype)sharedInstance;

- (void)translateData:(TransData *)tData to:(NSInteger)country completion:(TranslateCompletion)completion;

@end
