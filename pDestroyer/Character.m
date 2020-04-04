//
//  Character.m
//  pDestroyer
//
//  Created by ITmind on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Character.h"
#import "Level.h"
#import "Bonus.h"
#import "PathFindNode.h"
#import "Map(PathFinder).h"
#import "SimpleAudioEngine.h"
#import "Hud.h"

#define playerFrameName(t,n,p) [NSString stringWithFormat:@"%@%i_%@",t,n,p]

@implementation Character
@synthesize isPlayer;
@synthesize lifes;
@synthesize  move;
@synthesize bombpower;
@synthesize bombnumber;
@synthesize speed;
@synthesize isNetwork,typeCharacter;

+(Character*) characterOfType:(NSString*)type
{
    Character* tempPlayer = [[Character alloc] init];
    [tempPlayer initOfType:type];
    return tempPlayer;
}

CCAnimation* playerAnim(NSString* type, int numFrames, NSString* playerType){
    NSMutableArray *animFrames = [NSMutableArray array];
    for (int i = 0; i<numFrames; i++) {
        CCSpriteFrame* tempSprite = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:playerFrameName(type,i,playerType)];
        [animFrames addObject: tempSprite];
    }
    return [CCAnimation animationWithFrames:animFrames delay:1/6.0];
}

- (void) initOfType:(NSString*) type
{
    typeCharacter = type;
    sprite = [CCSprite spriteWithSpriteFrameName:playerFrameName(@"down",0,typeCharacter)];
    cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCAnimation* downAnimation = playerAnim(@"down", 3, typeCharacter);
    downAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:downAnimation restoreOriginalFrame:YES]];
    [downAction retain];
    
    CCAnimation* upAnimation = playerAnim(@"up", 3, typeCharacter);
    upAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:upAnimation restoreOriginalFrame:YES]];
    [upAction retain];
    
    CCAnimation* rightAnimation;
    if(mirrored){
        rightAnimation = playerAnim(@"left", 3, typeCharacter);
    }
    else
    {
        rightAnimation = playerAnim(@"right", 3, typeCharacter);
    }
    rightAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:rightAnimation restoreOriginalFrame:YES]];
    [rightAction retain];
    
    CCAnimation* leftAnimation = playerAnim(@"left", 3, typeCharacter);
    leftAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:leftAnimation restoreOriginalFrame:YES]];
    [leftAction retain];
    
    [self removeChild:sprite cleanup:YES];
    [self addChild:sprite];
}

- (id)init
{
    self = [super init];
    if (self) {
        typeCharacter = @"";
        direction = 0;
        move = NO;
        nextAction = -1;
        
        lifes = 1;
        bombpower = 1;
        bombnumber = 1;
        speed = 1;
        numSetBomb = 0;
        mirrored = false;
        numDeathFrame = 6;
        
        immortal = NO;
        runAct = NO;
        curAimFrame = 0;
    }
    
    return self;
}


-(void) setPosition:(CGPoint) pos
{
    sprite.position = pos;
}

-(CGPoint) position
{
    return sprite.position;
}

-(float) rotation
{
    return sprite.rotation;
}


-(void) setDirection:(int) dir
{
	if(direction!=dir){
		direction = dir;
	}
}

-(int) direction
{
	return direction;
}

-(void) virtualMove
{
    switch(direction)
    {
        case PLAYER_DOWN:
            [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"down",curAimFrame,typeCharacter)]];
            //currentAction = downAction;
            break;
        case PLAYER_RIGHT:
            if(mirrored){
                [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"left",curAimFrame,typeCharacter)]];
                [sprite flipX];
                [sprite runAction:[CCFlipX actionWithFlipX:YES]];
                //currentAction = leftAction;
            }
            else{
                [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"right",curAimFrame,typeCharacter)]];
                //currentAction = rightAction;
            }
            break;
        case PLAYER_LEFT:
            [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"left",curAimFrame,typeCharacter)]];
            if(mirrored){
                [sprite runAction:[CCFlipX actionWithFlipX:NO]];
            }
            //currentAction = leftAction;
            break;
        case PLAYER_UP:
            [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"up",curAimFrame,typeCharacter)]];
            //currentAction = upAction;
            break;
    }
    curAimFrame++;
    if(curAimFrame>2) curAimFrame = 0;
	
}


-(void) Move
{
    Level* level = (Level*) self.parent;
    Map* map = level.map;
    
    if(lifes<=0) return;
    //if(immortal) return;
    
    if(move){
		nextAction = direction;
		return;
	}
	move = YES;
    
    if(!isNetwork){
        [level movePlayer:self];
    }
    
    int step = map.tileSize.width;
    
	CGPoint playerPos = sprite.position;
    
	switch(direction)
	{
        case PLAYER_DOWN:
            playerPos.y -=step;
            [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"down",0,typeCharacter)]];
            currentAction = downAction;
            break;
        case PLAYER_RIGHT:
            playerPos.x +=step;
            if(mirrored){
                [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"left",0,typeCharacter)]];
                [sprite flipX];
                [sprite runAction:[CCFlipX actionWithFlipX:YES]];
                currentAction = leftAction;
            }
            else{
                [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"right",0,typeCharacter)]];
                currentAction = rightAction;
            }
            
            break;
        case PLAYER_LEFT:
            playerPos.x -=step;
            [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"left",0,typeCharacter)]];
            if(mirrored){
                [sprite runAction:[CCFlipX actionWithFlipX:NO]];
            }
            currentAction = leftAction;
            break;
        case PLAYER_UP:
            playerPos.y +=step;
            [sprite setDisplayFrame:[cache spriteFrameByName:playerFrameName(@"up",0,typeCharacter)]];
            currentAction = upAction;
            break;
	}
    
    [sprite runAction:currentAction];
    if([map isCollidableTile:playerPos isTileCoord:NO] || [map isCollectableTile:playerPos isTileCoord:NO]){
		move = NO;
		//[sprite stopAllActions];
        [sprite stopAction:currentAction];
		return;
	}
    
    ccTime moveDuration = 1-(0.01f*speed);
    moveAction = [CCSequence actions:[CCMoveTo actionWithDuration:moveDuration position:playerPos],[CCCallFuncN actionWithTarget:self selector:@selector(endMove:)], nil];
    
	[sprite runAction:moveAction];
	nextAction=-1;
	
}


-(void) endMove:(CCNode *)sender
{
    //Map* map = ((Level*) self.parent).map;
    
    
    if(move){
		//[sprite stopAllActions];
        [sprite stopAction:moveAction];
        [sprite stopAction:currentAction];
		move = NO;
		if(nextAction!=-1){
            if(isNetwork){
                //[self Move];
            }
		}
	}
    
    if(lifes<=0) return;
    //if(immortal) return;
    
    Level* level = (Level*)self.parent;
    if(collectBonus){
        Bonus* bonus = [((Level*)self.parent) getBonus:sprite.position isTileCoord:NO];
        if(bonus!=nil){
            if(bonus.active){
                [level removeBonus:bonus];
                switch([bonus collect]){
                    case 1:
                        bombnumber++;
                        if(isPlayer && !isNetwork) [level.hud addNumBomb];
                        if(level.sound){
                            [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.m4a"];
                        }
                        break;
                    case 2:
                        bombpower++;
                        if(isPlayer && !isNetwork) [level.hud addPower];
                        if(level.sound){
                            [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.m4a"];
                        }
                        break;
                    case 3:
                        lifes++;
                        if(isPlayer && !isNetwork) [level.hud addLife];
                        if(level.sound){
                            [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.m4a"];
                        }
                        break;
                    case 4:
                        if(isPlayer && !isNetwork) [level.hud addSpeed];
                        if(level.sound){
                            [[SimpleAudioEngine sharedEngine] playEffect:@"bonus.m4a"];
                        }
                        if(speed<70) speed+=10;
                        break;
                    case 5:
                        [level openExit];
                        if(level.sound){
                            [[SimpleAudioEngine sharedEngine] playEffect:@"pickupkey.mp3"];
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
    if (isPlayer && !level.isNetwork) {
        CGPoint exitCoord = level.map.exitTileCoord;
        CGPoint currentPlayerPos = [level.map tileCoordForPosition:self.position];
        if(CGPointEqualToPoint(exitCoord, currentPlayerPos)){
            [level levelComplite];
        }
    }
    
    if(patchStartNode == NULL) return;
    
	PathFindNode* nextNode = patchStartNode.nextNode;
	if(nextNode!=NULL){
		//set direction
		CGPoint newTileCoord = ccp(nextNode.nodeX,nextNode.nodeY);
		[self determineDirection:newTileCoord];
		[self Move];
		patchStartNode = nextNode;
	}
	else{
		//delete pach from memory
		//[self deletePath];
	}
}

-(void) removeLife
{
    if(immortal) return;
	lifes--;
    Level* level = (Level*)self.parent;
    
	//blink
    
	if(lifes==0){
        [sprite stopAllActions];
		move = NO;
        if (!isPlayer) {
            [level.hud addScore:40];
        }
        CCAnimation* deadAnimation = playerAnim(@"death", numDeathFrame, typeCharacter);
        CCAnimate* animateDead = [CCAnimate actionWithAnimation:deadAnimation restoreOriginalFrame:NO];
		[sprite runAction:[CCSequence actions:animateDead,[CCCallFuncN actionWithTarget:self.parent selector:@selector(characterDead:)],nil]];
	}
	else if(lifes>0)
    {
        //[sprite stopAllActions];
        //NSLog(@"set immortal for %i",self);
        immortal = YES;
        //move = NO;
        CCDelayTime* delayTime = [CCDelayTime actionWithDuration:0.9f];
        CCBlink* blink = [CCBlink actionWithDuration:1 blinks:10];
		[sprite runAction:[CCSequence actions:blink,delayTime, [CCCallFuncN actionWithTarget:self selector:@selector(disableImmortal:)],nil]];
        
        if(isPlayer){
            //NSLog(@"remove bonus");
            if(bombpower>1) bombpower--;
            if((bombnumber+numSetBomb)>1) bombnumber--;
            //if (bombnumber<1) {
            //    bombnumber = 1;
            //}
            if(speed>10) speed-=10;
            if (!isNetwork) {
                [level.hud setBonusLabelPower:bombpower life:lifes numbomb:bombnumber+numSetBomb speed:speed];
            }
            //else{
            //    [level.hud setBonusLabelPower:bombpower life:lifes numbomb:bombnumber speed:speed];
            //}
            
        }
	}
	
}

-(void) disableImmortal:(CCNode*) sender
{
    //NSLog(@"disable immortal");
    immortal = NO;
}

-(void) walkTo:(CGPoint) coord isTileCoord:(bool) isTileCoord
{
    if(lifes<=0) return;
    
    Level* level = (Level*) self.parent;
    Map* map = level.map;
    
	CGPoint from = [map tileCoordForPosition:self.position];
	CGPoint to;
	if(isTileCoord)
		to = coord;
	else
		to = [map tileCoordForPosition:coord];
	
	[self deletePath];
    
	patchStartNode = [map findPath:from.x :from.y :to.x :to.y];
	//cherz jopu, no pravilno
	if(!move){
		[self endMove:nil];
	}
}

-(int) determineDirection:(CGPoint) tileCoord
{
    Map* map = ((Level*) self.parent).map;
    
	CGPoint playerTileCoord = [map tileCoordForPosition:self.position];
	int x = tileCoord.x - playerTileCoord.x;
	int y = tileCoord.y - playerTileCoord.y;
    
	if(x>0) direction = 1;
	else if(x<0) direction = 2;
	else if(y>0) direction = 0;
	else if(y<0) direction = 3;
    
	return direction;
}

-(void) deletePath;
{
	if(patchStartNode == NULL) return;
    
	//find first node
	while(patchStartNode.parentNode != NULL){
		patchStartNode = patchStartNode.parentNode;
	}
    
	//delete
	while(patchStartNode.nextNode!=NULL){
		PathFindNode* nextNode = patchStartNode.nextNode;
        //[patchStartNode release];
		nextNode.parentNode = NULL;
		patchStartNode = nextNode;
	}
    
	patchStartNode = NULL;
}

-(void) stepAI
{
    if(lifes<=0) return;
	
	if(!move){
        
        Level* level = (Level*) self.parent;
        Map* map = level.map;
        CGPoint enemyTileCoord = [map tileCoordForPosition:self.position];
        CGSize layerSize = map.mapSize;
        CGPoint newTileCoord = ccp(0,0);
        srand(time(NULL)|clock());
        int a = 0;
        int b = 0;
        int newX = 0;
        int newY = 0;
        
		//random direction
		while(true){
			
			a = rand() % 4;
			b = (rand() % 5) +1; //lenght
            newX = 0;
            newY = 0;
            newTileCoord.x = enemyTileCoord.x;
            newTileCoord.y = enemyTileCoord.y;
            //NSLog(@"a:%i b:%i newTileCoordX:%f newTileCoordY:%f",a,b,newTileCoord.x,newTileCoord.y);
            
			switch(a){
                    
                case 0: //up
                    newY = enemyTileCoord.y-b;
                    if(0<= newY && newY <=layerSize.width)
                    {
                        newTileCoord.y = newY;
                    }
                    
                    break;
                case 1: //down
                    newY = enemyTileCoord.y+b;
                    if(0<= newY && newY <=layerSize.width)
                    {
                        newTileCoord.y = newY;
                    }
                    break;
                case 2: //left
                    newX = enemyTileCoord.x-b;
                    if(0<= newX && newX <=layerSize.height)
                    {
                        newTileCoord.x = newX;
                    }
                    break;
                case 3: //right
                    newX = enemyTileCoord.x+b;
                    if(0<= newX && newX <=layerSize.height)
                    {
                        newTileCoord.x = newX;
                    }
                    break;
			}
            //NSLog(@"newX:%i newTileCoordX:%f newY:%i newTileCoordY:%f",newX,newTileCoord.x,newY,newTileCoord.y);
			//prowerka na otkratost
			if([map tileArrayAtRow:newTileCoord.x col:newTileCoord.y] & TILE_OPEN){
				break;
			}
		}
        //NSLog(@"---------GO---------");
		[self walkTo:ccp(newTileCoord.x,newTileCoord.y) isTileCoord:YES];
        
	}

}

-(void) reverseDirection
{
    switch(direction){
        case PLAYER_LEFT:
            direction = PLAYER_RIGHT;
            break;
        case PLAYER_RIGHT:
            direction = PLAYER_LEFT;
            break;
        case PLAYER_DOWN:
            direction = PLAYER_UP;
            break;
        case PLAYER_UP:
            direction = PLAYER_DOWN;
            break;
	}
}

-(void) setColor:(ccColor3B) color{
    sprite.color = color;
}

-(void) blink{
    [sprite runAction:[CCBlink actionWithDuration:3 blinks:30]];
}

@end
