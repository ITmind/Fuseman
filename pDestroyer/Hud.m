//
//  MenuLayer.m
//  MenuLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "Hud.h"
#import "Player.h"

//@class HelloWorldLayer;

@implementation Hud
@synthesize score;

-(id) init
{
    if( (self=[super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        int startX = 260;
        int startY = 40;
        int offset = 40;
        
        CCSprite* sprite;
		//CCLabelTTF* label;
        
        
		sprite = [CCSprite spriteWithSpriteFrameName:@"bombnumber.png"];
		sprite.position = ccp(startX, startY);
		bombNumberLabel = [CCLabelTTF labelWithString:@"1" fontName:@"04B_09.TTF" fontSize:16];
        bombNumberLabel.tag = 1;
		bombNumberLabel.position=ccp(20,10);
        bombNumberLabel.color=ccc3(255,0,0);
		[sprite addChild:bombNumberLabel];
		[self addChild:sprite];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"bombpower.png"];
		sprite.position = ccp(startX+offset, startY);
		bombPowerLabel = [CCLabelTTF labelWithString:@"1" fontName:@"04B_09.TTF" fontSize:16];
        bombPowerLabel.tag = 1;
		bombPowerLabel.position=ccp(20,10);
        bombPowerLabel.color=ccc3(255,0,0);
		[sprite addChild:bombPowerLabel];
		[self addChild:sprite];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"life.png"];
		sprite.position = ccp(startX+offset*2, startY);
		lifeLabel = [CCLabelTTF labelWithString:@"1" fontName:@"04B_09.TTF" fontSize:16];
        lifeLabel.tag = 1;
		lifeLabel.position=ccp(20,10);
        lifeLabel.color=ccc3(255,0,0);
		[sprite addChild:lifeLabel];
		[self addChild:sprite];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"speed.png"];
		sprite.position = ccp(startX+offset*3, startY);
		speedLabel = [CCLabelTTF labelWithString:@"1" fontName:@"04B_09.TTF" fontSize:16];
        speedLabel.tag = 1;
		speedLabel.position=ccp(20,10);
        speedLabel.color=ccc3(255,0,0);
		[sprite addChild:speedLabel];
		[self addChild:sprite];
        
        score = [[NSUserDefaults standardUserDefaults] integerForKey:@"Score"];
        
        cLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",score] fontName:@"04B_09.TTF" fontSize:18];
		cLabel.position=ccp(350,winSize.height-18);
		cLabel.color=ccc3(255,255,255);
		[self addChild:cLabel];
        
        bombNumberLabel.tag = [[NSUserDefaults standardUserDefaults] integerForKey:@"bombNumber"];
        if(bombNumberLabel.tag==0) bombNumberLabel.tag = 1;
        bombNumberLabel.string = [NSString stringWithFormat:@"%i",bombNumberLabel.tag];
        
        bombPowerLabel.tag = [[NSUserDefaults standardUserDefaults] integerForKey:@"bombPower"];
        if(bombPowerLabel.tag==0) bombPowerLabel.tag = 1;
        bombPowerLabel.string = [NSString stringWithFormat:@"%i",bombPowerLabel.tag];
        
        lifeLabel.tag = [[NSUserDefaults standardUserDefaults] integerForKey:@"playerLife"];
        if(lifeLabel.tag==0) lifeLabel.tag = 1;
        lifeLabel.string = [NSString stringWithFormat:@"%i",lifeLabel.tag];
        
        speedLabel.tag = [[NSUserDefaults standardUserDefaults] integerForKey:@"playerSpeed"]/10;
        if(speedLabel.tag==0) speedLabel.tag = 1;
        speedLabel.string = [NSString stringWithFormat:@"%i",speedLabel.tag];
        
        
    }
    
    return self;
}

-(void) addScore:(int)addscore
{
    score+=addscore;
    cLabel.string = [NSString stringWithFormat:@"%i",score];
}

-(void) setScore:(int)addscore
{
    score=addscore;
    cLabel.string = [NSString stringWithFormat:@"%i",score];
}

-(int) score{
    return score;
}

-(void) addPower
{
    bombPowerLabel.tag++;
    bombPowerLabel.string = [NSString stringWithFormat:@"%i",bombPowerLabel.tag];
}

-(void) addLife
{
    lifeLabel.tag++;
    lifeLabel.string = [NSString stringWithFormat:@"%i",lifeLabel.tag];
}

-(void) addNumBomb
{
    bombNumberLabel.tag++;
    bombNumberLabel.string = [NSString stringWithFormat:@"%i",bombNumberLabel.tag];
}

-(void) addSpeed
{
    speedLabel.tag++;
    speedLabel.string = [NSString stringWithFormat:@"%i",(speedLabel.tag)];
}

-(void) clearBonus
{
    speedLabel.tag=1;
    speedLabel.string = [NSString stringWithFormat:@"%i",speedLabel.tag];
    bombPowerLabel.tag=1;
    bombPowerLabel.string = [NSString stringWithFormat:@"%i",bombPowerLabel.tag];
    lifeLabel.tag=1;
    lifeLabel.string = [NSString stringWithFormat:@"%i",lifeLabel.tag];
    bombNumberLabel.tag=1;
    bombNumberLabel.string = [NSString stringWithFormat:@"%i",bombNumberLabel.tag];
}

-(void) setBonusLabelPower:(int)power life:(int)life numbomb:(int)numbomb speed:(int)speed
{
    speedLabel.tag=speed/10;
    speedLabel.string = [NSString stringWithFormat:@"%i",speedLabel.tag];
    bombPowerLabel.tag=power;
    bombPowerLabel.string = [NSString stringWithFormat:@"%i",bombPowerLabel.tag];
    lifeLabel.tag=life;
    lifeLabel.string = [NSString stringWithFormat:@"%i",lifeLabel.tag];
    bombNumberLabel.tag=numbomb;
    bombNumberLabel.string = [NSString stringWithFormat:@"%i",bombNumberLabel.tag];
}

-(void) setBonusLabelForPlayer:(Player*)player
{
    [self setBonusLabelPower:player.bombpower life:player.lifes numbomb:player.bombnumber speed:player.speed];
}

@end
