//
//  AudioTool.h
//  NerveCat-Objc
//
//  Created by Light on 4-18.
//  Copyright © 2016年 Light. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioTool : NSObject

+ (void)playSoundWithSoundName:(NSString *)soundName;

/** loopNum 为负数循环播放，为0是播放1次，以此类推 */
+ (void)playMusicWithMusicName:(NSString *)musicName loopNum:(NSInteger)loopNum;
+ (void)pauseMusicWithMusicName:(NSString *)musicName;
@end
