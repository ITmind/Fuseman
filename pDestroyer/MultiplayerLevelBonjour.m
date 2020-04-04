//
//  MultiplayerLevelBonjour.m
//  fuseman
//
//  Created by ITmind on 02.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiplayerLevelBonjour.h"
#import "Map.h"
#import "Player.h"
#import "Map(PathFinder).h"
#import "Bonus.h"
#import "Hud.h"
#import "Bomb.h"
#import "SimpleAudioEngine.h"
#import "NSMutableArray+Queue.h"

@implementation MultiplayerLevelBonjour
@synthesize player2;

-(id) init{
    self = [super init];
    isPause = YES;
    isServer = NO;
    currentRaund = 1;
    scoreAnotherPlayer = 0;
    thisScore = 0;
    networkScore = 0;
    self.networkQueue = [NSMutableArray arrayWithCapacity:20];
    [self setup];
    return self;
}

-(void) startServer{
    characterDead = NO;
    [self unscheduleAllSelectors];
    [self initLevelWithFilename:@""];
    
    //PLAYER 2
    self.player2 = [Player playerOfType:@"player2.png"];
    CGPoint newPos = [map positionForTileCoord:ccp(TILE_COLS-2,TILE_ROWS-3)];
    newPos.x+=20;
    newPos.y-=15;
    self.player2.position = newPos;
    self.player2.isPlayer = YES;
    self.player2.speed =20;
    self.player2.isNetwork = YES;
    self.player2.lifes = 1;
    [self addChild:self.player2];
    [characters addObject:self.player2];
    
    //PLAYER 1
    self.player.speed = 20;
    self.player.lifes =1;
    [hud setBonusLabelForPlayer:self.player];
    
    NSMutableData* data = [NSMutableData dataWithBytes:&map->tileArray[0][0] length:475];
    [data appendBytes:&map->currentTileSet length:sizeof(unsigned char)];
    
    [data appendBytes:&numBonuses length:4];
    for (Bonus* bonus in bonuses) {
        CGPoint tileCoord = [map tileCoordForPosition:bonus.position];
        char x = tileCoord.x;
        char y = tileCoord.y;
        char t = bonus.type;
        [data appendBytes:&x length:1];
        [data appendBytes:&y length:1];
        [data appendBytes:&t length:1];
    }
    
    //NSData *data = [NSData dataWithBytes:&map->tileArray[0][0] length:475];
    while (![self send:data packetID:NETWORK_B_MAP]) {
        //send while NO;
    }
    
    [self schedule:@selector(sendCurrentGameStatus:) interval:0.5f];
    [self showText:[NSString stringWithFormat:@"RAUND %i",currentRaund]];
    numLevelLabel.string = [NSString stringWithFormat:@"Raund %i",currentRaund];
    minutes=7;
    hud.score = 0;
     isPause = NO;
    [player blink];
}
-(void) startClient{
    characterDead = NO;
    [self unscheduleAllSelectors];

    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"WAIT SERVER....." fontName:@"04B_09.TTF" fontSize:58];
    label1.color = ccc3(255, 255, 255);
    label1.position = ccp(winSize.width/2,winSize.height/2);
    [self addChild:label1];
    
    CCMenuItemFont *mainMenu = [CCMenuItemFont itemFromString:@"Cancel" target:self selector: @selector(mainMenuClick:)];
    self.pauseMenu = [CCMenu menuWithItems:mainMenu, nil];
	self.pauseMenu.position = ccp(winSize.width/2,winSize.height-500);
	[self.pauseMenu setColor:ccc3(255,255,255)];	
	[self addChild:pauseMenu];
    
    //wait connect
    
    //bonuses = [NSMutableArray arrayWithCapacity:numBonuses];
    //[bonuses retain];

    //map = [Map mapFromFile:@"blank.tmx"];
    //[map loadMapObjects];
}

-(void) reciveData:(NSData*)data packetID:(char)packetID
{
    unsigned char *bytePtr = (unsigned char *)[data bytes];
    
    switch (packetID) {
        case NETWORK_B_MAP:
            //self.bonuses = [NSMutableArray arrayWithCapacity:numBonuses];
            
            self.map = [Map mapFromFile:@"blank.tmx"];
            [map loadMapObjects];
            
            memcpy(map->tileArray,bytePtr, 475);
            self.map.currentTileSet = bytePtr[475];
            [self.map generateMapFromTileArray];
            [self initLevel];
            
            //[self send:data packetID:NETWORK_B_CLIENT_START];
            
            //load bonuses
            int numBon = 0;
            int curPosInArray = 479;
            memcpy(&numBon,&bytePtr[476], 4);
            for (int i=0; i<numBon; i++) {
                curPosInArray++;
                char x = bytePtr[curPosInArray];
                curPosInArray++;
                char y = bytePtr[curPosInArray];
                curPosInArray++;
                char t = bytePtr[curPosInArray];
                [self setBonusOfType:t tileCoord:ccp(x,y) addToLayer:NO];
            }
            
            //set own player position
            CGPoint newPos = [map positionForTileCoord:ccp(TILE_COLS-2,TILE_ROWS-3)];
            newPos.x+=20;
            newPos.y-=15;
            
            [self removeChild:player cleanup:YES];
            [self.player release];
            self.player = [Player playerOfType:@"player2.png"];
            //[player initOfType:@"player2.png"];
            self.player.speed = 20;
            self.player.position = newPos;
            self.player.lifes =1;
            self.player.bombnumber = 1;
            self.player.bombpower = 1;
            self.player.isPlayer = YES;
            [self addChild:self.player];
            [self.characters addObject:self.player];
            
            //set player2
            self.player2 = [Player playerOfType:@"player1.png"];
            newPos = [map positionForTileCoord:ccp(1,1)];
            newPos.x+=20;
            newPos.y-=15;
            self.player2.speed = 20;
            self.player2.position = newPos;
            self.player2.isPlayer = YES;
            self.player2.isNetwork = YES;
            self.player2.lifes = 1;
            self.player2.bombnumber = 1;
            self.player2.bombpower = 1;
            [self addChild:self.player2];
            [self.characters addObject:self.player2];
            
            [hud setBonusLabelForPlayer:player];
            [self showText:[NSString stringWithFormat:@"RAUND %i",currentRaund]];
            numLevelLabel.string = [NSString stringWithFormat:@"Raund %i",currentRaund];
            //minutes=7;
            isPause = NO;
            hud.visible = YES;
            hud.score = 0;
            
            [player blink];
            break;
        case NETWORK_B_CLIENT_START:
            //[self schedule:@selector(sendCurrentGameStatus:)];
            //[self schedule:@selector(executeNetworkQueue:)];
            break;
    }
}

-(void) recivegameData:(MultiGameDataStruct) struc packetID:(char)packetID
{
    switch (packetID) {
        case NETWORK_B_MOVE_EVENT:
            self.player2.direction = struc.direction;
            self.player2.position = ccp(struc.x,struc.y);
            [self.player2 endMove:nil];
            [self.player2 Move];
            break;
        case NETWORK_B_SET_BOMB_EVENT:
            //[self.player2 setBomb];
            if (true) {    
                Bomb* bomb = [Bomb bombOfType:@"bomb1" power:player2.bombpower];
                bomb.userData = self.player2;
                [self addChild:bomb z:-1 tag:2];
                CGPoint tileCoordForBomb = [map tileCoordForPosition:ccp(struc.x,struc.y)];
                CGPoint posForBomb = [map positionForTileCoord:tileCoordForBomb];
                posForBomb.x +=map.tileSize.width/2;
                posForBomb.y -=map.tileSize.height/2;
                bomb.position = posForBomb;
                [map setTileArrayAtRow:tileCoordForBomb.x col:tileCoordForBomb.y value:TILE_BOMB];
                [bombs addObject:bomb];
                [bomb blowUp:NO];
                if(sound){
                    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
                }
            }
            break;
        case NETWORK_B_DESTROY_WALL_EVENT:
            break;
        case NETWORK_B_EVENT:
                if(!isServer){
                    seconds = struc.seconds;
                    minutes = struc.minutes;
                }
                scoreAnotherPlayer = struc.scoreAnotherPlayer;
                
//                self.player2.direction = bytePtr[6];
//                self.player2.position = newPos;
//                CGPoint old = [self.player2 position];
//                if (!CGPointEqualToPoint(newPos, old)) {
//                    [self.player2 virtualMove];
//                }             
            break;
        default:
            break;
    }
   
}

-(void) destroyWall:(id)sender{
    //[super destroyWall:sender];
}

-(void) movePlayer:(id)sender{
    [super movePlayer:sender];
    [self send:NETWORK_B_MOVE_EVENT];
}

-(void) setBomb:(CGPoint) pos tilePos:(CGPoint)tilePos{
    [super setBomb:pos tilePos:tilePos];
    [self send:NETWORK_B_SET_BOMB_EVENT];
}

-(void) sendCurrentGameStatus:(ccTime) dt{
    if (isServer) {

        [self send:NETWORK_B_EVENT];
    }
}

//LEVEL INTERFACE
-(void) levelLost
{
    currentRaund++;
    if(currentRaund<=NUM_RAUNDS){
        if (!characterDead) {
            if (hud.score>scoreAnotherPlayer) {
                thisScore++;
                [self showText:[NSString stringWithFormat:@"PLAYER 1 SCORE WIN",currentRaund]];
            }
            else{
                networkScore++;
                [self showText:[NSString stringWithFormat:@"PLAYER 2 SCORE WIN",currentRaund]];
            }
        }
        
        [self replayClick:nil];
    }
    else{
        currentRaund =1;
        networkScore = 0;
        thisScore = 0;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        isPause = true;
        self.fog = [CCLayerColor node];
        [self.fog initWithColor:ccc4(0,0,0,220)];
        [self addChild:self.fog z:20];
        self.fog.position=CGPointZero;
        hud.visible = NO;
        
        CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"GAME OVER" fontName:@"04B_09.TTF" fontSize:88];
        label1.position = ccp(winSize.width/2,winSize.height-200);
        [fog addChild:label1];
        
        label1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",isServer?thisScore:networkScore] fontName:@"04B_09.TTF" fontSize:40];
        label1.position = ccp(winSize.width/2-50,winSize.height-300);
        [fog addChild:label1];
        
        label1 = [CCLabelTTF labelWithString:@":" fontName:@"04B_09.TTF" fontSize:88];
        label1.position = ccp(winSize.width/2,winSize.height-300);
        [fog addChild:label1];
        
        label1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",isServer?networkScore:thisScore] fontName:@"04B_09.TTF" fontSize:40];
        label1.position = ccp(winSize.width/2+50,winSize.height-300);
        label1.color = ccc3(0, 255, 0);
        [fog addChild:label1];
        
        //[CCMenuItemFont setFontName:@"Marker Felt"];
        [CCMenuItemFont setFontSize:30];
        
        CCMenuItemFont *mainMenu = [CCMenuItemFont itemFromString:@"MAIN MENU" target:self selector: @selector(mainMenuClick:)];
        CCMenuItemFont *replay = [CCMenuItemFont itemFromString:@"REPLAY" target:self selector: @selector(replayClick:)];
        
        CCActionInterval* color_action = [CCTintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
        CCActionInterval* color_back = [color_action reverse];
        CCFiniteTimeAction* seq = [CCSequence actions:color_action, color_back, nil];
        [replay runAction:[CCRepeatForever actionWithAction:(CCActionInterval*)seq]]; 
        
        self.pauseMenu = [CCMenu menuWithItems:mainMenu,replay, nil];
        self.pauseMenu.position = ccp(winSize.width/2,winSize.height/2-50);
        [self.pauseMenu alignItemsHorizontallyWithPadding:40.0f];
        [self.pauseMenu setColor:ccc3(255, 255, 255)];
        
        [self.fog addChild:pauseMenu z:2];
    }
}

-(void) replayClick:(id)sender
{
    hud.visible = NO;
    isPause = YES;
    [self removeAllChildrenWithCleanup:YES];

    //wait connect
    
    if(currentRaund>3){
        currentRaund =1;
        networkScore = 0;
        thisScore = 0;
    }
    //isPause = NO;
    if(isServer){
        [self startServer];
    }
    else{
        NSLog(@"replay start client");
        [self startClient];
    }

}

-(void)pauseClick:(id)sender
{
	self.fog = [CCLayerColor node];
	[self.fog initWithColor:ccc4(0,0,0,140)];
    [self addChild:fog z:20];
    self.fog.position=CGPointZero;
    
    [CCMenuItemFont setFontSize:48];
	CCMenuItemFont *mainMenu = [CCMenuItemFont itemFromString:@"Main menu" target:self selector: @selector(mainMenuClick:)];
    
	CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    self.pauseMenu = [CCMenu menuWithItems:mainMenu, nil];
	self.pauseMenu.position = ccp(winSize.width/2,winSize.height/2);
	[self.pauseMenu alignItemsVerticallyWithPadding:20.0f];
	[self.pauseMenu setColor:ccc3(255,255,255)];
	
	[self.fog addChild:pauseMenu z:2];
}

-(void) levelComplite
{
    //[self levelLost];
}

-(void) characterDead:(CCNode*) sender{
    characterDead = YES;
	[characters removeObject:sender.parent];
    if (!((Character*)sender.parent).isNetwork) {
        networkScore++;
    }
    else{
        thisScore++;
    }
    
    [self removeChild:sender.parent cleanup:YES];
    [self levelLost];
    
}

@end
