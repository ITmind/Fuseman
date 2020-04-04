
#import "Map.h"

@interface MapGenerator : Map {
    int currentCell;
	int totalCell;
	int fullfill;
	int wallshort;
	int h;
    
@public
	int r[2][((TILE_ROWS-4)/2)*((TILE_COLS-4)/2)];
}
@property int currentCell;
@property int totalCell;
@property int fullfill;
@property int wallshort;
@property int h;


-(void) initrandom;
-(int) getrandomX:(int*)x Y:(int*)y;

@end


