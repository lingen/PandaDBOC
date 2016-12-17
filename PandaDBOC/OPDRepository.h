//
//  OPRepository.h
//  Pods
//
//  Created by lingen on 16/3/21.
//
//

#import <Foundation/Foundation.h>
#import "OPDTableProtocol.h"


@interface OPDRepository : NSObject

/**
 *  是否开启严格模式
 */
@property (nonatomic,assign) BOOL strictMode;


-(void)close;

/**
 *  OPRepository初始化方法
 *
 *  @param dbPath  数据库路径
 *  @param tables  数据库表格定义
 *  @param version 数据库初始版本
 *
 *  @return OPRepository的实例
 */
-(instancetype)initWith:(NSString*) dbPath tables:(NSArray*)tables version:(int)version;


#pragma 同步更新方法，单个SQL
/**
 *  同步执行一个是更新操作
 *
 *  @param sql SQL语句
 *
 *  @return 返回是否执行成功
 */
-(BOOL)executeUpdate:(NSString*)sql;

/**
 *  同步执行一个是更新操作
 *
 *  @param sql  SQL语句
 *  @param args 参数列表
 *
 *  @return 返回是否执行成功
 */
-(BOOL)executeUpdate:(NSString*)sql withDictionaryArgs:(NSDictionary*)args;


/**
 *  将BLOCK里的数据库操作，全部归纳到一个事务中去
 *
 *  @param dbBlock BLOC行为
 *
 */
-(void)inTransaction:(void(^)(BOOL *rollback))dbBlock;

#pragma 同步查询
/**
 *  同步执行一个查询
 *
 *  @param sql 查询SQL
 *
 *  @return 返回查询结果，结果为NSArray，Array里面为NSDictionary
 */
-(NSArray*)executeQuery:(NSString*)sql;

/**
 *  同步执行一个查询
 *
 *  @param sql  查询SQL
 *  @param args 参数列表
 *
 *  @return 返回查询结果 ，结果为NSArray，Array里面为NSDictionary，是数据库的键值对
 */
-(NSArray*)executeQuery:(NSString*)sql withDictionaryArgs:(NSDictionary*)args;

#pragma 同步查询，单例
/**
 *  单例查询，当SQL语句仅返回一条数据时使用此方法
 *
 *  @param sql 查询SQL
 *
 *  @return 返回NSDictionary
 */
-(NSDictionary*)singleExecuteQuery:(NSString*)sql;

/**
 *  单例查询，当SQL语句仅返回一条数据时使用此方法
 *
 *  @param sql  SQL语句
 *  @param args 参数列表
 *
 *  @return 返回一个NSDictionary
 */
-(NSDictionary*)singleExecuteQuery:(NSString*)sql withDictionaryArgs:(NSDictionary*)args;

#pragma 同步查询，返回对象
/**
 *  同步查询，返回Model集合
 *
 *  @param sql            SQL语句
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返回一个数组，数组中为对象
 */
-(NSArray*)executeQuery:(NSString*)sql convertBlock:(id(^)(NSDictionary * result))convertBlock;


/**
 *  同步查询，返回Model集合
 *
 *  @param sql          SQL语句
 *  @param args         参数列表
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返回一个数组，数组中为对象
 */
-(NSArray*)executeQuery:(NSString *)sql withDictionaryArgs:(NSDictionary*)args convertBlock:(id (^)(NSDictionary* result))convertBlock;


#pragma 同步查询，对象且单例
/**
 *  同步查询，返回Model集合
 *
 *  @param sql            SQL语句
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返回一个对象
 */
-(id)singleExecuteQuery:(NSString*)sql convertBlock:(id(^)(NSDictionary * result))convertBlock;


/**
 *  同步查询，返回Model集合
 *
 *  @param sql          SQL语句
 *  @param args         参数列表
 *  @param convertBlock 用户提供NSDictionary到对象的整合block
 *
 *  @return 返返回一个对象
 */
-(id)singleExecuteQuery:(NSString *)sql withDictionaryArgs:(NSDictionary*)args convertBlock:(id (^)(NSDictionary* result))convertBlock;

/**
 *  同步查询数据库中某个表是否存在
 *
 *  @param tableName 表名
 *
 *  @return 返回结果
 */
-(BOOL)tableExists:(NSString*)tableName;

@end
