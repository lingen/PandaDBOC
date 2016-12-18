//
//  OPDUserRepository.h
//  PandaDBOC
//
//  Created by lingen on 2016/12/18.
//  Copyright © 2016年 lingen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPDRepository;

@interface OPDUserRepository : NSObject

@property (nonatomic,strong,nonnull) OPDRepository* repository;

+(instancetype)sharedInstance;

@end
