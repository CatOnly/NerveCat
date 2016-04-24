//
//  welcomeView.m
//  NerveCat-Objc
//
//  Created by Light on 4-19.
//  Copyright © 2016年 Light. All rights reserved.
//

#import "WelcomeView.h"
#import "SrcData.h"


@interface WelcomeView()

@property (assign, nonatomic) CGFloat catSpeed;

/** 游戏资源 */
@property (strong, nonatomic) SrcData *source;

@property (assign, nonatomic) CGFloat curX;
@property (assign, nonatomic) CGFloat curY;
@property (assign, nonatomic) CGFloat catWidth;
@property (assign, nonatomic) CGFloat catHeight;

@property (assign, nonatomic) CGFloat leftPosition;
@property (assign, nonatomic) CGFloat rightPosition;
@property (strong, nonatomic) NSString *curImgName;

@end
@implementation WelcomeView

- (SrcData *)source{
    if (_source == nil) {
        _source = [SrcData srcData];
    }
    return _source;
}


+ (instancetype)welcomeView{
    WelcomeView *welV = [[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:nil options:nil][0];
    return welV;
}


- (void)drawRect:(CGRect)rect {
    
    if (_curX > self.rightPosition) {
        _curImgName = self.source.imgCatRight;
        _catSpeed = -_catSpeed;
        
    }else if (_curX < self.leftPosition) {
        _curImgName = self.source.imgCatLeft;
        _catSpeed = -_catSpeed;
    }
    _curX = _curX +_catSpeed;
    UIImage *image = [UIImage imageNamed:_curImgName];
    [image drawInRect:CGRectMake(_curX, _curY, self.catWidth, self.catHeight)];
}

- (void)awakeFromNib{
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    self.catSpeed = 1;
    self.catWidth = 200;
    self.catHeight = 300;
    self.leftPosition = 10;
    self.rightPosition = viewWidth - _leftPosition - _catWidth;
    self.curX = _leftPosition;
    self.curY = (viewHeight - _catHeight) * 0.5;
    self.curImgName = self.source.imgCatLeft;
    
    // 加入 runloop 这个类将会一直不会被销毁
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCatPosition)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)updateCatPosition{
    [self setNeedsDisplay];
}

- (void)dealloc{
    NSLog(@"WelcomeView Dead!");
}
@end
