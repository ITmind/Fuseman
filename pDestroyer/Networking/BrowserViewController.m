#import "BrowserViewController.h"

#define kProgressIndicatorSize 20.0

// A category on NSNetService that's used to sort NSNetService objects by their name.
@interface NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService;
@end

@implementation NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService {
	return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}
@end


@implementation BrowserViewController
@synthesize ownName;
@synthesize delegate;

- (id)init{
	
	if ((self = [super init])) {
		services = [[NSMutableArray alloc] init];
	}

	return self;
}


- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain {
	
    [currentResolve stop];
	[netServiceBrowser stop];
	[services removeAllObjects];

	netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if(!netServiceBrowser) {
		return NO;
	}

	netServiceBrowser.delegate = self;
	[netServiceBrowser searchForServicesOfType:type inDomain:domain];

	//[self.tableView reloadData];
	return YES;
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    //NSLog(@"Remove service");
    
    if (currentResolve && [service isEqual:currentResolve]) {
		[currentResolve stop];
	}
    
    if(!moreComing){
        //NSLog(@"---- more comming");
        [services removeObject:service];
        [self updateService];
    }
}	

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    //NSLog(@"Find service");
    if(!moreComing){
        //NSLog(@"---- more comming");
        if(![service.name isEqual:ownName]){
            [services addObject:service];
            [self updateService];
        }
    }
}	

// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Not resolve");
    [currentResolve stop];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"Resolve adress");
    [service retain];
	[currentResolve stop];
	
	[self.delegate browserViewController:self didResolveInstance:service];
	[service release];
}

-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
    NSLog(@"Search...");
}
-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
    NSLog(@"Stop search");
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict{
    NSLog(@"Search error");
}

-(void) updateService{
    [self removeChild:serviceList cleanup:YES];
    serviceList = [CCMenu menuWithItems:nil];
    for (NSNetService* service in services) {
        CCMenuItemFont* button = [CCMenuItemFont itemFromString:service.name target:self selector:@selector(onSelect:)];
        button.userData = service;
        button.color = ccc3(200, 50, 50);
        [serviceList addChild:button];
    }
    [self addChild:serviceList];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    serviceList.position = ccp(winSize.width/2,winSize.height/2);
    
    [serviceList alignItemsVertically];
}

-(void) onSelect:(id)sender{
    [netServiceBrowser stop];
    CCMenuItemFont* button = (CCMenuItemFont*)sender;
    NSNetService* service = (NSNetService*) button.userData;
    currentResolve = service;
	[currentResolve setDelegate:self];
	[currentResolve resolveWithTimeout:0.0];
    
}

- (void)dealloc {
    [currentResolve stop];
	services = nil;
	[netServiceBrowser stop];
	netServiceBrowser = nil;	
	[super dealloc];
}

@end
