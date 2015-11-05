//
//  DHVector.m
//  DHTools
//
//  Created by DreamHack on 14-8-13.
//  Copyright (c) 2014年 DreamHack. All rights reserved.
//

#import "DHVector.h"
// 单位向量长度
#define UNIT_LENGTH 10
@implementation DHVector

// 已弃用
- (instancetype)initAsUnitVectorWithStartPoint:(CGPoint)start endPoint:(CGPoint)end
{
    self = [self initWithStartPoint:start endPoint:end];
    
    _startPoint = CGPointMake(0, 0);
    _endPoint = end;
    
    // 解二元二次方程组，解得
    CGFloat x = 1/(sqrt((1+pow((start.y-end.y)/(start.x-end.x), 2))));
    
    // 解出来有两个解，排除一个解：是方向相反，斜率相同的向量
    if (!((x > 0 && end.x > start.x) || (x < 0 && end.x < start.x) )) {
        x = -x;
    }
    
    CGFloat y = x * ((start.y-end.y)/(start.x-end.x));
    _endPoint = CGPointMake(x, y);
    
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

+ (DHVector *)vectorWithVector:(DHVector *)vector
{
    
    DHVector * aVector = [[DHVector alloc] initWithStartPoint:vector.startPoint endPoint:vector.endPoint];
    
    return aVector;
}

- (CGFloat)length
{
    
    return sqrt(pow((_startPoint.y - _endPoint.y), 2) + pow((_startPoint.x - _endPoint.x), 2));
    
}

- (CGFloat)angleOfOtherVector:(DHVector *)oVector
{
    CGPoint p = [self coordinateExpression];
    CGPoint op = [oVector coordinateExpression];
    
    // 向量夹角公式
    CGFloat cos = (p.x * op.x + p.y * op.y) / ([self length] * [oVector length]);
    return acos(cos);
}

- (CGFloat)angleOfXAxisPositiveVector
{
    
    return [self angleOfOtherVector:[DHVector xPositiveUnitVector]];
    
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

#pragma mark - 向量运算
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
- (void)mutipliedByNumber:(CGFloat)number
{
    _startPoint = CGPointMake(_startPoint.x * number, _startPoint.y * number);
    _endPoint = CGPointMake(_endPoint.x * number, _endPoint.y * number);
}

+ (DHVector *)aVector:(DHVector *)aVector mutipliedByNumber:(CGFloat)number
{
    CGPoint tp = aVector.startPoint;
    [aVector translationToPoint:CGPointMake(0, 0)];
    CGPoint p = CGPointMake(aVector.endPoint.x * number, aVector.endPoint.y * number);
    
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:p];
    
    [aVector translationToPoint:tp];
    
    return vector;
}

// 数量积（点积）
- (void)dotProductedByOtherVector:(DHVector *)vector
{
    CGPoint tp = _startPoint;
    
    [self translationToPoint:CGPointMake(0, 0)];
    CGPoint p = [vector coordinateExpression];
    _endPoint = CGPointMake(_endPoint.x * p.x, _endPoint.y * p.y);
    [self translationToPoint:tp];
    
}

+ (DHVector *)aVector:(DHVector *)aVector dotProductedByOtherVector:(DHVector *)oVector
{
    CGPoint p1 = [aVector coordinateExpression];
    CGPoint p2 = [aVector coordinateExpression];
    
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(p1.x * p2.x, p1.y * p2.y)];
    
    return vector;
}

#pragma mark - 平移
// 将起始点平移至某个点
- (void)translationToPoint:(CGPoint)point
{
    _endPoint = CGPointMake(point.x - _startPoint.x + _endPoint.x, point.y - _startPoint.y + _endPoint.y);
    _startPoint = point;
}

#pragma mark - 旋转

// 顺时针
- (void)rotateClockwiselyWithRadian:(CGFloat)radian
{
    // 首先将向量平移至原点
    CGPoint point = _startPoint;
    [self translationToPoint:CGPointMake(0, 0)];
    // 计算沿着原点旋转后的endpoint
    CGFloat x1 = _endPoint.x * cos(radian) + _endPoint.y * sin(radian);
    CGFloat y1 = -_endPoint.x * sin(radian) + _endPoint.y * cos(radian);
    
    _endPoint = CGPointMake(x1, y1);
    
    // 将startpoint移回原处
    [self translationToPoint:point];
}

// 逆时针
-(void)rotateAntiClockwiselyWithRadian:(CGFloat)radian
{
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
    [tempVector rotateAntiClockwiselyWithRadian:radianFromDegree(0.01)];
    if ([tempVector angleOfOtherVector:vector] < angle) {
        return angle;
    }
    
    return (2 * M_PI) - angle;
}



#pragma mark - 内部函数
// 弧度换算成角度
CGFloat degreeFromRadian(CGFloat radian)
{
    
    return (radian/M_PI)*180;
    
}

// 角度换算成弧度
CGFloat radianFromDegree(CGFloat degree)
{
    
    return (degree/180)*M_PI;
}


#pragma mark - 特殊向量

+ (DHVector *)xPositiveUnitVector
{
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(UNIT_LENGTH, 0)];
    return vector;
}

+ (DHVector *)xNegativeUnitVector
{
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(-UNIT_LENGTH, 0)];
    return vector;
}

+ (DHVector *)yPositiveUnitVector
{
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, UNIT_LENGTH)];
    return vector;
}

+ (DHVector *)yNegativeUnitVector
{
    DHVector * vector = [[DHVector alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, -UNIT_LENGTH)];
    return vector;
}

+ (DHVector *)zeroVector
{
    DHVector * vector = [[DHVector alloc] initWithCoordinateExpression:CGPointZero];
    
    return vector;
}

#pragma mark - 坐标转换

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

#pragma mark - override
- (NSString *)description
{
    return NSStringFromCGPoint([self coordinateExpression]);
}

@end
