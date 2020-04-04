//
//  tileset.m
//  fuseman
//
//  Created by ITmind on 16.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "tileset.h"

@implementation TileSet


-(id) init
{
    if( (self=[super init])) {
        _TileSet tileset1;
        tileset1.destroyWall = 18;
        tileset1.floor = 4;
        tileset1.wall = 13;
        _TileSet tileset2;
        
        tileset2.destroyWall = 17;
        tileset2.floor = 3;
        tileset2.wall = 12;
        
        _TileSet tileset3;
        tileset3.destroyWall = 15;
        tileset3.floor = 6;
        tileset3.wall = 8;
        
        tilesetArray[0] = tileset1;
        tilesetArray[1] = tileset2;
        tilesetArray[2] = tileset3;
        
    }
    
    return self;

}

@end
