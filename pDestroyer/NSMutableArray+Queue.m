//
//  NSMutableArray+Queue.m
//  fuseman
//
//  Created by ITmind on 13.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)
// Queues are first-in-first-out, so we remove objects from the head
- (id) dequeue {
    if ([self count] == 0) {
        return nil;
    }
    id queueObject = [[[self objectAtIndex:0] retain] autorelease];
    [self removeObjectAtIndex:0];
    return queueObject;
}


// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueue:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}
@end
