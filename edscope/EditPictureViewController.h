//
//  EditPictureViewController.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"
#import "Pictures.h"
#import "Sessions.h"

@interface EditPictureViewController : UIViewController

@property (strong,nonatomic) Pictures* currentPicture;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellScopeIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *magnificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pictureNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextArea;
@property (weak, nonatomic) IBOutlet UILabel *sharedLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewOnFlickrButton;

- (IBAction)didPressViewOnFlickr:(id)sender;
- (IBAction)didPressDone:(id)sender;

@end
