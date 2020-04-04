//
//  NSMutableArray(PathFinder).h
//  pDestroyer
//
//  Created by ITmind on 14.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PathFindNode;

@interface NSMutableArray(PathFinder)

-(PathFindNode*)nodeWithX:(int)x Y:(int)y;
-(PathFindNode*)lowestCostNode;

@end
