//
//  OPDUser+Repository.h
//  PandaDBOC
//
//  Created by lingen on 2016/12/18.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import "OPDUser.h"

@interface OPDUser (Repository)

/*
 * 查询用户表是否存在
 */
+(BOOL)userTableExists;

/*
 * 将一个用户存入表中
 */
-(BOOL)saveToDB;

/*
 * 将一个批量事务存入表中
 */
+(BOOL)batchSaveToDB:(NSArray*)users;

/*
 * 清除表中所有的数据
 */
+(BOOL)clearAllData;

/*
 * 根据用户名查询出对应的数据
 */
+(NSArray*)queryByNameFromDB:(NSString*)name;

/*
 * 根据多个用户名查询对应的数据
 */
+(NSArray*)queryByNameInFromDB:(NSArray*)names;

/*
 * 删除一个用户
 */
-(BOOL)deleteFromDB;

+(int)countForUserInDB;

@end
