//
//  MenuLayer.m
//  MenuLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "MenuLayer.h"
#import "Map(PathFinder).h"
#import "SceneManager.h"
#import "SlidingMenuGrid.h"
#import "Map.h"
#import "EnemyBall.h"
#import "SimpleAudioEngine.h"
#import "MultiplayerLevelGameKit.h"
#import "MultiplayerLevelBonjour.h"

//@class HelloWorldLayer;

@implementation MenuLayer

-(void) backgroundMusicFinished
{
    //NSLog(@"music stop");
    [self setBackgroundMusic];
}

-(void) setBackgroundMusic
{

    int rndMusic = arc4random() % 5+1;
        
    [[CDAudioManager sharedManager] playBackgroundMusic:[NSString stringWithFormat:@"track%i.mp3",rndMusic] loop:NO];

}

-(id) init{
    
	self = [super init];
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.7f];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0f];
    [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)]; 
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Music"]==0){
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"track1.mp3"loop:NO];
    }
    
	isPause = NO;
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"characters.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bonuses.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animtile.plist"];

    CGSize winSize = [CCDirector sharedDirector].winSize;
    int y = winSize.height/2;//(winSize.height/3)*2 + 18;
    int x = winSize.width/2;//(winSize.width/2)-30;
    
    CCSprite* background = [CCSprite spriteWithFile:@"menu.png"];
    background.position = ccp(winSize.width/2,winSize.height/2);
    //background->setPosition(ccp(x,winSize.height/2));
    [self addChild:background];

    [CCMenuItemFont setFontName:@"04B_09.TTF"];
    [CCMenuItemFont setFontSize:50];
    
    ccColor3B color = ccc3(77, 54, 31);
    
    CCMenuItemFont* single = [CCMenuItemFont itemFromString:@"New game" target:self selector: @selector(onNewGame:)];
    single.color = color;
    CCMenuItemFont* contine = [CCMenuItemFont itemFromString:@"Continue" target:self selector: @selector(launchLevel:)];
    contine.color = color;
    CCMenuItemFont* puzzle = [CCMenuItemFont itemFromString:@"Puzzle" target:self selector: @selector(launchPuzzle:)];
    puzzle.color = color;
    CCMenuItemFont* multiplayer = [CCMenuItemFont itemFromString:@"Multiplayer" target:self selector: @selector(launchMultiplayerGameKit:)];
    multiplayer.color = color;
    //CCMenuItemFont* conToMultiplayer = [CCMenuItemFont itemFromString:@"Connect" target:self selector: @selector(conectToMultiplayerGameKit:)];
    //multiplayer.color = ccc3(0, 0, 0);
    CCMenuItemFont* clear = [CCMenuItemFont itemFromString:@"Options" target:self selector: @selector(onOptions:)];
    clear.color = color;
    
    NSInteger numCompleteLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"numCompleteLevel"];
    if(numCompleteLevel>1){
        pMenu = [CCMenu menuWithItems:single, contine, puzzle, multiplayer, clear, nil];
    }
    else{
        pMenu = [CCMenu menuWithItems:single, puzzle, multiplayer, clear, nil];
    }
    //pMenu = [CCMenu menuWithItems:single, puzzle, clear, nil];
	
  	pMenu.position = ccp(x, y);
	[pMenu alignItemsVerticallyWithPadding: 20.0f];
	[self addChild:pMenu z: 2];
  
	return self;
}

- (void)onOptions:(id)sender{
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int y = (winSize.height/3)*2 + 18;
    int x = (winSize.width/2)-30;
    
    fog = [CCLayerColor node];
	[fog initWithColor:ccc4(0,0,0,200)];
    [self addChild:fog z:20];
    fog.position=CGPointZero;
      
	CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"OPTIONS"fontName:@"04B_19.TTF" fontSize:48];
	label1.position=ccp(winSize.width/2-30,winSize.height-70);
    [fog addChild:label1 z:1];
    
    [CCMenuItemFont setFontName: @"04B_19.TTF"];
    [CCMenuItemFont setFontSize:60];
    CCMenuItemFont* titleSound = [CCMenuItemFont itemFromString:@"Sound"];
    [titleSound setIsEnabled:NO];
    
    CCMenuItemToggle *item1 = [CCMenuItemToggle itemWithTarget:self selector:@selector(onOptionsSound:) items:
                               [CCMenuItemFont itemFromString: @"On"],
                               [CCMenuItemFont itemFromString: @"Off"],
                               nil];
    

    CCMenuItemFont* titleMusic = [CCMenuItemFont itemFromString:@"Music"];
    [titleMusic setIsEnabled:NO];
    //[CCMenuItemFont setFontName: @"Marker Felt"];
    //[CCMenuItemFont setFontSize:34];
    CCMenuItemToggle *item2 = [CCMenuItemToggle itemWithTarget:self selector:@selector(onOptionsMusic:) items:
                               [CCMenuItemFont itemFromString: @"On"],
                               [CCMenuItemFont itemFromString: @"Off"],
                               nil];
    
    int soundIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"Sound"];
    int musicIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"Music"];
    item1.selectedIndex = soundIndex;
    item2.selectedIndex = musicIndex;
    
	CCMenuItemFont* back = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(onBack:)];
	//back.position = ccp(0,0);
    //[self removeChild:pMenu cleanup:YES];
    
    pMenu = [CCMenu menuWithItems:
                    titleSound, titleMusic,
                    item1, item2,
                    back, nil]; // 9 items.
    [pMenu alignItemsInColumns:
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:1],
     nil];
    
    //pMenu = [CCMenu menuWithItems:back, nil];
    pMenu.position = ccp(x, y-100);
	[fog addChild:pMenu z:30];
    
}

-(void) onOptionsCallback:(id)sender{
    NSLog(@"selected item: %@ index:%u", [sender selectedItem], (unsigned int) [sender selectedIndex] );
}

-(void) onOptionsSound:(id)sender{
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    [[NSUserDefaults standardUserDefaults] setInteger:(unsigned int)[sender selectedIndex] forKey:@"Sound"];
}
-(void) onOptionsMusic:(id)sender{
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    [[NSUserDefaults standardUserDefaults] setInteger:(unsigned int)[sender selectedIndex] forKey:@"Music"];
    if (((unsigned int)[sender selectedIndex])==0) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"track1.mp3"loop:NO];
    }
    else{
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
    
    //[[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)];
}

- (void)onNewGame:(id)sender{
    //[[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    [self onClear:nil];
    [self launchLevel:nil];
    
    return;
//	int iMaxLevels = 30;
//
//    NSMutableArray* allItems = [NSMutableArray arrayWithCapacity:iMaxLevels];
//
//	for (int i = 1; i <= iMaxLevels; ++i)
//	{
//        //NSString* imageName = [NSString stringWithFormat:@"Level%i.png",i];
//        NSString* mapFileName = [[NSString stringWithFormat:@"Level%i.tmx",i] retain];
//        //NSString* imageLock = [NSString stringWithFormat:@"Level%i_Lock.png",i];
//        
//		CCSprite* normalSprite = [CCSprite spriteWithFile:@"select_level_normal.png"];
//		CCSprite* selectedSprite = [CCSprite spriteWithFile:@"select_level_normal.png"];
//		CCSprite* disabledSprite = [CCSprite spriteWithFile:@"select_level_disable.png"];
//		CCMenuItemSprite* item = [CCMenuItemSprite itemFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:self selector:@selector(launchLevel:)];
//        CCLabelTTF* numLevelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",i] fontName:@"Marker Felt" fontSize:48];
//        numLevelLabel.position=ccp(87,187);
//        [item addChild:numLevelLabel z:1];
//		item.tag=i;
//        item.userData = mapFileName;
//        
//        NSInteger numCompleteLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"numCompleteLevel"];
//        if(numCompleteLevel==0) numCompleteLevel = 1;
//        if(i>numCompleteLevel){
//            item.isEnabled = NO;
//            numLevelLabel.color = ccc3(66, 66, 66);
//        }
//
//		[allItems addObject:item];
//	}
//    
//    fog = [CCLayerColor node];
//	[fog initWithColor:ccc4(0,0,0,200)];
//    [self addChild:fog z:20];
//    fog.position=CGPointZero;
//    
////    for(Character* node in characters){
////        
////        if(node!=nil){
////            if(!node.isPlayer && node.lifes>0){
////                node.visible = YES;
////            }
////        }
////    }
//    
//	SlidingMenuGrid* layer = [SlidingMenuGrid menuWithArray:allItems cols:3 rows:2 position:ccp(0,0) padding:ccp(350,300) verticalPaging:NO];
//    [fog addChild:layer z:5];
//    
//    CGSize winSize = [CCDirector sharedDirector].winSize;
//	CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"SELECT   LEVEL"fontName:@"04B_19.TTF" fontSize:48];
//	label1.position=ccp(winSize.width/2,winSize.height-70);
//    [fog addChild:label1 z:1];
//    
//	CCMenuItemFont* back = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(onBack:)];
//	back.position = ccp(0,0);
//    [self removeChild:pMenu cleanup:YES];
//    pMenu = [CCMenu menuWithItems:back, nil];
//    pMenu.position = ccp(510,30);
//	[fog addChild:pMenu z:10];
    
    
}

- (void)onBack:(id)sender{
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
	[SceneManager goMenu];
}

-(void)onExit:(id)sender{
    //[[CCDirector sharedDirector] end];
}

-(void)onClear:(id)sender{
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"numCompleteLevel"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"bombNumber"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"bombPower"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"playerLife"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"playerSpeed"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Score"];
}

-(void) launchLevel:(id)sender
{    
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    NSInteger numCompleteLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"numCompleteLevel"];
    
    //int tag = ((CCNode*)sender).tag;
    //NSString* mapFileName = ((CCNode*)sender).userData;
    Level* level = [Level node];
    level.isPuzzle = NO;
    level.isRandom = NO;
    level.isNetwork = NO;
    level.numEnemy = 2;
    level.numBonuses = 2;
    level.currentLevel = numCompleteLevel;
    [level initLevelWithFilename:@""];

    [SceneManager go: [Level sceneForLevel:level] i:0];
}

-(void) launchSurvival:(id)sender
{    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    //Level* level = (Level*)[Level createLevel:@""];
    Level* level = [Level node];
    level.isPuzzle = NO;
    level.isRandom = NO;
    level.isNetwork = YES;
    level.numEnemy = 5;
    level.numBonuses = 10;
    level.currentLevel = 1;
    [level initLevelWithFilename:@""];
    
    [SceneManager go: [Level sceneForLevel:level] i:0];
}

-(void) launchPuzzle:(id)sender
{    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    Level* level = [Level node];
    level.isPuzzle = YES;
    level.isRandom = NO;
    level.isNetwork = NO;
    level.numEnemy = 0;
    level.numBonuses = 10;
    level.currentLevel = 1;
    [level initLevelWithFilename:@""];
    
    [SceneManager go: [Level sceneForLevel:level] i:0];
}

-(void) launchMultiplayerGameKit:(id)sender
{    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
    MultiplayerLevelBonjour* level = [MultiplayerLevelBonjour node];
    level.isPuzzle = NO;
    level.isRandom = NO;
    level.isNetwork = YES;
    level.numEnemy = 0;
    level.numBonuses = 10;
    level.currentLevel = 1;
    //[level startPicker];
    //[level initLevelWithFilename:@""];
    
    [SceneManager go: [MultiplayerLevelBonjour sceneForLevel:level] i:0];
}

-(void) conectToMultiplayerGameKit:(id)sender
{    
}

@end
