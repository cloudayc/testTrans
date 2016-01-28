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
    
    NSInteger sheetCount = [reader numberOfSheets];
    for (int i = 0; i < sheetCount; ++i) {
        NSLog(@"sheet name: %@", [reader sheetNameAtIndex:i]);
        
        NSUInteger rowBegin = 3;
//        NSInteger recordCount = 11;
        NSUInteger colBegin = 4;
        NSInteger colCount = 4;
        
        NSUInteger row = rowBegin;
        while (true) {
            DHcell *cell = [reader cellInWorkSheetIndex:i row:row col:colBegin];
            
            if (cell.str == NULL) {
                row = rowBegin;
                
                printf("\ncount: %lu\n", row);
                printf("---------------------------\n\n");
                break;
            }
            printf("%lu ", row);
            
            for (NSUInteger col = colBegin; col <= colCount; ++col) {
                DHcell *cell = [reader cellInWorkSheetIndex:i row:row col:col];
                printf("%s ", [cell.str UTF8String]);
                
                [tc translateString:cell.str to:0 completion:^(NSString *resultString, NSError *error) {
                    if (!error) {
                        NSLog(@"origin:%@ \n trans:%@", cell.str, resultString);
                    }
                }];
            }
            printf("\n ");
            
            row++;
        }
    }
    NSString *text = @"";
    
    text = [text stringByAppendingFormat:@"AppName: %@\n", reader.appName];
    text = [text stringByAppendingFormat:@"Author: %@\n", reader.author];
    text = [text stringByAppendingFormat:@"Category: %@\n", reader.category];
    text = [text stringByAppendingFormat:@"Comment: %@\n", reader.comment];
    text = [text stringByAppendingFormat:@"Company: %@\n", reader.company];
    text = [text stringByAppendingFormat:@"Keywords: %@\n", reader.keywords];
    text = [text stringByAppendingFormat:@"LastAuthor: %@\n", reader.lastAuthor];
    text = [text stringByAppendingFormat:@"Manager: %@\n", reader.manager];
    text = [text stringByAppendingFormat:@"Subject: %@\n", reader.subject];
    text = [text stringByAppendingFormat:@"Title: %@\n", reader.title];
    
    
    text = [text stringByAppendingFormat:@"\n\nNumber of Sheets: %u\n", reader.numberOfSheets];
    
#if 0
    [reader startIterator:0];
    
    while(YES) {
        DHcell *cell = [reader nextCell];
        if(cell.type == cellBlank) break;
        
        text = [text stringByAppendingFormat:@"\n%@\n", [cell dump]];
    }
#else
    int row = 2;
    while(YES) {
        DHcell *cell = [reader cellInWorkSheetIndex:0 row:row col:2];
        if(cell.type == cellBlank) break;
        DHcell *cell1 = [reader cellInWorkSheetIndex:0 row:row col:3];
        NSLog(@"\nCell:%@\nCell1:%@\n", [cell dump], [cell1 dump]);
        row++;
        
        //text = [text stringByAppendingFormat:@"\n%@\n", [cell dump]];
        //text = [text stringByAppendingFormat:@"\n%@\n", [cell1 dump]];
    }
#endif
}
@end
