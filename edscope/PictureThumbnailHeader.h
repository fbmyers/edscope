//
//  PictureThumbnailHeader.h
//  edscope
//
//  Created by Frankie Myers on 11/25/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureThumbnailHeader : UICollectionReusableView

@property (weak,nonatomic) IBOutlet UILabel* nameLabel;
@property (weak,nonatomic) IBOutlet UILabel* groupLabel;
@property (weak,nonatomic) IBOutlet UILabel* dateLabel;

@end
