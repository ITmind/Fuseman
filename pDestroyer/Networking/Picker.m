#import "Picker.h"
#import "SceneManager.h"

#define kOffset 5

@interface Picker ()
@property (nonatomic, retain, readwrite) BrowserViewController *bvc;
@property (nonatomic, retain, readwrite) CCLabelTTF *gameNameLabel;
@end

@implementation Picker

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@synthesize bvc = _bvc;
@synthesize gameNameLabel = _gameNameLabel;

-(id) init{
    if ((self = [super initWithColor:ccc4(200, 200, 200, 255)])) {
    }
    return self;
}

- (id)initWithType:(NSString*)type {
	if ((self = [super initWithColor:ccc4(10, 10, 10, 255)])) {
        self.bvc = [[BrowserViewController node]autorelease];
		[self.bvc searchForServicesOfType:type inDomain:@"local"];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Waiting for another player to join game:"fontName:@"04B_09.TTF" fontSize:28];
        label.position= ccp(winSize.width/2,winSize.height-100);
		[self addChild:label z:1];
		
		_gameNameLabel = [CCLabelTTF labelWithString:@"Default Name"fontName:@"04B_09.TTF" fontSize:28];
        _gameNameLabel.position= ccp(winSize.width/2,winSize.height-140);
		_gameNameLabel.string=@"";
        _gameNameLabel.color = ccc3(200, 200, 0);
		[self addChild:_gameNameLabel z:1];
		
		
		label = [CCLabelTTF labelWithString:@"Or, join a different game:"fontName:@"04B_09.TTF" fontSize:28];
        label.position= ccp(winSize.width/2,winSize.height-180);
        [self addChild:label z:1];
		
		CCMenuItemFont* back = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(onBack:)];
        CCMenu* menu = [CCMenu menuWithItems:back, nil];
        menu.position = ccp(510,80);
        [self addChild:menu z:1];

        CCSprite* background = [CCSprite spriteWithFile:@"menu.png"];
        background.position = ccp(winSize.width/2,winSize.height/2);
        background.color = ccc3(100, 100, 100);
        //background->setPosition(ccp(x,winSize.height/2));
        [self addChild:background];
        
		//[self.bvc.view setFrame:CGRectMake(0, runningY, self.boundingBox.size.width , self.boundingBox.size.height)];
		//[self addSubview:self.bvc.view];
        //_bvc.position= ccp(winSize.width/2,winSize.height/2);
        [self addChild:_bvc];
        
		
	}

	return self;
}

- (void)onBack:(id)sender{
    //[[SimpleAudioEngine sharedEngine] playEffect:@"bombplanted.wav"];
	[SceneManager goMenu];
}

- (void)dealloc {
	// Cleanup any running resolve and free memory
	//[self.bvc release];
	//[self.gameNameLabel release];
	
	//[super dealloc];
}

- (id<BrowserViewControllerDelegate>)delegate {
	return self.bvc.delegate;
}

- (void)setDelegate:(id<BrowserViewControllerDelegate>)delegate {
	[self.bvc setDelegate:delegate];
}

- (NSString *)gameName {
	return self.gameNameLabel.string;
}

- (void)setGameName:(NSString *)string {
	self.gameNameLabel.string=string;
	self.bvc.ownName = string;
}


@end
