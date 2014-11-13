//
//  CellScopeContext.m
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//


#import "CellScopeContext.h"

@implementation CellScopeContext

@synthesize flickrUsername,flickrUserID,studentName,groupName;

+ (id)sharedContext {
    static CellScopeContext *newContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newContext = [[self alloc] init];
    });
    return newContext;
}

- (id)init {
    if (self = [super init]) {
        flickrUserID = @"";
        flickrUsername = @"Not Logged In";
        studentName = @"";
        groupName = @"";
        
    }
    return self;
}


//this isn't the ideal place for this
+ (NSString*)getEXIFTitleString:(NSString*)imageTitle
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
    NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString* exifTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@"EXIFTitleFormat"];
    
    exifTitle = [exifTitle stringByReplacingOccurrencesOfString:@TITLE_PLACEHOLDER withString:imageTitle];
    exifTitle = [exifTitle stringByReplacingOccurrencesOfString:@USER_PLACEHOLDER withString:[[CellScopeContext sharedContext] studentName]];
    exifTitle = [exifTitle stringByReplacingOccurrencesOfString:@GROUP_PLACEHOLDER withString:[[CellScopeContext sharedContext] groupName]];
    exifTitle = [exifTitle stringByReplacingOccurrencesOfString:@IMAGENUMBER_PLACEHOLDER withString:[NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"PictureCount"]]];
    exifTitle = [exifTitle stringByReplacingOccurrencesOfString:@DATETIME_PLACEHOLDER withString:dateString];
    exifTitle = [exifTitle stringByReplacingOccurrencesOfString:@CELLSCOPEID_PLACEHOLDER withString:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"]];
    exifTitle = [exifTitle stringByReplacingOccurrencesOfString:@LOCATION_PLACEHOLDER withString:[[NSUserDefaults standardUserDefaults] stringForKey:@"Location"]];
    
    return exifTitle;
    
}
@end

