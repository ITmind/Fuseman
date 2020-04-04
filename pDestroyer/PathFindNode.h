
#import <Foundation/Foundation.h>

@interface PathFindNode : NSObject {
	int nodeX,nodeY;
	int cost;
	PathFindNode* parentNode;
    PathFindNode* nextNode;
}

+(id)node;
@property int nodeX;
@property int nodeY;
@property int cost;
@property (retain) PathFindNode* parentNode;
@property (retain) PathFindNode* nextNode;

@end
