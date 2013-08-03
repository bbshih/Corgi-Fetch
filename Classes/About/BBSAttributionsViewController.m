//
//  AttributionsViewController.m
//  CorgiFetch
//
//  Created by Billy Shih on 9/13/12.
//
//

#import "BBSAttributionsViewController.h"
#import "UIApplicationAddition.h"
#import "UIApplicationAddition.h"

@interface BBSAttributionsViewController ()

@end

@implementation BBSAttributionsViewController

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
    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *backImg = [UIImage imageNamed:@"backButton.png"];
    UIImage *backImgHighlight = [UIImage imageNamed:@"backButtonHighlight.png"];
    [button setImage:backImg forState:UIControlStateNormal];
    [button setImage:backImgHighlight forState:UIControlStateHighlighted];
    
    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, backImg.size.width, backImg.size.height);
    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    [self setTitle:@"Fetch: Attributions"];
}

- (void)viewDidUnload
{
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

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
