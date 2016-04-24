//
//  PerferData.m
//  NerveCat-Objc
//
//  Created by Light on 4-20.
//  Copyright © 2016年 Light. All rights reserved.
//

#import "PreferData.h"

@implementation PreferData

//implememtationSingleton(PreferData)
+ (instancetype)preferData{
    PreferData *data = [[self alloc] init];
    
    // 拿到系统偏好设置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 不管存什么对象系统会自动识别，这里即使是包装成 NSNumber对象也不会返回 nil，而是 0
    NSInteger score = [userDefaults integerForKey:@"bestScore"];
    
    data.curScore = 0;
    if (score == 0) {
        // 如果没有设定初始值
        data.bestScore = 99;
        data.isPlayMusic = YES;
    }else{
        // 有直接赋值，使用指针，避开点语法的重复设置
        data->_bestScore = score;
        data->_isPlayMusic = [userDefaults boolForKey:@"isPlayMusic"];
    }
    
    return data;
}


- (void)setIsPlayMusic:(BOOL)isPlayMusic{
    _isPlayMusic = isPlayMusic;
    [[NSUserDefaults standardUserDefaults] setBool:_isPlayMusic forKey:@"isPlayMusic"];
}

/** 历史最小的步数是最小成绩 */
- (void)setBestScore:(NSInteger)bestScore{
    _bestScore = bestScore;
    [[NSUserDefaults standardUserDefaults] setInteger:_bestScore forKey:@"bestScore"];
}

- (NSString *)bestScoreText{
    return [NSString stringWithFormat:@"最高分 %ld 步", (long)_bestScore];
}


- (NSString *)curScoreText{
    return [NSString stringWithFormat:@"已走 %ld %@", _curScore, @"步"];
}

@end
