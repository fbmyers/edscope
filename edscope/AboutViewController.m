//
//  AboutViewController.m
//  edscope
//
//  Displays the about.html file (included in Supporting Files) in a UIWebView.
//  This file includes information about CellScope, links to documentation and the lab website
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

//loads the about.html file from the bundle which displays general information about cellscope and documentation
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView setDelegate:self];
    [self.webView.scrollView setBounces:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        NSLog(@"opening link in safari: %@",[inRequest URL].absoluteString);
        
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)didPressDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
