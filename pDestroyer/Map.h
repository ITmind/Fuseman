//
//  Level.h
//  pDestroyer
//
//  Created by ITmind on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Global.h"


#define TILE_WALL 1
#define TILE_OPEN 2
//#define TILE_MARKED 2
#define TILE_BOMB 4
#define TILE_BONUS 8
#define TILE_DESTROY_OBJECT 16
#define TILE_KILL 32
#define TILE_ENEMY 64

#define TILE_TAG 100

#define TILE_ROWS 19
#define TILE_COLS 25

//#define SPRITE_WIDTH 30
//#define SPRITE_HEIGHT 30
@class Bonus;
@class PathFindNode;
@class Player;
@class TileSet;

@interface Map : CCNode{
    CCTMXTiledMap *_tileMap;
	CCTMXLayer *_background;
	CCTMXLayer *foreground;
	CCTMXLayer *meta;
    CCTMXObjectGroup* bonusesObjectGroup;
    NSMutableArray *pointerToOpenList;
	BOOL allowDiags;
    //int numWall;
    
    TileSet* tileSet;
    
@public    
    unsigned char tileArray[TILE_COLS][TILE_ROWS]; 
    unsigned char currentTileSet;

}
@property unsigned char currentTileSet;

+(Map*) mapFromFile:(NSString*) tmxFile;
-(CGPoint) playerSpawnPoint;
-(CGPoint) enemySpawnPoint;
-(void) initFromFile:(NSString*) tmxFile;

-(CGSize) mapSize;
-(CGSize) tileSize;
-(CGPoint) tileCoordForPosition:(CGPoint) position;
-(CGPoint) positionForTileCoord:(CGPoint) tileCoord;

-(bool) isCollidableTile:(CGPoint) coord isTileCoord:(bool) isTileCoord;
-(bool) isCollectableTile:(CGPoint) coord isTileCoord:(bool) isTileCoord;
-(NSString*) tileTypeForCoord:(CGPoint) coord isTileCoord:(bool) isTileCoord;

-(void) removeWall:(CGPoint) tileCoord isNetwork:(bool)isNetwork;
-(void) removeSender:(id) sender;

-(id) bonuses;
-(id) objects;

-(int) tileArrayAtRow:(int)row col:(int)col;
-(void) setTileArrayAtRow:(int)row col:(int)col value:(int)value;
-(void) removeTileArrayAtRow:(int)row col:(int)col value:(int)value;

-(void) generateMap:(int) numBonuses numEnemy:(int)numEnemy isSingleLevel:(bool) isSingleLevel;
-(void) generateMapFromTileArray;
-(CGPoint) exitTileCoord;
-(void) openExit;
-(int) numWall;
-(void) createWallForRandomCoord:(int) num;

@end
