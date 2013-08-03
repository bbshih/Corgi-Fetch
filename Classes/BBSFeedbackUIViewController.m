//
//  CFFeedbackUIViewController.m
//  CorgiFetch
//
//  Created by Billy Shih on 10/17/12.
//
//

#import "BBSFeedbackUIViewController.h"
#import "BBSWebBrowser.h"
#import "Config.h"

@interface BBSFeedbackUIViewController ()

@end

@implementation BBSFeedbackUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        buttonImage = [[UIImage imageNamed:@"button.png"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        buttonImageHighlight = [[UIImage imageNamed:@"buttonHighlight.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self interfaceOrientation] == UIInterfaceOrientationPortrait || [self interfaceOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                             [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22.0f],
                                                                             UITextAttributeFont,
                                                                             [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f],
                                                                             UITextAttributeTextShadowColor,
                                                                             [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5f)],
                                                                             UITextAttributeTextShadowOffset, nil]];
        [[[self navigationController] navigationBar] setTitleVerticalPositionAdjustment:-3.0f forBarMetrics:UIBarMetricsDefault];
    } else if ([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft || [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight) {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"landscapeNav.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                             [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f],
                                                                             UITextAttributeFont,
                                                                             [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f],
                                                                             UITextAttributeTextShadowColor,
                                                                             [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5f)],
                                                                             UITextAttributeTextShadowOffset, nil]];
        [[[self navigationController] navigationBar] setTitleVerticalPositionAdjustment:-2.0f forBarMetrics:UIBarMetricsLandscapePhone];
    }
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]]];
    // actions to load the background navigation view
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)]) {
        UIImage *revealIcon = [UIImage imageNamed:@"menu-icon.png"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealIcon
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self.navigationController.parentViewController
                                                                                action:@selector(revealToggle:)];
        [self.navigationItem.leftBarButtonItem setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.navigationItem.leftBarButtonItem setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController
                                                                            action:@selector(revealGesture:)];
        [self.navigationController.navigationBar addGestureRecognizer:self.panGestureRecognizer];
    }
    
    [self setTitle:@"Fetch: Feedback"];
    
    NSArray *buttons = [NSArray arrayWithObjects: [self reviewButton], [self emailButton], [self facebookButton], [self twitterButton], nil];
    
    for(UIButton *btn in buttons) {
        [btn setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [btn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Corgi Fetch"];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"me@billyshih.com"];
    
    [picker setToRecipients:toRecipients];
    
    [self presentModalViewController:picker animated:YES];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setReviewButton:nil];
    [self setEmailButton:nil];
    [self setFacebookButton:nil];
    [self setTwitterButton:nil];
    [super viewDidUnload];
}
- (IBAction)review:(id)sender {
    NSString *reviewURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", kAPP_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
}

- (IBAction)facebook:(id)sender {
    NSString *fbURL = @"fb://profile/153494528124839";
    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:fbURL]];

    if(canOpenURL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbURL]];
    } else {
        BBSWebBrowser *webBrowser = [[BBSWebBrowser alloc] initWithUrl:[NSURL URLWithString:kFacebookURL]];
        [[self navigationController] pushViewController:webBrowser animated:YES];
    }
}

- (IBAction)twitter:(id)sender {
    NSString *twURL = @"twitter://user?screen_name=corgifetch";
    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:twURL]];

    if(canOpenURL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twURL]];
    } else {
        BBSWebBrowser *webBrowser = [[BBSWebBrowser alloc] initWithUrl:[NSURL URLWithString:kTwitterURL]];
        [[self navigationController] pushViewController:webBrowser animated:YES];
    }
}

- (IBAction)emailMe:(id)sender {
    // This sample can run on devices running iPhone OS 2.0 or later
    // The MFMailComposeViewController class is only available in iPhone OS 3.0 or later.
    // So, we must verify the existence of the above class and provide a workaround for devices running
    // earlier versions of the iPhone OS.
    // We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
    // We launch the Mail application on the device, otherwise.
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *email = @"mailto:me@billyshih.com?&subject=Corgi Fetch";
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}
    
@end
