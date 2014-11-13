//
//  LoginViewController.m
//  edscope
//
//  Requests the student name and group/class name from the user and includes
//  buttons to launch the configuration page (password protected) and
//  the about page.
//
//  Created by Frankie Myers on 11/18/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize nameTextField,classTextField,versionLabel,passwordAlert;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //create the bottom info bar
    self.infoBarView = [InfoBarView makeInfoBarInView:self.view];
    
    //make the navigation bar pretty
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //hide navigation bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    //setup prompts
    self.nameLabel.text = [NSString stringWithFormat:@"%@:",[[NSUserDefaults standardUserDefaults] stringForKey:@"UserNamePrompt"]];
    self.classLabel.text = [NSString stringWithFormat:@"%@:",[[NSUserDefaults standardUserDefaults] stringForKey:@"GroupNamePrompt"]];
    
    
    //get default student/group name
    self.nameTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultUserName"];
    self.classTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultGroupName"];
    
    
    //get the app version
    NSString * appVersionString = [NSString stringWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    self.versionLabel.text = appVersionString;
    
    // Check if there is a stored Flickr token
	self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
                //stored token found, retrieve flickr username
                [[CellScopeContext sharedContext] setFlickrUserID:userId];
                [[CellScopeContext sharedContext] setFlickrUsername:userName];
			}
            //refresh the bottom status bar
            [self refreshInfoBar];
        });
	}];
    
}

- (void) viewWillDisappear:(BOOL)animated {
	[self.checkAuthOp cancel];
    [super viewWillDisappear:animated];
}

//update the flickr account name on the info bar at the bottom of the screen
- (void)refreshInfoBar
{
    NSString* flickrNameToDisplay;
    if ([FKDUReachability isConnected])
        flickrNameToDisplay = [[CellScopeContext sharedContext] flickrUsername];
    else
        flickrNameToDisplay = @"Offline";
    
    [self.infoBarView setFlickrUsername:flickrNameToDisplay
                            cellScopeID:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeID"]];
}

- (IBAction) didPressConfig:(id)sender;
{
    //throw up the password dialog box first
    passwordAlert = [[UIAlertView alloc] initWithTitle:@"Configuration Settings" message:@"Enter Password:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    passwordAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    [passwordAlert textFieldAtIndex:0].delegate = self;
    [passwordAlert show];
    
}

//callback from the password alert view dialog that is displayed when the user clicks configuration button
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* enteredPassword = [[alertView textFieldAtIndex:0] text];
    NSString* storedPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"ConfigPassword"];
    
    NSLog(@"Entered: %@", enteredPassword);
    NSLog(@"Stored: %@", storedPassword);
    
    if ([enteredPassword isEqualToString:storedPassword])
     {
         //password accepted, show config view
         [self performSegueWithIdentifier:@"ConfigurationSegue" sender:self];
     }
}

//handles when return key is pressed on keyboard (moves to next field or initiates segue)
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag==1) //student name field
        [self.classTextField becomeFirstResponder];
    else if (textField.tag==2) //group name field
        [self performSegueWithIdentifier:@"CaptureSegue" sender:nil];
    else //this is the textfield inside the password alert view popup
    {
        [textField resignFirstResponder];
        [passwordAlert dismissWithClickedButtonIndex:0 animated:YES];
        [self alertView:passwordAlert clickedButtonAtIndex:0];
    }
    return YES;
}

//save name/group to singleton context object which is used throughout app
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[CellScopeContext sharedContext] setStudentName:self.nameTextField.text];
    [[CellScopeContext sharedContext] setGroupName:self.classTextField.text];
}

//perform text field validation on a character-by-character basis
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //limits the length of the student name and group name
    if ((textField==nameTextField) || (textField==classTextField))
    {
        int newLength = [textField.text length] + [string length] - range.length;
        return (newLength > [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxTextFieldLength"]) ? NO : YES;
    }
    else
        return YES;
}

@end
