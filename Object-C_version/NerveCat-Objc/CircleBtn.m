//
//  CircleBtn.m
//  NerveCat-Objc
//
//  Created by Light on 12-16.
//  Copyright © 2015年 Light. All rights reserved.
//

#import "CircleBtn.h"

@class CatView;

@interface CircleBtn()
@end

@implementation CircleBtn

+ (CircleBtn *)circleBtnWithCenter:(CGPoint)center width:(CGFloat)width row:(NSInteger)row col:(NSInteger)col{
    CircleBtn *btn = [[self alloc] initWithFrame:CGRectMake(center.x, center.y, width, width)];
    btn.cost = CircleBtnDefaultCost;
    btn.distance = CircleBtnDefaultPath;
    btn.row = row;
    btn.col = col;
    btn.circleState = CircleBtnStateNormal;
    btn.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    btn.layer.cornerRadius = 0.5 * width;

    return btn;
}

// 重写set方法
- (void)setCircleState:(CircleBtnState)circleState{
    _circleState = circleState;
    switch (circleState) {
        case CircleBtnStateNormal:
            self.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
            break;
        case CircleBtnStateSelected:
            self.cost = CircleBtnDefaultCost;
            self.distance = CircleBtnSelectedPath;
            self.backgroundColor = [UIColor colorWithRed:1 green:0.46 blue:0.3 alpha:1];
            break;
        default:
//            self.backgroundColor = [UIColor blueColor]; // test code
            break;
    }
}

// 圆是否在整个图的边界
- (BOOL)isBoundary{
    NSInteger rowMax = CircleBtnDefaultRowMax;
    return (self.row == 0 || self.col == 0 || self.row == rowMax-1 || self.col == rowMax-1);
}

/** 当前选择是否为最佳选择，isCircle 是否围住了，但猫还能走 */
- (BOOL)isBestChoiceCompareCircle:(CircleBtn *)circle isEnclose:(BOOL)isEnclose{
    if (isEnclose) {
        return self.cost > circle.cost;
    }else{
        return self.distance < circle.distance;
    }
}

#pragma mark - 给调用这些方法的对象 赋值
// 取得每个圆的最小通路值
- (void)setShortPathFromCircles:(NSMutableArray *)circles{
    if (self.circleState == CircleBtnStateSelected) {
        return;
    }else if([self isBoundary]){
        self.distance = 0;
    }else{
        NSInteger shotest = CircleBtnDefaultPath;
        for (CircleBtn *c in [self getAllConnectWaysFromCircles:circles]) {
            NSInteger distance = c.distance;
            shotest = shotest > distance ? distance : shotest;
        }
        self.distance = shotest+1;
    }
}

// 取得每个圆的最大通路值
- (void)setMaxCostFromCircles:(NSMutableArray *)circles{
    if (self.circleState == CircleBtnStateSelected) {
        self.cost = CircleBtnDefaultCost;
    }else if ([self isBoundary]) {
        self.cost = 6 + 1;
    }else{
        self.cost = [self getAllConnectWaysFromCircles:circles].count;
    }
}

#pragma mark - 获得周围 能去的圆
- (NSMutableArray *)getAllConnectWaysFromCircles:(NSMutableArray *)circles{
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *allConnectCircles = [self getAllConnectCirclesFromCircles:circles];
    
    for (CircleBtn *circle in allConnectCircles) {
        if (circle.circleState == CircleBtnStateNormal) {
            [array addObject:circle];
        }
    }
    return array;
}


#pragma mark - 获得周围的 所有圆
- (NSMutableArray *)getAllConnectCirclesFromCircles:(NSMutableArray *)circles{
    NSMutableArray *array = [NSMutableArray array];
    
    CircleBtn *aroundC = nil;
    
    aroundC = [self getLeftFromCircles:circles];
    if (aroundC != nil) {
        [array addObject: aroundC];
    }
    aroundC = nil; // 清空以便循环利用
    
    aroundC = [self getUpperLeftFromCircles:circles];
    if (aroundC != nil) {
        [array addObject: aroundC];
    }
    aroundC = nil; // 清空以便循环利用
    
    aroundC = [self getUpperRightFromCircles:circles];
    if (aroundC != nil) {
        [array addObject: aroundC];
    }
    aroundC = nil; // 清空以便循环利用
    
    aroundC = [self getRightFromCircles:circles];
    if (aroundC != nil) {
        [array addObject: aroundC];
    }
    aroundC = nil; // 清空以便循环利用
    
    aroundC = [self getBottomRightFromCircles:circles];
    if (aroundC != nil) {
        [array addObject: aroundC];
    }
    aroundC = nil; // 清空以便循环利用
    
    aroundC = [self getBottomLeftFromCircles:circles];
    if (aroundC != nil) {
        [array addObject: aroundC];
    }
    
    return array;
}


// 判断传入的 x 或 y 是否角标越界
+ (BOOL)isOutsideWith:(NSInteger)row andCol:(NSInteger)col{
    NSInteger rowMax = CircleBtnDefaultRowMax;
    return (row < 0 || col < 0 || row > rowMax-1 || col > rowMax-1);
}

/**
 *  以下方法获得一个圆周围所有的圆：
 *  依赖于圆的摆放
 *  圆的摆放那是 @@@@
 *              @@@@
 *             @@@@
 *  才有效
 */
- (CircleBtn *)getLeftFromCircles:(NSMutableArray *)circles{
    NSInteger x = self.row;
    NSInteger y = self.col;
    --y;
    if ([CircleBtn isOutsideWith:x andCol:y]) {
        return nil;
    }
    return circles[x][y];
}
- (CircleBtn *)getUpperLeftFromCircles:(NSMutableArray *)circles{
    NSInteger x = self.row;
    NSInteger y = self.col;
    y = x % 2 == 0 ? y - 1 : y;
    --x;

    if ([CircleBtn isOutsideWith:x andCol:y]) {
        return nil;
    }
    return circles[x][y];
}
- (CircleBtn *)getUpperRightFromCircles:(NSMutableArray *)circles{
    NSInteger x = self.row;
    NSInteger y = self.col;
    y = x % 2 == 0 ? y : y + 1;
    --x;

    if ([CircleBtn isOutsideWith:x andCol:y]) {
        return nil;
    }
    return circles[x][y];
}
- (CircleBtn *)getRightFromCircles:(NSMutableArray *)circles{
    NSInteger x = self.row;
    NSInteger y = self.col;
    ++y;

    if ([CircleBtn isOutsideWith:x andCol:y]) {
        return nil;
    }
    return circles[x][y];
}
- (CircleBtn *)getBottomRightFromCircles:(NSMutableArray *)circles{
    NSInteger x = self.row;
    NSInteger y = self.col;
    y = x % 2 == 0 ? y : y + 1;
    ++x;

    if ([CircleBtn isOutsideWith:x andCol:y]) {
        return nil;
    }
    return circles[x][y];
}
- (CircleBtn *)getBottomLeftFromCircles:(NSMutableArray *)circles{
    NSInteger x = self.row;
    NSInteger y = self.col;
    y = x % 2 == 0 ? y - 1 : y;
    ++x;

    if ([CircleBtn isOutsideWith:x andCol:y]) {
        return nil;
    }
    return circles[x][y];
}
@end
