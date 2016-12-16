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

@end
