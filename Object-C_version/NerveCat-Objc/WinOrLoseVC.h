//
//  WinOrLoseVC.h
//  NerveCat-Objc
//
//  Created by Light on 12-19.
//  Copyright © 2015年 Light. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinOrLoseVC : UIViewController

@property (assign, nonatomic) BOOL isPlayerWin;
@property (assign, nonatomic) NSInteger highScore;
@property (assign, nonatomic) NSInteger currentScore;

+ (instancetype)winOrLoseViewController;

@end
