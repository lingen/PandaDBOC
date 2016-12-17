//
//  OPDSqlAndParams.h
//  PandaDBOC
//
//  Created by lingen on 2016/12/17.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPDSqlAndParams : NSObject

@property (nonnull,nonatomic,strong) NSString* sql;

@property (nonnull,nonatomic,strong) NSDictionary* params;

-(nonnull instancetype)initWithSql:(nonnull NSString*)sql andParams:(nonnull NSDictionary*)params;

@end
