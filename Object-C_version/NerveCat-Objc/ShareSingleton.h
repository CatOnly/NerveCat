//
//  ShareSingleton.h
//  NerveCat-Objc
//
//  Created by Light on 4-20.
//  Copyright © 2016年 Light. All rights reserved.
//


// 注意：
// 此文件 中含有全局变量，只执行一次，因此不能被继承

// .h 文件 声明方法
#define interfaceSingleton(name) + (instancetype)share##name;

// .m 文件 定义方法
// 系统自带 宏定义 判断是否为 arc模式
#define obj_arc
#if __has_feature(obj_arc)

#define implememtationSingleton(name) \
static id _instance = nil;\
+(instancetype)allocWithZone:(struct _NSZone *)zone{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{ _instance = [super allocWithZone:zone]; });\
return _instance;\
}\
+(instancetype)share##name{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{ _instance = [[self alloc] init]; });\
return _instance;\
}\
- (id)copyWithZone:(NSZone *)zone{ return _instance; }\
- (id)mutableCopyWithZone:(NSZone *)zone{ return _instance; }\
- (oneway void)release{}\
- (instancetype)retain{ return _instance; }\
- (NSInteger)retainCount{ return (unsigned long)MAXFLOAT;}

#else

// 如果是ARC 定义 ARC分类
#define implememtationSingleton(name) static id _instance = nil;\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{ _instance = [super allocWithZone:zone]; });\
return _instance;\
}\
+ (instancetype)share##name{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{ _instance = [[self alloc] init]; });\
return _instance;\
}\
- (id)copyWithZone:(NSZone *)zone{\
return _instance;\
}\
- (id)mutableCopyWithZone:(NSZone *)zone{\
return _instance;\
}

#endif
