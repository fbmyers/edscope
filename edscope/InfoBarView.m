//
//  InfoBarView.m
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "InfoBarView.h"

@implementation InfoBarView
@synthesize label1,label2,label3,icon1,icon2,icon3,background1,background2,background3;

+ (InfoBarView*)makeInfoBarInView:(UIView*)parentView
{
    //this is super annoying, but i can't seem to get this custom view to load properly via storyboard
    InfoBarView* ibv = [[[NSBundle mainBundle] loadNibNamed:@"InfoBarView" owner:self options:nil] objectAtIndex:0];
    ibv.frame = CGRectMake(0,748,1024,20); //TODO: fix this so it autosizes based on parentView
    [parentView addSubview:ibv];
    
    return ibv;
}

- (void)setFlickrUsername:(NSString*)flickrUsername
              cellScopeID:(NSString*)cellScopeID
{
    
    [self.label1 setHidden:YES];
    [self.icon1 setHidden:YES];
    [self.background1 setHidden:YES];
    [self.label2 setHidden:NO];
    [self.icon2 setHidden:NO];
    [self.background2 setHidden:NO];
    [self.label3 setHidden:NO];
    [self.icon3 setHidden:NO];
    [self.background3 setHidden:NO];
    
    [self.label2 setText:flickrUsername];
    [self.label3 setText:cellScopeID];
    
    [self.icon2 setImage:[UIImage imageNamed:@"flickricon.png"]];
    [self.icon3 setImage:[UIImage imageNamed:@"idicon.png"]];
    
}

- (void)setStudentName:(NSString*)studentName
             groupName:(NSString*)groupName
           cellScopeID:(NSString*)cellScopeID
{
    [self.label1 setHidden:NO];
    [self.icon1 setHidden:NO];
    [self.background1 setHidden:NO];
    [self.label2 setHidden:NO];
    [self.icon2 setHidden:NO];
    [self.background2 setHidden:NO];
    [self.label3 setHidden:NO];
    [self.icon3 setHidden:NO];
    [self.background3 setHidden:NO];
    
    [self.label1 setText:studentName];
    [self.label2 setText:groupName];
    [self.label3 setText:cellScopeID];
    
    [self.icon1 setImage:[UIImage imageNamed:@"usericon.png"]];
    [self.icon2 setImage:[UIImage imageNamed:@"groupicon.png"]];
    [self.icon3 setImage:[UIImage imageNamed:@"idicon.png"]];
    
}

@end
