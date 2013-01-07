//
//  Inventory.m
//  PlatformB
//
//  Created by Roberto Breve on 1/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Inventory.h"
#import "Item.h"

@implementation Inventory


-(NSMutableArray *) items{
    if (_items == nil) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

-(void) addItem:(Item *) item{
    [self.items addObject:item];
    [self addChild:item];
    item.position = ccp(0, [self.items count] * 50);
}

-(id) init{
    if (self = [super init]) {
        
        
    }
    return self;
}

@end
