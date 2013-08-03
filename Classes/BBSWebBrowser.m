//
//  CFWebBrowser.m
//  CorgiFetch
//
//  Created by Billy Shih on 10/15/12.
//
//

#import "BBSWebBrowser.h"

@interface BBSWebBrowser ()

@end

@implementation BBSWebBrowser

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.barStyle = UIBarStyleBlack;
        
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
	// Do any additional setup after loading the view.
         
    if([self interfaceOrientation] == UIInterfaceOrientationPortrait || [self interfaceOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
        [[self.navigationController navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22.0f],
                                                                           UITextAttributeFont,
                                                                           [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f],
                                                                           UITextAttributeTextShadowColor,
                                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5f)],
                                                                           UITextAttributeTextShadowOffset, nil]];
        [[self.navigationController navigationBar] setTitleVerticalPositionAdjustment:-3.0f forBarMetrics:UIBarMetricsDefault];
    } else if ([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft || [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight) {
        [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"landscapeNav.png"] forBarMetrics:UIBarMetricsLandscapePhone];
        
        [[self.navigationController navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f],
                                                                           UITextAttributeFont,
                                                                           [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f],
                                                                           UITextAttributeTextShadowColor,
                                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5f)],
                                                                           UITextAttributeTextShadowOffset, nil]];
        [[self.navigationController navigationBar] setTitleVerticalPositionAdjustment:-2.0f forBarMetrics:UIBarMetricsLandscapePhone];
    }
    
    
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
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    [[[self navigationController] navigationBar] removeGestureRecognizer:self.panGestureRecognizer];
    self.panGestureRecognizer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
