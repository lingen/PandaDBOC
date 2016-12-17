//
//  OPDSqlAndParams.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/17.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import "OPDSqlAndParams.h"

@implementation OPDSqlAndParams

-(nonnull instancetype)initWithSql:(nonnull NSString*)sql andParams:(nonnull NSDictionary*)params{
    if (self = [super init]) {
        _sql = sql;
        _params = params;
    }
    return self;
}

@end
