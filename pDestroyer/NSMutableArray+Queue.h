//
//  NSMutableArray+Queue.h
//  fuseman
//
//  Created by ITmind on 13.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end
