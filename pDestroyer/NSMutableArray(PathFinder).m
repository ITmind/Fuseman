//
//  NSMutableArray(PathFinder).m
//  pDestroyer
//
//  Created by ITmind on 14.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray(PathFinder).h"
#import "PathFindNode.h"

@implementation NSMutableArray(PathFinder)

-(PathFindNode*)nodeWithX:(int)x Y:(int)y {
	//Quickie method to find a given node in the array with a specific x,y value
	NSEnumerator *e = [self objectEnumerator];
	PathFindNode *n;
	if(e)
	{
		while((n = [e nextObject])) {
			if((n.nodeX == x) && (n.nodeY == y))
			{
				return n;
			}
		}
	}
	return nil;
}

-(PathFindNode*)lowestCostNode {
	//Finds the node in a given array which has the lowest cost
	PathFindNode *n, *lowest;
	lowest = nil;
	NSEnumerator *e = [self objectEnumerator];
	if(e) {
		while((n = [e nextObject])) {
			if(lowest == nil)
			{
				lowest = n;
			}
			else
			{
				if(n.cost < lowest.cost)
				{
					lowest = n;
				}
			}
		}
		return lowest;
	}
	return nil;
}

@end
