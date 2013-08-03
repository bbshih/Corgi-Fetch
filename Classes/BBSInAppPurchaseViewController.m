//
//  InAppPurchaseViewController.m
//  CorgiFetch
//
//  Created by Billy Shih on 9/8/12.
//
//

#import "BBSInAppPurchaseViewController.h"
#import "SVProgressHUD.h"
#import "UIApplicationAddition.h"
#import "BBSinappPurchase.h"
#import "BBSAppDelegate.h"

@interface BBSInAppPurchaseViewController ()

@end

@implementation BBSInAppPurchaseViewController

@synthesize upgradeButton;
@synthesize restoreButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    purchase = [[EBPurchase alloc] init];
//    purchase.delegate = self;
//    
//    isPurchased = NO;
    
    [self setupViews];

    [self setTitle: @"Support Corgi Fetch"];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"button.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"buttonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    
    [upgradeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [upgradeButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestedProduct:) name:@"requestedProduct" object:nil];
    [restoreButton setEnabled:NO];
    [upgradeButton setEnabled:NO]; // Only enable after populated with IAP price.
    
    // Request In-App Purchase product info and availability.
    
    if (![[BBSinappPurchase sharedPurchase] requestProduct])
    {
        // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
        [restoreButton setTitle:@"Purchase Disabled in Settings" forState:UIControlStateNormal];
    }
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setUpgradeButton:nil];
    [self setRestoreButton:nil];
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
        [self setupViews];
}

- (void)close:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)setupViews
{
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
        
        UIScrollView *tempScrollView=(UIScrollView *)self.view;
        tempScrollView.contentSize=CGSizeMake(320,500);
        [tempScrollView setScrollEnabled:NO];
        
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
        UIScrollView *tempScrollView=(UIScrollView *)self.view;
        tempScrollView.contentSize=CGSizeMake(480,420);
        [tempScrollView setScrollEnabled:YES];
    }
    
    UIImage *buttonImage = [[UIImage imageNamed:@"button.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"buttonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(close:)];
    [cancelButton setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [cancelButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[self navigationItem] setRightBarButtonItem:cancelButton];

}

- (IBAction)upgradeToPremium:(id)sender {
    // First, ensure that the SKProduct that was requested by
    // the EBPurchase requestProduct method in the viewWillAppear
    // event is valid before trying to purchase it.
    
    if (![[BBSinappPurchase sharedPurchase] purchaseProduct]) {
        // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
        UIAlertView *settingsAlert = [[UIAlertView alloc] initWithTitle:@"Allow Purchases" message:@"You must first enable In-App Purchase in your iOS Settings before making this purchase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [settingsAlert show];
    }
}

- (IBAction)restorePurchase:(id)sender {
    // Restore a customer's previous non-consumable or subscription In-App Purchase.
    // Required if a user reinstalled app on same device or another device.
    
    // Call restore method.
    if (![[BBSinappPurchase sharedPurchase] restoreProduct])
    {
        // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
        UIAlertView *settingsAlert = [[UIAlertView alloc] initWithTitle:@"Allow Purchases" message:@"You must first enable In-App Purchase in your iOS Settings before restoring a previous purchase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [settingsAlert show];
    }
}

- (void)requestedProduct:(id)sender
{
    NSString *productPrice = [[sender userInfo] valueForKey:@"productPrice"];
    
    if (productPrice != nil)
    {
        // Product is available, so update button title with price.
        
        [upgradeButton setTitle:[@"Upgrade to Premium " stringByAppendingString:productPrice] forState:UIControlStateNormal];
        upgradeButton.enabled = YES; // Enable buy button.
        restoreButton.enabled = YES;
        
    } else {
        // Product is NOT available in the App Store, so notify user.
        
        upgradeButton.enabled = NO; // Ensure buy button stays disabled.
        [upgradeButton setTitle:@"Upgrade to Premium" forState:UIControlStateNormal];
        
        UIAlertView *unavailAlert = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"This In-App Purchase item is not available in the App Store at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [unavailAlert show];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successfulPurchase:) name:@"successfulPurchase" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPurchase:) name:@"failedPurchase" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incompleteRestore:) name:@"incompleteRestore" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedRestore:) name:@"failedRestore" object:nil];
}


- (void)successfulPurchase:(id)sender
{
    BOOL isPurchased = [[[sender userInfo] valueForKey:@"isPurchased"] boolValue];
    BOOL isRestore = [[[sender userInfo] valueForKey:@"isRestore"] boolValue];
    // Purchase or Restore request was successful, so...
    // 1 - Unlock the purchased content for your new customer!
    // 2 - Notify the user that the transaction was successful.
    
    if (!isPurchased)
    {
        // If paid status has not yet changed, then do so now. Checking
        // isPurchased boolean ensures user is only shown Thank You message
        // once even if multiple transaction receipts are successfully
        // processed (such as past subscription renewals).
        
        
        //-------------------------------------
        
        // 1 - Unlock the purchased content and update the app's stored settings.
        
        //-------------------------------------
        
        // 2 - Notify the user that the transaction was successful.
        
        NSString *alertMessage;
        
        if (isRestore) {
            // This was a Restore request.
            alertMessage = @"Your purchase was restored and Corgi Fetch Premium is now unlocked!";
            
        } else {
            // This was a Purchase request.
            alertMessage = @"Your purchase was successful and Corgi Fetch Premium is now unlocked!";
        }
        
        UIAlertView *updatedAlert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [updatedAlert show];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self close:nil];
}


- (void)failedPurchase:(id)sender
{    
    // Purchase or Restore request failed or was cancelled, so notify the user.
    
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Purchase Stopped" message:@"Either you cancelled the request or Apple reported a transaction error. Please try again later, or contact me for assistance at me@billyshih.com." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failedAlert show];
}

- (void)incompleteRestore:(id)sender
{    
    // Restore queue did not include any transactions, so either the user has not yet made a purchase
    // or the user's prior purchase is unavailable, so notify user to make a purchase within the app.
    // If the user previously purchased the item, they will NOT be re-charged again, but it should
    // restore their purchase.
    
    UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:@"Restore Issue" message:@"A prior purchase transaction could not be found. To restore the purchased product, tap the Buy button. Paid customers will NOT be charged again, but the purchase will be restored." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [restoreAlert show];

}

- (void)failedRestore:(id)sender
{
    
    // Restore request failed or was cancelled, so notify the user.
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Restore Stopped" message:@"Either you cancelled the request or your prior purchase could not be restored. Please try again later, or contact me for assistance at me@billyshih.com." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failedAlert show];
}

@end
