//
//  AboutViewController.h
//  CorgiFetch
//
//  Created by Billy Shih on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BBSAboutViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    UIImage *buttonImage;
    UIImage *buttonImageHighlight;
    
    BOOL premium;
    BOOL hidden;
}
@property (weak, nonatomic) IBOutlet UIButton *attributionButton;
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) IBOutlet UITextView *aboutText;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *emailMeButton;
@property (weak, nonatomic) IBOutlet UIButton *premiumButton;

- (IBAction)hideAll:(id)sender;
- (IBAction)openAttributions:(id)sender;
- (IBAction)emailMe:(id)sender;
- (IBAction)showPremium:(id)sender;


-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

@end
