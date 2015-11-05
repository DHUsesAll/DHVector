//
//  DHVector.h
//  DHTools
//
//  Created by DreamHack on 14-8-13.
//  Copyright (c) 2014年 DreamHack. All rights reserved.
//

// 坐标是以左下角为坐标原点
// 用UIKit坐标的时候需要做一次转换
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 平面向量
@interface DHVector : NSObject

@property (nonatomic,readonly) CGPoint startPoint;
@property (nonatomic,readonly) CGPoint endPoint;

// 用两个点初始化一个向量
- (instancetype)initWithStartPoint:(CGPoint)start endPoint:(CGPoint)end;
// 用两个点确定方向，初始化一个单位向量
// 弃用，没卵用
//- (instancetype)initAsUnitVectorWithStartPoint:(CGPoint)start endPoint:(CGPoint)end;

// 用一个CGPoint作为坐标表达式初始化一个向量，该向量起点在(0,0)点
- (instancetype)initWithCoordinateExpression:(CGPoint)position;
// 相当于复制一个向量
+ (DHVector *)vectorWithVector:(DHVector *)vector;

#pragma mark - 向量相关方法
// 向量长度
- (CGFloat)length;

// 向量间的夹角，是弧度值， <=PI
- (CGFloat)angleOfOtherVector:(DHVector *)oVector;

// 与x轴正方向的夹角
- (CGFloat)angleOfXAxisPositiveVector;

// 向量的坐标形式，也就是将起始点移到原点后终止点所在的位置
- (CGPoint)coordinateExpression;

// 判断两个向量是否相等
- (BOOL)isEqualToVector:(DHVector *)aVector;

#pragma mark - 向量运算
// 加法
- (void)plusByOtherVector:(DHVector *)vector;
+ (DHVector *)aVector:(DHVector *)aVector plusByOtherVector:(DHVector *)oVector;

// 减法

// 本向量被另一个向量减：self - vector
- (void)substractedByOtherVector:(DHVector *)vector;
+ (DHVector *)aVector:(DHVector *)aVector substractedByOtherVector:(DHVector *)oVector;

// 数乘
- (void)mutipliedByNumber:(CGFloat)number;
+ (DHVector *)aVector:(DHVector *)aVector mutipliedByNumber:(CGFloat)number;

// 数量积（点积，内积）
- (void)dotProductedByOtherVector:(DHVector *)vector;
+ (DHVector *)aVector:(DHVector *)aVector dotProductedByOtherVector:(DHVector *)oVector;

// 向量积（叉积，外积）
// 叉积结果的方向会产生第三维度，在本类中暂不考虑第三维度
//- (void)crossProductedByOtherVector:(DHVector *)vector;
//+ (DHVector *)aVector:(DHVector *)aVector crossProductedByOtherVector:(DHVector *)oVector;

#pragma mark - 平移
// 将起始点平移至某个点
- (void)translationToPoint:(CGPoint)point;

#pragma mark - 沿着起始点旋转
// 顺时针旋转一个弧度
- (void)rotateClockwiselyWithRadian:(CGFloat)radian;

// 逆时针旋转
- (void)rotateAntiClockwiselyWithRadian:(CGFloat)radian;

#pragma mark - 到角
// 顺时针到角
- (CGFloat)clockwiseAngleToVector:(DHVector *)vector;

// 逆时针到角
- (CGFloat)antiClockwiseAngleToVector:(DHVector *)vector;


#pragma mark - 特殊向量
// x轴正方向的单位向量
+ (DHVector *)xPositiveUnitVector;

// x轴负方向的单位向量
+ (DHVector *)xNegativeUnitVector;

// y轴正方向的单位向量
+ (DHVector *)yPositiveUnitVector;

// y轴负方向的单位向量
+ (DHVector *)yNegativeUnitVector;

// 零向量
+ (DHVector *)zeroVector;

#pragma mark - 坐标转换
// 暂不支持自定义坐标系
+ (CGPoint)openGLPointFromUIKitPoint:(CGPoint)point referenceHeight:(CGFloat)height;
+ (CGPoint)uikitPointFromOpenGLPoint:(CGPoint)point referenceHeight:(CGFloat)height;

@end
