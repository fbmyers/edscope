//
//  AboutViewController.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate>

@property (weak,nonatomic) IBOutlet UIWebView* webView;

- (IBAction)didPressDone:(id)sender;

@end
