//
//  MovingSprite.h
//  PlatformB
//
//  Created by Roberto Breve on 1/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MovingSprite : CCSprite {

}

@property (nonatomic, assign) BOOL movingUp;
@property (nonatomic, assign) CGPoint initPosition;
@property (nonatomic, assign) int gId;

@end
