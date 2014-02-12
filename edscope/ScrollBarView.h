//
//  ScrollBarView.h
//  edscope
//
//  Created by Frankie Myers on 12/3/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollBarView : UIView

@property (nonatomic) float minLength;
@property (nonatomic) float maxLength;
@property (nonatomic) float lineWidth;
@property (nonatomic) float pixelsPerMM;
@property (nonatomic) float currentZoomFactor;
@property (nonatomic) float fontSize;
@property (strong,nonatomic) NSArray* snaps;
@property (nonatomic) BOOL showMicrons;

@end
