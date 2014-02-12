//
//  LoginViewController.h
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrKit.h"
#import "FKDUReachability.h"
#import "CaptureViewController.h"
#import "ConfigurationViewController.h"
#import "Sessions.h"
#import "CellScopeContext.h"
#import "InfoBarView.h"

@interface LoginViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (weak,nonatomic) IBOutlet UITextField* nameTextField;
@property (weak,nonatomic) IBOutlet UITextField* classTextField;
@property (weak,nonatomic) IBOutlet UILabel* versionLabel;
@property (strong,nonatomic) IBOutlet InfoBarView* infoBarView;

@property (strong,nonatomic) UIAlertView* passwordAlert;

@property (nonatomic, retain) FKDUNetworkOperation *checkAuthOp;

- (IBAction) didPressConfig:(id)sender;

@end
