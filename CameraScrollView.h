//
//  CameraScrollView.h
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "NSMutableDictionary+ImageMetadata.h"
#import "UIImage+Transform.h"
#import "ScrollBarView.h"
#import "MoviePlayerView.h"

@interface CameraScrollView : UIScrollView <UIScrollViewDelegate, AVCaptureFileOutputRecordingDelegate>

typedef NS_ENUM(NSInteger, CSCaptureMode) {
    CSCaptureModePhoto,
    CSCaptureModeVideo,
    CSCaptureModeTimelapse
};

typedef void (^VideoLoadCompletionBlock)(void);

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;

//stuff for movie playback
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic,strong) VideoLoadCompletionBlock videoCompletionBlock;

@property (strong,nonatomic) ScrollBarView* scrollBarView;
@property (strong,nonatomic) UIView* previewLayerView;
@property (strong,atomic) UIImage* lastCapturedImage;
@property (strong,atomic) NSMutableDictionary* lastImageMetadata;
@property (strong,atomic) NSURL* lastCapturedVideoURL;
@property (nonatomic) AVCaptureVideoOrientation orientation;
@property (nonatomic) CGAffineTransform transform;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL previewRunning;
@property (nonatomic) BOOL isFocusLocked;
@property (nonatomic) BOOL isExposureLocked;
@property (nonatomic) BOOL doPlaybackLoop;
@property (nonatomic) CSCaptureMode captureMode;

- (void) setupCameraWithMode:(CSCaptureMode)mode
                 Orientation:(AVCaptureVideoOrientation)orientation
                   transform:(CGAffineTransform)transform;

- (void) zoomExtentsWithAnimation:(BOOL)animated;
- (void) startPreview;
- (void) stopPreview;
- (void) grabImage;
- (void) startVideoRecording;
- (void) stopVideoRecording;
- (void) showImage:(UIImage*)image;
- (void) setExposureLock:(BOOL)locked;
- (void) setFocusLock:(BOOL)locked;

- (void) addScaleBarWithLocation:(CGPoint)location
                       minLength:(float)minLength
                       maxLength:(float)maxLength
                     pixelsPerMM:(float)pixelsPerMM
                 snapLengthsInMM:(NSArray*)snaps
                           color:(UIColor*)color
                       lineWidth:(float)lineWidth
                        fontSize:(float)fontSize
                     showMicrons:(BOOL)showMicrons;

//methods for movie playback
- (void)loadVideoFromFile:(NSURL*)fileURL
         completionAction:(VideoLoadCompletionBlock)completionBlock;

- (void)playVideo;
- (void)pauseVideo;
- (void)seekToTime:(CMTime)time;

@end
