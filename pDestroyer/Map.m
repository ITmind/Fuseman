//
//  Level.m
//  pDestroyer
//
//  Created by ITmind on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Map.h"
#import "Bonus.h"
#import "Level.h"
#import "Hud.h"
#import "SimpleAudioEngine.h"
#import "MapGenerator.h"
#import "tileset.h"


@implementation Map
@synthesize currentTileSet;

#define frameName(t,n) [NSString stringWithFormat:@"%@_anim%i.png",t,n]

CCAnimation* Anim(NSString* type, int numFrames){
    NSMutableArray *animFrames = [NSMutableArray array];
    for (int i = 0; i<numFrames; i++) {
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName(type,i)]];
    }
    return [CCAnimation animationWithFrames:animFrames delay:1/6.0];
}

+(Map*) mapFromFile:(NSString*)tmxFile
{
    Map* tempLevel = [[Map alloc] init];
    [tempLevel initFromFile:tmxFile];
    return tempLevel;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        allowDiags = NO;
        srand(time(NULL)|clock());
        currentTileSet = rand()%3;
        tileSet = [[TileSet alloc] init];
    }
    
    return self;
}

-(void) initFromFile:(NSString*)tmxFile
{
    _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:tmxFile];
    _background = [_tileMap layerNamed:@"Background"];
    meta = [_tileMap layerNamed:@"Meta"];
    meta.visible = NO;
    //_background.visible = NO;
    foreground = [_tileMap layerNamed:@"Foreground"];
    bonusesObjectGroup = [_tileMap objectGroupNamed:@"Bonuses"];
    
    //[[[_background textureAtlas] texture] setAntiAliasTexParameters];
    
    [self addChild:_tileMap];
    allowDiags = NO;
}

-(CGPoint) playerSpawnPoint
{
    CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objects != nil, @"'Objects' object group not found");
    NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPlayer"];        
    NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
    int x = [[spawnPoint valueForKey:@"x"] intValue];
    int y = [[spawnPoint valueForKey:@"y"] intValue];
	float offset = _tileMap.tileSize.width/2;
    
	return ccp(x+offset,y+offset+5);
}

-(CGPoint) enemySpawnPoint
{
    CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objects != nil, @"'Objects' object group not found");
    NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnEnemy"];        
    NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
    int x = [[spawnPoint valueForKey:@"x"] intValue];
    int y = [[spawnPoint valueForKey:@"y"] intValue];
	float offset = _tileMap.tileSize.width/2;
    
	return ccp(x+offset,y+offset+5);
}

-(CGSize) mapSize
{
    return _tileMap.mapSize;
}

-(CGSize) tileSize
{
    return _tileMap.tileSize;
}

-(CGPoint) tileCoordForPosition:(CGPoint)position
{
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(CGPoint) positionForTileCoord:(CGPoint)tileCoord
{
    int x = tileCoord.x * _tileMap.tileSize.width;
	int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (tileCoord.y*_tileMap.tileSize.height);
	return ccp(x,y);
}

-(bool) isCollidableTile:(CGPoint) coord isTileCoord:(bool) isTileCoord
{
	bool result = NO;
    
	CGPoint tileCoord = coord;
    if(!isTileCoord){
        tileCoord = [self tileCoordForPosition:coord];
    }
    
    if(tileArray[(int)tileCoord.x][(int)tileCoord.y]&TILE_WALL ||
       tileArray[(int)tileCoord.x][(int)tileCoord.y]&TILE_BOMB)
	{
		result = true;
	}
    
	if(!result){
        int tileGid = [meta tileGIDAt:tileCoord];
        
        if (tileGid) {
            
            NSDictionary* properties = [_tileMap propertiesForGID:tileGid];
            if (properties) {
                NSString *collision = [properties valueForKey:@"Collidable"];
                if (collision && [collision compare:@"True"] == NSOrderedSame) {
                    result = YES;
                }
            }
        }
    }
    
	return result;
}

-(bool) isCollectableTile:(CGPoint) coord isTileCoord:(bool) isTileCoord
{
	bool result = NO;
    
    CGPoint tileCoord = coord;
    if(!isTileCoord){
        tileCoord = [self tileCoordForPosition:coord];
    }
    
    if(tileArray[(int)tileCoord.x][(int)tileCoord.y]&TILE_DESTROY_OBJECT)
	{
		result = true;
	}
    
	if(!result){
        int tileGid = [meta tileGIDAt:tileCoord];
        
        if (tileGid) {
            
            NSDictionary* properties = [_tileMap propertiesForGID:tileGid];
            if (properties) {
                NSString *collision = [properties valueForKey:@"Collectable"];
                if (collision && [collision compare:@"True"] == NSOrderedSame) {
                    result = YES;
                }
            }
        }
    }
    
	return result;
}

-(void) removeWall:(CGPoint) tileCoord isNetwork:(bool)isNetwork
{
 
    NSString* wallType = [self tileTypeForCoord:tileCoord isTileCoord:YES];
	if(!wallType) return;
    
	[meta removeTileAt:tileCoord];
	[foreground removeTileAt:tileCoord];
    int col = tileCoord.x;
    int row = tileCoord.y;
    tileArray[col][row] = TILE_OPEN;
    
    Bonus* bonus = [((Level*)self.parent) getBonus:tileCoord isTileCoord:YES];
	if(bonus!=NULL){
		[bonus setActive:true];
		[self.parent addChild:bonus];
        tileArray[col][row] = tileArray[col][row]|TILE_BONUS;
	}
    
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName(wallType,0)];
	
    Level* level = (Level*)self.parent;
    if (!isNetwork) {
        [level.hud addScore:10];
    }
    
	CCAnimation* blowWallAnim = Anim(wallType, 4);
    CCAnimate* blowWallAction = [CCAnimate actionWithAnimation:blowWallAnim restoreOriginalFrame:NO];

    [self addChild:sprite];
	CGPoint posForSprite = [self positionForTileCoord:tileCoord];
	posForSprite.x +=self.tileSize.width/2;
	posForSprite.y -=self.tileSize.height/2;
    
	[sprite setPosition:posForSprite];
    
    if(level.sound){
        [[SimpleAudioEngine sharedEngine] playEffect:@"destroy.wav"];
    }
    
    CCAction* removeWallCallback = [CCCallFuncN actionWithTarget:self selector:@selector(removeSender:)];
	[sprite runAction:[CCSequence actions:blowWallAction,removeWallCallback, nil]];
    
}

-(void) removeSender:(id) sender{
    [self removeChild:sender cleanup:YES];
}

-(id) bonuses{
    return bonusesObjectGroup.objects;
}

-(id) objects{
    CCTMXObjectGroup *objectsGroup = [_tileMap objectGroupNamed:@"Objects"];
    return objectsGroup.objects;
}

-(int) tileArrayAtRow:(int)row col:(int)col
{
    return tileArray[row][col];
}

-(void) setTileArrayAtRow:(int)row col:(int)col value:(int)value
{
    tileArray[row][col] = tileArray[row][col]|value;
}

-(void) removeTileArrayAtRow:(int)row col:(int)col value:(int)value
{
    if(tileArray[row][col]&value){
        tileArray[row][col] = tileArray[row][col]^value;
    }
}

-(NSString*) tileTypeForCoord:(CGPoint) coord isTileCoord:(bool) isTileCoord{
    NSString* result = nil;
    
    CGPoint tileCoord = coord;
    if(!isTileCoord){
        tileCoord = [self tileCoordForPosition:coord];
    }
    
	int tileGid = [foreground tileGIDAt:tileCoord];
    
	if (tileGid) {
        
        NSDictionary* properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *type = [properties valueForKey:@"Type"];
            if (type) {
                result = type;
            }
        }
    }
    
	return result;
}

-(void) generateMap:(int) numBonuses numEnemy:(int)numEnemy isSingleLevel:(bool) isSingleLevel
{
    CCTMXObjectGroup *group = [_tileMap objectGroupNamed:@"Objects"];
    int x = 0;
	int y = 0;
    CGPoint tileCoord;
    
    MapGenerator* generator = [[MapGenerator alloc] init];
    for(int i=0;i<TILE_COLS;i++){
		for(int n=0;n<TILE_ROWS;n++){
            tileArray[i][n] = generator->tileArray[i][n];
            //set floor
            //NSLog(@"%i,%i",i,n);
            if (n==0||i==0||n==TILE_ROWS-1||n==TILE_ROWS-2 ||i==TILE_COLS-1
                ||(i==TILE_COLS-2 && n==1)
                ||(0<i && i<4 && TILE_ROWS-5<n && n<TILE_ROWS-2)) {
                //NSLog(@"continue");
                continue;
            }
            [_background setTileGID:tileSet->tilesetArray[currentTileSet].floor at:ccp(i,n)];
		}
	}
    

    for(int y=1;y<TILE_ROWS;y++){
        for(int x=1;x<TILE_COLS;x++){
            if((x==1 && y==1) || (x==2 && y==1) || (x==1 && y==2)) continue;
            if(y==14 && (x==1 || x==2 || x==3)) continue;
            if(tileArray[x][y]&TILE_WALL){
                int isMetaTile = [meta tileGIDAt:ccp(x,y)];
                if (!isMetaTile){ 
                    //[_background setTileGID:tileSet->tilesetArray[currentTileSet].wall at:ccp(x,y)];
                    [foreground setTileGID:tileSet->tilesetArray[currentTileSet].wall at:ccp(x,y)];
                    [meta setTileGID:19 at:ccp(x,y)];
                }
            }
        }
    }
    
	
    srand(time(NULL)|clock());
    int filldestroywall = 50;
   
    
	for(int y=1;y<TILE_ROWS;y+=1){
		for(int x=1;x<TILE_COLS;x+=1){
			if((x==1 && y==1) || (x==2 && y==1) || (x==1 && y==2)) continue;
            if((x==TILE_COLS-2 && y==TILE_ROWS-3) || (x==TILE_COLS-3 && y==TILE_ROWS-3) || (x==TILE_COLS-2 && y==TILE_ROWS-4)) continue;
            
			tileCoord = ccp(x,y);
			int isMetaTile = [meta tileGIDAt:tileCoord];
			int isBackgroundTile = [_background tileGIDAt:tileCoord];
			if (!isMetaTile && isBackgroundTile!=tileSet->tilesetArray[currentTileSet].wall) {
				int a = rand() % 100;
				if(a<filldestroywall){
                    [foreground setTileGID:tileSet->tilesetArray[currentTileSet].destroyWall at:tileCoord];
                    [meta setTileGID:20 at:tileCoord];
				}
			}
		}
	}
    
    
    //NSMutableArray* bonusesArray = [NSMutableArray arrayWithCapacity:numBonuses];
    for (int i=0; i<numBonuses; i++) {    
		while(true){
			srand(time(NULL)|clock());
			x = rand() % (TILE_COLS-1);
			y = rand() % (TILE_ROWS-1);
			int tileGid = [foreground tileGIDAt:ccp(x,y)];
			if(tileGid == tileSet->tilesetArray[currentTileSet].destroyWall && tileArray[x][y]!=TILE_BONUS){
				break;
			}
		}
		
		tileArray[x][y]=TILE_BONUS;
		CGPoint tileCoord = [self positionForTileCoord:ccp(x,y+1)];
        NSMutableDictionary* bonus = [NSMutableDictionary dictionaryWithCapacity:3];
        
        NSString* name = [NSString stringWithFormat:@"Bonus%i",i];
        int typeBonus = (rand() % 4)+1;
        //NSLog(@"bonus type: %i",typeBonus);
        
        [bonus setObject:name forKey:@"name"];
        [bonus setObject:[NSString stringWithFormat:@"%i",typeBonus] forKey:@"type"];
        [bonus setObject:[NSString stringWithFormat:@"%f",tileCoord.x] forKey:@"x"];
        [bonus setObject:[NSString stringWithFormat:@"%f",tileCoord.y] forKey:@"y"];
		
		[bonusesObjectGroup.objects addObject:bonus];
    }
    
    //set key
    if (isSingleLevel) {
        while(true){
			srand(time(NULL)|clock());
			x = rand() % (TILE_COLS-1);
			y = rand() % (TILE_ROWS-1);
			int tileGid = [foreground tileGIDAt:ccp(x,y)];
			if(tileGid == tileSet->tilesetArray[currentTileSet].destroyWall && tileArray[x][y]!=TILE_BONUS){
				break;
			}
		}
        
        tileArray[x][y]=TILE_BONUS;
		CGPoint tileCoord = [self positionForTileCoord:ccp(x,y+1)];
        NSMutableDictionary* bonus = [NSMutableDictionary dictionaryWithCapacity:3];
        
        NSString* name = [NSString stringWithFormat:@"Bonus%i",numBonuses+1];
        int typeBonus = 5;
        
        [bonus setObject:name forKey:@"name"];
        [bonus setObject:[NSString stringWithFormat:@"%i",typeBonus] forKey:@"type"];
        [bonus setObject:[NSString stringWithFormat:@"%f",tileCoord.x] forKey:@"x"];
        [bonus setObject:[NSString stringWithFormat:@"%f",tileCoord.y] forKey:@"y"];
		
		[bonusesObjectGroup.objects addObject:bonus];
    }
    
    NSMutableDictionary* spawnPoint = [NSMutableDictionary dictionaryWithCapacity:3];
    [spawnPoint setObject:@"SpawnPlayer" forKey:@"name"];
    [spawnPoint setObject:@"40" forKey:@"x"];
    [spawnPoint setObject:@"680" forKey:@"y"];
    [group.objects addObject:spawnPoint];
    
    NSMutableDictionary* exitPoint = [NSMutableDictionary dictionaryWithCapacity:3];
    [exitPoint setObject:@"Exit" forKey:@"name"];
    [exitPoint setObject:@"0" forKey:@"x"];
    [exitPoint setObject:@"680" forKey:@"y"];
    [group.objects addObject:exitPoint];
    
    int enemyTypeNumber = 0; 
    NSString* enemyType;
    for (int i=0; i<numEnemy; i++) {    
		while(true){
			srand(time(NULL)|clock());
			x = rand() % (TILE_COLS-1);
			y = rand() % (TILE_ROWS-1);
            if((x==1 && y==1) || (x==2 && y==1) || (x==1 && y==2)) continue;
			//int tileGid = [foreground tileGIDAt:];
            int isMetaTile = [meta tileGIDAt:ccp(x,y)];
			int isBackgroundTile = [_background tileGIDAt:ccp(x,y)];
            
			if(!isMetaTile && isBackgroundTile!=tileSet->tilesetArray[currentTileSet].wall && tileArray[x][y]!=TILE_ENEMY){
				break;
			}
		}
		
		tileArray[x][y]=TILE_ENEMY;
		CGPoint tileCoord = [self positionForTileCoord:ccp(x,y+1)];
        NSMutableDictionary* enemy = [NSMutableDictionary dictionaryWithCapacity:5];
        //NSLog(@"add enemy at %f:%f",tileCoord.x,tileCoord.y);
        NSString* name = [NSString stringWithFormat:@"EnemySpawn%i",i];
        
        
        [enemy setObject:name forKey:@"name"];
        [enemy setObject:@"SpawnPoint" forKey:@"type"];
        enemyTypeNumber = rand()%3;
        switch (enemyTypeNumber) {
            case 0:
                enemyType = @"ball.png";
                break;
            case 1:
                enemyType = @"snake.png";
                break;
            case 2:
                enemyType = @"rock.png";
                break;
            case 3:
                enemyType = @"gost.png";
                break;
            default:
                break;
        }
        [enemy setObject:enemyType forKey:@"character"];
        [enemy setObject:[NSString stringWithFormat:@"%f",tileCoord.x] forKey:@"x"];
        [enemy setObject:[NSString stringWithFormat:@"%f",tileCoord.y] forKey:@"y"];
		
		[group.objects addObject:enemy];
    }

    
}

-(void) generateMapFromTileArray
{
    CCTMXObjectGroup *group = [_tileMap objectGroupNamed:@"Objects"];

    for(int x=0;x<TILE_COLS;x++){
		for(int y=0;y<TILE_ROWS;y++){
            if (y==0||x==0||y==TILE_ROWS-1||y==TILE_ROWS-2 ||x==TILE_COLS-1
                ||(x==TILE_COLS-2 && y==1)
                ||(0<x && x<4 && TILE_ROWS-5<y && y<TILE_ROWS-2)) {
                //NSLog(@"continue");
                continue;
            }
            if(tileArray[x][y]&TILE_WALL){
                [_background setTileGID:tileSet->tilesetArray[currentTileSet].floor at:ccp(x,y)];
                [foreground setTileGID:tileSet->tilesetArray[currentTileSet].wall at:ccp(x,y)];
                [meta setTileGID:19 at:ccp(x,y)];
            }
            else if(tileArray[x][y]&TILE_DESTROY_OBJECT){
                [_background setTileGID:tileSet->tilesetArray[currentTileSet].floor at:ccp(x,y)];
                [foreground setTileGID:tileSet->tilesetArray[currentTileSet].destroyWall at:ccp(x,y)];
                [meta setTileGID:20 at:ccp(x,y)];
                
            }
            else if(tileArray[x][y]&TILE_OPEN){
                [_background setTileGID:tileSet->tilesetArray[currentTileSet].floor at:ccp(x,y)];
                
            }
        }
	}
    
    
    
    NSMutableDictionary* spawnPoint = [NSMutableDictionary dictionaryWithCapacity:3];
    [spawnPoint setObject:@"SpawnPlayer" forKey:@"name"];
    [spawnPoint setObject:@"40" forKey:@"x"];
    [spawnPoint setObject:@"680" forKey:@"y"];
    [group.objects addObject:spawnPoint];
    
    NSMutableDictionary* exitPoint = [NSMutableDictionary dictionaryWithCapacity:3];
    [exitPoint setObject:@"Exit" forKey:@"name"];
    [exitPoint setObject:@"0" forKey:@"x"];
    [exitPoint setObject:@"680" forKey:@"y"];
    [group.objects addObject:exitPoint];
    
}

-(CGPoint) exitTileCoord
{
    CCTMXObjectGroup *group = [_tileMap objectGroupNamed:@"Objects"];
    NSMutableDictionary *exitObject = [group objectNamed:@"Exit"];        
    int x = [[exitObject valueForKey:@"x"] intValue];
    int y = [[exitObject valueForKey:@"y"] intValue]+15;
    CGPoint posTileCoord = [self tileCoordForPosition:ccp(x,y)];
	return posTileCoord;
}

-(void) openExit
{
    CGPoint posTileCoord = [self exitTileCoord];
	CGPoint posCoord = [self positionForTileCoord:posTileCoord];
    [meta removeTileAt:posTileCoord];
    [_background removeTileAt:posTileCoord];
	tileArray[(int)posTileCoord.x][(int)posTileCoord.y] = TILE_OPEN;
    [_background setTileGID:128 at:posTileCoord];
    
    CCSprite* door = [CCSprite spriteWithSpriteFrameName:@"door.png"];
	// Font Item
	//CCLabelTTF *exitLabel = [CCLabelTTF labelWithString:@"exit" fontName:@"Marker Felt" fontSize:15];
	//exitLabel.position = ccp(posCoord.x+15,posCoord.y-14);		
	//[self addChild:exitLabel z:10];
    door.position = ccp(posCoord.x+(self.tileSize.width/2),posCoord.y-(self.tileSize.height/2));
    [self addChild:door z:10];
	CCActionInterval* color_action = [CCTintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
	CCActionInterval* color_back = [color_action reverse];
	CCFiniteTimeAction* seq = [CCSequence actions:color_action, color_back, NULL];
	[door runAction:[CCRepeatForever actionWithAction:(CCActionInterval*)seq]];
}

-(int) numWall
{
    int num = 0;
	for (int x=0; x<TILE_COLS-1; x++) {
		for (int y=0; y<TILE_ROWS-1; y++){
			if(tileArray[x][y]&TILE_DESTROY_OBJECT){
				num++;
			}
		}
	}
	
	return num;
}

-(void) createWallForRandomCoord:(int)num
{
    for(int i=0;i<num;i++){
		int x = 0;
		int y = 0;
		while(true){
			srand(time(NULL)|clock());
			x = (rand() % (TILE_COLS-3))+1;
			y = (rand() % (TILE_ROWS-5))+1;
			if(tileArray[x][y]&TILE_OPEN){
				break;
			}
		}
        
		[foreground setTileGID:tileSet->tilesetArray[currentTileSet].destroyWall at:ccp(x,y)];
		[meta setTileGID:155 at:ccp(x,y)];
		tileArray[x][y]=TILE_DESTROY_OBJECT;
	}
}
@end
