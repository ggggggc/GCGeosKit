//
//  GCGeosHelper.h
//  GCGeosKit
//
//  Created by 龚聪(Cong Gong)-顺丰科技 on 2019/4/9.
//  Copyright © 2019年 龚聪(Cong Gong)-顺丰科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GCGeosHelper : NSObject

/*!
 @brief 判断点集是否在一条直线上
 @param pointArr 坐标点数组，NSValue->CGPoint
 @return YES表示在一条线上
 */
+ (BOOL)isPointsInLine:(NSArray *)pointArr;

/*!
 @brief 取一组坐标点的外环（闭环）
 @param pointArr 坐标点数组，NSValue->CGPoint
 @return 外环坐标点集
 */
+ (NSArray *)outerRingWithPointArr:(NSArray *)pointArr;

/*!
 @brief 判断一个多边形是否包含一个坐标点
 @param polygon 多边形坐标点数组，NSValue->CGPoint
 @param point 所包含的坐标点
 @return 外环坐标点集
 */
+ (BOOL)isPolygonContainsPointWith:(NSArray *)polygon
                             point:(CGPoint)point;

@end
