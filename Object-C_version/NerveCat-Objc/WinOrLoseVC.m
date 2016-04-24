//
//  WinOrLoseVC.m
//  NerveCat-Objc
//
//  Created by Light on 12-19.
//  Copyright © 2015年 Light. All rights reserved.
//

#import "WinOrLoseVC.h"

@interface WinOrLoseVC ()
@property (weak, nonatomic) IBOutlet UIImageView *winBoard;
@property (weak, nonatomic) IBOutlet UIImageView *loseBoard;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;
@property (weak, nonatomic) IBOutlet UILabel *loseLabel;

@property (strong, nonatomic) NSArray *loseText;
@end

@implementation WinOrLoseVC

+ (instancetype)winOrLoseViewController{
    return [[self alloc] init];
}

- (NSArray *)loseText{
    if (_loseText == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"loseText" ofType:@".plist"];
        _loseText = [NSArray arrayWithContentsOfFile:path];
    }
    return _loseText;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isPlayerWin) {
        self.winBoard.hidden = NO;
        self.winLabel.hidden = NO;
        self.winLabel.text = [NSString stringWithFormat:@"本次成绩 %ld 步\n最高成绩 %ld 步",self.currentScore,self.highScore];
        
        self.loseBoard.hidden = YES;
        self.loseLabel.hidden = YES;
    }else{
        self.loseBoard.hidden = NO;
        self.loseLabel.hidden = NO;
        [self catLoseAndShout];
        
        self.winBoard.hidden = YES;
        self.winLabel.hidden = YES;
        
    }
}

- (void)catLoseAndShout{
    int index = arc4random_uniform((u_int32_t)self.loseText.count);
    self.loseLabel.text = self.loseText[index];
}

- (void)dealloc{
    NSLog(@"WinOrLoseVC Dead!");
}

@end
