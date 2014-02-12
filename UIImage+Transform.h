//
//  UIImage+Rotate.h
//  edscope
//
//  Created by Frankie Myers on 12/3/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

@interface UIImage (Transform)

- (UIImage *)applyTransform:(CGAffineTransform)transform;
- (UIImage *)applyRotation:(float)rads;

@end
