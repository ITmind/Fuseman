
#import "MultiplayerBonjour.h"
#import "Picker.h"
#import "AppDelegate.h"
#import "Map.h"
#import "Hud.h"
#import "NSMutableArray+Queue.h"
#import "Player.h"

#define kGameIdentifier		@"fuseman"
#define kMaxPacketSize 1024


#pragma mark -
@implementation MultiplayerBonjour

- (void) _showAlert:(NSString *)title
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
    
	//Create and advertise a new game and discover other availble games
	[self setup];
}

- (void) dealloc
{	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_inStream release];

	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream release];

	[_server release];
	
	[_picker release];
	
	[super dealloc];
}

- (void) setup {
	[_server release];
	_server = nil;
	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream release];
	_inStream = nil;
	_inReady = NO;

	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream release];
	_outStream = nil;
	_outReady = NO;
	
	_server = [TCPServer new];
	[_server setDelegate:self];
	NSError *error = nil;
	if(_server == nil || ![_server start:&error]) {
		if (error == nil) {
			NSLog(@"Failed creating server: Server instance is nil");
		} else {
		NSLog(@"Failed creating server: %@", error);
		}
		[self _showAlert:@"Failed creating server"];
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kGameIdentifier] name:nil]) {
		[self _showAlert:@"Failed advertising server"];
		return;
	}

	[self presentPicker:nil];
}

// Make sure to let the user know what name is being used for Bonjour advertisement.
// This way, other players can browse for and connect to this game.
// Note that this may be called while the alert is already being displayed, as
// Bonjour may detect a name conflict and rename dynamically.
- (void) presentPicker:(NSString *)name {
    [self removeChild:_picker cleanup:YES];
    
	if (!_picker) {
        //_picker = [Picker node];
		_picker = [[Picker alloc] initWithType:[TCPServer bonjourTypeFromIdentifier:kGameIdentifier]];
		_picker.delegate = self;
	}
	
	_picker.gameName = name;
    //if([self getChildByTag:1]==nil){
    hud.visible = NO;
    [self addChild:_picker z:1 tag:1];
    //}
}

- (void) destroyPicker {
	//[_picker removeFromSuperview];
	[_picker release];
	_picker = nil;
}

// If we display an error or an alert that the remote disconnected, handle dismissal and return to setup
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self setup];
}

- (bool) send:(NSData *)data packetID:(char)packetID
{
	if (_outStream && [_outStream hasSpaceAvailable]){
        
        uint32_t length = [data length]; //(uint32_t)htonl([data length]);
            // Don't forget to check the return value of 'write'
        [_outStream write:(uint8_t *)&packetID maxLength:1]; 
        [_outStream write:(uint8_t *)&length maxLength:4];
		if([_outStream write:[data bytes] maxLength:[data length]] == -1){
			NSLog(@"Failed sending data to peer");
        }
    }
    else{
        return NO;
    }
    
    return YES;
}

- (bool) send:(char)packetID
{
	if (_outStream && [_outStream hasSpaceAvailable]){
        
        [_outStream write:(uint8_t *)&packetID maxLength:1];
        
        MultiGameDataStruct gameData;
        CGPoint pos = player.position;
        gameData.x = pos.x;
        gameData.y = pos.y;
        gameData.direction = player.direction;
        gameData.seconds = seconds;
        gameData.minutes = minutes;
        gameData.scoreAnotherPlayer = thisScore;
        
		if([_outStream write:(uint8_t *)&gameData maxLength:sizeof(MultiGameDataStruct)] == -1){
			NSLog(@"Failed sending data to peer");
        }
    }
    else{
        return NO;
    }
    
    return YES;
    
}

- (void) openStreams
{
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}

- (void) browserViewController:(BrowserViewController *)bvc didResolveInstance:(NSNetService *)netService
{
	if (!netService) {
		[self setup];
		return;
	}

	// note the following method returns _inStream and _outStream with a retain count that the caller must eventually release
	if (![netService getInputStream:&_inStream outputStream:&_outStream]) {
		[self _showAlert:@"Failed connecting to server"];
		return;
	}

	[self openStreams];
}

-(void) reciveData:(NSData*) data packetID:(char)packetID{
    
}

-(void) recivegameData:(MultiGameDataStruct) struc packetID:(char)packetID{
    
}

-(void) startServer{
    
}
-(void) startClient{
    
}

@end


#pragma mark -
@implementation MultiplayerBonjour (NSStreamDelegate)

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	//UIAlertView *alertView;
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			[self destroyPicker];
			
			[_server release];
			_server = nil;

			if (stream == _inStream)
				_inReady = YES;
			else
				_outReady = YES;
			
			if (_inReady && _outReady) {
                isPause = NO;
                if(isServer){
                    [self startServer];
                }
                else{
                    NSLog(@"open stream start client");
                    [self startClient];
                }
			//	alertView = [[UIAlertView alloc] initWithTitle:@"Game started!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
			//	[alertView show];
			//	[alertView release];
			}
            
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
			if (stream == _inStream) {
            
                int len = 0;
                int packetID = 0;
                len = [_inStream read:(uint8_t*)&packetID maxLength:1];
                int streamStatus = stream.streamStatus;
                
				if(len <= 0) {
					if (streamStatus != NSStreamStatusAtEnd)
						[self _showAlert:@"Failed reading data from peer"];
				} else {
                    if(packetID==NETWORK_B_MAP){
                        int dataLength;
                        len = [_inStream read:(uint8_t*)&dataLength maxLength:4];
                        //uint32_t dataLength = (uint32_t)CFSwapInt32LittleToHost(len1);
                        uint8_t bytes[dataLength];
                        len = [_inStream read:bytes maxLength:dataLength];  
                        [self reciveData:[NSData dataWithBytes:bytes length:dataLength] packetID:packetID];
                    }
                    else{
                        MultiGameDataStruct gameData;
                        len = [_inStream read:(uint8_t*)&gameData maxLength:sizeof(MultiGameDataStruct)];
                        [self recivegameData:gameData packetID:packetID];
                    }
				}
			}
			break;
		}
		case NSStreamEventErrorOccurred:
		{
			//NSLog(@"%s", _cmd);
			//[self _showAlert:@"Error encountered on stream!"];			
			break;
		}
			
		case NSStreamEventEndEncountered:
		{
			UIAlertView	*alertView;
			
			//NSLog(@"%s", _cmd);
			
			alertView = [[UIAlertView alloc] initWithTitle:@"Peer Disconnected!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
			[alertView show];
			[alertView release];

			break;
		}
	}
}

@end


#pragma mark -
@implementation MultiplayerBonjour (TCPServerDelegate)

- (void) serverDidEnableBonjour:(TCPServer *)server withName:(NSString *)string
{
	//NSLog(@"%s", _cmd);
	[self presentPicker:string];
}

- (void)didAcceptConnectionForServer:(TCPServer *)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	if (_inStream || _outStream || server != _server)
		return;
	
	[_server release];
	_server = nil;
    isServer = YES;
	
	_inStream = istr;
	[_inStream retain];
	_outStream = ostr;
	[_outStream retain];
	
	[self openStreams];
}

@end
