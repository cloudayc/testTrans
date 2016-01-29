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

#import "TransData.h"

extern int xls_debug;

@interface ViewController()

@property (nonatomic, strong) NSMutableDictionary *sheetDict;


@end

@implementation ViewController
{
    NSUInteger requestCount;
    NSUInteger responseCount;
}

#pragma mark - View lifecycle

#define ROOT @"/Users/umeng/Documents/test/testTrans/output"

- (void)test {
    
    NSString *path = @"/Users/umeng/Documents/test/testTrans/output/out1.txt";
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        BOOL b = [fm createFileAtPath:path contents:nil attributes:nil];
        int a = b;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self test];
//    return;
    
    requestCount = 0;
    responseCount = 0;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"trans.xls"];
    //	NSString *path = @"/tmp/test.xls";
    
    // xls_debug = 1; // good way to see everything in the Excel file
    
    
    DHxlsReader *reader = [DHxlsReader xlsReaderFromFile:path];
    assert(reader);
    
    TranslateCenter *tc = [TranslateCenter sharedInstance];
    
    NSUInteger total = 0;
    
    NSString *dictPath = [NSString stringWithFormat:@"%@/%@", ROOT, @"total.plist"];
    NSMutableDictionary *sheetDict = [NSMutableDictionary dictionary];
    self.sheetDict = sheetDict;
    
    NSInteger sheetCount = [reader numberOfSheets] - 1;
    for (int i = 10; i <= sheetCount; ++i) {
        NSString *sheetName = [reader sheetNameAtIndex:i];
        NSLog(@"sheet name: %@", sheetName);
        
        NSUInteger rowBegin = 3;
        NSUInteger colBegin = 4;
        NSInteger colCount = 4;
        
        NSMutableArray *itemList = sheetDict[sheetName];
        if (!itemList) {
            itemList = [NSMutableArray array];
            sheetDict[sheetName] = itemList;
        }
        
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
                
                TransData *data = [TransData new];
                data.index = [NSNumber numberWithInteger:row];
                data.origin = cell.str;
                
                [itemList addObject:data];
                
                requestCount++;
                [tc translateData:data to:0 completion:^(TransData *data, NSError *error) {
                    if (!error) {
//                        printf("--原文:%s-- \n ==译文:%s==\n", [originString UTF8String], [resultString UTF8String]);
//                        printf("%s\n", [resultString UTF8String]);
//                        [resultString writeToFile:@"/Users/cloudayc/Documents/data.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                    responseCount++;
                    if (requestCount == responseCount) {
                        [self outputData];
                    }
                }];

            }
            printf("\n ");
            
            row++;
        }
    }
    
    NSLog(@"total:%lu", total);
}

- (void)outputData
{
    for (NSString *name in [_sheetDict allKeys]) {
        NSArray *list = _sheetDict[name];
        
        [self writeSheetDouble:list forName:name];
        
        [self writeSheetCompare:list forName:name];
    }
    
    [self writeSheetToPlist];
    
    NSLog(@"finish");
}

- (void)writeSheetDouble:(NSArray *)itemList forName:(NSString *)name
{
    NSMutableString *outStr = [NSMutableString string];

    for (TransData *data in itemList) {
        [outStr appendFormat:@"%@ %@\t%@\n", data.index, data.origin, data.translate];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@.txt", ROOT, @"double", name];
    [self writeData:outStr toPath:path];
}

- (void)writeSheetCompare:(NSArray *)itemList forName:(NSString *)name
{
    NSMutableString *outStr = [NSMutableString string];
    
    for (TransData *data in itemList) {
        [outStr appendFormat:@"%@原文:\t%@\n%@译文:\t%@\n", data.index, data.origin, data.index, data.translate];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@.txt", ROOT, @"compare", name];
    [self writeData:outStr toPath:path];
}

- (void)writeSheetToPlist
{
    NSMutableDictionary *outDict = [NSMutableDictionary dictionary];
    for (NSString *name in [_sheetDict allKeys]) {
        NSArray *list = _sheetDict[name];
        
        NSMutableArray *items = [NSMutableArray array];
        outDict[name] = items;
        
        for (TransData *data in list) {
            if (data.translate == nil) {
                NSLog(@"error: %@", data.origin);
                continue;
            }
            [items addObject:@{@"index": data.index, @"origin" : data.origin, @"translate" : data.translate}];
        }
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@", ROOT, @"total.plist"];
    [outDict writeToFile:path atomically:YES];
}


- (void)writeData:(id)data toPath:(NSString *)path
{
    if (path.length == 0) {
        return;
    }
    NSError *error = nil;
    [data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"error:%@\npath:%@", error.description, path);
    }
    
//    NSFileManager *fm = [NSFileManager defaultManager];
//    if (![fm fileExistsAtPath:path]) {
//        [fm createFileAtPath:path contents:nil attributes:nil];
//    }
}

@end
