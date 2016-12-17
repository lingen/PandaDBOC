//
//  OPDSQLiteManager.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/14.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import "OPDSQLiteManager.h"
#import <sqlite3.h>


static NSString* BEGIN_TRANSACTION = @"BEGIN TRANSACTION;";

static NSString* COMMIT = @"COMMIT;";

static NSString* ROLLBACK = @"ROLLBACK;";

static NSString* TYPE_TEXT = @"TEXT";

static NSString* TYPE_INT = @"INT";

static NSString* TYPE_REAL = @"REAL";

static NSString* TYPE_BLOB = @"BLOB";

@interface OPDSQLiteManager()


/*
 * DB File Location
 */
@property (nonatomic, strong) NSString *dbFilePath;

@property (nonatomic,assign) sqlite3 *sqlite3Database;

@property (nonatomic,assign) BOOL inTransaction;

@property (nonatomic,strong) NSString* errorMsg;

@end

@implementation OPDSQLiteManager


-(instancetype)initWithDBFileName:(NSString*)dbFileName{
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        _dbFilePath = [documentsDirectory stringByAppendingPathComponent:dbFileName];
    }
    return self;
}

-(instancetype)initWithDBPath:(NSString*)dbPath{
    if (self = [super init]) {
        _dbFilePath = dbPath;
        
    }
    return self;
}

-(BOOL)open{
    if (sqlite3_open([_dbFilePath UTF8String], &_sqlite3Database) == SQLITE_OK) {
        return YES;
    }
    return NO;
}

-(void)close{
    sqlite3_close(_sqlite3Database);
}

/*
 * Execute a update for a sql
 */
-(BOOL)executeUpdate:(NSString*)sql{
    return [self executeUpdate:sql params:nil];
}

#pragma mark UPDATE
/*
 * Execute a update for a sql and params,the params is dictionary
 */
-(BOOL)executeUpdate:(NSString*)sql params:(NSDictionary<NSString*,NSObject*>*)params{
    
    sqlite3_stmt *stmt = nil;
    
    int prepare_result = sqlite3_prepare_v2(_sqlite3Database, [sql UTF8String], -1, &stmt, NULL);
    
    if (prepare_result != SQLITE_OK) {
        [self p_checkError];
        return NO;
    }
    
    [self bindParams:stmt params:params];
    
    int step_result = sqlite3_step(stmt);
    
    sqlite3_finalize(stmt);
    
    if (step_result == SQLITE_OK || step_result == SQLITE_DONE) {
        return YES;
    }else{
        [self p_checkError];
    }
    
    return NO;
}


-(void)bindParams:(sqlite3_stmt*)stmt params:(NSDictionary<NSString*,NSObject*>*)params{
    if (!params) {
        return;
    }
    
    int count = sqlite3_bind_parameter_count(stmt);
    
    if (count > 0) {
        for(int i=1; i<= count;i++){
            NSString* name = [NSString stringWithUTF8String:sqlite3_bind_parameter_name(stmt, i)];
            
            name = [name substringFromIndex:1];
            
            NSObject* value = params[name];
            
            if ([value isKindOfClass:[NSString class]]) {
                NSString* stringValue = (NSString*)value;
                sqlite3_bind_text(stmt, i, [stringValue UTF8String], -1, SQLITE_TRANSIENT);
            }
            else if([value isKindOfClass:[NSNumber class]]){
                NSNumber* numberValue = (NSNumber*)value;
                if(CFNumberIsFloatType((CFNumberRef)numberValue)){
                    double doublueValue = [numberValue doubleValue];
                    sqlite3_bind_double(stmt, i, doublueValue);
                }
                else{
                    int intValue = [numberValue intValue];
                    sqlite3_bind_int(stmt, i, intValue);
                }
            }
            else if([value isKindOfClass:[NSData class]]){
                NSData* dataValue = (NSData*)value;
                sqlite3_bind_blob(stmt, 5, [dataValue bytes], (int)[dataValue length], SQLITE_TRANSIENT);
            }
            
            else if([value isKindOfClass:[NSArray class]]){
                NSArray* arrayValue = (NSArray*)value;
                NSString* stringValue = [self parseArray:arrayValue];
                sqlite3_bind_text(stmt, i, [stringValue UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            else if([value isKindOfClass:[NSMutableArray class]]){
                NSArray* arrayValue = [((NSMutableArray*)value) copy];
                NSString* stringValue = [self parseArray:arrayValue];
                sqlite3_bind_text(stmt, i, [stringValue UTF8String], -1, SQLITE_TRANSIENT);
            }
        }
    }
}

-(NSString*)parseArray:(NSArray*)values{
    NSMutableString* result = [[NSMutableString alloc] init];
    
    for (int i =0; i < values.count; i++) {
        NSString* value = [values[i] description];
        [result appendString:value];
        
        if (i != values.count - 1) {
            [result appendString:@","];
        }
    }
    
    return [result copy];
}

#pragma mark QUERY

/*
 * Execute a query
 */
-(NSArray<NSDictionary<NSString*,NSObject*>*>*)executeQuery:(NSString*)querySQL{
    return [self executeQuery:querySQL params:nil];
}

/*
 * Execute a query with a param
 */
-(NSArray<NSDictionary<NSString*,NSObject*>*>* )executeQuery:(NSString*)querySQL params:(NSDictionary<NSString*,NSObject*>*)params{
    sqlite3_stmt *stmt = nil;
    
    int prepare_result = sqlite3_prepare_v2(_sqlite3Database, [querySQL UTF8String], -1, &stmt, NULL);
    
    if (prepare_result != SQLITE_OK) {
        [self p_checkError];
        return nil;
    }
    
    [self bindParams:stmt params:params];
    
    int step_result = sqlite3_step(stmt);
    
    NSMutableArray<NSDictionary<NSString*,NSObject*>*>* results = [[NSMutableArray alloc] init];
    while(step_result == SQLITE_ROW) {
        NSMutableDictionary<NSString*,NSObject*>* rowData = [[NSMutableDictionary alloc] init];
        int cloumnCount = sqlite3_column_count(stmt);
        for(int index =0; index < cloumnCount; index++){
            NSString* name = [NSString stringWithUTF8String:sqlite3_column_name(stmt, index)];
            id value = [self toOCValue:stmt index:index];
            rowData[name] = value;
        }
        [results addObject:rowData];
        step_result = sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    return [results copy];
}

-(id)toOCValue:(sqlite3_stmt*)stmt index:(int)index{
    
    NSString* columnType = [[NSString stringWithUTF8String:sqlite3_column_decltype(stmt, index)] uppercaseString];
    
    if ([columnType isEqualToString:TYPE_TEXT]) {
        char *dbDataAsChars = (char *)sqlite3_column_text(stmt, index);
        return [NSString  stringWithUTF8String:dbDataAsChars];
    }
    else if([columnType isEqualToString:TYPE_INT]) {
        int vv = sqlite3_column_int(stmt, index);
        return [NSNumber numberWithInt:vv];
    }
    
    else if([columnType isEqualToString:TYPE_REAL]) {
        double vv = sqlite3_column_double(stmt, index);
        return [NSNumber numberWithDouble:vv];
    }
    
    else if([columnType isEqualToString:TYPE_BLOB]){
        const void *ptr = sqlite3_column_blob(stmt, index);
        int size = sqlite3_column_bytes(stmt, index);
        return [[NSData alloc] initWithBytes:ptr length:size];
    }
    
    return nil;
    
}

-(void)p_checkError{
    _errorMsg = [NSString stringWithUTF8String:sqlite3_errmsg(_sqlite3Database)];
    NSLog(@"PANDA DB ERROR:%@",_errorMsg);
}

#pragma mark 事务控制

-(void)beginTransaction{
    sqlite3_exec(_sqlite3Database,[BEGIN_TRANSACTION UTF8String], nil, nil, nil);
    _inTransaction = YES;
}

-(void)commit{
    sqlite3_exec(_sqlite3Database, [COMMIT UTF8String], nil, nil, nil);
    _inTransaction = NO;
}

-(void)rollback{
    sqlite3_exec(_sqlite3Database, [COMMIT UTF8String], nil, nil, nil);
    _inTransaction = NO;
    
}

-(BOOL)isInTransaction{
    return _inTransaction;
}


@end
