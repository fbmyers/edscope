//
//  CaptureViewController.m
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "CaptureViewController.h"

@implementation CaptureViewController

@synthesize currentSession,locationManager;
@synthesize cameraScrollView,backButton,snapButton,freezeButton,browseButton,videoModeButton,photoModeButton,stopwatchTimer,stopwatchLabel,savingVideoIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //function that handles when a new image has been captured
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureCompletedCallback)
                                                 name:@"ImageCaptured" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureCompletedCallback)
                                                 name:@"VideoCaptured" object:nil];
    
    
    NSString* mirroring = [[NSUserDefaults standardUserDefaults] stringForKey:@"Mirroring"];
    NSString* captureOrientation = [[NSUserDefaults standardUserDefaults] stringForKey:@"CaptureOrientation"];
    //CGAffineTransform transform;
    //AVCaptureVideoOrientation orientation;
    
    if ([mirroring isEqualToString:@"MirrorX"])
        self.previewTransform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0);
    else if ([mirroring isEqualToString:@"MirrorY"])
        self.previewTransform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    else if ([mirroring isEqualToString:@"MirrorXY"])
        self.previewTransform = CGAffineTransformMake(-1, 0, 0, -1, 0, 0);
    else
        self.previewTransform = CGAffineTransformIdentity; //no mirroring
    
    if ([captureOrientation isEqualToString:@"LandscapeLeft"])
        self.previewOrientation = AVCaptureVideoOrientationLandscapeLeft;
    else if ([captureOrientation isEqualToString:@"LandscapeRight"])
        self.previewOrientation = AVCaptureVideoOrientationLandscapeRight;
    else if ([captureOrientation isEqualToString:@"PortraitUpsideDown"])
        self.previewOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    else
        self.previewOrientation = AVCaptureVideoOrientationPortrait;
        
    
    //set up camera scroll view for photo acquisition
    [cameraScrollView setupCameraWithMode:CSCaptureModePhoto
                              Orientation:self.previewOrientation
                                transform:self.previewTransform];
    
    [cameraScrollView setBouncesZoom:YES];
    [cameraScrollView setBounces:YES];
    [cameraScrollView setMaximumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MaximumZoom"]];
    [cameraScrollView setMinimumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]];

    [cameraScrollView setBackgroundColor:[UIColor blackColor]];
    [cameraScrollView setExposureLock:[[NSUserDefaults standardUserDefaults] boolForKey:@"ExposureLockDefault"]];
    [cameraScrollView setFocusLock:[[NSUserDefaults standardUserDefaults] boolForKey:@"FocusLockDefault"]];
    
    [cameraScrollView addScaleBarWithLocation:CGPointMake(700,680)
                                    minLength:100
                                    maxLength:250
                                  pixelsPerMM:[[NSUserDefaults standardUserDefaults] floatForKey:@"PixelsPerMMPhotoPreview"]
                              snapLengthsInMM:@[@0.01,@0.02,@0.05,@0.1,@0.2,@0.5,@1.0,@2.0]
                                        color:[UIColor whiteColor]
                                    lineWidth:3
                                     fontSize:20
                                  showMicrons:YES];
    
    [self updateFocusAndExposureButtons];
    [self updatePhotoVideoModeButtons];
    
    [self.stopwatchLabel setHidden:YES];
    
    //set up info bar at bottom of screen
    self.infoBarView = [InfoBarView makeInfoBarInView:self.view];
    
    //set up location manager for geotagging photos
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [locationManager startUpdatingLocation];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [cameraScrollView setZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"] animated:NO];
    
    //prevent sleep mode while we are capturing images
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //the info bar is different during capture (shows user/group instead of flickr account)
    [self.infoBarView setStudentName:[[CellScopeContext sharedContext] studentName]
                           groupName:[[CellScopeContext sharedContext] groupName]
                         cellScopeID:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [super viewWillDisappear:animated];
}

- (IBAction)didPressSnap:(id)sender;
{
    if (cameraScrollView.captureMode==CSCaptureModePhoto)
        [cameraScrollView grabImage];
    else if (cameraScrollView.captureMode==CSCaptureModeVideo)
    {
        if (cameraScrollView.isRecording)
        {
            [cameraScrollView stopVideoRecording];
            [self.stopwatchTimer invalidate];
            [UIView animateWithDuration:0.25 animations:^{ //while it's saving, don't let the user press button again
                [snapButton setEnabled:NO];
                [snapButton setAlpha:0.4];
                [stopwatchLabel setAlpha:0.4];
                [savingVideoIndicator startAnimating];
            } completion:^(BOOL finished) { }];
        }
        else
        {
            //lock down the UI,switch rec button to stop button and display the stopwatch
            [UIView animateWithDuration:0.25 animations:^{
                [videoModeButton setEnabled:NO];
                [videoModeButton setAlpha:0.4];
                [photoModeButton setEnabled:NO];
                [photoModeButton setAlpha:0.4];
                [backButton setEnabled:NO];
                [backButton setAlpha:0.4];
                [browseButton setEnabled:NO];
                [browseButton setAlpha:0.4];
                [stopwatchLabel setText:@"00:00"];
                [stopwatchLabel setHidden:NO];
                [snapButton setImage:[UIImage imageNamed:@"stopbutton.png"] forState:UIControlStateNormal];
            } completion:^(BOOL finished) { }];
            

            //start recording video
            [cameraScrollView startVideoRecording];
            
            //start a timer to update a stopwatch which shows recording duration
            self.stopwatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateStopwatch)
                                           userInfo:nil
                                            repeats:YES];
        }
    }
}

- (void) updateStopwatch
{
    CMTime duration = cameraScrollView.movieOutput.recordedDuration;
    unsigned int totalSeconds = floor(CMTimeGetSeconds(duration));
    unsigned int minutes = floor(totalSeconds/60);
    unsigned int seconds = floor(totalSeconds%60);
    
    NSString* stopwatchString = [NSString stringWithFormat:@"%02i:%02i",minutes,seconds];
    
    [stopwatchLabel setText:stopwatchString];
    
    totalSeconds++;
    
}

- (IBAction)didDoubleTap:(id)sender
{
    //[self.cameraScrollView zoomExtentsWithAnimation:YES];
    [self.cameraScrollView setZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"] animated:YES];
    //TODO: need to also recenter scrolls, and this should be a built-in function in CSV
}

- (void) captureCompletedCallback
{
    NSLog(@"capture completed, saving...");
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PromptForTitle"])
    {
        NSString* alertTitle;
        NSString* alertMessage;
        if (cameraScrollView.captureMode==CSCaptureModePhoto)
        {
            alertTitle = @"New Photo";
            alertMessage = @"Enter a title for this photo:";
        }
        else if (cameraScrollView.captureMode==CSCaptureModeVideo)
        {
            alertTitle = @"New Video";
            alertMessage = @"Enter a title for this video:";
        }
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                         message:alertMessage
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag=1;
        [alert show];
    }
    else
    {
        [self saveMediaWithType:cameraScrollView.captureMode
                          title:@""];
    }
}

- (void) saveMediaWithType:(CSCaptureMode)mode
                     title:(NSString*)newTitle
{
    NSLog(@"did get video/image title");
    //this is not the best way to handle data exchange betwen CSV and CVC, should use a delegate
    NSMutableDictionary* metadata = cameraScrollView.lastImageMetadata;
    UIImage* image = cameraScrollView.lastCapturedImage;
    NSURL* videoURL = cameraScrollView.lastCapturedVideoURL;
    
    //increment the picture counter
    long pictureNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"PictureCount"] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:pictureNumber forKey:@"PictureCount"];
    
    //set EXIF metadata, geotagging, etc.
    [metadata setDateOriginal:[NSDate date]]; //set the date captured
    [metadata setLocation:[locationManager location]];
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"CaptureOrientation"] isEqualToString:@"Portrait"] ||
        [[[NSUserDefaults standardUserDefaults] stringForKey:@"CaptureOrientation"] isEqualToString:@"PortraitUpsideDown"])
        [metadata setImageOrientation:UIImageOrientationLeft];
    
    [metadata setCellScopeVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                      studentName:[[CellScopeContext sharedContext] studentName]
                        groupName:[[CellScopeContext sharedContext] groupName]
                     locationName:[[NSUserDefaults standardUserDefaults] stringForKey:@"Location"]
                      cellScopeID:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"]
                    magnification:[[NSUserDefaults standardUserDefaults] stringForKey:@"Magnification"]
                      pixelsPerMM:[[NSUserDefaults standardUserDefaults] floatForKey:@"PixelsPerMMPhoto"]
                    pictureNumber:pictureNumber];
    
    //this will get called after video/photo is saved (those functions are called below)
    void (^doneSavingInAssetLibrary)(NSURL*,NSError*) =
    ^(NSURL* assetURL, NSError* error)
    {
        if (error) {
            NSLog(@"Error writing video/image to photo album");
        }
        else {
            NSLog(@"did save video/image");
            
            //create and store a new session object if one hasn't been created yet
            if (self.currentSession==nil || self.currentSession.managedObjectContext==nil) //note that managedObjectContext will be nil if this session was deleted (because all photos were deleted)
            {
                Sessions* newSession = (Sessions *)[NSEntityDescription insertNewObjectForEntityForName:@"Sessions" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
                
                newSession.date = [NSDate timeIntervalSinceReferenceDate];
                newSession.student = [[CellScopeContext sharedContext] studentName];
                newSession.group = [[CellScopeContext sharedContext] groupName];
                newSession.cellscopeID = [[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"];
                newSession.location = [[NSUserDefaults standardUserDefaults] stringForKey:@"Location"];
                
                self.currentSession = newSession;
            }
            
            //if this was a video, grab the first frame (this should be done within CSV)
            UIImage* thumbImage;
            if (mode==CSCaptureModeVideo)
            {
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:assetURL options:nil];
                AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                NSError *err = NULL;
                CMTime time = CMTimeMake(1, 60);
                CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
                NSLog(@"err==%@, imageRef==%@", err, imgRef);
            
                thumbImage = [[UIImage alloc] initWithCGImage:imgRef];
            }
            else
                thumbImage = image;
            
            //add this picture and its thumbnail to core data
            float thumbSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"ThumbnailSize"];
            UIImage* thumbnail = [thumbImage thumbnailImage:thumbSize
                                     transparentBorder:1.0
                                          cornerRadius:10.0
                                  interpolationQuality:kCGInterpolationDefault];
            
            // Set up a Pictures entry to store in Core Data
            Pictures* newPicture = (Pictures *)[NSEntityDescription insertNewObjectForEntityForName:@"Pictures" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
            
            newPicture.path = assetURL.absoluteString;
            newPicture.number = pictureNumber;
            newPicture.title = newTitle;
            newPicture.notes = @"";
            if (mode==CSCaptureModePhoto)
            {
                newPicture.type = @"Photo";
                newPicture.pixelsPerMM = [[NSUserDefaults standardUserDefaults] floatForKey:@"PixelsPerMMPhoto"];
            }
            else if (mode==CSCaptureModeVideo)
            {
                newPicture.type = @"Video";
                newPicture.pixelsPerMM = [[NSUserDefaults standardUserDefaults] floatForKey:@"PixelsPerMMVideo"];
            }
            else if (mode==CSCaptureModeTimelapse)
            {
                newPicture.type = @"Timelapse";
                newPicture.pixelsPerMM = [[NSUserDefaults standardUserDefaults] floatForKey:@"PixelsPerMMPhoto"];
            }
            newPicture.date = [NSDate timeIntervalSinceReferenceDate];
            newPicture.magnification = [[NSUserDefaults standardUserDefaults] stringForKey:@"Magnification"];
            newPicture.thumbnail = UIImagePNGRepresentation(thumbnail);
            newPicture.gps = [[locationManager location] description];
            
            /*
             note: there is a bug in the apple generated code, if you change the CD schema,
             be sure to replace the addPicturesObject method with the following code, or you will get a crash at this point:
             - (void)addPicturesObject:(SubItem *)value {
             NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.subitems];
             [tempSet addObject:value];
             self.subitems = tempSet;
             }
             */
            [self.currentSession addPicturesObject:newPicture];

            if (![[[CellScopeContext sharedContext] managedObjectContext] save:&error]) {
                NSLog(@"Failed to add new picture with error: %@", [error domain]);
            }
            
        }
        
        //TODO: this will be unnecessary if I use similar convention with imaging as I do with video
        cameraScrollView.lastCapturedImage = nil;
        cameraScrollView.lastImageMetadata = nil;
        
        //unlock the UI
        [UIView animateWithDuration:0.25 animations:^{
            [videoModeButton setEnabled:YES];
            [videoModeButton setAlpha:1.0];
            [photoModeButton setEnabled:YES];
            [photoModeButton setAlpha:1.0];
            [backButton setEnabled:YES];
            [backButton setAlpha:1.0];
            [browseButton setEnabled:YES];
            [browseButton setAlpha:1.0];
            [stopwatchLabel setHidden:YES];
            [stopwatchLabel setAlpha:1.0];
            [snapButton setEnabled:YES];
            [snapButton setAlpha:1.0];
            
            if (mode==CSCaptureModeVideo)
            {
                [snapButton setImage:[UIImage imageNamed:@"recordbutton.png"] forState:UIControlStateNormal];
                [savingVideoIndicator stopAnimating];
            }
        } completion:^(BOOL finished) { }];
        
    };
    
    //save the photo/video to the asset library, then call the completion handler (above) which saves to core data
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (mode==CSCaptureModePhoto)
    {
        NSLog(@"storing image to asset library");
        [library writeImageToSavedPhotosAlbum:image.CGImage
                                     metadata:metadata
                              completionBlock:doneSavingInAssetLibrary];
    }
    else if (mode==CSCaptureModeVideo)
    {
        NSLog(@"Storing video in the asset library...");
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:videoURL
                                        completionBlock:doneSavingInAssetLibrary];
        }
    }

    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) //this is the title prompt for new photo/video
    {
        [self saveMediaWithType:cameraScrollView.captureMode
                          title:[[alertView textFieldAtIndex:0] text]];
    }
    else if (alertView.tag==2) //this is the "are you sure you want to end session" prompt
    {
        if (buttonIndex==1) //YES button
            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)didToggleFreeze:(id)sender;
{
    if (cameraScrollView.previewRunning)
    {
        [cameraScrollView stopPreview];
        
        [UIView animateWithDuration:0.25 animations:^{
             [self.freezeButton setImage:[UIImage imageNamed:@"livebutton.png"] forState:UIControlStateNormal];
             [self.snapButton setEnabled:NO];
             [self.snapButton setAlpha:0.4];
        } completion:^(BOOL finished) { }];
    }
    else
    {
        [cameraScrollView startPreview];
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.freezeButton setImage:[UIImage imageNamed:@"freezebutton.png"] forState:UIControlStateNormal];
            [self.snapButton setEnabled:YES];
            [self.snapButton setAlpha:1.0];
        } completion:^(BOOL finished) { }];
    }
}

- (IBAction)didPressBack:(id)sender
{
    //alert the user that going back will end their session
    NSString* alertMessage;
    if ([[[CellScopeContext sharedContext] studentName] isEqualToString:@""])
        alertMessage = @"This will end your current session.  Are you sure?";
    else
        alertMessage = [NSString stringWithFormat:@"This will end %@'s session.  Are you sure?",[[CellScopeContext sharedContext] studentName]];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"End Session" message:alertMessage delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = 2;
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
    
}

- (IBAction)didToggleAutoExposure:(id)sender
{
    if (cameraScrollView.isExposureLocked)
        [cameraScrollView setExposureLock:NO];
    else
        [cameraScrollView setExposureLock:YES];
    [self updateFocusAndExposureButtons];
}

- (IBAction)didToggleAutoFocus:(id)sender
{
    if (cameraScrollView.isFocusLocked)
        [cameraScrollView setFocusLock:NO];
    else
        [cameraScrollView setFocusLock:YES];
    [self updateFocusAndExposureButtons];
}

- (void)updateFocusAndExposureButtons
{
    if (cameraScrollView.isExposureLocked)
    {
        [self.exposureLockButton setTitle:@"AE Off" forState:UIControlStateNormal];
        [self.exposureLockButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.exposureLockButton setTitle:@"AE On" forState:UIControlStateNormal];
        [self.exposureLockButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    
    if (cameraScrollView.isFocusLocked)
    {
        [self.focusLockButton setTitle:@"AF Off" forState:UIControlStateNormal];
        [self.focusLockButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.focusLockButton setTitle:@"AF On" forState:UIControlStateNormal];
        [self.focusLockButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
}

- (IBAction)didPressVideoOrPhoto:(id)sender
{
    if (sender==photoModeButton && cameraScrollView.captureMode!=CSCaptureModePhoto)
    {

        [cameraScrollView setMinimumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]];
        [cameraScrollView setupCameraWithMode:CSCaptureModePhoto
                                  Orientation:self.previewOrientation
                                    transform:self.previewTransform];
        
        cameraScrollView.scrollBarView.pixelsPerMM = [[NSUserDefaults standardUserDefaults] floatForKey:@"PixelsPerMMPhotoPreview"];

        [UIView animateWithDuration:0.25 animations:^{
            [snapButton setImage:[UIImage imageNamed:@"snapbutton.png"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) { }];

        
    }
    else if (sender==videoModeButton && cameraScrollView.captureMode!=CSCaptureModeVideo)
    {
        [cameraScrollView setMinimumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.82];
        [cameraScrollView setupCameraWithMode:CSCaptureModeVideo
                                  Orientation:self.previewOrientation
                                    transform:self.previewTransform];

        
        cameraScrollView.scrollBarView.pixelsPerMM = [[NSUserDefaults standardUserDefaults] floatForKey:@"PixelsPerMMVideo"];
        [UIView animateWithDuration:0.25 animations:^{
            [snapButton setImage:[UIImage imageNamed:@"recordbutton.png"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) { }];
    }
    
    [self updatePhotoVideoModeButtons];
}

- (void)updatePhotoVideoModeButtons
{
    if (cameraScrollView.captureMode==CSCaptureModePhoto)
    {
        [self.photoModeButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [self.videoModeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
    }
    else if (cameraScrollView.captureMode==CSCaptureModeVideo)
    {
        [self.photoModeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.videoModeButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
}



@end
