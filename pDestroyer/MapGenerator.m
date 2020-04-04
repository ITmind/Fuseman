#import "MapGenerator.h"

@implementation MapGenerator
@synthesize currentCell;
@synthesize totalCell;
@synthesize fullfill;
@synthesize wallshort;
@synthesize h;

//MapGenerator(void): Map("blank.tmx")
-(id) init
{
    self = [super init];
    if (self) {
        [self initFromFile:@"blank.tmx"];
        
        fullfill = 100;
        wallshort = 40;
        for(int y=0;y<TILE_ROWS;y++){
            for(int x=0;x<TILE_COLS;x++){
                tileArray[x][y]=TILE_OPEN;
            }
        }
        //return;
        [self initrandom];
        int startx, starty;
        while ([self getrandomX:&startx Y:&starty]!=0)
        {
            
            if ((tileArray[startx][starty]&TILE_WALL)==1) continue;
            srand(time(NULL)|clock());
            if (rand()%100 > fullfill) continue;
            int sx=0,sy=0;
            do
            {
                sx=(rand()%3)-1;
                sy=(rand()%3)-1;
            } while ((sx==0 && sy==0) || (sx!=0 && sy!=0)); //sx==0 and sy==0
            
            while ((tileArray[startx][starty]&TILE_WALL)==0)
            {
                if (rand()%100 > wallshort)
                {
                    tileArray[startx][starty]=tileArray[startx][starty]|TILE_WALL;
                    break;
                }
                
                tileArray[startx][starty]=tileArray[startx][starty]|TILE_WALL;
                if(startx+sx<TILE_COLS && starty+sy<TILE_ROWS){
                    startx +=sx; starty+=sy;
                }
                
                tileArray[startx][starty]=tileArray[startx][starty]|TILE_WALL;
                if(startx+sx<TILE_COLS && starty+sy<TILE_ROWS){
                    startx +=sx; starty+=sy;
                }
            }
        }
    }
    return self;
}


-(void) initrandom
{
	int j=0;
	for (int y=2; y<TILE_ROWS-3; y+=2)
		for (int x=2; x<TILE_COLS-3; x+=2)
     {
		r[0][j] = x; r[1][j] = y; j++;
     }
	h=j-1;
}

-(int) getrandomX:(int*)x Y:(int*)y
{
	srand(time(NULL)|clock());
	int i = rand() % h;
	*x = r[0][i]; *y = r[1][i];
	r[0][i] = r[0][h]; r[1][i] = r[1][h];

	return --h;
}

@end
