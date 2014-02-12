//
//  PhotoViewViewController.m
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "PhotoViewViewController.h"

@interface PhotoViewViewController ()
@end

@implementation PhotoViewViewController

@synthesize cameraScrollView,currentPicture,image,progressView,playbackLocationSlider,playButton,playbackSliderUpdateTimer,loopButton,cancelUploadButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"loading photo viewer");
    
    [cameraScrollView setBouncesZoom:YES];
    [cameraScrollView setBounces:YES];
    [cameraScrollView setMaximumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MaximumZoom"]];
    [cameraScrollView setMinimumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.91];

    [cameraScrollView setBackgroundColor:[UIColor blackColor]];
    
    
    self.infoBarView = [InfoBarView makeInfoBarInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.progressView setHidden:YES];
    [self.uploadingLabel setHidden:YES];
    [self.cancelUploadButton setHidden:YES];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if ([FlickrKit sharedFlickrKit].isAuthorized && [FKDUReachability isConnected])
    {
        [self.uploadButton setEnabled:YES];
        [self.uploadButton setAlpha:1.0];
    }
    else
    {
        [self.uploadButton setEnabled:NO];
        [self.uploadButton setAlpha:0.4];
    }

    //setup scrollview orientation
    //this orientation business is so frustrating...nothing seems consistent
    if ([currentPicture.type isEqualToString:@"Photo"])
    {
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"CaptureOrientation" ] isEqualToString:@"Portrait"] ||
            [[[NSUserDefaults standardUserDefaults] stringForKey:@"CaptureOrientation" ] isEqualToString:@"PortraitUpsideDown"])
        {
            cameraScrollView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            cameraScrollView.transform = CGAffineTransformScale(cameraScrollView.transform, 1.0, -1.0);
        }
        else
        {
            cameraScrollView.transform = CGAffineTransformMakeRotation(M_PI_2);

        }
    }
    else if ([currentPicture.type isEqualToString:@"Video"])
    {
        cameraScrollView.transform = CGAffineTransformScale(cameraScrollView.transform, 1.0, -1.0);
    }
    
    
    //scale bar
    [cameraScrollView addScaleBarWithLocation:CGPointMake(700,680)
                                    minLength:100
                                    maxLength:250
                                  pixelsPerMM:currentPicture.pixelsPerMM
                              snapLengthsInMM:@[@0.01,@0.02,@0.05,@0.1,@0.2,@0.5,@1.0,@2.0]
                                        color:[UIColor whiteColor]
                                    lineWidth:3
                                     fontSize:20
                                  showMicrons:YES];
    
    //load the image
    NSURL *aURL = [NSURL URLWithString:currentPicture.path];
    
    NSLog(@"displaying image at: %@",currentPicture.path);
    
    if ([currentPicture.type isEqualToString:@"Photo"])
    {

        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             ALAssetRepresentation* rep = [asset defaultRepresentation];
             CGImageRef iref = [rep fullResolutionImage];
             
             image = [UIImage imageWithCGImage:iref];
             
             
             [cameraScrollView showImage:image];
             
             [cameraScrollView setZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.91 animated:NO];
             [cameraScrollView setMinimumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.91];
             [cameraScrollView setContentOffset:CGPointMake(250,0) animated:NO];


         }
         failureBlock:^(NSError *error)
         {
             // error handling
             NSLog(@"failure loading video/image from AssetLibrary");
         }];
        
        [playButton setHidden:YES];
        [loopButton setHidden:YES];
        [playbackLocationSlider setHidden:YES];
    }
    else if ([currentPicture.type isEqualToString:@"Video"])
    {
        
        [cameraScrollView loadVideoFromFile:aURL completionAction:^{

            
            NSLog(@"video loaded, updating UI");
            [cameraScrollView setZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.82 animated:NO];
            [cameraScrollView setMinimumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.82];
            [cameraScrollView setContentOffset:CGPointMake(130,76) animated:NO];

            
            self.playbackLocationSlider.maximumValue = CMTimeGetSeconds(cameraScrollView.playerItem.duration);
            self.playbackLocationSlider.value = 0.0;
            
            [playButton setHidden:NO];
            [loopButton setHidden:NO];
            [playbackLocationSlider setHidden:NO];
                        

        }];
        

    }
    
    //update the info bar
    [self refreshInfoBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.cameraScrollView.player!=nil)
        [self.cameraScrollView pauseVideo];
        
    [self stopPlaybackSliderUpdateTimer];
}

//this is a bit of a kludge, but the edit page will call this method when it
//dismisses so that the title/other metadata updates, but the picture
//doesn't have to reload
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.titleLabel setText:currentPicture.title];
    
}

- (void)refreshInfoBar
{
    NSString* flickrNameToDisplay;
    if ([FKDUReachability isConnected])
        flickrNameToDisplay = [[CellScopeContext sharedContext] flickrUsername];
    else
        flickrNameToDisplay = @"Offline";
    
    [self.infoBarView setFlickrUsername:flickrNameToDisplay
                            cellScopeID:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"]];
}

- (IBAction)didPressDelete:(id)sender
{
    UIAlertView* alert;
    if ([currentPicture.type isEqualToString:@"Video"])
        alert = [[UIAlertView alloc] initWithTitle:@"Delete Video" message:@"Are you sure?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    else if ([currentPicture.type isEqualToString:@"Photo"])
        alert = [[UIAlertView alloc] initWithTitle:@"Delete Photo" message:@"Are you sure?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    else if ([currentPicture.type isEqualToString:@"Timelapse"])
        alert = [[UIAlertView alloc] initWithTitle:@"Delete Timelapse" message:@"Are you sure?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
    alert.tag = 1;
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) //this is our delete alert
    {
        if (buttonIndex==1) //YES BUTTON
            [self deletePhoto];
    }
}

- (void)deletePhoto
{
    NSLog(@"deleting photo");
    
    //if this session only has one photo, delete the whole session
    if (currentPicture.session.pictures.count==1)
        [[[CellScopeContext sharedContext] managedObjectContext] deleteObject:currentPicture.session];
    else
        [[[CellScopeContext sharedContext] managedObjectContext] deleteObject:currentPicture];
    
    [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
        
    [self.navigationController popViewControllerAnimated:YES];
}

//alternative implementation using NSData
- (IBAction)didPressUpload:(id)sender
{
    NSLog(@"attempting to upload to flickr");
    //attempt to upload this photo to flickr
    //TODO: queue for multiple uploads
    
    currentPicture.uploadState = 1; //signifies that this photo is marked for uploading
    [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
    
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:currentPicture.date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
    NSString* dateString = [dateFormatter stringFromDate:date];
    
    NSString* flickrDescription = [NSString stringWithFormat:@"%@\n\nName: %@\nGroup/Class: %@\nLocation: %@\nCellScope ID: %@\nDate Taken: %@",
                                   currentPicture.notes,
                                   currentPicture.session.student,
                                   currentPicture.session.group,
                                   currentPicture.session.location,
                                   currentPicture.session.cellscopeID,
                                   dateString];
    
    NSMutableDictionary* uploadArgs = [[NSMutableDictionary alloc] init];
    
    //Flickr rejects empty titles (very weird), so don't include title in the arguments if it is ""
    if (!([currentPicture.title isEqualToString:@""]))
        [uploadArgs setObject:currentPicture.title forKey:@"title"];
    
    [uploadArgs setObject:flickrDescription forKey:@"description"];
    
    NSString* privacySetting = [[NSUserDefaults standardUserDefaults] stringForKey:@"FlickrPrivacy"];
    
    if ([privacySetting isEqualToString:@"Public"])
    {
            [uploadArgs setObject:@"1" forKey:@"is_public"];
            [uploadArgs setObject:@"1" forKey:@"is_friend"];
            [uploadArgs setObject:@"1" forKey:@"is_family"];
            [uploadArgs setObject:@"1" forKey:@"hidden"];
    }
    else if ([privacySetting isEqualToString:@"FriendsFamily"])
    {
            [uploadArgs setObject:@"0" forKey:@"is_public"];
            [uploadArgs setObject:@"1" forKey:@"is_friend"];
            [uploadArgs setObject:@"1" forKey:@"is_family"];
            [uploadArgs setObject:@"1" forKey:@"hidden"];
    }
    else //Private
    {
            [uploadArgs setObject:@"0" forKey:@"is_public"];
            [uploadArgs setObject:@"0" forKey:@"is_friend"];
            [uploadArgs setObject:@"0" forKey:@"is_family"];
            [uploadArgs setObject:@"2" forKey:@"hidden"];
    }


    [uploadArgs setObject:[NSString stringWithFormat:@"\"%@\" \"%@\" \"%@\" \"%@\" \"%@\"",
                           @"CellScope",
                           currentPicture.session.student,
                           currentPicture.session.group,
                           currentPicture.session.location,
                           currentPicture.session.cellscopeID]
                   forKey:@"tags"];
    
    //get the file from asset library as an NSData object
    NSURL *aURL = [NSURL URLWithString:currentPicture.path];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         NSUInteger size = (NSUInteger)rep.size;
         NSMutableData *imageData = [NSMutableData dataWithLength:size];
         NSError *error;
         [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
         
         //now asynchronously upload this image data
         self.uploadOp =  [[FlickrKit sharedFlickrKit] uploadImageWithData:imageData args:uploadArgs completion:^(NSString *imageID, NSError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                 } else {
                     if (currentPicture!=nil && currentPicture.managedObjectContext!=nil) //necessary because photo might have been deleted during upload
                     {
                         currentPicture.flickrID = imageID;
                         currentPicture.uploadState = 2; //photo has been uploaded
                         [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
                     }
                     NSString *msg = @"Upload Complete.";
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                 }
                 [self.uploadOp removeObserver:self forKeyPath:@"uploadProgress" context:NULL];
                 
                 [UIView animateWithDuration:0.25 animations:^{
                     [self.progressView setHidden:YES];
                     [self.uploadingLabel setHidden:YES];
                     [self.cancelUploadButton setHidden:YES];
                     [self.uploadButton setEnabled:YES];
                     [self.uploadButton setAlpha:1.0];
                 } completion:^(BOOL finished) { }];
                 
             });
         }];
         [self.uploadOp addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew context:NULL];
         
         //gray out the upload button so they don't try to do two concurrent uploads of same image
         [UIView animateWithDuration:0.25 animations:^{
             [self.progressView setHidden:NO];
             [self.uploadingLabel setHidden:NO];
             [self.cancelUploadButton setHidden:NO];
             [self.progressView setProgress:0.0];
             [self.uploadButton setEnabled:NO];
             [self.uploadButton setAlpha:0.4];
             
         } completion:^(BOOL finished) { }];
         
     }
            failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"failure loading image from AssetLibrary");
     }];
    

}

- (IBAction)didPressCancelUpload:(id)sender
{
    //cancel the upload operation and remove the progress observer
    [self.uploadOp cancel];
    [self.uploadOp removeObserver:self forKeyPath:@"uploadProgress" context:NULL];
    
    //switch upload state back to "not uploaded"
    currentPicture.uploadState = 0; //photo has been uploaded
    [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
    
    //reset the UI
    [UIView animateWithDuration:0.25 animations:^{
        [self.progressView setHidden:YES];
        [self.uploadingLabel setHidden:YES];
        [self.cancelUploadButton setHidden:YES];
        [self.uploadButton setEnabled:YES];
        [self.uploadButton setAlpha:1.0];
    } completion:^(BOOL finished) { }];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressPlay:(id)sender
{
    if (self.cameraScrollView.isPlaying)
    {
        [self.cameraScrollView pauseVideo];
        [self stopPlaybackSliderUpdateTimer];
        [UIView animateWithDuration:0.25 animations:^{
            [self.playButton setImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
         } completion:^(BOOL finished) { }];
    }
    else
    {
        [self.cameraScrollView playVideo];
        [self startPlaybackSliderUpdateTimer];
        [UIView animateWithDuration:0.25 animations:^{
            [self.playButton setImage:[UIImage imageNamed:@"pausebutton"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) { }];
    }
}

- (IBAction)didPressLoop:(id)sender
{
    if (self.cameraScrollView.doPlaybackLoop)
    {
        self.cameraScrollView.doPlaybackLoop = NO;
        [UIView animateWithDuration:0.25 animations:^{
            [self.loopButton setAlpha:0.4];
        }
        completion:^(BOOL finished) { }];
    }
    else
    {
        self.cameraScrollView.doPlaybackLoop = YES;
        [UIView animateWithDuration:0.25 animations:^{
            [self.loopButton setAlpha:1.0];
        }
        completion:^(BOOL finished) { }];
    }
}

- (void)updatePlaybackSliderPosition
{
    NSLog(@"updating");
    self.playbackLocationSlider.value = CMTimeGetSeconds(self.cameraScrollView.playerItem.currentTime);
    
    if (!self.cameraScrollView.isPlaying)
    {
        [self stopPlaybackSliderUpdateTimer];

        [UIView animateWithDuration:0.25 animations:^{
            [self.playButton setImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) { }];
    }
}

- (IBAction)didMovePlaybackSlider:(id)sender
{
    
    unsigned int timeNumerator = floor(playbackLocationSlider.value*cameraScrollView.playerItem.duration.timescale);
    
    [self.cameraScrollView seekToTime:CMTimeMake(timeNumerator,cameraScrollView.playerItem.duration.timescale)];
    
}

- (void) stopPlaybackSliderUpdateTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playbackSliderUpdateTimer invalidate];
        self.playbackSliderUpdateTimer = nil;
    });
}

- (void) startPlaybackSliderUpdateTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playbackSliderUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.033
                                                                          target:self
                                                                        selector:@selector(updatePlaybackSliderPosition)
                                                                        userInfo:nil
                                                                         repeats:YES];
    });
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        NSLog(@"progress: %f",progress);
        [self.progressView setProgress:progress];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditPictureSegue"])
    {
        EditPictureViewController* epvc = (EditPictureViewController*)[segue destinationViewController];
        epvc.currentPicture = self.currentPicture;
    }
}
@end
