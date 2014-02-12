//
//  PhotoBrowserViewController.h
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "Sessions.h"
#import "Pictures.h"
#import "PictureThumbnailCell.h"
#import "PictureThumbnailHeader.h"
#import "PhotoViewViewController.h"
#import "InfoBarView.h"
#import "CellScopeContext.h"

@interface PhotoBrowserViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *sessionList;
@property (strong,nonatomic) NSMutableArray *pictureIndexLookupTable;

@property (strong,nonatomic) InfoBarView* infoBarView;

@end
