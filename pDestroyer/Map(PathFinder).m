//
//  Map(PathFinder).m
//  pDestroyer
//
//  Created by ITmind on 14.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Map(PathFinder).h"
#import "PathFindNode.h"
#import "NSMutableArray(PathFinder).h"

@implementation Map(PathFinder)

-(void) loadMapObjects
{
	CGSize layerSize = meta.layerSize;
	for (int row=0; row<layerSize.width; row++) {
		for (int col=0; col<layerSize.height; col++) {
			
			tileArray[row][col] = TILE_OPEN;
			
			if([self isCollectableTile:ccp(row,col) isTileCoord:YES])
			{
				tileArray[row][col] = TILE_DESTROY_OBJECT;
			}
            else if([self isCollidableTile:ccp(row,col) isTileCoord:YES])
            {
                tileArray[row][col] = TILE_WALL;
            }
            
		}
	}
}

-(void) goFormX:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
    
    CGPoint from = [self tileCoordForPosition:ccp(fromX,fromY)];
	CGPoint to = [self tileCoordForPosition:ccp(toX,toY)];
    
	// Clear any old results;
	[self clear];
	
	// Flip the tileArray (the path algorithm expects the origin to be upper left)
	//[self flipTileArray];
	
	// Find the path
	[self findPath:from.x :from.y :to.x :to.y];
	
	// Flip the tileArray back so when we draw the path the objects will be
	// in the correct location on the map
	//[self flipTileArray];
    
	// Some debugging
    //	if (pathFound) {
    //		NSLog(@"Path FOUND!!!");
    //	}
    //	else {
    //		NSLog(@"Path NOT FOUND!!!");
    //	}
    
	pointerToOpenList = nil;
    
    //PathFindNode* nextNode= pathFound.nextNode;
	//while(nextNode!=NULL){
	//	CCSprite *s = [CCSprite spriteWithFile:@"Path.png"];
	//	CGPoint pos = [self positionForTileCoord:ccp(nextNode.nodeX,nextNode.nodeY)];
	//	pos.x+=15;
	//	pos.y-=15;
	//	s.position=pos;
	//	s.tag=TILE_TAG;
	//	[self addChild:s];
	//	nextNode= nextNode.nextNode;
	//}
    
    //	while(pathFound->nextNode!=NULL){
    //		PathFindNode* nextNode = pathFound->nextNode;
    //		[pathFound dealloc];
    //        nextNode->parentNode = nil;
    //		pathFound = nextNode;
    //	}
    
    //	// Now display the results of the discovered path
    //	for(int x=0;x<TILE_COLS;x++) {
    //		for(int y=0;y<TILE_ROWS;y++) {
    //			if (tileArray[x][y] == TILE_MARKED) {
    //				CCSprite *s = [[CCSprite alloc] initWithFile:@"Path.png"];
    //                CGPoint pos = [self positionForTileCoord:CGPointMake((float) x, (float) y)];
    //                pos.x +=15;
    //                pos.y -=15;
    //				s.position = pos;
    //				s.tag = TILE_TAG;
    //				[self addChild:s];
    //				NSLog(@"Marking %d, %d", x, y);
    //			}
    //		}
    //	}
}

// Clear the last find results
-(void) clear {
	//int x,y;
	
	// Unmark discovered cells in the array
	//for(x=0;x<TILE_COLS;x++) {
	//	for(y=0;y<TILE_ROWS;y++) {
	//		if(tileArray[x][y] == TILE_MARKED)
	//			tileArray[x][y] = TILE_OPEN;
	//	}
	//}
	
	// Create an array of nodes we need to remove from the parent
	// We can't do this while we iterate the list, so we'll mark them
	// then remove them below
	NSMutableArray *nodesToCleanup = [[NSMutableArray alloc] initWithCapacity:50];
	
	// Flag them for removal
	for (CCNode *node in self.children) {
		if (node.tag == TILE_TAG) {
			[nodesToCleanup addObject:node];
		}
	}
	
	// Now remove them
	for (CCNode *node in nodesToCleanup) {
		[node removeFromParentAndCleanup:YES];
	}
    
    //    if(startNode==nil){
    //		return;
    //	}
    //    
    //	while(startNode->nextNode!=nil){
    //		PathFindNode* nextNode = startNode->nextNode;
    //        [startNode dealloc];
    //		startNode = nextNode;
    //	}
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// A* methods begin//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)spaceIsBlocked:(int)x :(int)y; {
	//general-purpose method to return whether a space is blocked
	if(tileArray[x][y]&TILE_WALL || tileArray[x][y]&TILE_DESTROY_OBJECT || tileArray[x][y]&TILE_BOMB)
		return YES;
	else
		return NO;
}


-(PathFindNode*)findPath:(int)sx :(int)sy :(int)ex :(int)ey {
	//find path function. takes a starting point and end point and performs the A-Star algorithm
	//to find a path, if possible. Once a path is found it can be traced by following the last
	//node's parent nodes back to the start
	int x,y;
	int newX,newY;
	int currentX,currentY;
	NSMutableArray *openList, *closedList;
	
	if((sx == ex) && (sy == ey))
		return NO;
	
	openList = [NSMutableArray array];
	closedList = [NSMutableArray array];
	
	PathFindNode *currentNode = nil;
	PathFindNode *aNode = nil;
	
	PathFindNode* startNode = [PathFindNode node];
	startNode.nodeX = sx;
	startNode.nodeY = sy;
	startNode.parentNode = nil;
    startNode.nextNode = nil;
	startNode.cost = 0;
	[openList addObject: startNode];
	
	while([openList count])	{
		currentNode = [openList lowestCostNode];
		
		if((currentNode.nodeX == ex) && (currentNode.nodeY == ey)) {
			
			//********** PATH FOUND ********************	
			
			//*****************************************//
			//NOTE: Code below is for the app to trace/mark the path
			aNode = currentNode.parentNode;
            aNode.nextNode = currentNode;
			while(aNode.parentNode != nil)
			{
				//tileArray[aNode.nodeX][aNode.nodeY] = TILE_MARKED;
				aNode.parentNode.nextNode = aNode;
				aNode = aNode.parentNode;
			}
            startNode = aNode;
            //[startNode retain];
			return startNode;
			//*****************************************//
		}
		else
		{
			[closedList addObject: currentNode];
			[openList removeObject: currentNode];
			currentX = currentNode.nodeX;
			currentY = currentNode.nodeY;
			//check all the surrounding nodes/tiles:
			for(y=-1;y<=1;y++)
			{
				newY = currentY+y;
				for(x=-1;x<=1;x++)
				{
					newX = currentX+x;
					if(y || x)
					{
						//simple bounds check for the demo app's array
						if((newX>=0)&&(newY>=0)&&(newX<TILE_COLS)&&(newY<TILE_ROWS))
						{
							// Prevent diagonal checks if flag is set
							if ((!(y==-1 && x==-1) && !(y==-1 && x==1)
								 && !(y== 1 && x== -1) && !(y==1 && x==1))) {
								
								if(![openList nodeWithX:newX Y:newY])
								{
									if(![closedList nodeWithX:newX Y:newY])
									{
										if(![self spaceIsBlocked: newX :newY])
										{
											aNode = [PathFindNode node];
											aNode.nodeX = newX;
											aNode.nodeY = newY;
											aNode.parentNode = currentNode;
                                            aNode.nextNode = nil;
											aNode.cost = currentNode.cost + 1;
											
											//Compute your cost here. This demo app uses a simple manhattan
											//distance, added to the existing cost
											aNode.cost += (abs((newX) - ex) + abs((newY) - ey));
											//////////
											
											[openList addObject: aNode];
										}
									}
								}
							}
						}
					}
				}
			}
		}		
	}
	//**** NO PATH FOUND *****
	return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// End A* code/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


@end
