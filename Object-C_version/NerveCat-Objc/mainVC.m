//
//  ViewController.m
//  NerveCat-Objc
//
//  Created by Light on 12-15.
//  Copyright © 2015年 Light. All rights reserved.
//

#import "mainVC.h"
#import "CircleBtn.h"
#import "CatImgView.h"
#import "WinOrLoseVC.h"
#import "WelcomeView.h"

#import "PreferData.h"
#import "SrcData.h"
#import "AudioTool.h"

@interface mainVC ()

@property (weak, nonatomic) IBOutlet UILabel *curStepNumText;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreText;
@property (weak, nonatomic) IBOutlet UIView *gameView;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

@property (assign, nonatomic) BOOL isPlay;

/** 当前已走步数 */
@property (assign, nonatomic) NSInteger currentStepNum;

/** 游戏偏好设置 */
@property (strong, nonatomic) PreferData *prefer;
/** 游戏资源 */
@property (strong, nonatomic) SrcData *source;

/** 猫的位置 */
@property (weak, nonatomic) CatImgView *cat;
/** 所有圆的集合，二维数组 */
@property (strong, nonatomic) NSMutableArray *circles;

@property (weak, nonatomic) UIButton *startBtn;
@property (weak, nonatomic) WelcomeView *welcomeView;
@property (strong, nonatomic) WinOrLoseVC *resultVC;

@end

@implementation mainVC

- (PreferData *)prefer{
    if (_prefer == nil) {
        _prefer = [PreferData preferData];
    }
    return _prefer;
}

- (SrcData *)source{
    if (_source == nil) {
        _source = [SrcData srcData];
    }
//    NSLog(@"%@ at %s",_source,__func__);
    return _source;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isPlay = self.prefer.isPlayMusic;
    [self.playOrPauseBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [self playBGMIfCan: self.isPlay];

    
    // 创建圆的二维数组
    self.circles = [NSMutableArray arrayWithCapacity:CircleBtnDefaultRowMax];
    
    // 将每个圆添加到 窗口上
    for (NSMutableArray *aRow in self.circles) {
        for (CircleBtn *circle in aRow) {
            [_gameView addSubview: circle];
        }
    }
    
    // 得到猫的初始索引
    NSInteger idx = CircleBtnDefaultRowMax / 2;
    // 创建猫
    self.cat = [CatImgView catWithCircle:self.circles[idx][idx] scale:1.2 xOffset:0 yOffset:-20];
    // 将 猫添加到 GameView中
    [self.gameView addSubview: self.cat];

    // 更新整个游戏界面
    [self updateView];
    
#warning test using, you can delete these code after test done
    [[NSUserDefaults standardUserDefaults] setInteger:99 forKey:@"bestScore"]; // 偏好重置「测试用」
    
    WelcomeView *v = [WelcomeView welcomeView];
    self.welcomeView = v;
    [self.view addSubview: v];
    
    // 添加 按钮循环动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.toValue = @0.8;
    anim.duration = 0.7;
    anim.repeatCount = MAXFLOAT;
    [self.startBtn.layer addAnimation:anim forKey:nil];

}

- (void)updateView{
    // 显示最高分
    self.bestScoreText.text = self.prefer.bestScoreText;
    self.currentStepNum = 0;
    self.prefer.curScore = 0;
    self.curStepNumText.text = self.prefer.curScoreText;

    [self updateGameView];
}

#pragma mark - 圆 的事件、设置、所有圆状态的刷新
// 刷新所有的圆 设置障碍物
- (void)updateGameView{
    // 1. 还原所有 圆的状态
    for (NSMutableArray *aRow in self.circles) {
        for (CircleBtn *c in aRow) {
            c.cost = CircleBtnDefaultCost;
            c.distance = CircleBtnDefaultPath;
            c.circleState = CircleBtnStateNormal;
        }
    }
    
    // 2. 重新设置 猫的位置和状态
    CircleBtn *centerCircle = self.circles[CircleBtnDefaultRowMax/2][CircleBtnDefaultRowMax/2];
    self.cat.circle = centerCircle;
    self.cat.isEnclose = NO;
    
    // 3. 重新设置 selected状态的障碍物
    NSInteger gameLevel = 2;
    for (NSMutableArray *aRow in self.circles) {
        for (CircleBtn *c in aRow) {
            if (c.circleState != CircleBtnStateCatHold  && arc4random_uniform(10) < gameLevel) {
                c.circleState = CircleBtnStateSelected;
            }
        }
    }
    //  4. 更新舞台权值
    [self updatePathOrCostForCircles:self.circles];
}

- (void)setCircles:(NSMutableArray *)circles{
    _circles = circles;
    
    NSInteger rowMax = CircleBtnDefaultRowMax;
    CGFloat   border = 5;
    CGFloat interval = 5;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 2*border - interval*(rowMax-1)) / (rowMax + 0.5);
    CGFloat xOffset = 0;
    
    for (NSInteger i = 0; i < rowMax; i++) {
        // 创建每一行的数组
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSInteger j = 0; j < rowMax; j++) {
            // 计算偏移量
            xOffset = i%2 == 0 ? border: (border + width * 0.5);
            // 计算位置
            CGPoint center = CGPointMake(xOffset + j * (width + interval), i * width);
            // 得到圆
            CircleBtn *c = [CircleBtn circleBtnWithCenter:center width:width row:i col:j];
            // 给圆添加监听
            [c addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            // 给每一行的数组赋值
            [array addObject:c];
        }
        // 将 行数组添加到 总数组中
        [_circles addObject:array];
    }
}

// 点击后执行的操作顺序不能变
- (void)click:(CircleBtn *)circle{
    if (circle.circleState == CircleBtnStateNormal) {
        // 1. 将选择的圆的状态改变
        circle.circleState = CircleBtnStateSelected;
        
        // 2. 更新所有圆的信息
        [self updatePathOrCostForCircles:self.circles];
        
        // 3. 猫根据现有的状况做出判断
        CircleBtn *nextCircle = [self.cat getNextCircleFromCircles:self.circles];
        if (nextCircle == nil) {
            [AudioTool playMusicWithMusicName:self.source.soundWin loopNum:0];
            [self playerWinGame];
            
        }else if([nextCircle isBoundary]){
            [AudioTool playMusicWithMusicName:self.source.soundLose loopNum:0];
            [self.cat catGoToCircle:nextCircle];
            [self updateCurrentScore];
            [self playerLoseGame];
            
        }else{
            [AudioTool playMusicWithMusicName:self.source.soundClick loopNum:0];
            [self.cat catGoToCircle:nextCircle];
            [self updateCurrentScore];
        }
    }else{
        [AudioTool playMusicWithMusicName:self.source.soundTap loopNum:0];
    }
}

// 根据所有圆的索引 判断更新的权值「含有测试代码」
- (void)updatePathOrCostForCircles:(NSMutableArray *)circles{
    if (self.cat.isEnclose){
        [mainVC updateCostForCircles:circles];
#warning test code
//        [mainVC testCostValueFromCircles:circles];
    }else{
        // 执行两遍结果跟准确
        [mainVC updatePathForCircles:circles];
        [mainVC updatePathForCircles:circles];
        
        // 测试代码
//        [mainVC testDistanceValueFromCircles:circles];
    }
}

// 更新 最大通路值
+ (void)updateCostForCircles:(NSMutableArray *)circles{
    // 遍历 所有圆 整个二维数组
    for (NSMutableArray *aRow in circles) {
        for (CircleBtn *circle in aRow) {
            [circle setMaxCostFromCircles:circles];
        }
    }
}

// 更新 最短路径值
// 必须四个方向按顺序做，不能一起执行
+ (void)updatePathForCircles:(NSMutableArray *)circles{
    // 左上
    for (int i=0; i < CircleBtnDefaultRowMax; i++) {
        for (int j=0; j < CircleBtnDefaultRowMax; j++) {
            [circles[i][j] setShortPathFromCircles:circles];
            [circles[j][i] setShortPathFromCircles:circles];
        }
    }
    // 右上
    for (int i=0; i < CircleBtnDefaultRowMax; i++) {
        for (int j=0; j < CircleBtnDefaultRowMax; j++) {
            [circles[i][CircleBtnDefaultRowMax-1-j] setShortPathFromCircles:circles];
            [circles[j][CircleBtnDefaultRowMax-1-i] setShortPathFromCircles:circles];
        }
    }
    // 右下
    for (int i=0; i < CircleBtnDefaultRowMax; i++) {
        for (int j=0; j < CircleBtnDefaultRowMax; j++) {
            [circles[CircleBtnDefaultRowMax-1-i][CircleBtnDefaultRowMax-1-j] setShortPathFromCircles:circles];
            [circles[CircleBtnDefaultRowMax-1-j][CircleBtnDefaultRowMax-1-i] setShortPathFromCircles:circles];
        }
    }
    // 左下
    for (int i=0; i < CircleBtnDefaultRowMax; i++) {
        for (int j=0; j < CircleBtnDefaultRowMax; j++) {
            [circles[CircleBtnDefaultRowMax-1-i][j] setShortPathFromCircles:circles];
            [circles[CircleBtnDefaultRowMax-1-j][i] setShortPathFromCircles:circles];
        }
    }
}

#pragma mark - 音乐按钮设置
- (IBAction)playAgain:(id)sender {
    [AudioTool playMusicWithMusicName:self.source.soundTap loopNum:0];
    [self updateView];
}

- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    NSString *imgName = isPlay ? self.source.imgBtnPlay : self.source.imgBtnPause;
    [self.playOrPauseBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}

// 播放和暂停按钮状态的切换
- (void)playOrPause{
    BOOL isPlay = !self.isPlay;
    [self playBGMIfCan: isPlay];
    
    // 保持本地变量和模型变量一致
    self.prefer.isPlayMusic = isPlay;
    self.isPlay = isPlay;
}

// 是否该播放BGM音乐
- (void)playBGMIfCan:(BOOL)isPlay{
    NSString *musicName = self.source.soundBGM;
    if (isPlay) {
        [AudioTool playMusicWithMusicName:musicName loopNum:-1];
    }else{
        [AudioTool pauseMusicWithMusicName:musicName];
    }
    
}

#pragma mark - 记分板设置
- (void)updateCurrentScore{
    // 当前步数 +1
    self.currentStepNum++;
    // 更新记分板
    self.prefer.curScore = self.currentStepNum;
    self.curStepNumText.text = self.prefer.curScoreText;
}


#pragma mark - 开始按钮设置
- (UIButton *)startBtn{
    if (_startBtn == nil) {
        CGFloat btnWidth = 300;
        CGFloat btnHeight = 80;
        CGFloat x = (self.view.bounds.size.width - btnWidth) * 0.5;
        CGFloat y = self.view.bounds.size.height - btnHeight - 80;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:self.source.imgBtnStart] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(x, y, btnWidth, btnHeight);
        [self.view addSubview:btn];
        _startBtn = btn;
    }
    return _startBtn;
}

- (void)startGame{
    // 添加转场动画
    CATransition *anim = [CATransition animation];
    anim.type = @"push";
    anim.subtype = kCATransitionFromLeft;
    anim.duration = 0.5;
    [self.view.layer addAnimation:anim forKey:nil];
    
    // 移除欢迎界面
    [self.welcomeView removeFromSuperview];
    self.welcomeView = nil;
    
    if (self.resultVC != nil) {
        [self.resultVC.view removeFromSuperview];
        [self.resultVC removeFromParentViewController];
    }
    self.startBtn.hidden = YES;
    
    [self updateView];
    
    [AudioTool playMusicWithMusicName:self.source.soundTap loopNum:0];
}

#pragma mark - 输赢窗口管理
- (void)playerLoseGame{
    // 添加子控制器和view
    WinOrLoseVC *resultVC = [WinOrLoseVC winOrLoseViewController];
    [self addChildViewController:resultVC];
    resultVC.isPlayerWin = NO;
    self.resultVC = resultVC;
    [self.view addSubview:resultVC.view];
    
    // 将 btn前置显示
    [self.view bringSubviewToFront:self.startBtn];
    self.startBtn.hidden = NO;
}

- (void)playerWinGame{
    // 比较最高分，记录最高分
    if (self.prefer.bestScore > self.currentStepNum) {
        self.prefer.bestScore = self.currentStepNum;
    }
    // 显示最高分
    self.bestScoreText.text = self.prefer.bestScoreText;
    
    // 添加子控制器和view
    WinOrLoseVC *resultVC = [WinOrLoseVC winOrLoseViewController];
    [self addChildViewController:resultVC];
    resultVC.isPlayerWin = YES;
    resultVC.highScore = self.prefer.bestScore;
    resultVC.currentScore = self.currentStepNum;
    self.resultVC = resultVC;
    [self.view addSubview:resultVC.view];
    
    // 将 btn前置显示
    [self.view bringSubviewToFront:self.startBtn];
    self.startBtn.hidden = NO;
}

#pragma mark - testCode
+ (void)testDistanceValueFromCircles:(NSArray *)circles{
    for (NSMutableArray *a in circles) {
        for (CircleBtn *c in a) {
            NSString *s = [NSString stringWithFormat:@"%ld",(long)c.distance];
            [c setTitle:s forState:UIControlStateNormal];
        }
    }
}
+ (void)testCostValueFromCircles:(NSArray *)circles{
    for (NSMutableArray *a in circles) {
        for (CircleBtn *c in a) {
            NSString *s = [NSString stringWithFormat:@"%ld",(long)c.cost];
            [c setTitle:s forState:UIControlStateNormal];
        }
    }

}

@end
