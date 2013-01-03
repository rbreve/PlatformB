//
//  MovingSprite.m
//  PlatformB
//
//  Created by Roberto Breve on 1/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MovingSprite.h"


@implementation MovingSprite

@synthesize movingUp = _movingUp, gId = _gId, initPosition = _initPosition;

-(id) initWithFile:(NSString *)filename rect:(CGRect)rect{
    if (self = [super initWithFile:filename rect:rect]) {
        self.movingUp = NO;
        self.initPosition = ccp(rect.origin.x, rect.origin.y);
    }
    return self;
}



@end
