//
//  DHVector.m
//  DHTools
//
//  Created by DreamHack on 14-8-13.
//  Copyright (c) 2014年 DreamHack. All rights reserved.
//

#import "DHVector.h"
// 单位向量长度
#define IDENTITY_LENGTH 1
static NSString * const kDHVectorCoordinateSystemKey = @"kDHVectorCoordinateSystemKey";

@implementation DHVector

+ (void)initialize
{
    [self setVectorCoordinateSystem:DHVectorCoordinateSystemUIKit];
}

+ (void)setVectorCoordinateSystem:(DHVectorCoordinateSystem)coordinateSystem
{
    [[NSUserDefaults standardUserDefaults] setObject:@(coordinateSystem) forKey:kDHVectorCoordinateSystemKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (DHVectorCoordinateSystem)coordinateSystem
{
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kDHVectorCoordinateSystemKey] integerValue];
}

- (instancetype)initAsIdentityVectorWithAngleToXPositiveAxis:(CGFloat)radian
{
    self = [DHVector xPositiveIdentityVector];
    [self rotateClockwiselyWithRadian:radian];
    return self;
}

- (instancetype)initWithStartPoint:(CGPoint)start endPoint:(CGPoint)end
{
    self = [super init];
    _startPoint = start;
    _endPoint = end;
    return self;
}

- (instancetype)initWithCoordinateExpression:(CGPoint)position
{
    self = [self initWithStartPoint:CGPointZero endPoint:position];
    
    return self;
}

+ (instancetype)vectorWithVector:(DHVector *)vector
{
    DHVector * aVector = [[DHVector alloc] initWithStartPoint:vector.startPoint endPoint:vector.endPoint];
    
    return aVector;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"start : %@, end: %@, coordinate: %@",NSStringFromCGPoint(self.startPoint),NSStringFromCGPoint(self.endPoint),NSStringFromCGPoint([self coordinateExpression])];
}

@end

@implementation DHVector (VectorDescriptions)

- (CGFloat)length
{
    return sqrt(pow((_startPoint.y - _endPoint.y), 2) + pow((_startPoint.x - _endPoint.x), 2));
}

- (void)setLength:(CGFloat)length
{
    [self multipliedByNumber:length/self.length];
}

- (CGFloat)angleOfOtherVector:(DHVector *)oVector
{
    // 通过向量点积的几何意义反解向量夹角
    CGFloat cos = [self dotProductedByOtherVector:oVector] / ([self length] * [oVector length]);
    return acos(cos);
}

- (CGFloat)angleOfXAxisPositiveVector
{
    return [self angleOfOtherVector:[DHVector xPositiveIdentityVector]];
}

- (CGPoint)coordinateExpression
{
    CGPoint p = CGPointZero;
    
    p.x = _endPoint.x - _startPoint.x;
    p.y = _endPoint.y - _startPoint.y;
    
    return p;
}

- (BOOL)isEqualToVector:(DHVector *)aVector
{
    CGPoint selfExpression = [self coordinateExpression];
    CGPoint expression = [aVector coordinateExpression];
    return CGPointEqualToPoint(selfExpression, expression);
}


#pragma mark - 到角

// 顺时针到角 = 另一个向量到该向量的逆时针到角
- (CGFloat)clockwiseAngleToVector:(DHVector *)vector
{
    return [vector antiClockwiseAngleToVector:self];
}

// 如果另一个向量在这个向量的逆时针方向上（夹角小于PI），则到角 = 夹角
// 若不是，则到角 = 2PI - 夹角
- (CGFloat)antiClockwiseAngleToVector:(DHVector *)vector
{
    // 判断是否在逆时针方向上
    // 首先如果它们的夹角是PI，则直接返回
    if ([self angleOfOtherVector:vector] == M_PI) {
        
        return M_PI;
    }
    
    
    // 然后，将该向量延逆时针方向旋转一度，如果它们的夹角减小，则是在逆时针方向
    
    CGFloat angle = [self angleOfOtherVector:vector];
    
    DHVector * tempVector = [DHVector vectorWithVector:self];
    [tempVector rotateAntiClockwiselyWithRadian:0.01/180.f*M_PI];
    if ([tempVector angleOfOtherVector:vector] < angle) {
        return angle;
    }
    
    return (2 * M_PI) - angle;
}

@end

#pragma mark - 向量运算
@implementation DHVector (VectorArithmetic)
// 类方法返回的向量起始点为坐标原点

// 加法
- (void)plusByOtherVector:(DHVector *)vector
{
    CGPoint tp = _startPoint;
    [self translationToPoint:CGPointMake(0, 0)];
    CGPoint p = [vector coordinateExpression];
    _endPoint = CGPointMake(_endPoint.x+p.x , _endPoint.y+p.y);
    [self translationToPoint:tp];
}

+ (DHVector *)aVector:(DHVector *)aVector plusByOtherVector:(DHVector *)oVector
{
    CGPoint p1 = [aVector coordinateExpression];
    CGPoint p2 = [oVector coordinateExpression];
    
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(p1.x+p2.x, p1.y+p2.y)];
    
    return vector;
}

// 减法
// 本向量被另一个向量减：self - vector
- (void)substractedByOtherVector:(DHVector *)vector
{
    CGPoint tp = _startPoint;
    [self translationToPoint:CGPointMake(0, 0)];
    CGPoint p = [vector coordinateExpression];
    _endPoint = CGPointMake(_endPoint.x - p.x, _endPoint.y - p.y);
    [self translationToPoint:tp];
}


+ (DHVector *)aVector:(DHVector *)aVector substractedByOtherVector:(DHVector *)oVector
{
    CGPoint p1 = [aVector coordinateExpression];
    CGPoint p2 = [oVector coordinateExpression];
    
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(p1.x-p2.x, p1.y-p2.y)];
    
    return vector;
}

// 数乘
- (void)multipliedByNumber:(CGFloat)number
{
    CGPoint startPoint = self.startPoint;
    [self translationToPoint:CGPointZero];
    
    self.endPoint = CGPointMake(_endPoint.x * number, _endPoint.y * number);
    [self translationToPoint:startPoint];
}

+ (DHVector *)aVector:(DHVector *)aVector multipliedByNumber:(CGFloat)number
{
    CGPoint tp = aVector.startPoint;
    [aVector translationToPoint:CGPointMake(0, 0)];
    CGPoint p = CGPointMake(aVector.endPoint.x * number, aVector.endPoint.y * number);
    
    DHVector * vector = [[DHVector alloc] initWithCoordinateExpression:p];
    
    [aVector translationToPoint:tp];
    
    return vector;
}

// 数量积（点积）
- (CGFloat)dotProductedByOtherVector:(DHVector *)vector
{
    return [DHVector aVector:self dotProductedByOtherVector:vector];
}

+ (CGFloat)aVector:(DHVector *)aVector dotProductedByOtherVector:(DHVector *)oVector
{
    CGPoint p = [aVector coordinateExpression];
    CGPoint op = [oVector coordinateExpression];
    return p.x * op.x + p.y * op.y;
}

@end

@implementation DHVector (VectorOperations)

#pragma mark - 平移
// 将起始点平移至某个点
- (void)translationToPoint:(CGPoint)point
{
    _endPoint = CGPointMake(point.x - _startPoint.x + _endPoint.x, point.y - _startPoint.y + _endPoint.y);
    _startPoint = point;
}

#pragma mark - 旋转

- (void)rotateWithCoordinateSystem:(DHVectorCoordinateSystem)coordinateSystem radian:(CGFloat)radian clockWisely:(BOOL)flag
{
    if (coordinateSystem == DHVectorCoordinateSystemOpenGL) {
        [self rotateInOpenGLSystemWithRadian:radian clockwisely:flag];
    } else {
        [self rotateInOpenGLSystemWithRadian:radian clockwisely:!flag];
    }
}

- (void)rotateInOpenGLSystemWithRadian:(CGFloat)radian clockwisely:(BOOL)flag
{
    if (flag) {
        // 首先将向量平移至原点
        CGPoint point = _startPoint;
        [self translationToPoint:CGPointMake(0, 0)];
        // 计算沿着原点旋转后的endpoint
        CGFloat x1 = _endPoint.x * cos(radian) + _endPoint.y * sin(radian);
        CGFloat y1 = -_endPoint.x * sin(radian) + _endPoint.y * cos(radian);
        
        _endPoint = CGPointMake(x1, y1);
        
        // 将startpoint移回原处
        [self translationToPoint:point];
    } else {
        // 首先将向量平移至原点
        CGPoint point = _startPoint;
        [self translationToPoint:CGPointMake(0, 0)];
        // 计算沿着原点旋转后的endpoint
        CGFloat x1 = _endPoint.x * cos(radian) - _endPoint.y * sin(radian);
        CGFloat y1 = _endPoint.x * sin(radian) + _endPoint.y * cos(radian);
        
        _endPoint = CGPointMake(x1, y1);
        
        // 将startpoint移回原处
        [self translationToPoint:point];
    }
}

// 顺时针
- (void)rotateClockwiselyWithRadian:(CGFloat)radian
{
    [self rotateWithCoordinateSystem:self.coordinateSystem radian:radian clockWisely:YES];
}

// 逆时针
- (void)rotateAntiClockwiselyWithRadian:(CGFloat)radian
{
    [self rotateWithCoordinateSystem:self.coordinateSystem radian:radian clockWisely:NO];
}

- (void)reverse
{
    CGPoint startPoint = self.startPoint;
    self.startPoint = self.endPoint;
    self.endPoint = startPoint;
}

@end


@implementation DHVector (SpecialVectors)

#pragma mark - 特殊向量

+ (DHVector *)xPositiveIdentityVector
{
    DHVector * vector = [[DHVector alloc] initWithCoordinateExpression:CGPointMake(IDENTITY_LENGTH, 0)];
    return vector;
}

+ (DHVector *)xNegativeIdentityVector
{
    DHVector * vector = [[DHVector alloc] initWithCoordinateExpression:CGPointMake(-IDENTITY_LENGTH, 0)];
    return vector;
}

+ (DHVector *)yPositiveIdentityVector
{
    DHVector * vector = [[DHVector alloc] initWithCoordinateExpression:CGPointMake(0, IDENTITY_LENGTH)];
    return vector;
}

+ (DHVector *)yNegativeIdentityVector
{
    DHVector * vector = [[DHVector alloc] initWithCoordinateExpression:CGPointMake(0, -IDENTITY_LENGTH)];
    return vector;
}

+ (DHVector *)zeroVector
{
    DHVector * vector = [[DHVector alloc] initWithCoordinateExpression:CGPointZero];
    
    return vector;
}

@end



#pragma mark - 坐标转换

@implementation DHVector (CoordinateSystemConverting)

+ (CGPoint)openGLPointFromUIKitPoint:(CGPoint)point referenceHeight:(CGFloat)height
{
    CGPoint p = CGPointZero;
    p.x = point.x;
    p.y = height - point.y;
    
    return p;
}

+ (CGPoint)uikitPointFromOpenGLPoint:(CGPoint)point referenceHeight:(CGFloat)height
{
    CGPoint p = CGPointZero;
    p.x = point.x;
    p.y = height - point.y;
    
    return p;
}


@end

#import <objc/runtime.h>
@implementation DHVector (DrawVector)

static const void * kDHVectorLineWidthKey = &kDHVectorLineWidthKey;
static const void * kDHVectorLineColorKey = &kDHVectorLineColorKey;

@dynamic lineWidth, lineColor;

- (CGFloat)lineWidth
{
    return [objc_getAssociatedObject(self, kDHVectorLineWidthKey) floatValue];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    objc_setAssociatedObject(self, kDHVectorLineWidthKey, @(lineWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)lineColor
{
    return objc_getAssociatedObject(self, kDHVectorLineColorKey);
}

- (void)setLineColor:(UIColor *)lineColor
{
    objc_setAssociatedObject(self, kDHVectorLineColorKey, lineColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)drawOnView:(UIView *)view
{
    CAShapeLayer * shapeLayer = [self shapeLayer];
    shapeLayer.frame = view.bounds;
    [view.layer addSublayer:shapeLayer];
}

- (CAShapeLayer *)shapeLayer
{
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:self.startPoint];
    [bezierPath addLineToPoint:self.endPoint];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = self.lineWidth;
    shapeLayer.strokeColor = self.lineColor.CGColor;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.path = bezierPath.CGPath;
    
    return shapeLayer;
}

@end
