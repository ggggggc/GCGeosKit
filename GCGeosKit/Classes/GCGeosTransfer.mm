//
//  GCGeosTransfer.m
//  GCGeosKit
//
//  Created by 龚聪(Cong Gong)-顺丰科技 on 2019/4/11.
//  Copyright © 2019年 龚聪(Cong Gong)-顺丰科技. All rights reserved.
//

#import "GCGeosTransfer.h"
#import <math.h>

#include <geos/geom/Coordinate.h>
#include <geos/geom/Geometry.h>
#include <geos/geom/GeometryFactory.h>
#include <geos/geom/LineString.h>
#include <geos/geom/LinearRing.h>
#include <geos/geom/MultiPolygon.h>
#include <geos/geom/Point.h>
#include <geos/geom/Polygon.h>
#include <geos/geom/CoordinateArraySequenceFactory.h>
#include <geos/operation/polygonize/Polygonizer.h>
#include <geos/simplify/TaggedLinesSimplifier.h>

using namespace geos::geom;
using namespace geos::operation;
using namespace geos::simplify;

using namespace std;

@implementation GCGeosTransfer

//判定两个浮点型是否相等（一定误差范围）
bool valueIsEqual(double x,double x1){
    if(fabs(x - x1) < 1e-6){
        return YES;
    }
    return NO;
}

//判断多点是否在一条直线上
+ (BOOL)isPointsInLine:(NSArray *)array{
    // 判定两矩形是否相交
    NSInteger sizeCount = array.count;
    if(sizeCount < 3){
        //少于3个点，要么是个点，要么是条线
        return YES;
    }
    
    BOOL isLine = YES;
    
    CGPoint p0 = [array[0] CGPointValue];
    CGPoint p1 = [array[1] CGPointValue];
    
    for (int i = 2; i < sizeCount; i ++) {
        CGPoint p = [array[i] CGPointValue];
        
        //先看是否在水平或纵向一条直线上
        if((valueIsEqual(p.x, p0.x) && valueIsEqual(p.x, p1.x)) ||
           (valueIsEqual(p.y, p0.y) && valueIsEqual(p.y, p1.y))){
            continue;
        }
        //再看斜率是否一样
        if((p.y - p0.y)/(p.x - p0.x) == (p.y - p1.y)/(p.x - p1.x)){
            //斜率一样
            continue;
        }
        //已有三个点，不在一条直线上了
        isLine = NO;
        break;
    }
    return isLine;
}

//取一组坐标点的外环（闭环）
+ (NSArray *)outerRingWithPointArr:(NSArray *)pointArr{
    
    //先检测点集是否只有一个点、或在一条直线上
    if([self isPointsInLine:pointArr]){
        return pointArr;
    }
    
    const GeometryFactory *geometryFactory = GeometryFactory::getDefaultInstance();
    CoordinateArraySequenceFactory seqFactory;
    //    GeometryCollection *multiPolygon = geometryFactory->createGeometryCollection();
    CoordinateSequence *cse = seqFactory.create();
    
    NSMutableArray *tempPoints = [NSMutableArray arrayWithArray:pointArr];
    //添加尾点
    [tempPoints addObject:[tempPoints firstObject]];
    int pointCount = (int)tempPoints.count;
    
    for (int i = 0; i < pointCount; i ++) {
        CGPoint point = [tempPoints[i] CGPointValue];
        //点集
        Coordinate coor(point.x,point.y);
        cse->add(coor, false);
    }
    //创建线条
    LineString *lineString = geometryFactory->createLineString(cse);
    //取buffer
    Geometry *tempPolygon = lineString->buffer(0.001, 6);
    
    if(tempPolygon != nullptr &&
       (tempPolygon->getGeometryTypeId() == GeometryTypeId::GEOS_POLYGON)){
        //多边形
        Polygon *tempP = dynamic_cast<Polygon *>(tempPolygon);
        //取外环
        const LinearRing *tempLine = dynamic_cast<const LinearRing *>(tempP->getExteriorRing());
        Polygon *polygon = geometryFactory->createPolygon((LinearRing *)tempLine, nullptr);
        //获取新的外环点集
        tempPoints = [self getPointsWithGeometry:polygon];
        
        geometryFactory->destroyGeometry(polygon);
    }else{
        geometryFactory->destroyGeometry(tempPolygon);
    }
    
    return tempPoints;
}

//取几何边界点
+ (NSMutableArray *)getPointsWithGeometry:(const Geometry *)geo{
    
    CoordinateSequence *tempSeq = geo->getCoordinates();
    long seqSize = tempSeq->getSize();
    
    NSMutableArray *nowPoints = [NSMutableArray array];
    for (int i = 0; i < seqSize; i ++) {
        double x = tempSeq->getX(i);
        double y = tempSeq->getY(i);
        CGPoint nowPoint = CGPointMake(x, y);
        [nowPoints addObject:@(nowPoint)];
    }
    return nowPoints;
}

// 判断一个多边形是否包含一个坐标点
+ (BOOL)isPolygonContainsPointWith:(NSArray *)polygon
                             point:(CGPoint)point {
    
    bool isIntersectOnSection = false;
    int count = (int)polygon.count;
    
    int nCross = 0;
    for (int i = 0; i < count; ++ i) {
        
        CGPoint p1 = [polygon[i] CGPointValue];
        CGPoint p2 = [polygon[(i + 1) % count] CGPointValue];
        
        // 求解 y=p.y 与 p1 p2 的交点
        if (p1.y == p2.y) {   // p1p2 与 y=p0.y平行
            continue;
        }
        if (point.y < fminf(p1.y, p2.y)) { // 交点在p1p2延长线上
            continue;
        }
        if (point.y > fmaxf(p1.y, p2.y)) { // 交点在p1p2延长线上
            continue;
        }
        // 求交点的 X 坐标
        double x = (double)(point.y-p1.y)*(double)(p2.x-p1.x)/(double)(p2.y-p1.y)+p1.x;
        
        /** added on 2011.10.02.15.21，是否正好相交在边上~ */
        //        NSLog(@" —— x=%f, p.x=%f", x, p.x);
        if (fabs(x - point.x) < 10e-4) {
            //            NSLog(@"点正好相交在多边形的边上~");
            isIntersectOnSection = true;
            break;
        }
        if (x > point.x) { // 只统计单边交点
            nCross ++;
        }
    }
    if(isIntersectOnSection || nCross%2==1) {    // 单边交点为偶数，点在多边形之外
        return YES;
    } else {
        return NO;
    }
}

@end
