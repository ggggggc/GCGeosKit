//
//  GCGeosHelper.m
//  GCGeosKit
//
//  Created by 龚聪(Cong Gong)-顺丰科技 on 2019/4/9.
//  Copyright © 2019年 龚聪(Cong Gong)-顺丰科技. All rights reserved.
//

#import "GCGeosHelper.h"
#import "GCGeosTransfer.h"

@implementation GCGeosHelper

+ (BOOL)isPointsInLine:(NSArray *)pointArr{
    return [GCGeosTransfer isPointsInLine:pointArr];
}

+ (NSArray *)outerRingWithPointArr:(NSArray *)pointArr{
    return [GCGeosTransfer outerRingWithPointArr:pointArr];
}

+ (BOOL)isPolygonContainsPointWith:(NSArray *)polygon
                             point:(CGPoint)point{
    return [GCGeosTransfer isPolygonContainsPointWith:polygon point:point];
}

@end
