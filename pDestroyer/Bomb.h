
#import "cocos2d.h"
#import "Global.h"


#define NUM_FRAME 3

#define RAY_UP 0
#define RAY_DOWN 1
#define RAY_LEFT 2
#define RAY_RIGHT 3

@class Map;
@class Player;

@interface Bomb : CCNode
{
    
@private
	CCNode *spriteSheet;
	CCSpriteFrameCache *cache;
	CCSprite* sprite;
    
	NSString* typeBomb;
	
	CCAnimation* blowAnimation;
	CCAnimation* blowAnimation2;
    
	int state;
	int power;	
    int numDestroyWall;
}
@property int power;
@property int numDestroyWall;
@property int state;

+(Bomb*) bombOfType:(NSString*)bombType power:(int)_power;
-(void) initBombOfType:(NSString*)type;

-(void) setPosition:(CGPoint) pos;
-(CGPoint) position;

-(void) actionFinish:(id)sender;
-(void) beforeExplosion:(id)sender;

//BOMB metods
-(void) blowUp:(bool)immediate;
-(void) animateBlowUp;
-(void) animateBlowRays;
-(void) addBlowRay:(int) directionRay;
-(bool) addPowerRay:(int) diretionRay index:(int) i;
-(void) markMapTile:(unsigned char) typeTile;

@end

