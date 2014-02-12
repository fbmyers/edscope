//
//  MoviePlayerView.m
//  edscope
//
//  Created by Frankie Myers on 12/4/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MoviePlayerView : UIView

@end

@implementation MoviePlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end
