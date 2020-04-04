//
//  MultiplayerLevelBonjour.h
//  fuseman
//
//  Created by ITmind on 02.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiplayerBonjour.h"

#define NUM_RAUNDS 3

@interface MultiplayerLevelBonjour : MultiplayerBonjour
{
    Player* player2;
    int currentRaund;
    char networkScore;
    bool characterDead;
    CCLabelTTF* info;
}
@property (retain) Player* player2;
-(void) sendCurrentGameStatus:(ccTime) dt;
@end
