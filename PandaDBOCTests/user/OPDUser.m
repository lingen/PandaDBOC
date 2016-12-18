//
//  OPDUser.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/17.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import "OPDUser.h"

@implementation OPDUser

-(instancetype)initWithName:(NSString*)name age:(int)age weight:(double)weight moreInfo:(NSString*)moreInfo{
    if (self = [super init]) {
        _name = name;
        _age = age;
        _weight = weight;
        _moreInfo = moreInfo;
    }
    return self;
}

@end
