
#import "Player.h"
#import "Bomb.h"
#import "Map(PathFinder).h"
#import "Map.h"
#import "Level.h"
#import "PathFindNode.h"
#import "NSMutableArray(PathFinder).h"
#import "SimpleAudioEngine.h"
#import "Hud.h"


@implementation Player

+(Player*) playerOfType:(NSString*)type
{
    Player* tempPlayer = [[Player alloc] init];
    [tempPlayer initOfType:type];
    return tempPlayer;
}

- (void) initOfType:(NSString*) type
{
    mirrored = YES;
    numDeathFrame = 5;
    [super initOfType:type];
    collectBonus = YES;
    
    bombnumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"bombNumber"];
    if(bombnumber==0) bombnumber = 1;
    
    bombpower = [[NSUserDefaults standardUserDefaults] integerForKey:@"bombPower"];
    if(bombpower==0) bombpower = 1;
    
    lifes = [[NSUserDefaults standardUserDefaults] integerForKey:@"playerLife"];
    if(lifes==0) lifes = 1;
    
    speed = [[NSUserDefaults standardUserDefaults] integerForKey:@"playerSpeed"];
    if(speed==0) speed = 10;
    
    //speed = 40;
    //bombpower = 7;
    //bombnumber = 3;
}

-(void) setBomb{
    Level* level = (Level*) self.parent;
    Map* map = level.map;
    
    if(bombnumber>0){
		CGPoint tileCoordForBomb = [map tileCoordForPosition:self.position];
		CGPoint posForBomb = [map positionForTileCoord:tileCoordForBomb];
		posForBomb.x +=map.tileSize.width/2;
		posForBomb.y -=map.tileSize.height/2;
        
        if (!isNetwork) {
            [level setBomb:posForBomb tilePos:tileCoordForBomb];
        }
        
		Bomb* bomb = [Bomb bombOfType:@"bomb1" power:bombpower];
		bomb.position = posForBomb;
        bomb.userData = self;
		[self.parent addChild:bomb z:-1 tag:2];
        [map setTileArrayAtRow:tileCoordForBomb.x col:tileCoordForBomb.y value:TILE_BOMB];
		bombnumber--;
        numSetBomb++;
        [level.bombs addObject:bomb];
		[bomb blowUp:NO];
        if(level.sound){
            [[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
        }
	}
}

-(void) bombBlowUpFinish:(id)sender
{
    bombnumber++;
    numSetBomb--;
}

-(void) stepAI
{
    Level* level = (Level*) self.parent;
    Map* map = level.map;
    
    if(!move){
		//CGPoint playerPos = level.player.position;
		//CGPoint playerTileCoord = [map tileCoordForPosition:playerPos];
		CGPoint enemyTileCoord = [map tileCoordForPosition:self.position];
        
		points = [NSMutableArray arrayWithCapacity:0];
        [self analyze];
        
        switch(currentState){
            case STATE_WALK:
                if (points.count!=0) {
                    PathFindNode* lowesNode = [points lowestCostNode];
                    if(CGPointEqualToPoint(ccp(lowesNode.nodeX,lowesNode.nodeY), enemyTileCoord)){
                        [self setBomb];
                    }
                    else{
                        [self walkTo:ccp(lowesNode.nodeX,lowesNode.nodeY) isTileCoord:true];
                    }
                }
                break;
            case STATE_BOMB:
                //uyti s linii
                [self determineDirection:walkDestCoord];
                [self findHoleForCoord:enemyTileCoord reverse:NO];
                break;
            case STATE_DESTROY:
                if(CGPointEqualToPoint(walkDestCoord,enemyTileCoord)){
					[self setBomb];
                    [self reverseDirection]; 
					[self Move];
				}
                else{
                    [self walkTo:walkDestCoord isTileCoord:true];
                }
                break;
            case STATE_WAIT:
                break;
		}
        
		
		
	}

}

-(void) analyze
{
    Level* level = (Level*) self.parent;
    Map* map = level.map;
    
    CGPoint playerPos = level.player.position;
    CGPoint playerTileCoord = [map tileCoordForPosition:playerPos];
    CGPoint enemyTileCoord = [map tileCoordForPosition:self.position];
    
    int row=0;
    int col=0;
    bool up= YES;
    bool down=YES;
    bool left=YES;
    bool right=YES;
    
    for(int i = 0;i<=4;i++){

		if(up){
			col = enemyTileCoord.y-i-1;
			row = enemyTileCoord.x;
			if([map tileArrayAtRow:row col:col] & TILE_OPEN){
			}
			else if([map tileArrayAtRow:row col:col] & TILE_BOMB)
			{
				walkDestCoord = ccp(row,col);
				currentState = STATE_BOMB;
				return;
			}
			else if([map tileArrayAtRow:row col:col] & TILE_KILL){
				currentState = STATE_WAIT;
				return;
			}
			else{ up = NO;}
		}
		if(down){
			col = enemyTileCoord.y+i+1;
			row = enemyTileCoord.x;
			if([map tileArrayAtRow:row col:col] & TILE_OPEN){
			}
			else if([map tileArrayAtRow:row col:col] & TILE_BOMB)
			{
				walkDestCoord = ccp(row,col);
				currentState = STATE_BOMB;
				return;
			}
			else if([map tileArrayAtRow:row col:col] & TILE_KILL){
				currentState = STATE_WAIT;
				return;
			}
			else{ down = NO;}
		}
		if(right){
			col = enemyTileCoord.y;
			row = enemyTileCoord.x+i+1;
			if([map tileArrayAtRow:row col:col] & TILE_OPEN){
			}
			else if([map tileArrayAtRow:row col:col] & TILE_BOMB)
			{
				walkDestCoord = ccp(row,col);
				currentState = STATE_BOMB;
				return;
			}
			else if([map tileArrayAtRow:row col:col] & TILE_KILL){
				currentState = STATE_WAIT;
				return;
			}
			else{ right = NO;}
		}
		if(left){
			col = enemyTileCoord.y;
			row = enemyTileCoord.x-i-1;
			if([map tileArrayAtRow:row col:col] & TILE_OPEN){
			}
			else if([map tileArrayAtRow:row col:col] & TILE_BOMB)
			{
				walkDestCoord = ccp(row,col);
				currentState = STATE_BOMB;
				return;
			}
			else if([map tileArrayAtRow:row col:col] & TILE_KILL){
				currentState = STATE_WAIT;
				return;
			}
			else{ left = NO;}
		}
	}
    
	row=0;
	col=0;
	up = true;
	down = true;
	left = true;
	right = true;
	currentState = STATE_WALK;
    
    for(int i = 0;i<4;i++){
        if(up){
            col = enemyTileCoord.y-i-1;
            row = enemyTileCoord.x;
            if([map tileArrayAtRow:row col:col] & TILE_OPEN){
                PathFindNode* point = [PathFindNode node];
                point.nodeX = row;
                point.nodeY = col;
                point.cost = abs((playerTileCoord.x - row))+abs((playerTileCoord.y - col)); 
                [points addObject:point];
                walkDestCoord = ccp(row,col);
            }
            else if([map tileArrayAtRow:row col:col] & TILE_DESTROY_OBJECT)
            { 
                currentState = STATE_DESTROY;
                walkDestCoord = ccp(row,col+1);
                return;
            }
            else{
                up = NO;
            }
        }
        if(down){
            col = enemyTileCoord.y+i+1;
            row = enemyTileCoord.x;
            if([map tileArrayAtRow:row col:col] & TILE_OPEN){
                PathFindNode* point = [PathFindNode node];
                point.nodeX = row;
                point.nodeY = col;
                point.cost = abs((playerTileCoord.x - row))+abs((playerTileCoord.y - col)); 
                [points addObject:point];
                walkDestCoord = ccp(row,col);
            }
            else if([map tileArrayAtRow:row col:col] & TILE_DESTROY_OBJECT)
            { 
                currentState = STATE_DESTROY;
                walkDestCoord = ccp(row,col+1);
                return;
            }
            else{
                down = NO;
            }
        }
        if(right){
            col = enemyTileCoord.y;
            row = enemyTileCoord.x+i+1;
            if([map tileArrayAtRow:row col:col] & TILE_OPEN){
                PathFindNode* point = [PathFindNode node];
                point.nodeX = row;
                point.nodeY = col;
                point.cost = abs((playerTileCoord.x - row))+abs((playerTileCoord.y - col));  
                [points addObject:point];
                walkDestCoord = ccp(row,col);
            }
            else if([map tileArrayAtRow:row col:col] & TILE_DESTROY_OBJECT)
            { 
                currentState = STATE_DESTROY;
                walkDestCoord = ccp(row-1,col);
                return;
            }
            else{
                right=NO;
            }
        }
        if(left){
            col = enemyTileCoord.y;
            row = enemyTileCoord.x-i-1;
            if([map tileArrayAtRow:row col:col] & TILE_OPEN){
                PathFindNode* point = [PathFindNode node];
                point.nodeX = row;
                point.nodeY = col;
                point.cost = abs((playerTileCoord.x - row))+abs((playerTileCoord.y - col));  
                [points addObject:point];
                walkDestCoord = ccp(row,col);
            }
            else if([map tileArrayAtRow:row col:col] & TILE_DESTROY_OBJECT)
            { 
                currentState = STATE_DESTROY;
                walkDestCoord = ccp(row+1,col);
                return;
            }
            else{
                left=NO;
            }
        }
    }
    
}

-(void) findHoleForCoord:(CGPoint)tileCoord reverse:(_Bool)reverse
{
    Level* level = (Level*) self.parent;
    Map* map = level.map;
    
	int x = (int)tileCoord.x;
	int y = (int)tileCoord.y;
	int nextX = (int)tileCoord.x;
	int nextY = (int)tileCoord.y;
    
	switch(direction)
	{
        case PLAYER_LEFT:
            if(reverse) y++;
            else y--;
            nextX++;
            break;
        case PLAYER_RIGHT:
            if(reverse) y++;
            else y--;
            nextX--;
            break;
        case PLAYER_UP:
            if(reverse) x--;
            else x++;
            nextY++;
            break;
        case PLAYER_DOWN:
            if(reverse) x--;
            else x++;
            nextY--;
            break;
	}
    
	if([map tileArrayAtRow:x col:y] & TILE_OPEN)
	{
		[self walkTo:ccp(x,y) isTileCoord:YES];
	}
	else if(!reverse)
	{
        [self findHoleForCoord:tileCoord reverse:YES];
	}
	else
	{
		//go to one cell
        [self walkTo:ccp(nextX,nextY) isTileCoord:YES];
	}
}

-(void) correctBonus:(int)numlevel
{
    //correct for level
    //if(bombpower>numlevel) bombpower = numlevel;
    //if(bombnumber>numlevel) bombnumber = numlevel;
    //if(lifes>numlevel) lifes = numlevel;
    //if(speed>numlevel) speed = numlevel*10*4;
    
    //correct for max value
    if(bombpower>15) bombpower = 15;
    if(bombnumber>20) bombnumber = 20;
    if(lifes>10) lifes = 10;
    if(speed>70) speed = 70;
    
}
@end

