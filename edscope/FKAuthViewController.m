//
//  FKAuthViewController.m
//  FlickrKitDemo
//
//  Created by David Casserly on 03/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKAuthViewController.h"
#import "FlickrKit.h"

@interface FKAuthViewController ()
@property (nonatomic, retain) FKDUNetworkOperation *authOp;
@end

@implementation FKAuthViewController

@synthesize webView,activityIndicator;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator startAnimating];
    [self.webView setDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
	// This schema must be defined in Info.plist
	// Flickr will call this back.
	NSString *callbackURLString = @"cellscope://auth";
	
	// Begin the authentication process
	self.authOp = [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:[NSURL URLWithString:callbackURLString] permission:FKPermissionDelete completion:^(NSURL *flickrLoginPageURL, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:flickrLoginPageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];			
				[self.webView loadRequest:urlRequest];


			} else {			
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The internet connection appears to be offline." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
                [alert setDelegate:self];
			}
        });		
	}];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.authOp cancel];
    [super viewWillDisappear:animated];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Web View


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //If they click NO DONT AUTHORIZE, this is where it takes you by default... maybe take them to my own web site, or show something else
	
    NSURL *url = [request URL];
    
	// If it's the callback url, then lets trigger that
    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            return NO;
        }
    }
	
    return YES;
	
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"failed to load login page");
    NSLog(@"%@",error.description);
}

@end
