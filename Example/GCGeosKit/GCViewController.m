//
//  GCViewController.m
//  GCGeosKit
//
//  Created by ggggggc on 08/14/2019.
//  Copyright (c) 2019 ggggggc. All rights reserved.
//

#import "GCViewController.h"
#import <GCGeosKit/GCGeosKit.h>

@interface GCViewController ()

@property(nonatomic,strong)UIBezierPath *circlePath;
@property(nonatomic,strong)CAShapeLayer *circleLayer;
@property(nonatomic,strong)NSMutableArray *circlePoints;

@end

@implementation GCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 40)];
    titleLabel.text = @"多边形无内交画圈";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
 
    [self.view.layer addSublayer:self.circleLayer];
    //    [GCGeosHelper isPolygonContainsPointWith:array point:CGPointMake(0, 0)];
}

//手势
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //开始，记下第一个点
    CGPoint startPoint = [[touches anyObject] locationInView:self.view];
    
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.circlePath removeAllPoints];
    [self.circlePoints removeAllObjects];
    [self.circlePath moveToPoint:startPoint];
    [self.circlePoints addObject:@(startPoint)];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint endPoint = [[touches anyObject] locationInView:self.view];
    [self.circlePoints addObject:@(endPoint)];
    [self.circlePath addLineToPoint:endPoint];
    
    //进行多边形过滤
    self.circlePoints = [NSMutableArray arrayWithArray:[GCGeosHelper outerRingWithPointArr:self.circlePoints]];
    
    [self.circlePath removeAllPoints];
    for (int i = 0; i < self.circlePoints.count; i ++) {
        CGPoint thisPoint = [self.circlePoints[i] CGPointValue];
        if(i == 0){
            [self.circlePath moveToPoint:thisPoint];
        }else{
            [self.circlePath addLineToPoint:thisPoint];
        }
    }
    [self.circlePath closePath];
    
    self.circleLayer.path = self.circlePath.CGPath;
    self.circleLayer.strokeStart = 0;
    self.circleLayer.strokeEnd = 1;
    self.circleLayer.fillRule = kCAFillRuleEvenOdd;
    self.circleLayer.fillColor = [[UIColor orangeColor] colorWithAlphaComponent:0.2].CGColor;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint movePoint = [[touches anyObject] locationInView:self.view];
    if(CGPointEqualToPoint(movePoint, [[self.circlePoints lastObject] CGPointValue])){
        //跟上一个点相同的话，则舍弃
        return;
    }
    [self.circlePath addLineToPoint:movePoint];
    [self.circlePoints addObject:@(movePoint)];
    
    self.circleLayer.path = self.circlePath.CGPath;
    self.circleLayer.strokeStart = 0;
    self.circleLayer.strokeEnd = 1;
}

- (UIBezierPath *)circlePath{
    if(!_circlePath){
        _circlePath = [UIBezierPath bezierPath];
    }
    return _circlePath;
}

- (CAShapeLayer *)circleLayer{
    if(!_circleLayer){
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.strokeColor = [UIColor orangeColor].CGColor;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.lineWidth = 2;
        _circleLayer.lineCap = kCALineCapRound;
    }
    return _circleLayer;
}

@end
