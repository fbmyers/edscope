//
//  CellScopeContext.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#define TITLE_PLACEHOLDER "<TITLE>"
#define USER_PLACEHOLDER "<USER>"
#define GROUP_PLACEHOLDER "<GROUP>"
#define IMAGENUMBER_PLACEHOLDER "<IMAGENUMBER>"
#define DATETIME_PLACEHOLDER "<DATETIME>"
#define CELLSCOPEID_PLACEHOLDER "<CELLSCOPEID>"
#define LOCATION_PLACEHOLDER "<LOCATION>"

@interface CellScopeContext : NSObject

//TODO: add managed object context, session, etc.
@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSString* flickrUsername;
@property (nonatomic, retain) NSString* flickrUserID;
@property (nonatomic, retain) NSString* studentName;
@property (nonatomic, retain) NSString* groupName;

+ (id)sharedContext;

+ (NSString*)getEXIFTitleString:(NSString*)imageTitle;

@end
