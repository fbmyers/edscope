//
//  PictureThumbnailCell.h
//  edscope
//
//  Created by Frankie Myers on 11/25/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pictures.h"
#import "Sessions.h"

@interface PictureThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoIcon;
@property (weak, nonatomic) IBOutlet UIImageView *uploadIcon;

@property (nonatomic, strong) Pictures *picture;


@end
