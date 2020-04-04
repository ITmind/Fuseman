//
//  Rock.m
//  pDestroyer
//
//  Created by ITmind on 13.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Rock.h"
#import "Level.h"
#import "Map.h"

@implementation Rock 

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        mirrored = YES;
        [super initOfType:@"rock.png"];
        isPlayer = NO;
        collectBonus = NO;
        lifes=2;
        speed=10;
        numDeathFrame=1;
        
    }
    
    return self;
}

@end
