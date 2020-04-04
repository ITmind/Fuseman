//
//  EnemyBall.m
//  pDestroyer
//
//  Created by ITmind on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnemyBall.h"
#import "Level.h"
#import "Map.h"

@implementation EnemyBall 

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        mirrored = YES;
        [super initOfType:@"ball.png"];
        isPlayer = NO;
        collectBonus = NO;
        numDeathFrame = 4;
        speed=10;
    }
    
    return self;
}

@end
