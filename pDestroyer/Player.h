
#import "cocos2d.h"
#import "Character.h"

#define STATE_WALK 0 
#define STATE_BOMB 1
#define STATE_DESTROY 2 
#define STATE_WAIT 3 

@interface Player : Character {
	int currentState;
	CGPoint walkDestCoord; 
    NSMutableArray* points;
}
+(Player*) playerOfType:(NSString*)type;
-(void) setBomb;
-(void) bombBlowUpFinish:(id)sender;
-(void) stepAI;

-(void) analyze;
-(void) findHoleForCoord:(CGPoint)tileCoord reverse:(bool)reverse;
-(void) correctBonus:(int)numlevel;

@end


