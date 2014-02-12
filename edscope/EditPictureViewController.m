//
//  EditPictureViewController.m
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "EditPictureViewController.h"

@implementation EditPictureViewController

@synthesize nameLabel,groupLabel,locationLabel,cellScopeIDLabel,magnificationLabel,typeLabel,dateLabel,pictureNumberLabel,titleField,notesTextArea,sharedLabel,viewOnFlickrButton,imageView;

@synthesize currentPicture;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

    NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:currentPicture.date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
    NSString* dateString = [dateFormatter stringFromDate:date];
    
    self.nameLabel.text = currentPicture.session.student;
    self.groupLabel.text = currentPicture.session.group;
    self.locationLabel.text = currentPicture.session.location;
    self.cellScopeIDLabel.text = currentPicture.session.cellscopeID;
    self.magnificationLabel.text = currentPicture.magnification;
    self.typeLabel.text = currentPicture.type;
    //TODO: if timelapse, handle interval
    self.dateLabel.text = dateString;
    self.pictureNumberLabel.text = [NSString stringWithFormat:@"%d",currentPicture.number];
    self.titleField.text = currentPicture.title;
    self.notesTextArea.text = currentPicture.notes;
    self.sharedLabel.text = (currentPicture.uploadState==2) ? @"YES" : @"NO";
    
    if (currentPicture.uploadState==2)
        [self.viewOnFlickrButton setHidden:NO];
    else
        [self.viewOnFlickrButton setHidden:YES];
    
    UIImage* thumbImage = [UIImage imageWithData:currentPicture.thumbnail];
    [imageView setImage:thumbImage];
    
    if ([currentPicture.type isEqualToString:@"Video"])
    {
        imageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        imageView.transform = CGAffineTransformScale(imageView.transform, 1.0, -1.0); //this is actually a fxn of mirroring
    }
    else if ([currentPicture.type isEqualToString:@"Photo"])
    {
        imageView.transform = CGAffineTransformMakeRotation(M_PI);
        imageView.transform = CGAffineTransformScale(imageView.transform, -1.0, 1.0); //this is actually a fxn of mirroring
    }
    
    //TODO: GPS
}

- (void)viewWillDisappear:(BOOL)animated
{
    currentPicture.title = self.titleField.text;
    currentPicture.notes = self.notesTextArea.text;
    [currentPicture.managedObjectContext save:nil];
    
    [[self presentingViewController] viewDidAppear:YES]; //this causes the label to refresh in the photo viewer
    
    [super viewWillDisappear:animated];
}

- (void)didPressViewOnFlickr:(id)sender
{
    NSLog(@"loading flickr photo w/ ID: %@ and userID: %@",currentPicture.flickrID, [[CellScopeContext sharedContext] flickrUserID]);

    NSString* flickrURL = [NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@",
                           [[CellScopeContext sharedContext] flickrUserID],
                           currentPicture.flickrID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:flickrURL]];
    
}

- (IBAction)didPressDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
