//
//  HelloWorldLayer.h
//  pDestroyer
//
//  Created by ITmind on 29.07.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer

@class SneakyJoystick;
@class SneakyButton;

@class Player;
@class Map;
@class Bomb;
@class Bonus;
@class Hud;
@class Character;

@interface Level : CCLayer
{
    Map* map;
    Player* player;
    //Player* enemy;
	//Bomb* bomb;
    
    SneakyJoystick *leftJoystick;
	SneakyButton *rightButton;
    
    NSMutableArray* bonuses;
    NSMutableArray* bombs;
	NSMutableArray* characters;
    int numBonuses;
    int numEnemy;
    
    float ZoomStartDistance;
    float ZoomFactor;
    float minScale;
    bool isPause;
    
    CCLayerColor* fog;
    CCMenu* pauseMenu;
    CCMenuItemImage* pauseButton;
    Hud* hud;
    
    bool isPuzzle;
    bool isRandom;
    bool isNetwork;
    int currentLevel;
    
    CCLabelTTF* timerLabel;
    int minutes;
    int seconds;
    
    bool music;
    bool sound;
    
    CCLabelTTF* numLevelLabel;
    
    NSMutableArray* networkQueue;
    //CCLabelTTF* startlabel;
}
@property (retain) Map* map;
@property (retain) Player* player;
@property (retain) NSMutableArray* characters;
@property (retain) NSMutableArray* bombs;
@property (retain) NSMutableArray* bonuses;
@property (retain) NSMutableArray* networkQueue;
@property (retain) CCLabelTTF* numLevelLabel;
@property (retain) CCLabelTTF* timerLabel;
@property (retain) CCMenu* pauseMenu;
@property (retain) CCMenuItemImage* pauseButton;
@property (retain) CCLayerColor* fog;

@property (retain) Hud* hud;
@property bool isPause;
@property bool isPuzzle;
@property bool isRandom;
@property bool isNetwork;
@property int numBonuses;
@property int numEnemy;
@property int currentLevel;
@property bool sound;

+(CCScene *) sceneForLevel:(Level*) level;
+(CCLayer*) createLevel:(NSString*) tilemapFilename;

-(void) backgroundMusicFinished;
-(void) setBackgroundMusic;

-(void) initLevelWithFilename:(NSString*) tilemapFilename;
-(void) initLevel;

-(void) setViewpointCenter:(CGPoint) position;
-(void) ai: (ccTime) dt;
-(void) control: (ccTime) dt;
-(void) tick: (ccTime) dt;
-(void) timer: (ccTime) dt;

//MAP
-(bool) isBonus:(CGPoint) coord isTileCoord:(bool) isTileCoord;
-(void) setBonusOfType:(int) type tileCoord:(CGPoint) tileCoord addToLayer:(bool) addToLayer;
-(Bonus*) getBonus:(CGPoint) tileCoord isTileCoord:(bool) isTileCoord;
-(Bomb*) getBomb:(CGPoint) tileCoord isTileCoord:(bool) isTileCoord;
-(void) removeBonus:(Bonus*)bonus;
-(void) setAllBonuses;
-(void) openExit;
-(void) setAllCharacter;
-(Character*) addCharacterOfType:(NSString*) type coord:(CGPoint)coord isTileCoord:(bool)isTileCoord;

//EVENTS
-(void) characterDead:(CCNode*) sender;


//MENU
-(void) pauseClick:(id)sender;
-(void) resumeClick:(id)sender;
-(void) mainMenuClick:(id)sender;
-(void) replayClick:(id)sender;
-(void) nextLevelClick:(id)sender;
-(void) levelComplite;
-(void) levelLost;

-(void) deleteSender:(id)sender;

//EVENTS
-(void) destroyWall:(id)sender;
-(void) movePlayer:(id)sender;
-(void) setBomb:(CGPoint) pos tilePos:(CGPoint)tilePos;

-(void) showText:(NSString *)text;

@end
