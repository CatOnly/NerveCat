//
//  CatView.h
//  NerveCat-Objc
//
//  Created by Light on 12-16.
//  Copyright © 2015年 Light. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleBtn.h"

@interface CatImgView : UIImageView

@property (nonatomic, weak) CircleBtn *circle;
/** 猫是否被困住 */
@property (nonatomic, assign) BOOL isEnclose;

// 初始化
+ (instancetype)catWithCircle:(CircleBtn *)circle scale:(CGFloat)scale xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset;

/** 猫走到一个圆的位置 */
- (void)catGoToCircle:(CircleBtn *)nextCircle;

/** 猫的下一步位置，可以返回 nil */
- (CircleBtn *)getNextCircleFromCircles:(NSMutableArray *)circles;

@end
