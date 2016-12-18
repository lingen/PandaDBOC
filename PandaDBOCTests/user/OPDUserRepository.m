//
//  OPDUserRepository.m
//  PandaDBOC
//
//  Created by lingen on 2016/12/18.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import "OPDUserRepository.h"
#import "OPDRepository.h"
#import "OPDUser+DB.h"

@implementation OPDUserRepository

+(instancetype)sharedInstance{
    static OPDUserRepository* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OPDUserRepository alloc] init];
        [instance initRepository];
    });
    return instance;
}


-(void)initRepository{
    NSString* dbName = @"user.db";
    

    NSArray* tables = @[[OPDUser class]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dbFilePath = [documentsDirectory stringByAppendingPathComponent:dbName];
    
    _repository = [[OPDRepository alloc] initWith:dbFilePath tables:tables version:1];
    
    NSLog(@"初始化数据库成功");
    
}
@end
