#import "Bomb.h"
#import "Map.h"
#import "Player.h"
#import "Level.h"
#import "SimpleAudioEngine.h"

//#define bombFrameName(t,n) [NSString stringWithFormat:@"%@_anim%i",t,n]
#define bombFrameName(t,n) [NSString stringWithFormat:@"%@_anim%i.png",t,n]

@implementation Bomb
@synthesize power;
@synthesize numDestroyWall;
@synthesize state;


CCAnimation* bombAnim(NSString* type, int numFrames){
    NSMutableArray *animFrames = [NSMutableArray array];
    for (int i = 0; i<numFrames; i++) {
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:bombFrameName(type,i)]];
    }
    return [CCAnimation animationWithFrames:animFrames delay:1/6.0];
}

- (id)init
{
    self = [super init];
    if (self) {
        typeBomb = @"bomb1";
        state = 1;
        power = 1;
    }
    
    return self;
}

-(void) initBombOfType:(NSString*)type
{
    typeBomb = type;
    spriteSheet = [CCNode node];
    sprite = [CCSprite spriteWithSpriteFrameName:bombFrameName(typeBomb,0)];
    blowAnimation = bombAnim(typeBomb,4);
    blowAnimation2 = bombAnim(@"blowup",4);
    [blowAnimation retain];
    [blowAnimation2 retain];
    
    [spriteSheet addChild:sprite z:1 tag:2];
    [self addChild:spriteSheet];
}

+(Bomb*) bombOfType:(NSString*)bombType power:(int)_power
{
    Bomb* tempBomb = [[Bomb alloc] init];
    tempBomb.power = _power;
    [tempBomb initBombOfType:bombType];
    return tempBomb;
}


-(void) setPosition:(CGPoint) pos
{
	sprite.position=pos;
}

-(CGPoint) position
{
	return sprite.position;
}

-(void) blowUp:(bool)immediate 
{
    //NSLog(@"state: %i",state);
    [sprite stopAllActions];
    if(immediate){
        state = 2;
        [self animateBlowRays];
    }
    else{
        state = 1;
    }
	[self animateBlowUp];
        
	//[self animateBlowRays];
}

-(void) markMapTile:(unsigned char) typeTile
{
    //add tile_kill
	Level* level = (Level*)self.parent;
	CGPoint curCoord = [level.map tileCoordForPosition:sprite.position];
    [level.map setTileArrayAtRow:curCoord.x col:curCoord.y value:typeTile];
    
	bool up = YES;
	bool down = YES;
	bool left = YES;
	bool right = YES;
    
	for(int i =1;i<power+1;i++)
	{
		if(right){
			curCoord.x+=i;
			if([level.map tileArrayAtRow:curCoord.x col:curCoord.y] & TILE_OPEN)
			{
				[level.map setTileArrayAtRow:curCoord.x col:curCoord.y value:typeTile];
			}
			else{ right = NO;}
			curCoord.x-=i;
		}
        
		if(left){
			curCoord.x-=i;
			if([level.map tileArrayAtRow:curCoord.x col:curCoord.y] & TILE_OPEN)
			{
				[level.map setTileArrayAtRow:curCoord.x col:curCoord.y value:typeTile];
			}
			else{ left = NO;}
			curCoord.x+=i;
		}
        
		if(down){
			curCoord.y-=i;
			if([level.map tileArrayAtRow:curCoord.x col:curCoord.y] & TILE_OPEN)
			{
				[level.map setTileArrayAtRow:curCoord.x col:curCoord.y value:typeTile];
			}
			else{ down = NO;}
			curCoord.y+=i;
		}
        
		if(up){
			curCoord.y+=i;
			if([level.map tileArrayAtRow:curCoord.x col:curCoord.y] & TILE_OPEN)
			{
				[level.map setTileArrayAtRow:curCoord.x col:curCoord.y value:typeTile];
			}
			else{ up = NO;}
			curCoord.y-=i;
		}
        
	}

}

-(void) animateBlowUp
{
	CCAnimate* animate;
	CCAnimate* animate2;
    Level* level = (Level*)self.parent;

    //CCAction* callback = [CCCallFunc actionWithTarget:self selector:@selector(actionFinish)];

    CCAction* callback = [CCCallFuncN actionWithTarget:self selector:@selector(actionFinish:)];
    CCAction* playSound = [CCCallFuncN actionWithTarget:self selector:@selector(beforeExplosion:)];
    Player* player = (Player*) self.userData;
    CCAction* bombBlowUpFinish = [CCCallFuncN actionWithTarget:player selector:@selector(bombBlowUpFinish:)];
    
    CCDelayTime* delayTime = [CCDelayTime actionWithDuration:2.0f];
    
	if(state==1){
		animate = [CCAnimate actionWithAnimation:blowAnimation restoreOriginalFrame:NO];
        [sprite runAction:[CCSequence actions: delayTime, playSound, animate,callback,nil]];
	}
	else{
        [level.bombs removeObject:self];
        CGPoint curCoord = [level.map tileCoordForPosition:sprite.position];
        //[self markMapTile:TILE_KILL];
		[level.map setTileArrayAtRow:(int)curCoord.x col:(int)curCoord.y value:TILE_KILL];
        
		animate2 = animate = [CCAnimate actionWithAnimation:blowAnimation2 restoreOriginalFrame:NO];
		[sprite runAction:[CCSequence actions: animate2,callback,bombBlowUpFinish,nil]];
	}
}

-(void) animateBlowRays
{
    numDestroyWall = 0;
    
	[self addBlowRay:RAY_UP];	
	[self addBlowRay:RAY_DOWN];	
	[self addBlowRay:RAY_LEFT];	
	[self addBlowRay:RAY_RIGHT];	
    
    Level* level = (Level*) self.parent;
    if (level.isPuzzle) {
        //if(numDestroyWall == 1 && [level.map numWall]>1){
        //    numDestroyWall=2;
        //}
        if(numDestroyWall > 0 && [level.map numWall]>2){
            [level.map createWallForRandomCoord:1];//numDestroyWall-1 ];
        }
    }
    
}


-(bool) addPowerRay:(int) directionRay index:(int)i
{
    Level* level = (Level*) self.parent;
    Map* map = level.map;
    
    bool result = NO;
    NSString* frameType;
    NSString* intermediate;
    CCAction* callback = [CCCallFuncN actionWithTarget:self selector:@selector(actionFinish:)];
    
	CGPoint pos = sprite.position;

	switch(directionRay){
        case RAY_UP:
            pos.y +=i*(SPRITE_HEIGHT-1);
            intermediate = @"rayvert";
            frameType = @"rayup";
            break;
        case RAY_DOWN:
            pos.y -=i*(SPRITE_HEIGHT-1);
            intermediate = @"rayvert";
            frameType = @"raydown";
            break;
        case RAY_LEFT:
            pos.x -=i*(SPRITE_WIDTH-1);
            intermediate = @"rayhoriz";
            frameType = @"rayleft";
            break;
        case RAY_RIGHT:
            pos.x +=i*(SPRITE_WIDTH-1);
            intermediate = @"rayhoriz";
            frameType = @"rayright";
            break;
        default:
            break;
	}
	
    CCSprite* ray = [CCSprite spriteWithSpriteFrameName:bombFrameName(frameType,0)];
    CGPoint rayPos = [map tileCoordForPosition:pos];
    //NSLog(@"ray tileArray %f:%f is %i",rayPos.x,rayPos.y,[level.map tileArrayAtRow:rayPos.x col:rayPos.y]);
    
    if([map tileArrayAtRow:rayPos.x col:rayPos.y]&TILE_BOMB){
        //NSLog(@"destroy another bomb");
        Bomb* temp = [level getBomb:rayPos isTileCoord:YES];
        //NSLog(@"state %i",temp.state);
		if(temp.state == 1){
			[temp blowUp:true];
		}
    }
    
    if(![map isCollidableTile:pos isTileCoord:NO]){
        
        
        //check wall
		if([map isCollectableTile:pos isTileCoord:NO]){
            Player* player = (Player*) self.userData;
			[map removeWall:rayPos isNetwork:player.isNetwork];
            numDestroyWall++;
            return NO;
		}
        
        ray.position=pos;
        //CGPoint curCoord = [map tileCoordForPosition:sprite.position];
        //NSLog(@"set tile_kill at %f:%f",rayPos.x, rayPos.y);
		[map setTileArrayAtRow:rayPos.x col:rayPos.y value:TILE_KILL];
        [spriteSheet addChild:ray z:1 tag:3];
        
        CCAnimation* rayAnimation;
        
        if(i==power){
            rayAnimation = bombAnim(frameType, 4);
        }
        else{
            rayAnimation = bombAnim(intermediate, 4);
        }
        
        CCAnimate* animate = [CCAnimate actionWithAnimation:rayAnimation restoreOriginalFrame:NO];
        [ray runAction:[CCSequence actions: animate,callback,nil]];
        
        result = true;
        
		//check characters
		for(Player* node in level.characters){

			if(node!=nil){
				CGPoint playerPos = [map tileCoordForPosition:node.position];
				CGPoint bombPos = [map tileCoordForPosition:sprite.position ];
				if(CGPointEqualToPoint(playerPos,rayPos) ||
					CGPointEqualToPoint(playerPos,bombPos) ){
						[node removeLife];
				}
			}
		}
        
    }
    
    return result;
}

-(void) addBlowRay:(int)directionRay
{
    for(int i = 1;i<(power+1);i++){
		if(![self addPowerRay:directionRay index:i]) return;
	}
}

-(void) actionFinish:(id)sender 
{
    Level* level = (Level*) self.parent;

	if(state==1){
		state=2;
		[self animateBlowRays];
		[self animateBlowUp];
	}
	else if(state==2){
        
        CGPoint curCoord = [level.map tileCoordForPosition:((CCSprite*)sender).position];
        //NSLog(@"tileArray %f:%f is %i",curCoord.x,curCoord.y,[level.map tileArrayAtRow:curCoord.x col:curCoord.y]);
        
        //NSLog(@"remove tile_kill and tile_bomb at %f:%f",curCoord.x, curCoord.y);
        [level.map removeTileArrayAtRow:curCoord.x col:curCoord.y value:TILE_KILL];
        [level.map removeTileArrayAtRow:curCoord.x col:curCoord.y value:TILE_BOMB];
		//[level.map setTileArrayAtRow:(int)curCoord.x col:(int)curCoord.y value:TILE_OPEN];
        [spriteSheet removeChild:sender cleanup:YES];
        
        if(!level.isNetwork && [level isBonus:curCoord isTileCoord:YES]){
            for (int i=0;i<4; i++) {
                Character* enemy = [level addCharacterOfType:@"gost.png" coord:curCoord isTileCoord:YES];
                [enemy setDirection:i];
                [enemy Move];
            }
        }
    }

}

-(void) beforeExplosion:(id)sender 
{
    Level* level = (Level*) self.parent;
    if(level.sound){
        [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.m4a"];
    }
}

@end