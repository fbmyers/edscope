//
//  InfoBarView.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoBarView : UIView

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIImageView *icon1;
@property (weak, nonatomic) IBOutlet UIImageView *icon2;
@property (weak, nonatomic) IBOutlet UIImageView *icon3;
@property (weak, nonatomic) IBOutlet UIView *background1;
@property (weak, nonatomic) IBOutlet UIView *background2;
@property (weak, nonatomic) IBOutlet UIView *background3;

+ (InfoBarView*)makeInfoBarInView:(UIView*)parentView;

- (void)setFlickrUsername:(NSString*)flickrUsername
              cellScopeID:(NSString*)cellScopeID;

- (void)setStudentName:(NSString*)studentName
             groupName:(NSString*)groupName
           cellScopeID:(NSString*)cellScopeID;

@end
