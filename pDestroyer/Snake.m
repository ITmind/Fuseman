//
//  Sneak.m
//  pDestroyer
//
//  Created by ITmind on 13.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Snake.h"
#import "Level.h"
#import "Map.h"

@implementation Snake 

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        mirrored = YES;
        [super initOfType:@"snake.png"];
        isPlayer = NO;
        collectBonus = NO;
        speed=30;
        numDeathFrame=1;
    }
    
    return self;
}

@end
