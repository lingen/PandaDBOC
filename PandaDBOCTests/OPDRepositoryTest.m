//
//  OPDRepositoryTest.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/18.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OPDUser.h"
#import "OPDUser+DB.h"
#import "OPDUser+Repository.h"

@interface OPDRepositoryTest : XCTestCase

@end

@implementation OPDRepositoryTest

- (void)setUp {
    [super setUp];
    [OPDUser clearAllData];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testCreateRepository{
    BOOL sucess = [OPDUser userTableExists];
    if (sucess) {
        NSLog(@"用户表已创建成功");
    }else{
        NSLog(@"数据库创建失败");
    }
    assert(sucess);
}

-(void)testAddUser{
    OPDUser* user = [[OPDUser alloc] initWithName:@"张三" age:14 weight:12.0 moreInfo:@"张三是一个工程师"];
    BOOL success = [user saveToDB];
    assert(success);
}

-(void)testQueryUser{
    OPDUser* user = [[OPDUser alloc] initWithName:@"张三" age:14 weight:12.0 moreInfo:@"张三是一个工程师"];
    [user saveToDB];
    
    OPDUser* user2 = [OPDUser queryByNameFromDB:@"张三"][0];
    
    assert([user.name isEqualToString:user2.name]);
}

-(void)testQueryUserWithIn{
    OPDUser* user = [[OPDUser alloc] initWithName:@"张三" age:14 weight:12.0 moreInfo:@"张三是一个工程师"];
    [user saveToDB];
    
    OPDUser* user2 = [[OPDUser alloc] initWithName:@"李四" age:16 weight:14.0 moreInfo:@"李四是一个软件工程师"];
    [user2 saveToDB];
    
    NSArray* results = [OPDUser queryByNameInFromDB:@[@"张三",@"李四"]];
    
    assert(results.count == 2);
}

-(void)testBatchSave{
    NSMutableArray* users = [[NSMutableArray alloc] init];
    for (int i =0 ; i< 10000; i++) {
        OPDUser* user = [[OPDUser alloc] initWithName:[NSString stringWithFormat:@"张三%@",@(i)] age:14 weight:12.0 moreInfo:@"张三是一个工程师"];
        [users addObject:user];
    }
    
    [OPDUser batchSaveToDB:users];
    
    int count = [OPDUser countForUserInDB];
    assert(count == 10000);
}
@end
