//
//  UIImage+Rotate.m
//  edscope
//
//  Created by Frankie Myers on 12/3/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "UIImage+Transform.h"

@implementation UIImage (Transform)

- (UIImage *)applyTransform:(CGAffineTransform)transform
{
    float newSide = MAX([self size].width, [self size].height);
    CGSize size =  CGSizeMake(newSide, newSide);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-[self size].width/2,-[self size].height/2,size.width, size.height),self.CGImage);
    
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

- (UIImage *)applyRotation:(float)rads
{
    float newSide = MAX([self size].width, [self size].height);
    CGSize size =  CGSizeMake(newSide, newSide);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, newSide/2, newSide/2);
    CGContextRotateCTM(ctx, rads);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-[self size].width/2,-[self size].height/2,size.width, size.height),self.CGImage);
    
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

@end
