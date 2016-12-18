//
//  OPDUser+DB.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/17.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import "OPDUser+DB.h"
#import "OPDColumn.h"
#import "OPDTable.h"

@implementation OPDUser (DB)

/*
 * 实现此方法，用于数据库表的创建
 */
+(OPDTable*)createTable{
    OPDColumn* name = [[OPDColumn alloc] initNotNullColumn:@"name_" type:OPDColumnText];
    OPDColumn* age = [[OPDColumn alloc] initNotNullColumn:@"age_" type:OPDColumnInteger];
    OPDColumn* weight = [[OPDColumn alloc] initWith:@"weight_" type:OPDColumnReal];
    OPDColumn* more = [[OPDColumn alloc]  initWith:@"more_" type:OPDColumnBlob];
    
    OPDTable* table = [[OPDTable alloc] initWith:@"user_" columns:@[name,age,weight,more]];
    return table;
}

/*
 *实现此方法，用于数据库表的升级功能
 */
+(NSArray*)updateTable:(NSNumber *)fromVersion toVersion:(NSNumber *)toVersion{
    return nil;
}

@end
