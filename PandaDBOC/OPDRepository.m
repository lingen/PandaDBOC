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
#import "OPDSQLiteManager.h"

static NSString* PANDA_VERSION_TABLE_NAME = @"PANDA_VERSION_";

//创建版本控制的语句
static NSString* CREATE_VERSION_TABLE = @"CREATE TABLE IF NOT EXISTS PANDA_VERSION_ (VALUE_ INT NOT NULL)";

//初始化版本控制的语句
static NSString* INIT_VERSION_TABLE_CONTENT = @"INSERT INTO PANDA_VERSION_ (VALUE_) values (%@)";

//查询当前的版本号
static NSString* QUERY_CURRENT_VERSION = @"SELECT VALUE_ FROM PANDA_VERSION_ LIMIT 1";

//更新版本SQL
static NSString* UPDATE_VERSION = @"UPDATE PANDA_VERSION_ SET VALUE_ = %d";

static NSString* DB_THREAD_MARK = @"PANDA DB OC THREAD";

static NSString* DB_QUEUE_NAME = @"PANDA DB OC QUEUE";

@interface OPDRepository()

@property (nonnull,nonatomic,strong) OPDSQLiteManager* sqliteManager;

@property (nonnull,nonatomic,strong) dispatch_queue_t dbQueue;

@property (nonnull,nonatomic,strong) NSArray* tables;

@property (nonatomic,assign) int version;

@end


@implementation OPDRepository

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
    if (self = [super init]) {
        _sqliteManager = [[OPDSQLiteManager alloc] initWithDBPath:dbPath];
        [_sqliteManager open];
        _tables = [tables copy];
        _version = version;
        _dbQueue = dispatch_queue_create([DB_QUEUE_NAME UTF8String], DISPATCH_QUEUE_SERIAL);
        
        [self p_initOrUpdate];
    }
    return self;
}

/*
 * 初始化数据库或升级数据库
 */
-(void)p_initOrUpdate{
    if ([self tableExists:PANDA_VERSION_TABLE_NAME]) {
        [self p_updateRepository];
    }else{
        [self p_initRepository];
    }
}

#pragma  mark 初始化数据库
-(void)p_initRepository{
    dispatch_sync(_dbQueue, ^{
        
        [_sqliteManager beginTransaction];
        
        //初始化版本号表
        BOOL success = [_sqliteManager executeUpdate:CREATE_VERSION_TABLE];
        if (success) {
            NSLog(@"Panda Success：初始化数据库，创建版本号表成功");
        }else{
            NSLog(@"Panda Error：初始化数据库，创建版本号表失败");
            [_sqliteManager rollback];
        }
        
        //初始化版本号的值
        success = [_sqliteManager executeUpdate:INIT_VERSION_TABLE_CONTENT params:@{@"value":@(_version)}];
        if (success) {
            NSLog(@"Panda Success：初始化版本值为:%@",@(_version));
        }else{
            NSLog(@"Panda Error：初始化版本值失败");
            [_sqliteManager rollback];
        }
        
        NSMutableString* createRepositorySqls = [[NSMutableString alloc] init];
        
        //初始化所有的表
        for (Class tableProtocolClass in _tables) {
            //进行数据库层的初始化操作
            if ([tableProtocolClass conformsToProtocol:@protocol(OPDTableProtocol)]) {
                OPDTable* opfTable = [tableProtocolClass performSelector:@selector(createTable)];
                //获取建表语句
                [createRepositorySqls appendString:[opfTable createTableSQL]];
                
                NSString* indexSQL = [opfTable createIndexSQL];
                if (indexSQL && ![indexSQL isEqualToString:@""]) {
                    //获取创建索引的语句
                    [createRepositorySqls appendString:indexSQL];
                }
            }
        }
        
        success = [_sqliteManager executeUpdate:[createRepositorySqls copy]];
        
        if (success) {
            NSLog(@"Panda Success:表初始化成功:%@",createRepositorySqls);
            [_sqliteManager commit];
        }else{
            NSLog(@"Panda Error:表初始化失败%@",createRepositorySqls);
            [_sqliteManager rollback];
        }
        
        NSLog(@"Panda Init Repository Success");
        
    });
}


-(void)p_updateRepository{
    dispatch_sync(_dbQueue, ^{
        [_sqliteManager beginTransaction];
        
        NSArray* result = [_sqliteManager executeQuery:QUERY_CURRENT_VERSION];
        
        int currentVersion = 1;
        if (result.count > 0) {
            NSDictionary* value = result[0];
            currentVersion = [value[@"value_"] intValue];
        }
        
        
        NSMutableArray *sqls = [[NSMutableArray alloc] init];

        //对于更新，也需要创建不存在的表
        for (Class tableProtocolClass in _tables) {
            //进行数据库层的初始化操作
            if ([tableProtocolClass conformsToProtocol:@protocol(OPDTableProtocol)]) {
                OPDTable* opfTable = [tableProtocolClass performSelector:@selector(createTable)];
                if (!opfTable) {
                    continue;
                }
                BOOL tableExist = [self p_tableExists:opfTable.tableName];
                
                if (!tableExist) {
                    //获取建表语句
                    [sqls addObject:[opfTable createTableSQL]];
                    NSString* indexSQL = [opfTable createIndexSQL];
                    if (indexSQL && ![indexSQL isEqualToString:@""]) {
                        //获取创建索引的语句
                        [sqls addObject:indexSQL];
                    }
                }
            }
        }
        
        //数据库升级行为
        for (int begin = currentVersion; begin <= _version - 1 ; begin++) {
            int end = begin + 1;
            
            //进行表更新操作
            for (Class tableProtocolClass in _tables) {
                //进行数据库层的初始化操作
                if ([tableProtocolClass conformsToProtocol:@protocol(OPDTableProtocol)]) {
                    NSArray* tableSQLs = [tableProtocolClass  performSelector:@selector(updateTable:toVersion:) withObject:@(begin) withObject:@(end)];
                    if (tableSQLs && tableSQLs.count > 0) {
                        [sqls addObjectsFromArray:tableSQLs];
                    }
                }
            }
        }
        
        //更新Version版本号
        NSString* updateVersionSQL = [NSString stringWithFormat:UPDATE_VERSION,_version];
        [sqls addObject:updateVersionSQL];
        
        
        BOOL success = [_sqliteManager executeUpdate:[sqls componentsJoinedByString:@";"]];
        
        if (success) {
            NSLog(@"Panda Success：数据库更新成功");
            [_sqliteManager commit];
        }else{
            NSLog(@"Panda Error：版本更新失败");
            [_sqliteManager rollback];
        }
    });
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
    __block BOOL success = NO;
    [self write:^(OPDSQLiteManager *sqliteManager) {
        success = [sqliteManager executeUpdate:sql];
    }];
    return success;
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
    __block BOOL success = NO;
    [self write:^(OPDSQLiteManager *sqliteManager) {
        success = [sqliteManager executeUpdate:sql params:args];
    }];
    return success;
}


#pragma 同步更新方法，多个SQL


/**
 *  将BLOCK里的数据库操作，全部归纳到一个事务中去
 *
 *  @param dbBlock BLOC行为
 *
 */
-(void)inTransaction:(void(^)(BOOL *rollback))dbBlock{
    __block BOOL rollback;
    if ([self isInTransaction]) {
        dbBlock(&rollback);
    }else{
        dispatch_sync(_dbQueue, ^{
            [self markInTrsaction];
            [_sqliteManager beginTransaction];
            dbBlock(&rollback);
            if (rollback) {
                [_sqliteManager rollback];
            }else{
                [_sqliteManager commit];
            }
            [self cancelMarkInTransaction];
        });
    }
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
    return [self executeQuery:sql withDictionaryArgs:nil];
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
    __block NSArray* values = nil;
    [self reader:^(OPDSQLiteManager *sqliteManager) {
        values = [_sqliteManager executeQuery:sql params:args];
    }];
    return values;
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
    return [self singleExecuteQuery:sql withDictionaryArgs:nil];
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
    __block NSDictionary* values = nil;
    [self reader:^(OPDSQLiteManager *sqliteManager) {
        NSArray* results = [_sqliteManager executeQuery:sql params:nil];
        if (results && results.count > 0) {
            values = results[0];
        }
    }];
    return values;
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
    return [self executeQuery:sql withDictionaryArgs:nil convertBlock:convertBlock];
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
    __block NSArray* values = nil;
    [self reader:^(OPDSQLiteManager *sqliteManager) {
        NSArray* results = [_sqliteManager executeQuery:sql params:args];
        NSMutableArray* converts = [[NSMutableArray alloc] init];
        for (NSDictionary* result in results) {
            [converts addObject:convertBlock(result)];
        }
        values = [converts copy];
    }];
    return values;
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
    return [self singleExecuteQuery:sql withDictionaryArgs:nil convertBlock:convertBlock];
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
    NSArray* values = [self executeQuery:sql withDictionaryArgs:args convertBlock:convertBlock];
    if (values && values.count >0) {
        return values[0];
    }
    return nil;
}

/**
 *  同步查询数据库中某个表是否存在
 *
 *  @param tableName 表名
 *
 *  @return 返回结果
 */
-(BOOL)tableExists:(NSString*)tableName{
    __block BOOL tableExists = NO;
    
    dispatch_sync(_dbQueue, ^{
        tableExists = [self p_tableExists:tableName];
    });
    return tableExists;
}

-(BOOL)p_tableExists:(NSString*)tableName{
    NSString* querySQL = @"SELECT * FROM sqlite_master WHERE type='table' AND name=:name COLLATE NOCASE";
    NSArray* result = [_sqliteManager executeQuery:querySQL params:@{
                                                                     @"name":tableName
                                                                     }];
    if (result && result.count > 0) {
        return YES;
    }
    return NO;
}

-(void)close{
    dispatch_sync(_dbQueue, ^{
        [_sqliteManager close];
    });
}

#pragma mark对读写的封装

-(void)reader:(void (^)(OPDSQLiteManager* sqliteManager))readBlock{
    if ([self isInTransaction]) {
        readBlock(_sqliteManager);
    }else{
        dispatch_sync(_dbQueue, ^{
            [self markInTrsaction];
            readBlock(_sqliteManager);
            [self cancelMarkInTransaction];
        });
    }
}

-(void)write:(void (^)(OPDSQLiteManager* sqliteManager))writeBlock{
    if ([self isInTransaction]) {
        writeBlock(_sqliteManager);
    }else{
        dispatch_sync(_dbQueue, ^{
            [self markInTrsaction];
            [_sqliteManager beginTransaction];
            writeBlock(_sqliteManager);
            [_sqliteManager commit];
            [self cancelMarkInTransaction];
        });
    }
}



#pragma mark 对事务的判断

-(void)markInTrsaction{
    [[NSThread currentThread] setName:DB_THREAD_MARK];
}

-(void)cancelMarkInTransaction{
    [[NSThread currentThread] setName:nil];
}

-(BOOL)isInTransaction{
    return [DB_THREAD_MARK isEqualToString:[NSThread currentThread].name];
}

@end
