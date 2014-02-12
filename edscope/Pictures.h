//
//  Pictures.h
//  edscope
//
//  Created by Frankie Myers on 11/30/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sessions;

@interface Pictures : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * flickrID;
@property (nonatomic, retain) NSString * gps;
@property (nonatomic, retain) NSString * magnification;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic) int32_t number;
@property (nonatomic, retain) NSString * path;
@property (nonatomic) float pixelsPerMM;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic) float timelapseInterval;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic) int32_t uploadState;
@property (nonatomic, retain) Sessions *session;

@end
