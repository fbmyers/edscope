//
//  Sessions.m
//  edscope
//
//  Created by Frankie Myers on 11/26/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "Sessions.h"
#import "Pictures.h"


@implementation Sessions

@dynamic cellscopeID;
@dynamic date;
@dynamic group;
@dynamic location;
@dynamic student;
@dynamic pictures;

- (void)addPicturesObject:(Pictures *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.pictures];
    [tempSet addObject:value];
    self.pictures = tempSet;
}

@end
