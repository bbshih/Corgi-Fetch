//
//  CFFeedbackUIViewController.h
//  CorgiFetch
//
//  Created by Billy Shih on 10/17/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BBSFeedbackUIViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    UIImage *buttonImage;
    UIImage *buttonImageHighlight;
}
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *reviewButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
- (IBAction)review:(id)sender;
- (IBAction)facebook:(id)sender;
- (IBAction)twitter:(id)sender;
- (IBAction)emailMe:(id)sender;

-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
@end
