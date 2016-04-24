//
//  CircleBtn.h
//  NerveCat-Objc
//
//  Created by Light on 4-16.
//  Copyright © 2016年 Light. All rights reserved.
//

#import <UIKit/UIKit.h>

// 必须是整数
#define CircleBtnDefaultRowMax 9
#define CircleBtnDefaultCost -10

#define CircleBtnDefaultPath 10
#define CircleBtnSelectedPath 100

typedef enum{
    CircleBtnStateNormal,
    CircleBtnStateSelected,
    CircleBtnStateCatHold
} CircleBtnState;


@interface CircleBtn : UIButton

/** 圆所在的 行 */
@property (nonatomic, assign) NSInteger row;
/** 圆所在的 列 */
@property (nonatomic, assign) NSInteger col;
/** 圆的最大通路个数 */
@property (nonatomic, assign) NSInteger cost;
/** 圆的最短路径个数 */
@property (nonatomic, assign) NSInteger distance;
/** 圆的显示状态 */
@property (nonatomic, assign) CircleBtnState circleState;

+ (CircleBtn *)circleBtnWithCenter:(CGPoint)center width:(CGFloat)width row:(NSInteger)row col:(NSInteger)col;

- (BOOL)isBoundary;
- (BOOL)isBestChoiceCompareCircle:(CircleBtn *)circle isEnclose:(BOOL)isEnclose;

- (NSMutableArray *)getAllConnectWaysFromCircles:(NSMutableArray *)circles;
- (NSMutableArray *)getAllConnectCirclesFromCircles:(NSMutableArray *)circles;

- (void)setShortPathFromCircles:(NSMutableArray *)circles;
- (void)setMaxCostFromCircles:(NSMutableArray *)circles;
@end
