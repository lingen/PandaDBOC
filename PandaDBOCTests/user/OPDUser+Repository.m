//
//  OPDUser+Repository.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/18.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import "OPDUser+Repository.h"
#import "OPDUserRepository.h"
#import "OPDRepository.h"
@implementation OPDUser (Repository)

/*
 * 查询用户表是否存在
 */
+(BOOL)userTableExists{
    return [[OPDUserRepository sharedInstance].repository tableExists:@"user_"];
}

/*
 * 将一个用户存入表中
 */
-(BOOL)saveToDB{
    NSString* sql = @"replace into user_ (name_,age_,weight_,more_) values (:name,:age,:weight,:more)";
    
    NSData* more = [self.moreInfo dataUsingEncoding:NSUTF8StringEncoding];
 
    return [[OPDUserRepository sharedInstance].repository executeUpdate:sql withDictionaryArgs:@{
                                                                                                @"age":@(self.age),
                                                                                                @"name":self.name,
                                                                                                @"weight":@(self.weight),
                                                                                                @"more":more
                                                                                                 }];
}

/*
 * 将一个批量事务存入表中
 */
+(BOOL)batchSaveToDB:(NSArray*)users{
    __block BOOL success = NO;
    [[OPDUserRepository sharedInstance].repository inTransaction:^(BOOL *rollback) {
        for (OPDUser* user in users) {
            success = [user saveToDB];
            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];
    return success;
}

/*
 * 清除表中所有的数据
 */
+(BOOL)clearAllData{
    NSString* deletSQL = @"delete from user_";
    
    return [[OPDUserRepository sharedInstance].repository executeUpdate:deletSQL];
}

/*
 * 根据用户名查询出对应的数据
 */
+(NSArray*)queryByNameFromDB:(NSString*)name{
    NSString* querySQL = @"select * from user_ where name_ = :name";
    NSArray* values = [[OPDUserRepository sharedInstance].repository executeQuery:querySQL withDictionaryArgs:@{
                                                                                                                @"name":name
                                                                                                                 }];
    NSMutableArray* users = [[NSMutableArray alloc] init];
    for (NSDictionary* value in values) {
        OPDUser* user = [OPDUser instanceFromDB:value];
        if (user) {
            [users addObject:user];
        }
    }
    
    return [users copy];
}

/*
 * 根据多个用户名查询对应的数据
 */
+(NSArray*)queryByNameInFromDB:(NSArray*)names{
    NSString* querySQL = @"select * from user_ where name_ in :name";
    NSArray* values = [[OPDUserRepository sharedInstance].repository executeQuery:querySQL withDictionaryArgs:@{
                                                                                                                @"name":names
                                                                                                                }];
    NSMutableArray* users = [[NSMutableArray alloc] init];
    for (NSDictionary* value in values) {
        OPDUser* user = [OPDUser instanceFromDB:value];
        if (user) {
            [users addObject:user];
        }
    }
    
    return [users copy];
}

/*
 * 删除一个用户
 */
-(BOOL)deleteFromDB{
    NSString* deletSQL = @"delete from user_ where name_ = :name";
    return [[OPDUserRepository sharedInstance].repository executeUpdate:deletSQL withDictionaryArgs:@{
                                                                                                     @"name":self.name
                                                                                                      }];
}

+(int)countForUserInDB{
    NSString* querySQL = @"select count(*) as count from user_";
    NSNumber *result = [[OPDUserRepository sharedInstance].repository singleExecuteQuery:querySQL convertBlock:^id(NSDictionary *result) {
        int count =  [result[@"count"] intValue];
        return @(count);
    }];
    
    return [result intValue];
}

+(instancetype)instanceFromDB:(NSDictionary*)dic{
    OPDUser* user = nil;
    if (dic && dic.count > 0) {
        user = [[OPDUser alloc] init];
        user.name = dic[@"name_"];
        user.age = [dic[@"age_"] intValue];
        user.weight = [dic[@"weight"] doubleValue];
        
        NSData* data = dic[@"more_"];
        user.moreInfo =[ NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
    }
    return user;
}

@end
