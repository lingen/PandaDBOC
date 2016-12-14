//
//  OPDSQLiteManager.h
//  PandaDBOC
//
//  Created by lingen on 2016/12/14.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPDSQLiteManager : NSObject

-(instancetype)initWithDBFileName:(NSString*)dbFileName;

/*
 * open the connection with db file
 */
-(BOOL)open;

/*
 * close the db connection
 */
-(void)close;

/*
 * execute a update for a sql
 */
-(BOOL)executeUpdate:(NSString*)sql;

/*
 * execute a update for a sql and params,the params is dictionary
 */
-(BOOL)executeUpdate:(NSString*)sql params:(NSDictionary<NSString*,NSObject*>*)params;

/*
 * execute a query
 */
-(NSArray<NSDictionary<NSString*,NSObject*>*>*)executeQuery:(NSString*)querySQL;

/*
 * execute a query with a param
 */
-(NSArray<NSDictionary<NSString*,NSObject*>*>*)executeQuery:(NSString*)querySQL params:(NSDictionary<NSString*,NSObject*>*)params;

/*
 * begin A Transaction
 */
-(void)beginTransaction;

/*
 * a transaction success,commit it
 */
-(void)commit;

/*
 * a transaction fail,rollback it
 */
-(void)rollback;

/*
 * check if is it current db connection in transactiono
 */
-(BOOL)isInTransaction;

@end
