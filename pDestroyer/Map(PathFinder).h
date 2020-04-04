//
//  Map(PathFinder).h
//  pDestroyer
//
//  Created by ITmind on 14.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Map.h"

@interface Map(PathFinder)

//-(unsigned char) tileTypeFromRow:(int) row col:(int) col;
//-(void) setTileTypeToRow:(int) row col:(int) col  type:(unsigned char)type;
-(void) loadMapObjects;
-(void) goFormX:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY;
-(void) clear;
-(PathFindNode*) findPath:(int)sx :(int)sy :(int)ex :(int)ey;

@end
