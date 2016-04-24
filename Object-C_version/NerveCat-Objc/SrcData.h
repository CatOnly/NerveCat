//
//  SrcData.h
//  NerveCat-Objc
//
//  Created by Light on 4-20.
//  Copyright © 2016年 Light. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareSingleton.h"

@interface SrcData : NSObject

@property (strong, nonatomic) NSString *imgBoardLose;
@property (strong, nonatomic) NSString *imgBoardWin;

@property (strong, nonatomic) NSString *imgCatAngry;
@property (strong, nonatomic) NSString *imgCatDefault;
@property (strong, nonatomic) NSString *imgCatRight;
@property (strong, nonatomic) NSString *imgCatLeft;

@property (strong, nonatomic) NSString *imgBtnStart;
@property (strong, nonatomic) NSString *imgBtnPlay;
@property (strong, nonatomic) NSString *imgBtnPause;

@property (strong, nonatomic) NSString *soundLose;
@property (strong, nonatomic) NSString *soundWin;
@property (strong, nonatomic) NSString *soundClick;
@property (strong, nonatomic) NSString *soundTap;
@property (strong, nonatomic) NSString *soundBGM;

+ (instancetype)srcWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

/** 返回单例资源对象 */
+ (instancetype)srcData;

interfaceSingleton(SrcData)
@end
