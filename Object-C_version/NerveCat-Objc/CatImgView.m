//
//  CatView.m
//  NerveCat-Objc
//
//  Created by Light on 4-16.
//  Copyright © 2016年 Light. All rights reserved.
//

#import "CatImgView.h"
#import "SrcData.h"

static int i = 0;

@interface CatImgView()
/** 游戏资源 */
@property (strong, nonatomic) SrcData *source;

@property (strong, nonatomic) NSMutableArray *normalCats;
@property (strong, nonatomic) NSMutableArray *angryCats;

@property (assign, nonatomic) CGFloat xOffset;
@property (assign, nonatomic) CGFloat yOffset;

@end

@implementation CatImgView
- (SrcData *)source {
    if (_source == nil) {
        _source = [SrcData srcData];
    }
//    NSLog(@"%@ at %s",_source,__func__);
    return _source;
}

- (void)setCircle:(CircleBtn *)circle {
    circle.circleState = CircleBtnStateCatHold;
    _circle = circle;
    [self catPositionWithView:circle];
}

+ (instancetype)catWithCircle:(CircleBtn *)circle scale:(CGFloat)scale xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset{
    
    CatImgView *cat = [[self alloc] init];
    [cat setCatWithFrame:circle.frame andScale:scale];
    
    cat.xOffset = xOffset;
    cat.yOffset = yOffset;
    
    cat.isEnclose = NO;
    cat.userInteractionEnabled = NO;
    cat.circle = circle;
    cat.center = CGPointMake(circle.center.x + xOffset, circle.center.y + yOffset);

    return cat;
}

// 初始化猫的样子和尺寸并添加动画
- (void)setCatWithFrame:(CGRect)frame andScale:(CGFloat)scale {
    // 加载大图片
    UIImage *normalCat = [UIImage imageNamed:self.source.imgCatDefault];
    UIImage *angryCat = [UIImage imageNamed:self.source.imgCatAngry];
    
    // 获得小图的尺寸
    CGFloat nomarlW = normalCat.size.width / 4.0;
    CGFloat nomarlH = normalCat.size.height / 4.0;
    CGFloat angryW = normalCat.size.width / 4.0;
    CGFloat angryH = normalCat.size.height / 4.0;
    
    // 设置 self尺寸
    CGFloat width = frame.size.width * scale;
    CGFloat height = width / nomarlW * nomarlH;
    self.frame = CGRectMake(0, 0, width, height);
    
    // 创建小图片的一维数组
    self.normalCats = [NSMutableArray array];
    self.angryCats = [NSMutableArray array];
    
    // 给小图片一维数组 赋值
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            // 剪裁位置 和 大小
            CGRect clipNormal = CGRectMake(j*nomarlW, i*nomarlH, nomarlW, nomarlH);
            CGRect clipAngry = CGRectMake(j*angryW, i*angryH, angryW, angryH);
            
            // 裁剪
            CGImageRef normalRef = CGImageCreateWithImageInRect(normalCat.CGImage, clipNormal);
            CGImageRef angryRef = CGImageCreateWithImageInRect(angryCat.CGImage, clipAngry);
            
            UIImage *normalImg = [UIImage imageWithCGImage:normalRef];
            UIImage *angryImg = [UIImage imageWithCGImage:angryRef];
            
            [self.angryCats addObject:angryImg];
            [self.normalCats addObject:normalImg];
        }
    }
    // 添加动画：小图片数组轮番显示
    // 方法1 屏幕刷星的时候会调用「屏幕 1s刷新 60次」
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateImage)];
    link.frameInterval = 3;
    // 添加到主运行循环
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    // 方法2
    //    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
    // 获取像素和点的比例
    //    CGFloat scale = [UIScreen mainScreen].scale;
}

- (void)updateImage {
    if (i > 15) {
        i = 0;
    }
    
    if (self.isEnclose) {
        self.image = self.angryCats[i];
    }else {
        self.image = self.normalCats[i];
    }
    i++;
    
    // 这个方法不会马上调用 drawReck方法，只是添加标记，下次刷新的时候调用
    [self setNeedsDisplay];
}


#pragma mark - 与猫移动相关的方法
// 根据其他 View 的位置获取 catView的位置
- (void)catPositionWithView:(UIView *)view{
    self.center = CGPointMake(view.center.x + self.xOffset, view.center.y + self.yOffset);
}

/** 猫的下一步位置，可以返回 nil */
- (CircleBtn *)getNextCircleFromCircles:(NSMutableArray *)circles{
    // 猫能去的所有位置数组，如果没有地方可去，数组为空，该函数会返回 nil
    NSMutableArray *allWays = [self.circle getAllConnectWaysFromCircles:circles];
    
    // 判断猫是否被围住了 但还可以走的标志
    BOOL Enclose = [self isEncloseCatFromCircles:circles];
    self.isEnclose = Enclose;
    
    CircleBtn *nextCircle = nil;
    
    if (allWays.count > 0) {
        nextCircle = allWays[0];
        
        for (int i = 0; i < allWays.count; i++) {
            CircleBtn *currentCircle = allWays[i];
    
            if ([currentCircle isBoundary]) {
                return currentCircle;
            }else if (![nextCircle isBestChoiceCompareCircle:currentCircle isEnclose:Enclose]) {
                nextCircle = allWays[i];
            }
        }
    }
    return nextCircle;
}

- (void)catGoToCircle:(CircleBtn *)nextCircle{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    
    CGPoint p = CGPointMake(self.circle.center.x + self.xOffset, self.circle.center.y + self.yOffset);
    anim.fromValue = [NSValue valueWithCGPoint:p];
    anim.duration = 0.5;
    
    p = CGPointMake(nextCircle.center.x + self.xOffset, nextCircle.center.y + self.yOffset);
    anim.toValue = [NSValue valueWithCGPoint:p];
    
    [self.layer addAnimation:anim forKey:@"position"];
    
    self.circle.circleState = CircleBtnStateNormal;
    self.circle = nextCircle;
    self.circle.circleState = CircleBtnStateCatHold;
}

// 玩家是否胜利，猫是否被围住了，但猫还能走
- (BOOL)isEncloseCatFromCircles:(NSMutableArray *)circles{
    // 判断堵死的标准 path的值上升到何值时 猫被堵死
    int standard = 10;
    int count = 0; // 6个方向堵死的个数
    for (CircleBtn *circle in [self.circle getAllConnectCirclesFromCircles:circles]) {
        if (circle.distance >= standard) {
            ++count;
        }
    }
    // 是否 6个方向全部
    return count == 6 ? YES : NO;
}

@end
