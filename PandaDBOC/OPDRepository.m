//
//  OPRepository.m
//  Pods
//
//  Created by lingen on 16/3/21.
//
//

#import "OPDRepository.h"
#import "OPDTableProtocol.h"
#import "OPDTable.h"


@interface OPDRepository()

@end

//创建版本控制的语句
static NSString* CREATE_VERSION_TABLE = @"CREATE TABLE PANDA_VERSION_ (VALUE_ INT NOT NULL)";

//初始化版本控制的语句
static NSString* INIT_VERSION_TABLE_CONTENT = @"INSERT INTO PANDA_VERSION_ (VALUE_) values (%@)";

//查询当前的版本号
static NSString* QUERY_CURRENT_VERSION = @"SELECT VALUE_ FROM PANDA_VERSION_ LIMIT 1";

//更新版本SQL
static NSString* UPDATE_VERSION = @"UPDATE PANDA_VERSION_ SET VALUE_ = %d";

@implementation OPDRepository


-(void)close{
    
}

/**
 *  OPRepository初始化方法
 *
 *  @param dbPath  数据库路径
 *  @param tables  数据库表格定义
 *  @param version 数据库初始版本
 *
 *  @return OPRepository的实例
 */
-(instancetype)initWith:(NSString*) dbPath tables:(NSArray*)tables version:(int)version{
    return nil;
}


#pragma 同步更新方法，单个SQL
/**
 *  同步执行一个是更新操作
 *
 *  @param sql SQL语句
 *
 *  @return 返回是否执行成功
 */
-(BOOL)executeUpdate:(NSString*)sql{
    return NO;
}

/**
 *  同步执行一个是更新操作
 *
 *  @param sql  SQL语句
 *  @param args 参数列表
 *
 *  @return 返回是否执行成功
 */
-(BOOL)executeUpdate:(NSString*)sql withDictionaryArgs:(NSDictionary*)args{
    return NO;
}


#pragma 同步更新方法，多个SQL
/**
 *  执行一系列的SQL操作
 *
 *  @param sqls SQL语句集合
 *
 *  @return 返回成功或失败，只有所有的成功才会成功
 */
-(BOOL)executeUpdates:(NSArray *)sqls{
    return NO;
}

/**
 *  执行一系列的SQL操作
 *
 *  @param sqls SQL语句集合
 *  @param args 对应的参数列表，有多少个SQL，就必须有多少个参数列表
 *
 *  @return 返回成功或失败，只有所有的成功才会成功
 */
-(BOOL)executeUpdates:(NSArray *)sqls withDictionaryArgs:(NSArray*)args{
    return NO;
}


/**
 *  将BLOCK里的数据库操作，全部归纳到一个事务中去
 *
 *  @param dbBlock BLOC行为
 *
 */
-(void)inTransaction:(void(^)(BOOL *rollback))dbBlock{
}

#pragma 同步查询
/**
 *  同步执行一个查询
 *
 *  @param sql 查询SQL
 *
 *  @return 返回查询结果，结果为NSArray，Array里面为NSDictionary
 */
-(NSArray*)executeQuery:(NSString*)sql{
    return nil;
}

/**
 *  同步执行一个查询
 *
 *  @param sql  查询SQL
 *  @param args 参数列表
 *
 *  @return 返回查询结果 ，结果为NSArray，Array里面为NSDictionary，是数据库的键值对
 */
-(NSArray*)executeQuery:(NSString*)sql withDictionaryArgs:(NSDictionary*)args{
    return nil;
}

#pragma 同步查询，单例
/**
 *  单例查询，当SQL语句仅返回一条数据时使用此方法
 *
 *  @param sql 查询SQL
 *
 *  @return 返回NSDictionary
 */
-(NSDictionary*)singleExecuteQuery:(NSString*)sql{
    return nil;
}

/**
 *  单例查询，当SQL语句仅返回一条数据时使用此方法
 *
 *  @param sql  SQL语句
 *  @param args 参数列表
 *
 *  @return 返回一个NSDictionary
 */
-(NSDictionary*)singleExecuteQuery:(NSString*)sql withDictionaryArgs:(NSDictionary*)args{
    return nil;
}

#pragma 同步查询，返回对象
/**
 *  同步查询，返回Model集合
 *
 *  @param sql            SQL语句
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返回一个数组，数组中为对象
 */
-(NSArray*)executeQuery:(NSString*)sql convertBlock:(id(^)(NSDictionary * result))convertBlock{
    return nil;
}


/**
 *  同步查询，返回Model集合
 *
 *  @param sql          SQL语句
 *  @param args         参数列表
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返回一个数组，数组中为对象
 */
-(NSArray*)executeQuery:(NSString *)sql withDictionaryArgs:(NSDictionary*)args convertBlock:(id (^)(NSDictionary* result))convertBlock{
    return nil;
}


#pragma 同步查询，对象且单例
/**
 *  同步查询，返回Model集合
 *
 *  @param sql            SQL语句
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返回一个对象
 */
-(id)singleExecuteQuery:(NSString*)sql convertBlock:(id(^)(NSDictionary * result))convertBlock{
    return nil;
}


/**
 *  同步查询，返回Model集合
 *
 *  @param sql          SQL语句
 *  @param args         参数列表
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返返回一个对象
 */
-(id)singleExecuteQuery:(NSString *)sql withDictionaryArgs:(NSDictionary*)args convertBlock:(id (^)(NSDictionary* result))convertBlock{
    return nil;
}

/**
 *  同步查询数据库中某个表是否存在
 *
 *  @param tableName 表名
 *
 *  @return 返回结果
 */
-(BOOL)queryTableExists:(NSString*)tableName{
    return NO;
}

@end
