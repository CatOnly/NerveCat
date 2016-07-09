//
//  AudioTool.m
//  NerveCat-Objc
//
//  Created by Light on 12-18.
//  Copyright © 2015年 Light. All rights reserved.
//

#import "AudioTool.h"
#import <AVFoundation/AVFoundation.h>
static NSMutableDictionary *_soundIDs;
static NSMutableDictionary *_players;

@implementation AudioTool

// 类初始化
+ (void)initialize{
    _soundIDs = [NSMutableDictionary dictionary];
    _players = [NSMutableDictionary dictionary];
}

/**
 *  限制：
 *  声音长度要小于 30 秒
 *  In linear PCM 或者 IMA4 (IMA/ADPCM) 格式的
 *  打包成 .caf, .aif, 或者 .wav 的文件
 *  不能控制播放的进度
 *  调用方法后立即播放声音
 *  没有循环播放和立体声控制
 */
+ (void)playSoundWithSoundName:(NSString *)soundName{
    // 1. 定义 SystemSoundID
    SystemSoundID soundID = 0;
    // 2. 从字典取对应的 soundID，如果是 nil说明没有存发
    soundID = [_soundIDs[soundName] unsignedIntValue];
    if (soundID == 0){
        CFURLRef url =  (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        
        if (url == nil){
            NSLog(@"%s 文件路径获取失败, 播放音乐名:%@",__func__, soundName);
            return;
        }
        
        AudioServicesCreateSystemSoundID(url, &soundID);
        
        // 将 soundID 存入字典
        [_soundIDs setObject:@(soundID) forKey:soundName];
    }
    
    // 3. 播放音效
    AudioServicesPlaySystemSound(soundID);
}

+ (void)playMusicWithMusicName:(NSString *)musicName loopNum:(NSInteger)loopNum{
    // 1.定义播放器
    AVAudioPlayer *player = nil;

    // 2.从字典中取player,如果取出出来是空,则对应创建对应的播放器
    player = _players[musicName];
    if (player == nil) {
        // 2.1.获取对应音乐资源
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
        
        if (fileUrl == nil){
            NSLog(@"%s 文件路径获取失败, 播放音乐名:%@, 循环次数:%ld",__func__, musicName, (long)loopNum);
            return;
        }
        
        // 2.2.创建对应的播放器
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        player.numberOfLoops = loopNum;
        // 2.3.将player存入字典中
        [_players setObject:player forKey:musicName];

        // 2.4.准备播放
        [player prepareToPlay];
    }
    // 3.播放音乐
    [player play];
}

+ (void)pauseMusicWithMusicName:(NSString *)musicName{
    assert(musicName);
    
    // 1.取出对应的播放
    AVAudioPlayer *player = _players[musicName];
    
    // 2.判断player是否nil
    if (player) {
        [player pause];
    }
}

@end

