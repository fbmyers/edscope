//
//  PhotoBrowserViewController.m
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "PhotoBrowserViewController.h"


@implementation PhotoBrowserViewController

@synthesize pictureIndexLookupTable, sessionList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //leaving this off for now
    //self.infoBarView = [InfoBarView makeInfoBarInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    //  Grab the data
    self.sessionList = [CoreDataHelper getObjectsForEntity:@"Sessions" withSortKey:@"date" andSortAscending:NO andContext:[[CellScopeContext sharedContext] managedObjectContext]];
    
    //  Force table refresh
    [self.collectionView reloadData];
    
    
    //let's bring this back when we allow multiple uploads
    //[self.infoBarView setFlickrUsername:[[CellScopeContext sharedContext] flickrUsername]
    //                        cellScopeID:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ViewPictureSegue"])
    {
        PhotoViewViewController* pvvc = (PhotoViewViewController*)[segue destinationViewController];
        PictureThumbnailCell* selectedPicture = (PictureThumbnailCell*)sender;
        pvvc.currentPicture = selectedPicture.picture;
    }
}


#pragma mark - UICollectionView Datasource

//return number of images for a given session
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    Sessions* thisSession = (Sessions*)[self.sessionList objectAtIndex:section];
    return thisSession.pictures.count;
}

//return number of sessions
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return self.sessionList.count;
}

//populate each cell: image thumbnail and title
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PictureThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PictureThumbnailCell" forIndexPath:indexPath];
    
    Sessions* thisSession = (Sessions*)[self.sessionList objectAtIndex:indexPath.section];
    cell.picture = (Pictures*)[thisSession.pictures objectAtIndex:indexPath.item];
    UIImage* thumbImage = [UIImage imageWithData:cell.picture.thumbnail];
    

    //need to fix this in the image itself
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"CaptureOrientation" ] isEqualToString:@"Portrait"] ||
        [[[NSUserDefaults standardUserDefaults] stringForKey:@"CaptureOrientation" ] isEqualToString:@"PortraitUpsideDown"])
    {
        if ([cell.picture.type isEqualToString:@"Video"])
        {
            cell.imageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            cell.imageView.transform = CGAffineTransformScale(cell.imageView.transform, 1.0, -1.0); //this is actually a fxn of mirroring
        }
        else if ([cell.picture.type isEqualToString:@"Photo"])
        {
            cell.imageView.transform = CGAffineTransformMakeRotation(M_PI);
            cell.imageView.transform = CGAffineTransformScale(cell.imageView.transform, -1.0, 1.0); //this is actually a fxn of mirroring
        }
    }
    
    //display thumbnail
    [cell.imageView setImage:thumbImage];
    
    //display icons
    if ([cell.picture.type isEqualToString:@"Video"])
        [cell.videoIcon setHidden:NO];
    else if ([cell.picture.type isEqualToString:@"Photo"])
        [cell.videoIcon setHidden:YES];
    
    if (cell.picture.uploadState==2)
        [cell.uploadIcon setHidden:NO];
    else
        [cell.uploadIcon setHidden:YES];
    
    //display title
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowTitlesInThumbnails"])
        [cell.titleLabel setText:cell.picture.title];
    else
        [cell.titleLabel setText:@""];
    return cell;
}

// populate headers with session info: name, group, and date
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind==UICollectionElementKindSectionHeader)
    {
        PictureThumbnailHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                             UICollectionElementKindSectionHeader withReuseIdentifier:@"PictureThumbnailHeader" forIndexPath:indexPath];
        
        Sessions* thisSession = (Sessions*)[self.sessionList objectAtIndex:indexPath.section];
        
        NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:thisSession.date];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"DateFormat"]];
        NSString* dateString = [dateFormatter stringFromDate:date];
        
        [headerView.nameLabel setText:thisSession.student];
        [headerView.groupLabel setText:thisSession.group];
        [headerView.dateLabel setText:dateString];
        
        return headerView;
    }
    else
    {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                              UICollectionElementKindSectionFooter withReuseIdentifier:@"PictureThumbnailFooter" forIndexPath:indexPath];
        return footerView;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item (for upload/delete)
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item (for upload/delete)
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    size.height = [[NSUserDefaults standardUserDefaults] floatForKey:@"ThumbnailSize"];
    size.width = size.height;
    return size;
}
/*
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}
*/
@end
