//
//  ViewController.m
//  DHVectorDemo
//
//  Created by DreamHack on 15-11-23.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import "ViewController.h"
#import "DHVector2D.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [DHVector2D setVectorCoordinateSystem:DHVectorCoordinateSystemUIKit];
    
    DHVector2D * vector = [[DHVector2D alloc] initWithCoordinateExpression:CGPointMake(100, 100)];
    vector = [[DHVector2D alloc] initAsIdentityVectorWithAngleToXPositiveAxis:M_PI/4];
    [vector multipliedByNumber:100*sqrt(2)];
    DHVector2D * aVector = [[DHVector2D alloc] initWithCoordinateExpression:CGPointMake(80, 0)];
    
    [aVector translationToPoint:CGPointMake(100, 100)];
    
    [aVector multipliedByNumber:2];
    
    [aVector rotateClockwiselyWithRadian:M_PI/8];
    
    DHVector2D * resultVector = [DHVector2D aVector:vector plusByOtherVector:aVector];
    resultVector.lineWidth = 2;
    resultVector.lineColor = [UIColor blackColor];
    [resultVector drawOnView:self.view];
    
    if ([[DHVector2D aVector:resultVector substractedByOtherVector:vector] isEqualToVector:aVector]) {
        NSLog(@"加减法的实现没有问题！");
    }
    
    vector.lineColor = [UIColor redColor];
    vector.lineWidth = 2;
    
    aVector.lineColor = [UIColor blueColor];
    aVector.lineWidth = 2;
    NSLog(@"%f",[vector angleOfOtherVector:aVector]/M_PI*180);
    
    [vector drawOnView:self.view];
    [aVector drawOnView:self.view];
}

@end
