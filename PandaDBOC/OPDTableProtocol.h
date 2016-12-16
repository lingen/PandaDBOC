//
//  OPTableProtocol.h
//  Pods
//
//  Created by lingen on 16/3/21.
//
//

#import <Foundation/Foundation.h>

@class OPDTable;

@protocol OPDTableProtocol <NSObject>


@required

/*
 * 实现此方法，用于数据库表的创建
 */
+(OPDTable*)createTable;

/*
 *实现此方法，用于数据库表的升级功能
 */
+(NSArray*)updateTable:(NSNumber *)fromVersion toVersion:(NSNumber *)toVersion;


@end
