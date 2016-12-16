//
//  OPFColumn.h
//  Pods
//
//  Created by lingen on 16/3/23.
//
//

#import <Foundation/Foundation.h>
/**
 *  列类型定义
 */
typedef NS_ENUM(NSInteger,OPDColumnType) {
    /** *  文本类型 */
    OPDColumnText,
    
    /** *  int型 */
    OPDColumnInteger,
    
    /** *  blob */
    OPDColumnBlob,
    
    /** *  Real，浮点类型 */
    OPDColumnReal
};

@interface OPDColumn : NSObject


/**
 *  数据库列名称
 */
@property (nonatomic,strong) NSString* name;

/**
 *  列类型
 */
@property (nonatomic,assign) OPDColumnType columnType;

/**
 *  列是否允许为空
 */
@property (nonatomic,assign) BOOL notNull;


/**
 *  定义一个列，指定名称与类型
 *
 *  @param name 列名称
 *  @param type 类型
 *
 *  @return 返回列定义
 */
-(instancetype)initWith:(NSString*)name type:(OPDColumnType)type;

/**
 *  定义一个列，指定名称与类型且不允许为空
 *
 *  @param name 列名称
 *  @param type 类型
 *
 *  @return 返回一个列定义
 */
-(instancetype)initNotNullColumn:(NSString*)name type:(OPDColumnType)type;

/**
 *  获取此列的创建表的语句
 *
 *  @return 返回建列的SQL语句
 */
-(NSString*)columnCreateSQL;


@end
