//
//  ScrollBarView.m
//  edscope
//
//  Created by Frankie Myers on 12/3/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ScrollBarView.h"

@implementation ScrollBarView

@synthesize pixelsPerMM,maxLength,minLength,lineWidth,currentZoomFactor,fontSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.minLength = 10.0;
        self.maxLength = 100.0;
        self.lineWidth = 2.0;
        self.fontSize = 20;
        self.snaps = @[@0.01,@0.02,@0.05,@0.1,@0.2,@0.5,@1.0,@2.0];
        self.showMicrons = YES;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, lineWidth);
    
    float height = rect.size.height;
    float width = rect.size.width;
    
    float currentSnapLength;
    float barLength;
    
    NSNumber* s;
    
    for (s in self.snaps)
    {
        currentSnapLength = [s floatValue];
        barLength = currentSnapLength*pixelsPerMM*currentZoomFactor;
        if (barLength>minLength && barLength<=maxLength)
            break;
    }
    
    
    CGContextMoveToPoint(context, width,height-lineWidth); //start at this point
    
    CGContextAddLineToPoint(context, width-barLength, height-lineWidth); //draw to this point
    
    NSString* text;
    
    if ((currentSnapLength<1.0) && self.showMicrons)
        text = [NSString stringWithFormat:@"%1.0f %Cm",currentSnapLength*1000,0x03BC];
    else
        text = [NSString stringWithFormat:@"%1.1f mm",currentSnapLength];
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    CGSize stringSize = [text sizeWithFont:font];
    CGRect stringRect = CGRectMake(width-stringSize.width, 0, stringSize.width, stringSize.height);
    
    //[[UIColor blackColor] set];
    //CGContextFillRect(context, stringRect);
    
    [[UIColor whiteColor] set];
    [text drawInRect:stringRect withFont:font];
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

@end
