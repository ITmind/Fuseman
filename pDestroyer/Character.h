//
//  Character.h
//  pDestroyer
//
//  Created by ITmind on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define PLAYER_DOWN 0
#define PLAYER_RIGHT 1
#define PLAYER_LEFT 2
#define PLAYER_UP 3

@class PathFindNode;

@interface Character : CCNode{
    CCSpriteFrameCache *cache;
	CCSprite* sprite;
	NSString* typeCharacter;
	char direction; //0-down, 1-right, 2-left, 3-up
    
    CCAction* downAction;
	CCAction* upAction;
	CCAction* leftAction;
	CCAction* rightAction;
	CCAction* moveAction;
    CCAction* currentAction;
    
    bool move;
    int nextAction;
    
    int lifes;
	int speed;
	int bombpower;
	int bombnumber;
    int numSetBomb;
    
    PathFindNode* patchStartNode;
    
    bool collectBonus;
    bool isPlayer;
    bool mirrored;
    int numDeathFrame;
    
    bool immortal;
    bool isNetwork;
    
    bool runAct;
    int curAimFrame;
}

@property bool isPlayer;
@property int lifes;
@property bool move;
@property int bombpower;
@property int bombnumber;
@property int speed;
@property bool isNetwork;
@property (retain) NSString* typeCharacter;


+(Character*) characterOfType:(NSString*)type;
- (void) initOfType:(NSString*) type;

//
-(void) setPosition:(CGPoint) pos;
-(CGPoint) position;
-(float) rotation;

-(void) setDirection:(int) dir;
-(int) direction;
-(int) determineDirection:(CGPoint) tileCoord;

//
-(void) Move;
-(void) endMove:(CCNode*) sender;
-(void) walkTo:(CGPoint) coord isTileCoord:(bool) isTileCoord;
-(void) deletePath;

-(void) removeLife;
-(void) disableImmortal:(CCNode*) sender;

-(void) stepAI;
-(void) reverseDirection;

-(void) setColor:(ccColor3B) color;
-(void) virtualMove;

-(void) blink;

@end
