//
//  MenuLayer.h
//  MenuLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Player;

@interface Hud : CCLayer {
    int score;
    CCLabelTTF* cLabel;
    
	CCLabelTTF* bombNumberLabel;
	CCLabelTTF* bombPowerLabel;
	CCLabelTTF* lifeLabel;
	CCLabelTTF* speedLabel;
}
@property int score;

-(void) addScore:(int) addscore;
-(void) setScore:(int)addscore;
-(int) score;
-(void) addPower;
-(void) addLife;
-(void) addNumBomb;
-(void) addSpeed;
-(void) clearBonus;
-(void) setBonusLabelPower:(int)power life:(int)life numbomb:(int)numbomb speed:(int)speed;
-(void) setBonusLabelForPlayer:(Player*)player;

@end
