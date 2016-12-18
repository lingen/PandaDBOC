//
//  OPDUser.h
//  PandaDBOC
//
//  Created by lingen on 2016/12/17.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPDUser : NSObject

@property (nonnull,nonatomic,strong) NSString* name;

@property (nonatomic,assign) int age;

@property (nonatomic,assign) double weight;

@property (nullable,nonatomic,strong) NSString* moreInfo;

-(instancetype)initWithName:(NSString*)name age:(int)age weight:(double)weight moreInfo:(NSString*)moreInfo;

@end
