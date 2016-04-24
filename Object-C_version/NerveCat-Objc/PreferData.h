//
//  PerferData.h
//  NerveCat-Objc
//
//  Created by Light on 12-20.
//  Copyright © 2015年 Light. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferData : NSObject

/** 标记是否音乐在播放 */
@property (assign, nonatomic) BOOL isPlayMusic;
@property (assign, nonatomic) NSInteger bestScore;
@property (assign, nonatomic) NSInteger curScore;

/** 返回对象实例 */
+ (instancetype)preferData;

- (NSString *)bestScoreText;
- (NSString *)curScoreText;

// 声明单例方法
//interfaceSingleton(PerferData)

@end
