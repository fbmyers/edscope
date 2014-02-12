//
//  CaptureViewController.h
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImage+Resize.h"
#import "CameraScrollView.h"
#import "Pictures.h"
#import "Sessions.h"
#import "PhotoBrowserViewController.h"
#import "InfoBarView.h"
#import "CellScopeContext.h"

@interface CaptureViewController : UIViewController <UIAlertViewDelegate>

@property (strong,nonatomic) Sessions* currentSession;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (nonatomic) AVCaptureVideoOrientation previewOrientation;
@property (nonatomic) CGAffineTransform previewTransform;

@property (weak,nonatomic) IBOutlet CameraScrollView* cameraScrollView;
@property (weak,nonatomic) IBOutlet UIButton* backButton;
@property (weak,nonatomic) IBOutlet UIButton* freezeButton;
@property (weak,nonatomic) IBOutlet UIButton* snapButton;
@property (weak,nonatomic) IBOutlet UIButton* browseButton;
@property (weak, nonatomic) IBOutlet UIButton* focusLockButton;
@property (weak, nonatomic) IBOutlet UIButton* exposureLockButton;
@property (weak, nonatomic) IBOutlet UIButton* videoModeButton;
@property (weak, nonatomic) IBOutlet UIButton* photoModeButton;
@property (weak, nonatomic) IBOutlet UILabel *stopwatchLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *savingVideoIndicator;

@property (strong,nonatomic) NSTimer* stopwatchTimer;

@property (strong,nonatomic) InfoBarView* infoBarView;


- (IBAction)didPressSnap:(id)sender;
- (IBAction)didToggleFreeze:(id)sender;
- (IBAction)didToggleAutoFocus:(id)sender;
- (IBAction)didToggleAutoExposure:(id)sender;
- (IBAction)didDoubleTap:(id)sender;
- (IBAction)didPressBack:(id)sender;
- (IBAction)didPressVideoOrPhoto:(id)sender;

- (void)captureCompletedCallback;
- (void)saveMediaWithType:(CSCaptureMode)mode
                    title:(NSString*)newTitle;
- (void)updateFocusAndExposureButtons;
- (void)updateStopwatch;

//AVCaptureFileOutputRecordingDelegate methods
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error;

@end
