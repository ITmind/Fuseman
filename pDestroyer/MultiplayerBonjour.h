
#import "BrowserViewController.h"
#import "Picker.h"
#import "TCPServer.h"
#import "Level.h"

typedef enum {
	NETWORK_B_ACK,					// no packet
	NETWORK_B_MAP,				// decide who is going to be the server
	NETWORK_B_MOVE_EVENT,				// send position
	NETWORK_B_SET_BOMB_EVENT,				// send fire
	NETWORK_B_DESTROY_WALL_EVENT,				
    NETWORK_B_EVENT,
    NETWORK_B_CLIENT_START
    
} packetCodesBonjour;

struct MultiGameDataStruct {
    uint16_t x;
    uint16_t y;
    uint8_t direction;
    uint8_t minutes;
    uint8_t seconds;
    uint16_t scoreAnotherPlayer;
};

typedef struct MultiGameDataStruct MultiGameDataStruct;

@interface MultiplayerBonjour : Level <BrowserViewControllerDelegate, TCPServerDelegate,
									 NSStreamDelegate>
{
	Picker				*_picker;
	TCPServer			*_server;
	NSInputStream		*_inStream;
	NSOutputStream		*_outStream;
	BOOL				_inReady;
	BOOL				_outReady;
    bool isServer;
    unsigned char numPlayers;
    
    int scoreAnotherPlayer;
    char thisScore;
}

-(void) reciveData:(NSData*)data packetID:(char)packetID;
-(void) recivegameData:(MultiGameDataStruct) struc packetID:(char)packetID;
-(bool) send:(NSData *)data packetID:(char)packetID;
-(bool) send:(char)packetID;
-(void) startServer;
-(void) startClient;
-(void) setup;
- (void) presentPicker:(NSString *)name;
- (void) browserViewController:(BrowserViewController *)bvc didResolveInstance:(NSNetService *)netService;

@end
