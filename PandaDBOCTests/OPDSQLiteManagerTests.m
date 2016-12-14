//
//  OPDSQLiteManagerTests.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/14.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OPDSQLiteManager.h"

@interface OPDSQLiteManagerTests : XCTestCase

@end

@implementation OPDSQLiteManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testOpen{
    OPDSQLiteManager* sqliteManager = [[OPDSQLiteManager alloc] initWithDBFileName:@"abc.sqlite"];
    if ([sqliteManager open]) {
        NSLog(@"建立数据库是否成功");
    }else{
        NSLog(@"建立数据库失败");
    }
    [sqliteManager close];
}

-(void)testExecuteUpdate{
    OPDSQLiteManager* sqliteManager = [[OPDSQLiteManager alloc] initWithDBFileName:@"abc.sqlite"];
    if ([sqliteManager open]) {
        BOOL success =  [sqliteManager executeUpdate:@"create table if not exists abc(name text,age int,weight real,info blob);" ];
        if (success) {
            NSLog(@"执行 SQL成功");
        }else{
            NSLog(@"执行 SQL 失败");
        }
    }else{
        NSLog(@"建立数据库失败");
    }
    [sqliteManager close];
    
}

-(void)testExecuteQuery{
    OPDSQLiteManager* sqliteManager = [[OPDSQLiteManager alloc] initWithDBFileName:@"abc.sqlite"];
    
    [sqliteManager open];
    
    [sqliteManager executeUpdate:@"delete from abc"];
    
    BOOL success = [sqliteManager executeUpdate:@"insert into abc(name,age,weight) values(:name,:age,:weight)" params:@{
                                                                                                                        @"name":@"lingen",
                                                                                                                        @"age":@(2),
                                                                                                                        @"weight":@(23.12)
                                                                                                                        }];
    
    if (success) {
        NSLog(@"执行插入成功");
    }else{
        NSLog(@"执行插入失败");
    }
    
    
    NSArray* results = [sqliteManager executeQuery:@"select * from abc"];
    
    NSLog(@"%@",results);
    
    [sqliteManager close];
}

@end
