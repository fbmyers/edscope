//
//  CameraScrollView.m
//  CellScope
//
//  Created by Frankie Myers on 11/7/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "CameraScrollView.h"

@implementation CameraScrollView

static const NSString *ItemStatusContext;

@synthesize session,device,input,stillOutput;
@synthesize previewLayerView,scrollBarView;
@synthesize previewRunning,isFocusLocked,isExposureLocked,isRecording,isPlaying,doPlaybackLoop;
@synthesize lastCapturedImage;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self setBouncesZoom:NO];
        [self setBounces:NO];
        [self setScrollEnabled:YES];
        [self setMaximumZoomScale:10.0];
        
        [self setShowsHorizontalScrollIndicator:YES];
        [self setShowsVerticalScrollIndicator:YES];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        
        [self setIsRecording:NO];
        [self setExposureLock:NO];
        [self setFocusLock:NO];
        [self setPreviewRunning:NO];
        [self setDoPlaybackLoop:NO];
        [self setCaptureMode:CSCaptureModePhoto];
    }
    return self;
}

- (void) setupCameraWithMode:(CSCaptureMode)mode
                 Orientation:(AVCaptureVideoOrientation)orientation
                   transform:(CGAffineTransform)transform
{
    
    if (previewLayerView!=nil)
        [previewLayerView removeFromSuperview];
    
    self.captureMode = mode;
    self.orientation = orientation;
    self.transform = transform;
    
    // Setup the AV foundation capture session
    self.session = [[AVCaptureSession alloc] init];
    if (self.captureMode==CSCaptureModePhoto)
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    else if (self.captureMode==CSCaptureModeVideo)
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Setup image preview layer (subview within this scrollview)
    CGRect frame = CGRectMake(0, 0, 2592, 1936); //TODO: grab the resolution from the camera?
    previewLayerView = [[UIView alloc] initWithFrame:frame];
    CALayer *viewLayer = previewLayerView.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.session];
    captureVideoPreviewLayer.frame = viewLayer.bounds;
    [viewLayer addSublayer:captureVideoPreviewLayer];
    [self addSubview:previewLayerView];
    [self sendSubviewToBack:previewLayerView];
    [self setContentSize:frame.size];

    //this is a kludge...will revise this
    if (orientation==AVCaptureVideoOrientationPortrait || orientation==AVCaptureVideoOrientationPortraitUpsideDown)
        [self setContentOffset:CGPointMake(750,550) animated:NO];
    
    //handles zoom events
    [self setDelegate:self];
    
    //apply transform
    [self setTransform:transform];
    
    // Setup still image output
    if (self.captureMode==CSCaptureModePhoto)
    {
        self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillOutput setOutputSettings:outputSettings];
        
        // Add session input and output
        [self.session addInput:self.input];
        [self.session addOutput:self.stillOutput];
    }
    else if (self.captureMode==CSCaptureModeVideo)
    {
        // Setup output
        self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        // Add session input and output
        [self.session addInput:self.input];
        [self.session addOutput:self.movieOutput];
    }
    
    [self setExposureLock:isExposureLocked];
    [self setFocusLock:isFocusLocked];
    
    [self startPreview];
    
    //handle orientation and mirroring
    AVCaptureConnection* previewLayerConnection = captureVideoPreviewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported])
    {
        [previewLayerConnection setVideoOrientation:orientation];
    }

    [self setZoomScale:self.minimumZoomScale animated:NO];
    
    //TODO: are these necessary?
    [previewLayerView setNeedsDisplay];
    [self setNeedsDisplay];
    
}

//not currently using this
- (void) zoomExtentsWithAnimation:(BOOL)animated
{
    float horizZoom = self.bounds.size.width / previewLayerView.bounds.size.width;
    float vertZoom = self.bounds.size.height / previewLayerView.bounds.size.height;
    
    float zoomFactor = MIN(horizZoom,vertZoom)*1.005;
    
    [self setMinimumZoomScale:zoomFactor];
    
    
    [self setZoomScale:zoomFactor animated:animated];
    
}

//might remove these...unless we do something with freeze/thaw buttons
- (void) startPreview
{
    [self.session startRunning];
    previewRunning = YES;
}

- (void) stopPreview
{
    [self.session stopRunning];
    previewRunning = NO;
}

- (void) grabImage
{
    if (self.captureMode!=CSCaptureModePhoto)
    {
        NSLog(@"Must be in photo mode to grab image");
        return;
    }
    //TODO: rather than using notifications, use a block here, which returns the UIImage and Exif data
    
     //necessary to loop like this? seems kludgy
     AVCaptureConnection *videoConnection = nil;
     for (AVCaptureConnection *connection in stillOutput.connections)
     {
         for (AVCaptureInputPort *port in [connection inputPorts])
         {
             if ([[port mediaType] isEqual:AVMediaTypeVideo] )
             {
                 videoConnection = connection;
                 break;
             }
         }
         if (videoConnection) { break; }
     }
     
     self.lastCapturedImage = nil;
     self.lastImageMetadata = nil;
    
     [videoConnection setVideoOrientation:self.orientation];  //should do this during setupCamera instead
    
     NSLog(@"about to request a capture from: %@", stillOutput);
    
     [stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         if (imageSampleBuffer==nil)
         {
             NSLog(@"error with capture: %@",[error description]);
         }
         else
         {
             // initialize the metadata with the exifattachments provided by the camera
             self.lastImageMetadata = [[NSMutableDictionary alloc] initWithImageSampleBuffer:imageSampleBuffer];
             
             NSLog(@"metadata: %@", self.lastImageMetadata);
             
             //grab the image data and create a UIImage object
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             
             //self.lastCapturedImage = [[[UIImage alloc] initWithData:imageData] applyRotation:M_PI_2];
             self.lastCapturedImage = [[UIImage alloc] initWithData:imageData];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageCaptured" object:nil];
         }
         
     }];
    
}

- (void) startVideoRecording
{
    NSLog(@"starting video");
    
    //Create temporary URL to record to
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath])
    {
        NSError *error;
        // Remove the old temporary movie
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
        {
            NSLog(@"error removing old temp file");
            return;
        }
    }
    self.isRecording = YES;
    
    //start recording to temp file
    [self.movieOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

- (void) stopVideoRecording
{
    if (self.isRecording)
    {
        NSLog(@"video stopped");
        [self.movieOutput stopRecording];
        self.isRecording = NO;
        
    }
}

//this delegate gets called when video recording is complete
//should switch this to a notification, just as image is done, and use lastcapturedvideoURL
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    
    self.lastCapturedVideoURL = outputFileURL;
    self.lastImageMetadata = [[NSMutableDictionary alloc] init];
    self.lastCapturedImage = [[UIImage alloc] init]; //snapshot of first frame;
    
    
    NSLog(@"%@",[self.movieOutput.metadata description]);  //what's in here? can we put it in metadata
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoCaptured" object:nil];
    
}

- (void) showImage:(UIImage*)image
{
    CGRect frame = CGRectMake(0, 0, 2592, 1936);
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:image];
    previewLayerView = imageView;
    
    [self addSubview:previewLayerView];
    
    [self setDelegate:self];
    [self setContentSize:frame.size];
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return previewLayerView;
}

- (void)setExposureLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        if (locked)
            [self.device setExposureMode:AVCaptureExposureModeLocked];
        else
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        isExposureLocked = locked;
        [self.device unlockForConfiguration];
    }
    else
        NSLog(@"Error: %@",error);
    
}

- (void)setFocusLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        if (locked)
            [self.device setFocusMode:AVCaptureFocusModeLocked];
        else
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        isFocusLocked = locked;
        [self.device unlockForConfiguration];
    }
    else
        NSLog(@"Error: %@",error);
}

- (void) addScaleBarWithLocation:(CGPoint)location
                       minLength:(float)minLength
                       maxLength:(float)maxLength
                     pixelsPerMM:(float)pixelsPerMM
                 snapLengthsInMM:(NSArray*)snaps
                           color:(UIColor*)color
                       lineWidth:(float)lineWidth
                        fontSize:(float)fontSize
                     showMicrons:(BOOL)showMicrons
{
    ScrollBarView* sbv = [[ScrollBarView alloc] initWithFrame:CGRectMake(location.x,location.y,maxLength,((lineWidth*4)+fontSize))];
    sbv.minLength = minLength;
    sbv.maxLength = maxLength;
    sbv.lineWidth = lineWidth;
    sbv.fontSize = fontSize;
    sbv.snaps = snaps;
    sbv.showMicrons = showMicrons;
    sbv.pixelsPerMM = pixelsPerMM;
    sbv.currentZoomFactor = self.zoomScale;
    sbv.backgroundColor = [UIColor clearColor];
    [self.superview addSubview:sbv];
    [self.superview bringSubviewToFront:sbv];
    
    self.scrollBarView = sbv;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"zoom factor: %f, content offset x: %f, content offset y: %f",self.zoomScale,self.contentOffset.x,self.contentOffset.y);
    if (self.scrollBarView!=nil)
    {
        self.scrollBarView.currentZoomFactor = self.zoomScale;
        [self.scrollBarView setNeedsDisplay];
    }
    
}

- (void)loadVideoFromFile:(NSURL*)fileURL
         completionAction:(VideoLoadCompletionBlock)completionBlock;
{

    self.videoCompletionBlock = completionBlock;
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         // Completion handler block.
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            NSLog(@"finished loading video");
                            
                            NSError *error;
                            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                            
                            if (status == AVKeyValueStatusLoaded) {
                                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                                [self.playerItem addObserver:self forKeyPath:@"status"
                                                     options:0 context:&ItemStatusContext];
                                [[NSNotificationCenter defaultCenter] addObserver:self
                                                                         selector:@selector(playerItemDidReachEnd:)
                                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                                           object:self.playerItem];
                                
                                
                                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                                CGRect frame = CGRectMake(0, 0, 2592, 1936);
                                MoviePlayerView* playerView = [[MoviePlayerView alloc] initWithFrame:frame];
                                
                                [playerView setPlayer:self.player];
                                self.previewLayerView = playerView;
                                
                                [self addSubview:playerView];
                                [self setDelegate:self];
                                
                                [self setContentSize:frame.size];
                                
                            }
                            else {
                                // You should deal with the error appropriately.
                                NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                            }
                        });

     }];
}

//necessary?
- (void)playVideo
{
    [self.player play];
    self.isPlaying = YES;
}

- (void)pauseVideo
{
    [self.player pause];
    self.isPlaying = NO;
}

- (void)seekToTime:(CMTime)time
{
    [self.player seekToTime:time];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (context == &ItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           self.videoCompletionBlock();
                           NSLog(@"player update");
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self.player seekToTime:kCMTimeZero];
    if (self.doPlaybackLoop)
        [self.player play];
    else
        self.isPlaying = NO;
}

@end
