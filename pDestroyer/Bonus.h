//
//  Bonus.h
//  pDestroyer
//
//  Created by ITmind on 07.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Global.h"

@class Map;

@interface Bonus : CCNode {
    CCSprite* sprite;
    
    char type;
    bool isCollect;
    bool active;
}
@property char type;
@property bool active;

+(Bonus*) bonusOfType:(char)bonusType;
-(void) initBonusType:(char)bonusType;

-(int) collect;
-(bool) isCollect;

@end
