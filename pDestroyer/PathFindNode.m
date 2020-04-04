
#import "PathFindNode.h"

@implementation PathFindNode
@synthesize nodeX;
@synthesize nodeY;
@synthesize cost;
@synthesize parentNode;
@synthesize nextNode;

+(id)node {
	return [[[PathFindNode alloc] init] autorelease];
}

@end
