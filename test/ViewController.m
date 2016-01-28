//
//  ViewController.m
//  TestDHlibxls
//
//  Created by David Hoerl on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "DHxlsReaderIOS.h"
#import "TranslateCenter.h"

extern int xls_debug;

@implementation ViewController
{
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"trans.xls"];
    //	NSString *path = @"/tmp/test.xls";
    
    // xls_debug = 1; // good way to see everything in the Excel file
    
    
    DHxlsReader *reader = [DHxlsReader xlsReaderFromFile:path];
    assert(reader);
    
    TranslateCenter *tc = [TranslateCenter sharedInstance];
    
    NSUInteger total = 0;
    
    NSInteger sheetCount = 1;//[reader numberOfSheets];
    for (int i = sheetCount; i <= sheetCount; ++i) {
        NSLog(@"sheet name: %@", [reader sheetNameAtIndex:i]);
        
        NSUInteger rowBegin = 3;
//        NSInteger recordCount = 11;
        NSUInteger colBegin = 4;
        NSInteger colCount = 4;
        
        NSUInteger row = rowBegin;
        while (true) {
            DHcell *cell = [reader cellInWorkSheetIndex:i row:row col:colBegin];
            
            if (cell.str == NULL) {
                
                total += row;
                
                printf("\ncount: %lu\n", row);
                printf("---------------------------\n\n");
                
                row = rowBegin;
                break;
            }
//            printf("%lu ", row);
            
            for (NSUInteger col = colBegin; col <= colCount; ++col) {
                DHcell *cell = [reader cellInWorkSheetIndex:i row:row col:col];
                printf("%s\n", [cell.str UTF8String]);
                NSDictionary *dict;
                [tc translateString:cell.str to:0 completion:^(NSString *originString, NSString *resultString, NSError *error) {
                    if (!error) {
//                        printf("--原文:%s-- \n ==译文:%s==\n", [originString UTF8String], [resultString UTF8String]);
                        printf("%s\n", [resultString UTF8String]);
                        [resultString writeToFile:@"/Users/cloudayc/Documents/data.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                }];

            }
            printf("\n ");
//            sleep(1);
            row++;
        }
    }
    
    NSLog(@"total:%lu", total);
}
@end
