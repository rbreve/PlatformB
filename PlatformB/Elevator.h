//
//  Elevator.h
//  PlatformB
//
//  Created by Roberto Breve on 1/2/13.
//
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"

@interface Elevator : NSObject

enum {
    isElevator = 2,
	isMovable = 1,
};

@property (nonatomic, assign) BOOL movingUp;
@property (nonatomic, assign) CGPoint initPosition;
@property (nonatomic, assign) int gId;
@property (nonatomic, strong) CCSprite *sprite;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) BOOL initYRandom;

@end
