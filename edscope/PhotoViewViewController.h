//
//  PhotoViewViewController.h
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FlickrKit.h"
#import "FKDUReachability.h"
#import "CellScopeContext.h"
#import "Pictures.h"
#import "Sessions.h"
#import "CameraScrollView.h"
#import "InfoBarView.h"
#import "EditPictureViewController.h"

@interface PhotoViewViewController : UIViewController

@property (strong,nonatomic) Pictures* currentPicture;
@property (strong,nonatomic) UIImage* image;

@property (weak,nonatomic) IBOutlet CameraScrollView* cameraScrollView;
@property (weak,nonatomic) IBOutlet UIProgressView* progressView;
@property (weak,nonatomic) IBOutlet UILabel* titleLabel;
@property (weak,nonatomic) IBOutlet UILabel* uploadingLabel;
@property (weak,nonatomic) IBOutlet UIButton* uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelUploadButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *loopButton;
@property (weak, nonatomic) IBOutlet UISlider *playbackLocationSlider;
@property (strong,nonatomic) NSTimer* playbackSliderUpdateTimer;
@property (strong,nonatomic) InfoBarView* infoBarView;

@property (nonatomic, retain) FKImageUploadNetworkOperation *uploadOp;
@property (nonatomic, retain) NSString *userID;

- (IBAction)didPressDelete:(id)sender;
- (IBAction)didPressUpload:(id)sender;
- (IBAction)didPressBack:(id)sender;
- (IBAction)didPressPlay:(id)sender;
- (IBAction)didPressLoop:(id)sender;
- (IBAction)didMovePlaybackSlider:(id)sender;
- (IBAction)didPressCancelUpload:(id)sender;

- (void)deletePhoto;
- (void)updatePlaybackSliderPosition;
- (void) stopPlaybackSliderUpdateTimer;
- (void) startPlaybackSliderUpdateTimer;

@end
