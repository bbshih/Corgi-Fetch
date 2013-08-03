//
//  AboutViewController.m
//  CorgiFetch
//
//  Created by Billy Shih on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSAboutViewController.h"
#import "BBSAttributionsViewController.h"
#import "UIApplicationAddition.h"
#import "UIApplicationAddition.h"
#import "BBSInAppPurchaseViewController.h"
#import "BBSAppDelegate.h"
#import "BBSWebBrowser.h"
#import "Config.h"

@interface BBSAboutViewController ()

@end

@implementation BBSAboutViewController
@synthesize emailMeButton;
@synthesize attributionButton;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize aboutText;
@synthesize hideButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        buttonImage = [[UIImage imageNamed:@"button.png"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        buttonImageHighlight = [[UIImage imageNamed:@"buttonHighlight.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        hidden = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    premium = NO;
    
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
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"odinbackground.png"]]];
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
    
    [self setTitle:@"Fetch: About"];
    
    NSArray *buttons = [NSArray arrayWithObjects: [self emailMeButton], [self premiumButton], nil];

    for(UIButton *btn in buttons) {
        [btn setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [btn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }
    
    UIImage *buttonGrayImage;
    buttonGrayImage = [[UIImage imageNamed:@"buttonGray.png"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonGrayHighlightImage;
    buttonGrayHighlightImage = [[UIImage imageNamed:@"buttonGrayHighlight.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [[self attributionButton] setBackgroundImage:buttonGrayImage forState:UIControlStateNormal];
    [[self attributionButton] setBackgroundImage:buttonGrayHighlightImage forState:UIControlStateHighlighted];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (premium == NO && [(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium]) {
        [[self premiumButton] removeFromSuperview];
        [[self aboutText] setFrame:CGRectMake(self.aboutText.frame.origin.x, self.aboutText.frame.origin.y, self.aboutText.frame.size.width, self.aboutText.frame.size.height + 40.0f)];
        premium = YES;
    }
}

- (void)viewDidUnload
{
    [[[self navigationController] navigationBar] removeGestureRecognizer:self.panGestureRecognizer];
    self.panGestureRecognizer = nil;
    [self setAboutText:nil];
    [self setHideButton:nil];
    [self setAttributionButton:nil];
    [self setEmailMeButton:nil];
    [self setPremiumButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsSupportedOrientation(interfaceOrientation);
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
        [[[self navigationController] navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                             [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22.0f],
                                                                             UITextAttributeFont,
                                                                             [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f],
                                                                             UITextAttributeTextShadowColor,
                                                                             [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5f)],
                                                                             UITextAttributeTextShadowOffset, nil]];
        [[[self navigationController] navigationBar] setTitleVerticalPositionAdjustment:-3.0f forBarMetrics:UIBarMetricsDefault];
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
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
}

- (IBAction)hideAll:(id)sender {
    if (hidden) {

        NSArray *buttons = [NSArray arrayWithObjects: [self attributionButton], [self emailMeButton], [self premiumButton], nil];
        for (UIButton *btn in buttons) {
            [btn setAlpha:1.0f];
            [btn setEnabled:YES];
        }
        [[self aboutText] setAlpha:0.8f];
        [[self hideButton] setTitle:@"Hide" forState:UIControlStateNormal];
        hidden = NO;
    } else {
        NSArray *buttons = [NSArray arrayWithObjects: [self attributionButton], [self emailMeButton], [self premiumButton], nil];
        for (UIButton *btn in buttons) {
            [btn setAlpha:0.0f];
            [btn setEnabled:YES];
        }
        
        [[self aboutText] setAlpha:0.0f];
        [[self hideButton] setTitle:@"Show" forState:UIControlStateNormal];
        hidden = YES;
    }
        
}

- (IBAction)openAttributions:(id)sender {
    BBSAttributionsViewController *avc = [[BBSAttributionsViewController alloc] initWithNibName:@"AttributionsViewController" bundle:nil];
    [[self navigationController] pushViewController:avc animated:YES];
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

- (IBAction)showPremium:(id)sender {
    BBSInAppPurchaseViewController *purchaseVC = [[BBSInAppPurchaseViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:purchaseVC];
    [self presentViewController:navController animated:YES completion:nil];
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
