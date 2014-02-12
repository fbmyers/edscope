//
//  ConfigurationViewController.h
//  edscope
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrKit.h"
#import "CellScopeContext.h"

@interface ConfigurationViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* locationField;
@property (weak, nonatomic) IBOutlet UITextField* scopeIDField;
@property (weak, nonatomic) IBOutlet UITextField* magnificationField;
@property (weak, nonatomic) IBOutlet UITextField* pixelsPerMMPhotoField;
@property (weak, nonatomic) IBOutlet UITextField* pixelsPerMMPreviewField;
@property (weak, nonatomic) IBOutlet UITextField* pixelsPerMMVideoField;
@property (weak, nonatomic) IBOutlet UITextField* defaultNameField;
@property (weak, nonatomic) IBOutlet UITextField* defaultGroupField;
@property (weak, nonatomic) IBOutlet UITextField* configPasswordField;
@property (weak, nonatomic) IBOutlet UISwitch* promptForTitle;

@property (weak,nonatomic) IBOutlet UIButton* flickrLoginButton;
@property (weak,nonatomic) IBOutlet UILabel* flickrLoginLabel;

@property (weak, nonatomic) IBOutlet UIButton *publicPrivacyButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsPrivacyButton;
@property (weak, nonatomic) IBOutlet UIButton *privatePrivacyButton;

@property (weak, nonatomic) IBOutlet UIButton *mirrorXButton;
@property (weak, nonatomic) IBOutlet UIButton *mirrorYButton;

@property (strong,nonatomic) NSString* mirroringSetting;
@property (strong,nonatomic) NSString* privacySetting;


@property (nonatomic, retain) FKDUNetworkOperation *completeAuthOp;

- (IBAction) didPressFlickrLogin:(id)sender;
- (IBAction)didPressDeletePhotos:(id)sender;
- (IBAction)didPressResetSettings:(id)sender;
- (IBAction)didPressMirroringButton:(id)sender;
- (IBAction)didPressPrivacyButton:(id)sender;

- (void)setupFlickrButton;
- (void)setupMirroringButtons;
- (void)setupPrivacyButtons;
- (void)fetchValuesFromPreferences;
- (void)saveValuesToPreferences;
- (void)clearCoreData;
- (void)resetConfigurationSettings;

@end
