//
//  Sessions.h
//  edscope
//
//  Created by Frankie Myers on 11/26/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pictures;

@interface Sessions : NSManagedObject

@property (nonatomic, retain) NSString * cellscopeID;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * student;
@property (nonatomic, retain) NSOrderedSet *pictures;
@end

@interface Sessions (CoreDataGeneratedAccessors)

- (void)insertObject:(Pictures *)value inPicturesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPicturesAtIndex:(NSUInteger)idx;
- (void)insertPictures:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePicturesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPicturesAtIndex:(NSUInteger)idx withObject:(Pictures *)value;
- (void)replacePicturesAtIndexes:(NSIndexSet *)indexes withPictures:(NSArray *)values;
- (void)addPicturesObject:(Pictures *)value;
- (void)removePicturesObject:(Pictures *)value;
- (void)addPictures:(NSOrderedSet *)values;
- (void)removePictures:(NSOrderedSet *)values;
@end
