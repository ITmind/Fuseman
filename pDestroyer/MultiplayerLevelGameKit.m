//
//  MultiplayerLevelGameKit.m
//  fuseman
//
//  Created by ITmind on 17.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiplayerLevelGameKit.h"
#import "SceneManager.h"
#import "Map.h"

//
// various states the game can get into
//
typedef enum {
	kStateStartGame,
	kStatePicker,
	kStateMultiplayer,
	kStateMultiplayerCointoss,
	kStateMultiplayerReconnect
} gameStates;

//
// for the sake of simplicity tank1 is the server and tank2 is the client
//
typedef enum {
	kServer,
	kClient
} gameNetwork;

// GameKit Session ID for app
#define kTankSessionID @"fuseman"
#define kMaxTankPacketSize 1024
const float kHeartbeatTimeMaxDelay = 2.0f;

@implementation MultiplayerLevelGameKit
@synthesize gameState, peerStatus, gameSession, gamePeerId, lastHeartbeatDate, connectionAlert;

//-(id) init{
//    if( (self=[super init])) {
//        
//	}
//	return self;
//}

-(void) initMultiplayerIsServer:(bool)_isServer {
    peerStatus = kServer;
    gamePacketNumber = 0;
    gameSession = nil;
    gamePeerId = nil;
    lastHeartbeatDate = nil;
    isServer = _isServer;
    
    NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
    gameUniqueID = [uid hash];
    
    self.gameState = kStateStartGame; // Setting to kStateStartGame does a reset of players, scores, etc. See -setGameState: below
    
    //[NSTimer scheduledTimerWithTimeInterval:0.033 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
    
    fog = [CCLayerColor node];
	[fog initWithColor:ccc4(0,0,0,230)];
    [self addChild:fog z:10];
    fog.position=CGPointZero;
    
    if (isServer) {
        gameSession = [[GKSession alloc] initWithSessionID:nil displayName:@"Server" sessionMode:GKSessionModeServer]; 
         gameSession.available = YES;
        gameSession.delegate = self;
        [gameSession setDataReceiveHandler:self withContext:NULL];
        NSLog(@"Create server");
    }
    else{
        gameSession = [[GKSession alloc] initWithSessionID:nil displayName:@"Client" sessionMode:GKSessionModeClient];
        NSLog(@"Create client");
        gameSession.available = YES;
        gameSession.delegate = self;
        [gameSession setDataReceiveHandler:self withContext:NULL];
//        NSArray * arr = [gameSession peersWithConnectionState:GKPeerStateAvailable];
//        for (NSString* s in arr) {
//            NSLog(@" %@",s);
//            [gameSession connectToPeer:s withTimeout:5];
//        }
        //[gameSession connectToPeer:@"Server" withTimeout:5];
    }
    [gameSession retain];
   
    //NSLog(@"gameSesion aviable %@",gameSession.available?@"YES":@"NO");
    
    //[self startPicker];
    //[self schedule: @selector(gameLoop:)interval:0.033f];
}


- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"ERROR: %@",error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"ERROR: %@",error);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID{
    NSLog(@"client want connect %@",peerID);
    if([gameSession acceptConnectionFromPeer:peerID error:nil]){
        NSLog(@"client connection accept %@", peerID);
    }
}

//- (BOOL)acceptConnectionFromPeer:(NSString *)peerID error:(NSError **)error{
//    NSLog(@"client connection accept %@", peerID);
//    return YES;
//}

- (void)denyConnectionFromPeer:(NSString *)peerID{
    NSLog(@"client connection deny %@", peerID);
}

#pragma mark Peer Picker Related Methods

-(void)startPicker {
    NSLog(@"startPicker");
	GKPeerPickerController*		picker;
	
	self.gameState = kStatePicker;			// we're going to do Multiplayer!
	
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}

#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker { 
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    NSLog(@"peerPickerControllerDidCancel");
    
	// autorelease the picker. 
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	if(self.gameSession != nil)	{
		[self invalidateSession:self.gameSession];
		self.gameSession = nil;
	}
	
	// go back to start mode
	self.gameState = kStateStartGame;
} 

/*
 *	Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *		- see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type { 
    NSLog(@"peerPickerController sessionForConnectionType");
    GKSession *session;
    if (isServer) {
        session = [[GKSession alloc] initWithSessionID:kTankSessionID displayName:@"Server" sessionMode:GKSessionModeServer]; 
    }
    else{
        session = [[GKSession alloc] initWithSessionID:kTankSessionID displayName:@"Client" sessionMode:GKSessionModeClient]; 
    }
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session { 
    NSLog(@"peerPickerController");
	// Remember the current peer.
	self.gamePeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	self.gameSession = session; // retain
	self.gameSession.delegate = self; 
	[self.gameSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	//NSLog(@"Create sesion");
    [self removeChild:fog cleanup:YES];
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
    if (isServer) {
        [self sendNetworkPacket:self.gameSession packetID:NETWORK_MAP withData:&map->tileArray ofLength:25*19 reliable:YES];
    }
	self.gameState = kStateMultiplayerCointoss;
} 


#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
    NSLog(@"invalidateSession");
	if(session != nil) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession. 
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { 
    NSLog(@"receiveData");
	static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];
	//
	// developer  check the network time and make sure packers are in order
	//
	int packetTime = pIntData[0];
	int packetID = pIntData[1];
	if(packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
		return;	
	}
	
	lastPacketTime = packetTime;
	switch( packetID ) {
		case NETWORK_COINTOSS:
        {
            // coin toss to determine roles of the two players
            int coinToss = pIntData[2];
            // if other player's coin is higher than ours then that player is the server
            if(coinToss > gameUniqueID) {
                self.peerStatus = kClient;
            }
            
            // notify user of tank color
            //self.gameLabel.text = (self.peerStatus == kServer) ? kBlueLabel : kRedLabel; // server is the blue tank, client is red
            //self.gameLabel.hidden = NO;
            // after 1 second fire method to hide the label
            //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideGameLabel:) userInfo:nil repeats:NO];
        }
			break;
        case NETWORK_MAP:
        {
            NSLog(@"recive map");
            //*map->tileArray[0] = &pIntData[2]; 
            memcpy( &map->tileArray[0], &pIntData[2], 25*19 ); 
            [map generateMap:numBonuses numEnemy:numEnemy isSingleLevel:NO];
            [self initLevel];
            //NSLog(@"current tile set %i",recivemap.currentTileSet);
            // notify user of tank color
            //self.gameLabel.text = (self.peerStatus == kServer) ? kBlueLabel : kRedLabel; // server is the blue tank, client is red
            //self.gameLabel.hidden = NO;
            // after 1 second fire method to hide the label
            //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideGameLabel:) userInfo:nil repeats:NO];
        }
			break;
		case NETWORK_MOVE_EVENT:
        {
            // received move event from other player, update other player's position/destination info
            //tankInfo *ts = (tankInfo *)&incomingPacket[8];
            int peer = (self.peerStatus == kServer) ? kClient : kServer;
            //tankInfo *ds = &tankStats[peer];
            //ds->tankDestination = ts->tankDestination;
            //ds->tankDirection = ts->tankDirection;
        }
			break;
		case NETWORK_FIRE_EVENT:
        {
            // received a missile fire event from other player, update other player's firing status
            //tankInfo *ts = (tankInfo *)&incomingPacket[8];
            int peer = (self.peerStatus == kServer) ? kClient : kServer;
            //tankInfo *ds = &tankStats[peer];
            //ds->tankMissile = ts->tankMissile;
            //ds->tankMissilePosition = ts->tankMissilePosition;
            //ds->tankMissileDirection = ts->tankMissileDirection;
        }
			break;
		case NETWORK_HEARTBEAT:
        {
            // Received heartbeat data with other player's position, destination, and firing status.
            
            // update the other player's info from the heartbeat
            //tankInfo *ts = (tankInfo *)&incomingPacket[8];		// tank data as seen on other client
            //int peer = (self.peerStatus == kServer) ? kClient : kServer;
            //tankInfo *ds = &tankStats[peer];					// same tank, as we see it on this client
            //memcpy( ds, ts, sizeof(tankInfo) );
            
            // update heartbeat timestamp
            self.lastHeartbeatDate = [NSDate date];
            
            // if we were trying to reconnect, set the state back to multiplayer as the peer is back
            if(self.gameState == kStateMultiplayerReconnect) {
                if(self.connectionAlert && self.connectionAlert.visible) {
                    [self.connectionAlert dismissWithClickedButtonIndex:-1 animated:YES];
                }
                self.gameState = kStateMultiplayer;
            }
        }
			break;
		default:
			// error
			break;
	}
}

- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend {
    NSLog(@"sendNetworkPacket");
	// the packet we'll send is resued
	static unsigned char networkPacket[kMaxTankPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxTankPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = gamePacketNumber++;
		pIntData[1] = packetID;
		// copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length ); 
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
		if(howtosend == YES) { 
			[session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataReliable error:nil];
		} else {
			[session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
		}
	}
}

#pragma mark GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state { 
    NSLog(@"session didChangeState");
	switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"GKPeerStateAvailable");
            [gameSession connectToPeer:peerID withTimeout:5];
            break;
        case GKPeerStateConnected:
            NSLog(@"GKPeerStateConnected");
            break;
        case GKPeerStateConnecting:
            NSLog(@"GKPeerStateConnecting");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"GKPeerStateDisconnected");
            break;
        case GKPeerStateUnavailable:
            NSLog(@"GKPeerStateUnavailable");
            break;
        default:
            break;
    }
	
	if(state == GKPeerStateDisconnected) {
        NSLog(@"connect sucess %@",peerID);
		// We've been disconnected from the other peer.
		
		// Update user alert or throw alert if it isn't already up
		NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
		if((self.gameState == kStateMultiplayerReconnect) && self.connectionAlert && self.connectionAlert.visible) {
			self.connectionAlert.message = message;
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
			self.connectionAlert = alert;
			[alert show];
			[alert release];
		}
		
		// go back to start mode
		self.gameState = kStateStartGame; 
	} 
} 

#pragma mark -

//
// Game loop runs at regular interval to update game based on current game state
//
- (void)gameLoop{//: (ccTime) dt {
	static int counter = 0;
	switch (self.gameState) {
		case kStatePicker:
		case kStateStartGame:
			break;
		case kStateMultiplayerCointoss:
			[self sendNetworkPacket:self.gameSession packetID:NETWORK_COINTOSS withData:&gameUniqueID ofLength:sizeof(int) reliable:YES];
            NSLog(@"Size of map %lu", sizeof(map));
            [self sendNetworkPacket:self.gameSession packetID:NETWORK_MAP withData:&map->tileArray ofLength:25*19 reliable:YES];
			self.gameState = kStateMultiplayer; // we only want to be in the cointoss state for one loop
			break;
		case kStateMultiplayer:
			//[self updateTanks];
			counter++;
			if(!(counter&7)) { // once every 8 updates check if we have a recent heartbeat from the other player, and send a heartbeat packet with current state
				if(self.lastHeartbeatDate == nil) {
					// we haven't received a hearbeat yet, so set one (in case we never receive a single heartbeat)
					self.lastHeartbeatDate = [NSDate date];
				}
				else if(fabs([self.lastHeartbeatDate timeIntervalSinceNow]) >= kHeartbeatTimeMaxDelay) { // see if the last heartbeat is too old
					// seems we've lost connection, notify user that we are trying to reconnect (until GKSession actually disconnects)
					NSString *message = [NSString stringWithFormat:@"Trying to reconnect...\nMake sure you are within range of %@.", [self.gameSession displayNameForPeer:self.gamePeerId]];
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
					self.connectionAlert = alert;
					[alert show];
					[alert release];
					self.gameState = kStateMultiplayerReconnect;
				}
				
				// send a new heartbeat to other player
				tankInfo ts;
                ts.tankMissile =0;
				[self sendNetworkPacket:gameSession packetID:NETWORK_HEARTBEAT withData:&ts ofLength:sizeof(tankInfo) reliable:NO];
			}
			break;
		case kStateMultiplayerReconnect:
			// we have lost a heartbeat for too long, so pause game and notify user while we wait for next heartbeat or session disconnect.
			counter++;
			if(!(counter&7)) { // keep sending heartbeats to the other player in case it returns
				tankInfo ts;
                ts.tankMissile =0;
				[self sendNetworkPacket:gameSession packetID:NETWORK_HEARTBEAT withData:&ts ofLength:sizeof(tankInfo) reliable:NO];
			}
			break;
		default:
			break;
	}
}

#pragma mark UIAlertViewDelegate Methods

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// 0 index is "End Game" button
	if(buttonIndex == 0) {
        [SceneManager goMenu];
		self.gameState = kStateStartGame; 
	}
}

- (void)setGameState:(NSInteger)newState {
	if(newState == kStateStartGame) {
		if(self.gameSession) {
			// invalidate session and release it.
			[self invalidateSession:self.gameSession];
			self.gameSession = nil;
		}
		
		// reset players to initial positions
	}
	
	gameState = newState;
}

@end
