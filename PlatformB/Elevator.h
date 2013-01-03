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

@property (nonatomic, assign) BOOL movingUp;
@property (nonatomic, assign) CGPoint initPosition;
@property (nonatomic, assign) int gId;
@property (nonatomic, strong) CCSprite *sprite;


@end
