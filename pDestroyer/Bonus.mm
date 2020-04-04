//
//  Bonus.m
//  pDestroyer
//
//  Created by ITmind on 07.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bonus.h"
#import "Map.h"
#import "Level.h"

@implementation Bonus
@synthesize active, type;

- (id)init
{
    self = [super init];
    if (self) {
        type = 0;
        isCollect = NO;
        active = NO;
    }
    
    return self;
}

+(Bonus*) bonusOfType:(char)bonusType{
    Bonus* bonus = [[Bonus alloc] init];
    [bonus initBonusType:bonusType];
    return bonus;
}

-(void) initBonusType:(char)bonusType{
    type = bonusType;
    
    switch(type){
        case 1:
            sprite = [CCSprite spriteWithSpriteFrameName:@"bombnumber.png"];
            break;
        case 2:
            sprite = [CCSprite spriteWithSpriteFrameName:@"bombpower.png"];
            break;
        case 3:
            sprite = [CCSprite spriteWithSpriteFrameName:@"life.png"];
            break;
        case 4:
            sprite = [CCSprite spriteWithSpriteFrameName:@"speed.png"];
            break;
        case 5:
            sprite = [CCSprite spriteWithSpriteFrameName:@"key.png"];
            break;
        default:
            break;
	}
    
    CGPoint p = sprite.position;
    p.x += 20;
    p.y -= 20;
    sprite.position = p;
	[self addChild:sprite];
}

-(int) collect{
    isCollect = YES;
    active = NO;
    Level* level = (Level*) self.parent;
    CGPoint tileCoord = [level.map tileCoordForPosition:self.position];
    [level.map removeTileArrayAtRow:tileCoord.x col:tileCoord.y value:TILE_BONUS];
    [self removeChild:sprite cleanup:YES];
    return type;
}

-(bool) isCollect{
    return isCollect;
}

@end
