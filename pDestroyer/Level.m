//
//  HelloWorldLayer.mm
//  pDestroyer
//
//  Created by ITmind on 29.07.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "Level.h"

#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedJoystickExample.h"
#import "SneakyJoystickSkinnedDPadExample.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "ColoredCircleSprite.h"

#import "Player.h"
#import "Map.h"
#import "Bomb.h"
#import "Bonus.h"
#import "PathFindNode.h"
#import "NSMutableArray(PathFinder).h"
#import "Map(PathFinder).h"
#import "EnemyBall.h"
#import "Snake.h"
#import "Rock.h"
#import "SceneManager.h"
#import "Hud.h"
#import "Gost.h"
#import "SimpleAudioEngine.h"

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation Level
@synthesize map;
@synthesize characters;
@synthesize player;
@synthesize isPause;
@synthesize hud;
@synthesize isPuzzle;
@synthesize isNetwork;
@synthesize isRandom;
@synthesize numBonuses;
@synthesize numEnemy;
@synthesize currentLevel;
@synthesize bombs;
@synthesize sound,bonuses,numLevelLabel,pauseMenu,pauseButton,fog,timerLabel;
@synthesize networkQueue;

-(void) backgroundMusicFinished
{
    //NSLog(@"music stop");
    [self setBackgroundMusic];
}

-(void) setBackgroundMusic
{
    
    if(!music) return;
    int rndMusic = arc4random() % 5+1;
    
    [[CDAudioManager sharedManager] playBackgroundMusic:[NSString stringWithFormat:@"track%i.mp3",rndMusic] loop:NO];
    
}

+(CCScene *) sceneForLevel:(Level *)level
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	//Level *layer = [Level node];
	
	// add layer as a child to scene
	[scene addChild: level];
	
    Hud* _hud = [Hud node];
    level.hud=_hud;
    if(level.isNetwork) level.hud.visible = NO;
    [level.hud setBonusLabelPower:level.player.bombpower life:level.player.lifes numbomb:level.player.bombnumber speed:level.player.speed];
    [scene addChild:_hud z:5];
	// return the scene
	return scene;
}

+(CCLayer*) createLevel:(NSString*) tilemapFilename
{
    Level* newLevel = [Level node];
    [newLevel initLevelWithFilename:tilemapFilename];
    return newLevel;
}

-(void) initLevelWithFilename:(NSString*) tilemapFilename
{
    self.bonuses = [NSMutableArray arrayWithCapacity:numBonuses];
    
    if (currentLevel>0 && !isNetwork) {
        numBonuses = 2;
        numEnemy = 7;
    }
    
    if(isRandom||isNetwork||isPuzzle||currentLevel>0){
        self.map = [Map mapFromFile:@"blank.tmx"];
        [self.map generateMap:numBonuses numEnemy:numEnemy isSingleLevel:(!isPuzzle && !isNetwork)];
    }
    else{
        self.map = [Map mapFromFile:tilemapFilename];
    }
    
    [self initLevel];
} 

-(void) initLevel{
    self.hud.visible = YES;
    [self removeAllChildrenWithCleanup:YES];
    
    self.characters = [NSMutableArray arrayWithCapacity:2];
    self.bombs = [NSMutableArray arrayWithCapacity:2];
    self.bonuses = [NSMutableArray arrayWithCapacity:2];
    
    [self addChild:map z:-1];
    [self.map loadMapObjects];
    [self setAllBonuses];
    [self setAllCharacter];
    
    self.player = [Player playerOfType:@"player1.png" ];
    self.player.position = [map playerSpawnPoint];
    self.player.isPlayer = YES;
    [self addChild:player z:1 tag:1];
    [self.player correctBonus:currentLevel];
    
    self.player.speed=20;
    if(self.isPuzzle) {
        self.player.speed=30;
        self.player.lifes++;
    }

    
    
    //enemy = [Player playerOfType:@"player2"];
    //enemy.position = [map enemySpawnPoint];
    //[self addChild:enemy z:1 tag:1];
    
   [self.characters addObject:self.player];
    
    SneakyJoystickSkinnedBase *leftJoy = [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
    leftJoy.position = ccp(75,75);
    leftJoy.backgroundSprite = [CCSprite spriteWithFile:@"DPad_BG.png"];
    leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,150,150)];
    leftJoystick = [leftJoy.joystick retain];
    leftJoystick.isDPad = YES;
    [self addChild:leftJoy];
    
    SneakyButtonSkinnedBase *rightBut = [[[SneakyButtonSkinnedBase alloc] init] autorelease];
    rightBut.position = ccp(980,42);
    rightBut.defaultSprite = [CCSprite spriteWithFile:@"bomb_button.png"];//[ColoredCircleSprite circleWithColor:ccc4(255, 255, 255, 128) radius:32];
    rightBut.activatedSprite = [CCSprite spriteWithFile:@"bomb_button.png"];//[ColoredCircleSprite circleWithColor:ccc4(255, 255, 255, 255) radius:32];
    rightBut.pressSprite = [CCSprite spriteWithFile:@"bomb_button.png"];//[ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 255) radius:32];
    rightBut.button = [[SneakyButton alloc] initWithRect:CGRectMake(0, 0, 80, 80)];
    rightButton = [rightBut.button retain];
    rightButton.isToggleable = NO;
    rightButton.rateLimit = 0;
    [self addChild:rightBut];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    self.pauseButton = [CCMenuItemImage itemFromNormalImage:@"button_pause2.png" selectedImage:@"button_pause2.png" target:self selector:@selector(pauseClick:)];
    self.pauseButton.position = ccp(winSize.width - 65, winSize.height - 43);
    CCMenu* pMenu = [CCMenu menuWithItems:pauseButton, nil];
    //CCMenu* pMenu = CCMenu::menuWithItems(pauseButton, NULL);
    pMenu.position= CGPointZero;
    [self addChild:pMenu z:10];
    //[self setViewpointCenter:player.position];
    
    self.numLevelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"level %i",currentLevel] fontName:@"Marker Felt" fontSize:18];
    self.numLevelLabel.position=ccp(225,winSize.height-18);
    [self addChild:self.numLevelLabel z:1];
    
    if (isPuzzle) {
        minutes = 25;
    }
    else if(currentLevel>17){
        minutes = 10;
    }
    else{
        minutes = 6;
    }
    seconds = 0;
    self.timerLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i:%i",minutes,seconds] fontName:@"Marker Felt" fontSize:18];
    self.timerLabel.position=ccp(85,winSize.height-18);
    [self addChild:self.timerLabel z:1];
    [self timer:0];
    
    //[self openExit];
    [self unscheduleAllSelectors];
    [self schedule: @selector(tick:)];
    [self schedule: @selector(ai:)interval:0.5f];
    [self schedule: @selector(timer:)interval:1.0f];
    [self schedule: @selector(control:)];
    
    //MUSIC
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Music"]==1){
        music = NO;
    }
    else{
        music = YES;
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Sound"]==1){
        sound = NO;
    }
    else{
        sound = YES;
    } 
    
    if(music){
        [self setBackgroundMusic];
        [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)];
    }
    
    if (isPuzzle) {
        [self showText:@"Destroy all wall !!!"];
    }
    //[map openExit];
    
}

-(void) deleteSender:(id)sender{
    //[(CCNode*) sender stopAllActions];
    [self removeChild:sender cleanup:YES];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = NO;
       
        isPause = NO;
        ZoomFactor = 0.01f;
        ZoomStartDistance = 0;
        minScale = 0.5f;
        self.characters = [NSMutableArray arrayWithCapacity:2];
        self.bombs = [NSMutableArray arrayWithCapacity:2];
        
        		
	}
	return self;
}

-(void) draw
{
    glTranslatef(0.5f,0.5f,0);
    [super draw];
    glTranslatef(-0.5f,-0.5f,0);
}

-(void) setViewpointCenter:(CGPoint)position
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (map.mapSize.width * map.tileSize.width) 
            - winSize.width / 2);
    y = MIN(y, (map.mapSize.height * map.tileSize.height) 
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

-(void) control: (ccTime) dt
{
    if(isPause) return;
    
    if (abs(leftJoystick.stickPosition.x)>0 || abs(leftJoystick.stickPosition.y)>0){
        if (abs(leftJoystick.stickPosition.x) > abs(leftJoystick.stickPosition.y)) {
            if (leftJoystick.stickPosition.x > 0) {
                player.direction =  PLAYER_RIGHT;
                [player Move];
            } else {
                player.direction = PLAYER_LEFT;
                [player Move];
            }    
        } else {
            if (leftJoystick.stickPosition.y > 0) {
                player.direction = PLAYER_UP;
                [player Move];
            } else {
                player.direction = PLAYER_DOWN;
                [player Move];
            }
        }
        //[self movePlayer:player];
    }
    
    if(rightButton.value)
    {
        //[self setBomb:player];
        [player setBomb];
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(isPause) return;
    for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        
        CGPoint touchTileLocation = [map tileCoordForPosition:location];
        if(!([map tileArrayAtRow:touchTileLocation.x col:touchTileLocation.y]&TILE_OPEN)) return;
        
        CGPoint playerTilePosition = [map tileCoordForPosition:player.position];
        if(CGPointEqualToPoint(touchTileLocation, playerTilePosition)){
            //[self setBomb:player];
            [player setBomb];
        }
        else{
            [player walkTo:location isTileCoord:false];
            //CGPoint playerPos = player.position;
            //[map goFormX:playerPos.x fromY:playerPos.y toX:location.x toY:location.y];
        }
        return;
	}
    
   
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    return;
    
    if(isPause) return;
    
	if ([touches count] == 2) {
		NSArray *twoTouch = [touches allObjects];
        
		UITouch *tOne = [twoTouch objectAtIndex:0];
		UITouch *tTwo = [twoTouch objectAtIndex:1];
		CGPoint firstTouch = [tOne locationInView:[tOne view]];
		CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
		CGFloat currentDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
        NSLog(@"curDist: %f  startdist: %f",currentDistance, ZoomStartDistance);
		if (ZoomStartDistance == 0) {
			ZoomStartDistance = currentDistance;
			// set to 0 in case the two touches weren't at the same time
		} else if (currentDistance - ZoomStartDistance > 0) {
			// zoom in
            NSLog(@"zoom in: %f < 1.0f",self.scale);
			if (self.scale < 1.0f) {
				//ZoomFactor += ZoomFactor *0.05f;
				self.scale += ZoomFactor;
			}
            
			// Still To Do - make view centered on pinch
            
			ZoomStartDistance = currentDistance;
		} else if (currentDistance - ZoomStartDistance < 0) {
			// zoom out
            NSLog(@"zoom out: %f > %f",self.scale,minScale);
			if (self.scale > minScale) {
				//ZoomFactor -= ZoomFactor *0.05f;
				self.scale -= ZoomFactor;
			}
            
			ZoomStartDistance = currentDistance;
		}
		//set the new position based on the new scale:
		NSLog(@"Touch Moved, Count 2, ZoomFactor %f, Self.position.x %f y %f", ZoomFactor, self.position.x, self.position.y);
		//[self setPosition:ccp(self.position.x*ZoomFactor,self.position.y*ZoomFactor)];
	}	  
    
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}

-(void) timer:(ccTime)dt
{
    
    if (isPuzzle) {
        if([map numWall]==0) [self levelComplite];
    }
    seconds--;
    if (seconds<0) {
        minutes--;
        seconds = 60;
    }
    
    NSString* minutesString;
    NSString* secondsString;
    if (seconds>9) {
        secondsString = [NSString stringWithFormat:@"%i",seconds];
    }
    else{
        secondsString = [NSString stringWithFormat:@"0%i",seconds];
    }
    if (minutes>9) {
        minutesString = [NSString stringWithFormat:@"%i",minutes];
    }
    else{
        minutesString = [NSString stringWithFormat:@"0%i",minutes];
    }
    
    timerLabel.string = [NSString stringWithFormat:@"%@:%@",minutesString,secondsString];
    
    if (minutes<0) {
        [self levelLost];
    }
}

-(void) ai: (ccTime) dt;
{
    if(self.isPause) return;
    for(Character* node in self.characters){
        if(!node.isPlayer && node.lifes>0){
            if(node!=nil){
                [node stepAI];
            }
        }
    }
}

-(void) tick: (ccTime) dt
{
    if(self.isPause) return;
    
    for(Character* node in self.characters){
        if(node!=nil){
            if(node.lifes>0){
                CGPoint characterPos = [map tileCoordForPosition:node.position];
                if([map tileArrayAtRow:characterPos.x col:characterPos.y]&TILE_KILL){
                    [node removeLife];
                }
                
                if (!node.isPlayer) {
                    
                    CGPoint playerTilePos = [map tileCoordForPosition:player.position];                                                                                                                                                                                                                                                                                                                                                                                                                                    
                    if (CGPointEqualToPoint(characterPos, playerTilePos)) {
                        [player removeLife];
                        if (player.lifes<1) {
                            isPause = YES;
                        }
                        
                        return;
                    }
                }
            }
        }
    }

    
}

-(void) checkScore
{
    //check score
    int num = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastAddLifeScore"];
    if(hud.score>num+3000)
    {
        //player.lifes++; 
        //[hud addLife];
        
    }
}

-(bool) isBonus:(CGPoint) coord isTileCoord:(bool) isTileCoord
{
	CGPoint tileCoord = coord;
    if(!isTileCoord){
        tileCoord = [map tileCoordForPosition:coord];
    }
    
    //NSLog(@"tileArray %f:%f is %i",tileCoord.x,tileCoord.y,[map tileArrayAtRow:tileCoord.x col:tileCoord.y]);
    if([map tileArrayAtRow:tileCoord.x col:tileCoord.y] & TILE_BONUS){
        return YES;
    }
    
//    for(CCNode* node in bonuses){
//        
//		if(node!=NULL){
//			CGPoint bonusPos = [map tileCoordForPosition:node.position];
//			if(CGPointEqualToPoint(bonusPos,tileCoord)){
//				return YES;
//			}
//		}
//	}
    
	return NO;
}

-(Bonus*) getBonus:(CGPoint) coord isTileCoord:(bool) isTileCoord
{
    CGPoint tileCoord = coord;
    if(!isTileCoord){
        tileCoord = [map tileCoordForPosition:coord];
    }
    
	for(Bonus* node in self.bonuses){
		if(node!=NULL){
            if(!node.isCollect){
                CGPoint bonusPos = [map tileCoordForPosition:node.position];
                if(CGPointEqualToPoint(bonusPos,tileCoord)){
                    return node;
                }
            }
		}
	}
    
	return nil;
}

-(void) removeBonus:(Bonus *)bonus{
    [bonuses removeObject:bonus];
}

-(void) setBonusOfType:(int) type tileCoord:(CGPoint) tileCoord addToLayer:(bool) addToLayer
{
	Bonus* bonus = [Bonus bonusOfType:type];
	[bonuses addObject:bonus ];
    [map setTileArrayAtRow:tileCoord.x col:tileCoord.y value:TILE_BONUS];
    //NSLog(@"set bonus at %f:%f is %i",tileCoord.x,tileCoord.y,[map tileArrayAtRow:tileCoord.x col:tileCoord.y]);
    CGPoint coord = [map positionForTileCoord:tileCoord];
    bonus.position = coord;
    [bonus setActive:true];
    
    if(![map isCollectableTile:coord isTileCoord:NO]){
        [self addChild:bonus];
    }
}

-(void) setAllBonuses
{
    
	int x, y, type;
    
	for(NSMutableDictionary *dict in map.bonuses) 
	{
        
        x = [[dict valueForKey:@"x"] intValue];
        y = [[dict valueForKey:@"y"] intValue];
        
		CGPoint coord = ccp(x,y);
		CGPoint tileCoord = [map tileCoordForPosition:coord];
		tileCoord.y --;
		type = [[dict valueForKey:@"type"] intValue];
        [self setBonusOfType:type tileCoord:tileCoord addToLayer:NO];
        
	}
}

-(Bomb*) getBomb:(CGPoint) coord isTileCoord:(bool) isTileCoord
{
    CGPoint tileCoord = coord;
    if(!isTileCoord){
        tileCoord = [map tileCoordForPosition:coord];
    }
    
	for(Bomb* node in bombs){
		if(node!=NULL){
			CGPoint bonusPos = [map tileCoordForPosition:node.position];
			if(CGPointEqualToPoint(bonusPos,tileCoord)){
				return node;
			}
		}
	}
    
	return nil;
}

-(void) characterDead:(CCNode*) sender{

    //NSLog(@"delete sprite");
	[characters removeObject:sender.parent];
    //int index = [characters indexOfObject:sender.parent];
    //Character* i = [characters objectAtIndex:index];
    //bool b = i.isPlayer;
    if (!((Character*)sender.parent).isPlayer) {
        [hud addScore:100];
    }
    else{
        [self levelLost];
    }
    
    [self removeChild:sender.parent cleanup:YES];

}

-(Character*) addCharacterOfType:(NSString*)type coord:(CGPoint)coord isTileCoord:(_Bool)isTileCoord
{
    if(isTileCoord){
		coord.y++;
		coord = [map positionForTileCoord:coord];
	}
    
    Character* enemy;
    
    coord.x+=20;
    coord.y+=25;
    if ([type compare:@"ball.png"] == NSOrderedSame) {
        enemy= [[EnemyBall alloc ] init];
        enemy.position = coord;
        [self addChild:enemy z:1 tag:1];
        [characters addObject:enemy];
    }
    else if([type compare:@"snake.png"] == NSOrderedSame) {
        enemy= [[Snake alloc ] init];
        enemy.position = coord;
        [self addChild:enemy z:1 tag:1];
        [characters addObject:enemy];
    }
    else if([type compare:@"rock.png"] == NSOrderedSame) {
        enemy= [[Rock alloc ] init];
        enemy.position = coord;
        [self addChild:enemy z:1 tag:1];
        [characters addObject:enemy];
    }
    else if([type compare:@"gost.png"] == NSOrderedSame) {
        enemy= [[Gost alloc ] init];
        enemy.position = coord;
        [self addChild:enemy z:1 tag:1];
        [characters addObject:enemy];
    }
    
	return enemy;
}

-(void) setAllCharacter
{
    
	int x, y;
    NSString* type;
    NSString* characterType;
    
	for(NSMutableDictionary *dict in map.objects) 
	{
        type = [dict valueForKey:@"type"];
        if (type && [type compare:@"SpawnPoint"] == NSOrderedSame) {
            
            x = [[dict valueForKey:@"x"] intValue];
            y = [[dict valueForKey:@"y"] intValue];
            characterType = [dict valueForKey:@"character"];
            [self addCharacterOfType:characterType coord:ccp(x,y) isTileCoord:NO];
            

        }
        
	}
}

-(void)pauseClick:(id)sender
{
    isPause = YES;
    // [self schedule: @selector(timer:)interval:1.0f];
    [self unschedule:@selector(timer:)];
	pauseButton.isEnabled = NO;
	self.fog = [CCLayerColor node];
	[self.fog initWithColor:ccc4(0,0,0,140)];
    [self addChild:self.fog z:20];
    self.fog.position=CGPointZero;
    
	//[CCMenuItemFont setFontName:@"Marker Felt"];
    [CCMenuItemFont setFontSize:48];
    CCMenuItemFont *resume = [CCMenuItemFont itemFromString:@"Resume" target:self selector: @selector(resumeClick:)];
	CCMenuItemFont *mainMenu = [CCMenuItemFont itemFromString:@"Main menu" target:self selector: @selector(mainMenuClick:)];
    
	CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    self.pauseMenu = [CCMenu menuWithItems:resume,mainMenu, nil];
	self.pauseMenu.position = ccp(winSize.width/2,winSize.height/2);
	[self.pauseMenu alignItemsVerticallyWithPadding:20.0f];
	[self.pauseMenu setColor:ccc3(255,255,255)];
	
	[self.fog addChild:self.pauseMenu z:2];

}

-(void) resumeClick:(id)sender
{
    isPause = NO;
    [self schedule: @selector(timer:)interval:1.0f];
    pauseButton.isEnabled = YES;
    [self removeChild:fog cleanup:YES];
}

-(void)mainMenuClick:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:currentLevel forKey:@"numCompleteLevel"];
    [[NSUserDefaults standardUserDefaults] setInteger:hud.score forKey:@"Score"];
    [SceneManager goMenu];
}

-(void) openExit
{
    [map openExit]; 
}

-(void) levelComplite
{
    hud.visible = NO;

    [[NSUserDefaults standardUserDefaults] setInteger:currentLevel+1 forKey:@"numCompleteLevel"];
    [[NSUserDefaults standardUserDefaults] setInteger:hud.score forKey:@"Score"];
    
    int num = [[NSUserDefaults standardUserDefaults] integerForKey:@"bombNumber"];
    if(player.bombnumber>num) [[NSUserDefaults standardUserDefaults] setInteger:player.bombnumber forKey:@"bombNumber"];
    
    num = [[NSUserDefaults standardUserDefaults] integerForKey:@"bombPower"];
    if(player.bombpower>num) [[NSUserDefaults standardUserDefaults] setInteger:player.bombpower forKey:@"bombPower"];
    
    num = [[NSUserDefaults standardUserDefaults] integerForKey:@"playerLife"];
    if(player.lifes>num) [[NSUserDefaults standardUserDefaults] setInteger:player.lifes forKey:@"playerLife"];
    
    num = [[NSUserDefaults standardUserDefaults] integerForKey:@"playerSpeed"];
    if(player.speed>num) [[NSUserDefaults standardUserDefaults] setInteger:player.speed forKey:@"playerSpeed"];
    
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    isPause = true;
	self.fog = [CCLayerColor node];
	[self.fog initWithColor:ccc4(0,0,0,220)];
    [self addChild:self.fog z:20];
    self.fog.position=CGPointZero;

    CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"LEVEL COMPLETE" fontName:@"04B_09.TTF" fontSize:58];
	label1.position = ccp(winSize.width/2,winSize.height-200);
	[self.fog addChild:label1];
    
    if (currentLevel>30) {
        label1.string = @"GAME OVER";
    }

    
    
    CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"SCORE" fontName:@"04B_09.TTF" fontSize:38];
	label2.position = ccp(winSize.width/2-130,winSize.height-350);
    [fog addChild:label2];
    
	CCLabelTTF* label3 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",hud.score] fontName:@"04B_09.TTF" fontSize:38];
	label3.position = ccp(winSize.width/2+140,winSize.height-350);
	[fog addChild:label3];
    
    //[CCMenuItemFont setFontName:@"Marker Felt"];
    [CCMenuItemFont setFontSize:30];
    
    CCMenuItemFont *mainMenu = [CCMenuItemFont itemFromString:@"MAIN MENU" target:self selector: @selector(mainMenuClick:)];
    CCMenuItemFont *replay = [CCMenuItemFont itemFromString:@"REPLAY" target:self selector: @selector(replayClick:)];
    CCMenuItemFont *nextLevel = [CCMenuItemFont itemFromString:@"NEXT LEVEL" target:self selector: @selector(nextLevelClick:)];
	
	CCActionInterval* color_action = [CCTintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
	CCActionInterval* color_back = [color_action reverse];
	CCFiniteTimeAction* seq = [CCSequence actions:color_action, color_back, nil];
	[nextLevel runAction:[CCRepeatForever actionWithAction:(CCActionInterval*)seq]]; 
    
    if (currentLevel>30 || isPuzzle) {
        self.pauseMenu = [CCMenu menuWithItems:replay,mainMenu, nil];
        [self.pauseMenu alignItemsHorizontallyWithPadding:30];
    }
    else{
        self.pauseMenu = [CCMenu menuWithItems:replay,mainMenu,nextLevel, nil];
        [self.pauseMenu alignItemsInColumns:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2], nil];
    }
	self.pauseMenu.position = ccp(winSize.width/2,winSize.height/2-150);
	
    [self.pauseMenu setColor:ccc3(255, 255, 255)];
	
	[self.fog addChild:self.pauseMenu z:2];
}

-(void) levelLost
{
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"numCompleteLevel"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Score"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"bombNumber"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"bombPower"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"playerLife"];
    [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"playerSpeed"];
    currentLevel = 1;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    isPause = YES;
	self.fog = [CCLayerColor node];
	[self.fog initWithColor:ccc4(0,0,0,220)];
    [self addChild:fog z:20];
    self.fog.position=CGPointZero;
    hud.visible = NO;
    
    CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"YOU LOST" fontName:@"04B_09.TTF" fontSize:88];
	label1.position = ccp(winSize.width/2,winSize.height-300);
	[self.fog addChild:label1];
    
    
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
	
	[self.fog addChild:self.pauseMenu z:2];
}

-(void) replayClick:(id)sender
{
    hud.visible = YES;
    isPause = NO;
    [self removeAllChildrenWithCleanup:YES];
    [self initLevelWithFilename:@""];
    [hud init];
    [hud setBonusLabelPower:player.bombpower life:player.lifes numbomb:player.bombnumber speed:player.speed];
}

-(void) nextLevelClick:(id)sender
{
    hud.visible = YES;
    isPause = NO;
    [self removeAllChildrenWithCleanup:YES];
    currentLevel++;
    if (currentLevel>30) {
        [SceneManager goMenu];
        return;
    }
    
    NSString* levelName = [NSString stringWithFormat:@"Level%i.tmx",currentLevel];
    //[self init];
    
    characters = [[NSMutableArray arrayWithCapacity:2] retain];
    bombs = [[NSMutableArray arrayWithCapacity:2] retain];
    
    [self initLevelWithFilename:levelName];
    [hud init];
    [hud setBonusLabelPower:player.bombpower life:player.lifes numbomb:player.bombnumber speed:player.speed];
}

-(void) destroyWall:(id)sender{
    
}
-(void) movePlayer:(id)sender{
    
}
-(void) setBomb:(CGPoint) pos tilePos:(CGPoint)tilePos{
    
}

-(void) showText:(NSString *)text
{
    if(sound){
        //[[SimpleAudioEngine sharedEngine] playEffect:@"bonus.mp3"];
    }
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF* textLabel = [CCLabelTTF labelWithString:text fontName:@"04B_09.TTF" fontSize:60]; //Marker Felt
    textLabel.position=ccp(winSize.width/2,winSize.height/2);
    textLabel.color=ccc3(10,255,10);
    textLabel.scale = 0.3f;
    [self addChild:textLabel z:30];
    [textLabel runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5f scale:1.0f],
                          [CCFadeOut actionWithDuration:0.5f],
                          [CCCallFuncN actionWithTarget:self selector:@selector(deleteSender:)],
                          nil]];
}

@end
