//
//  tileset.h
//  fuseman
//
//  Created by ITmind on 16.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

struct _TileSet {
    int floor;
    int destroyWall;
    int wall;
};
typedef struct _TileSet _TileSet;

@interface TileSet: NSObject{
@public
    _TileSet tilesetArray[3];
}

@end
