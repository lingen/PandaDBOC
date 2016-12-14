//
//  SQLiteManager.h
//  PandaDBOC
//
//  Created by lingen on 2016/12/14.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SQLiteManager : NSObject

-(instancetype)initWithDBFileName:(NSString*)dbFileName;

/*
 * Open the connection with db file
 */
-(BOOL)open;

/*
 * Close the db connection
 */
-(void)close;

/*
 * Execute a update for a sql
 */
-(BOOL)executeUpdate:(NSString*)sql;

/*
 * Execute a update for a sql and params,the params is dictionary
 */
-(BOOL)executeUpdate:(NSString*)sql params:(NSDictionary<NSString*,NSObject*>*)params;

/*
 * Execute a query
 */
-(NSArray<NSDictionary<NSString*,NSObject*>*>*)executeQuery:(NSString*)querySQL;

/*
 * Execute a query with a param
 */
-(NSArray<NSDictionary<NSString*,NSObject*>*>*)executeQuery:(NSString*)querySQL params:(NSDictionary<NSString*,NSObject*>*)params;

-(void)beginTransaction;

-(void)commit;

-(void)rollback;


@end
