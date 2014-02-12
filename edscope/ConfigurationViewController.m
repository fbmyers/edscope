//
//  ConfigurationViewController.m
//  edscope
//
//  This view allows users to change preferences (stored in NSUserDefaults, with the default-configuration.plist providing default values)
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "ConfigurationViewController.h"

@implementation ConfigurationViewController

@synthesize locationField,scopeIDField,magnificationField,pixelsPerMMPhotoField,pixelsPerMMVideoField,pixelsPerMMPreviewField,defaultGroupField,defaultNameField,configPasswordField,promptForTitle,flickrLoginButton,flickrLoginLabel,privatePrivacyButton,friendsPrivacyButton,publicPrivacyButton,mirrorXButton,mirrorYButton,mirroringSetting,privacySetting;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flickrAuthenticateCallback:) name:@"FlickrAuthCallbackNotification" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self fetchValuesFromPreferences];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveValuesToPreferences];
    [self.completeAuthOp cancel];
    [super viewWillDisappear:animated];
}

//populate the view with values from NSUserDefaults
- (void) fetchValuesFromPreferences
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    self.scopeIDField.text = [prefs stringForKey:@"CellScopeID"];
    self.locationField.text = [prefs stringForKey:@"Location"];
    self.magnificationField.text = [prefs stringForKey:@"Magnification"];
    self.pixelsPerMMPhotoField.text = [[NSString alloc] initWithFormat:@"%3.0f",[prefs floatForKey:@"PixelsPerMMPhoto"]];
    self.pixelsPerMMPreviewField.text = [[NSString alloc] initWithFormat:@"%3.0f",[prefs floatForKey:@"PixelsPerMMPhotoPreview"]];
    self.pixelsPerMMVideoField.text = [[NSString alloc] initWithFormat:@"%3.0f",[prefs floatForKey:@"PixelsPerMMVideo"]];
    
    self.defaultNameField.text = [prefs stringForKey:@"DefaultStudentName"];
    self.defaultGroupField.text = [prefs stringForKey:@"DefaultGroupName"];
    self.configPasswordField.text = [prefs stringForKey:@"ConfigPassword"];
    self.promptForTitle.on = [prefs boolForKey:@"PromptForTitle"];
    
    self.privacySetting = [prefs stringForKey:@"FlickrPrivacy"];
    self.mirroringSetting = [prefs stringForKey:@"Mirroring"];
    
    [self setupFlickrButton];
    [self setupMirroringButtons];
    [self setupPrivacyButtons];
}

//save all preferences
- (void) saveValuesToPreferences
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setValue:self.scopeIDField.text forKey:@"CellScopeID"];
    [prefs setValue:self.locationField.text forKey:@"Location"];
    [prefs setValue:self.magnificationField.text forKey:@"Magnification"];
    [prefs setFloat:self.pixelsPerMMPhotoField.text.floatValue forKey:@"PixelsPerMMPhoto"];
    [prefs setFloat:self.pixelsPerMMPreviewField.text.floatValue forKey:@"PixelsPerMMPhotoPreview"];
    [prefs setFloat:self.pixelsPerMMVideoField.text.floatValue forKey:@"PixelsPerMMVideo"];
    
    [prefs setValue:self.defaultGroupField.text forKey:@"DefaultGroupName"];
    [prefs setValue:self.defaultNameField.text forKey:@"DefaultStudentName"];
    [prefs setValue:self.configPasswordField.text forKey:@"ConfigPassword"];
    [prefs setBool:self.promptForTitle.on forKey:@"PromptForTitle"];
    
    [prefs setValue:self.privacySetting forKey:@"FlickrPrivacy"];
    [prefs setValue:self.mirroringSetting forKey:@"Mirroring"];
    
    [prefs synchronize];
}

- (void)setupFlickrButton
{
    if ([[FlickrKit sharedFlickrKit] isAuthorized])
    {
        [self.flickrLoginButton setHidden:NO];
        [self.flickrLoginButton setTitle:@"Logout" forState:UIControlStateNormal];
        [self.flickrLoginLabel setHidden:NO];
        [self.flickrLoginLabel setText:[NSString stringWithFormat:@"You are logged in to Flickr as %@",[[CellScopeContext sharedContext] flickrUsername]]];
    }
    else
    {
        [self.flickrLoginButton setHidden:NO];
        [self.flickrLoginButton setTitle:@"Login to Flickr" forState:UIControlStateNormal];
        [self.flickrLoginLabel setHidden:YES];
    }
}

//currently not exposed on the UI
- (IBAction)didPressMirroringButton:(id)sender
{
    if (sender==self.mirrorXButton && [self.mirroringSetting isEqualToString:@"None"])
        self.mirroringSetting = @"MirrorX";
    else if (sender==self.mirrorXButton && [self.mirroringSetting isEqualToString:@"MirrorX"])
        self.mirroringSetting = @"None";
    else if (sender==self.mirrorXButton && [self.mirroringSetting isEqualToString:@"MirrorY"])
        self.mirroringSetting = @"MirrorXY";
    else if (sender==self.mirrorXButton && [self.mirroringSetting isEqualToString:@"MirrorXY"])
        self.mirroringSetting = @"MirrorY";
    else if (sender==self.mirrorYButton && [self.mirroringSetting isEqualToString:@"None"])
        self.mirroringSetting = @"MirrorY";
    else if (sender==self.mirrorYButton && [self.mirroringSetting isEqualToString:@"MirrorY"])
        self.mirroringSetting = @"None";
    else if (sender==self.mirrorYButton && [self.mirroringSetting isEqualToString:@"MirrorX"])
        self.mirroringSetting = @"MirrorXY";
    else if (sender==self.mirrorYButton && [self.mirroringSetting isEqualToString:@"MirrorXY"])
        self.mirroringSetting = @"MirrorX";
    
    [self setupMirroringButtons];
}

//toggle among different privacy options
- (IBAction)didPressPrivacyButton:(id)sender
{
    if (sender==self.publicPrivacyButton)
        self.privacySetting = @"Public";
    else if (sender==self.friendsPrivacyButton)
        self.privacySetting = @"FriendsFamily";
    else if (sender==self.privatePrivacyButton)
        self.privacySetting = @"Private";

    [self setupPrivacyButtons];
}

//highlight appropriate mirroring button based on current setting
- (void)setupMirroringButtons
{
    [self.mirrorYButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.mirrorXButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    if ([mirroringSetting isEqualToString:@"MirrorX"])
        [self.mirrorXButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([mirroringSetting isEqualToString:@"MirrorY"])
        [self.mirrorYButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([mirroringSetting isEqualToString:@"MirrorXY"])
    {
        [self.mirrorYButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [self.mirrorXButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
}

//highlight appropriate privacy button based on current setting
- (void)setupPrivacyButtons
{
    [self.publicPrivacyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.friendsPrivacyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.privatePrivacyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    if ([privacySetting isEqualToString:@"Public"])
        [self.publicPrivacyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else if ([privacySetting isEqualToString:@"FriendsFamily"])
        [self.friendsPrivacyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    else //PRIVATE
        [self.privatePrivacyButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    
}


- (IBAction)didPressDeletePhotos:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset" message:@"You have selected to delete all photos and videos from the CellScope app.  Note that this does not permanently delete them from your iPad or from Flickr.  Proceed?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = 1;
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) //core data delete alert box
    {
        if (buttonIndex==1) //YES BUTTON
            [self clearCoreData];
    }
    else if (alertView.tag==2) //preferences delete
    {
        if (buttonIndex==1) //YES BUTTON
            [self resetConfigurationSettings];
    }
}

- (void)clearCoreData
{
    NSPersistentStoreCoordinator* psc = [[[CellScopeContext sharedContext] managedObjectContext] persistentStoreCoordinator];
    NSArray *stores = [psc persistentStores];
    
    for(NSPersistentStore *store in stores) {
        [psc removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:store.URL options:nil error:nil];
    }
    
    NSLog(@"Core Data SQLite file deleted and persistent store recreated");
    
}

- (void)resetConfigurationSettings
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [prefs removePersistentDomainForName:appDomain];
    [self fetchValuesFromPreferences];
}

- (IBAction)didPressResetSettings:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset" message:@"You have selected to reset all configuration settings to their default values. Proceed?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = 2;
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (IBAction)didPressFlickrLogin:(id)sender
{
    if ([FlickrKit sharedFlickrKit].isAuthorized) //already logged in, so logout
    {
        [[FlickrKit sharedFlickrKit] logout];
        
        //it's important to delete any cookies associated with the flickr login
        //because otherwise it won't allow a new user to login (will just reauthenticate
        //the old user). I'm deleting all the cookies here because Flickr has a bunch of
        //federated login options with google, yahoo, facebook, etc., so this is just easier
        //(and there's no reason the app should have any browser cookies stored).
        //I DON'T THINK this cookie storage is shared with safari, but it might be shared
        //with other apps???
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *allCookies = [cookies cookies];
        for(NSHTTPCookie *cookie in allCookies) {
            //if(([[cookie domain] rangeOfString:@"flickr.com"].location != NSNotFound) ||
            //   ([[cookie domain] rangeOfString:@"yahoo.com"].location != NSNotFound) ||
            //   ([[cookie domain] rangeOfString:@"google.com"].location != NSNotFound) ||
            //   ([[cookie domain] rangeOfString:@"facebook.com"].location != NSNotFound))
                
                [cookies deleteCookie:cookie];
        }
        
        [[CellScopeContext sharedContext] setFlickrUserID:@""];
        [[CellScopeContext sharedContext] setFlickrUsername:@"Not Logged In"];
        
        [self setupFlickrButton];
    }
    else //go to flickr login page
    {
        [self performSegueWithIdentifier:@"FlickrLoginSegue" sender:sender];
    }
}

//this is the method which handles a login attempt (it is initiated by a URL request to the app from Flickr
- (void) flickrAuthenticateCallback:(NSNotification *)notification {
	NSURL *callbackURL = notification.object;
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) { //login successful
                
                [[CellScopeContext sharedContext] setFlickrUserID:userId];
                [[CellScopeContext sharedContext] setFlickrUsername:userName];
                
                [self setupFlickrButton];
                
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
			[self.navigationController popViewControllerAnimated:YES];
		});
	}];
}

//perform text field validation on a character-by-character basis
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //number-only fields
    if (textField==pixelsPerMMPhotoField || textField==pixelsPerMMPreviewField  || textField==pixelsPerMMVideoField )
    {
        NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        for (int i = 0; i < [string length]; ++i)
        {
            unichar c = [string characterAtIndex:i];
            if (![numberCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        
        return YES;
    }
    //these fields should have a limited length
    else if ((textField==locationField) ||
             (textField==defaultGroupField) ||
             (textField==defaultNameField) ||
             (textField==configPasswordField))
    {
        int newLength = [textField.text length] + [string length] - range.length;
        return (newLength > [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxTextFieldLength"]) ? NO : YES;
    }
    else if (textField==magnificationField)
    {
        int newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
    }
    else
        return YES;
}

@end
