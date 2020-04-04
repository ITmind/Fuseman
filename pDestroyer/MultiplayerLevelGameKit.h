//
//  MultiplayerLevelGameKit.h
//  fuseman
//
//  Created by ITmind on 17.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Level.h"

typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
    NETWORK_MAP,				// recive map
	NETWORK_MOVE_EVENT,				// send position
	NETWORK_FIRE_EVENT,				// send fire
	NETWORK_HEARTBEAT				// send of entire state at regular intervals
} packetCodes;

typedef struct {
	CGPoint		tankPreviousPosition;
	CGPoint		tankPosition;
	CGPoint		tankMissilePosition;
	CGPoint		tankDestination;
	
	float		tankRotation;
	float		tankDirection;
	float		tankMissileDirection;
	int			tankMissile;
} tankInfo;

@interface MultiplayerLevelGameKit : Level <GKPeerPickerControllerDelegate, GKSessionDelegate, UIAlertViewDelegate>{
    NSInteger	gameState;
	NSInteger	peerStatus;
	
	// networking
	GKSession		*gameSession;
	int				gameUniqueID;
	int				gamePacketNumber;
	NSString		*gamePeerId;
	NSDate			*lastHeartbeatDate;
	
	UIAlertView		*connectionAlert;
    bool isServer;
    
}
@property(nonatomic) NSInteger		gameState;
@property(nonatomic) NSInteger		peerStatus;

@property(nonatomic, retain) GKSession	 *gameSession;
@property(nonatomic, copy)	 NSString	 *gamePeerId;
@property(nonatomic, retain) NSDate		 *lastHeartbeatDate;
@property(nonatomic, retain) UIAlertView *connectionAlert;

- (void)startPicker;
- (void) initMultiplayerIsServer:(bool)_isServer;
- (void)invalidateSession:(GKSession *)session;
- (void)gameLoop;//: (ccTime) dt;
- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend;

@end
