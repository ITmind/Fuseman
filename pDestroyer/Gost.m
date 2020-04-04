//
//  Rock.m
//  pDestroyer
//
//  Created by ITmind on 13.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Gost.h"

@implementation Gost 

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        mirrored = YES;
        [super initOfType:@"gost.png"];
        isPlayer = NO;
        collectBonus = NO;
        lifes=5;
        speed=10;
        numDeathFrame=3;
        
    }
    
    return self;
}

@end
