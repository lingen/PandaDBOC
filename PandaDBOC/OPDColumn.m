//
//  OPFColumn.m
//  Pods
//
//  Created by lingen on 16/3/23.
//
//

#import "OPDColumn.h"


static const NSString* COLUMN_TEXT = @"text";

static const NSString* COLUMN_BLOB = @"blob";

static const NSString* COLUMN_INTEGER = @"int";

static const NSString* COLUMN_REAL = @"real";

@implementation OPDColumn

/**
 *  定义一个列，指定名称与类型
 *
 *  @param name 列名称
 *  @param type 类型
 *
 *  @return 返回列定义
 */
-(instancetype)initWith:(NSString*)name type:(OPDColumnType)type{
    if (self = [super init]) {
        _name = name;
        _columnType = type;
        return self;
    }
    return nil;
}

/**
 *  定义一个列，指定名称与类型且不允许为空
 *
 *  @param name 列名称
 *  @param type 类型
 *
 *  @return 返回一个列定义
 */
-(instancetype)initNotNullColumn:(NSString*)name type:(OPDColumnType)type{
    if (self = [self init]) {
        _name = name;
        _columnType = type;
        _notNull = YES;
        return self;
    }
    return nil;
}

/**
 *  获取此列的创建表的语句
 *
 *  @return 返回建列的SQL语句
 */
-(NSString*)columnCreateSQL{
    NSString* sql = [NSString stringWithFormat:@"%@ %@ %@",_name,[self p_columnTypeString],_notNull?@"not null":@""];
    return sql;
}

/**
 *  返回不同类型的字符表示
 *
 */
-(NSString*)p_columnTypeString{
    if (_columnType == OPDColumnText) {
        return [COLUMN_TEXT copy];
    }
    
    if (_columnType == OPDColumnInteger) {
        return [COLUMN_INTEGER copy];
    }
    
    if (_columnType == OPDColumnReal) {
        return [COLUMN_REAL copy];
    }
    
    if (_columnType == OPDColumnBlob) {
        return [COLUMN_BLOB copy];
    }
    return nil;
}
@end
