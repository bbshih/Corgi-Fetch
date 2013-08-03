//
//  YTVVideoDetailViewController.m
//  Corgi Fetch
//
//  Created by Billy Shih on 8/20/12.
//
//

#import "BBSVideoDetailViewController.h"
#import "UILabel+VerticalAlign.h"
#import "UIApplicationAddition.h"

@interface BBSVideoDetailViewController ()

@end

@implementation BBSVideoDetailViewController

@synthesize sourceButton;
@synthesize v;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    [self setTitle:@"Details"];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]]];
    
    [videoTitle setText:[v title]];
    [videoTitle alignTop];
    
    [videoThumbnail setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[v thumbURL]]]]];

    [author setText:[v author]];
    
    // Set date    
    // define the range you're interested in
    NSRange stringRange = {0, MIN([[v datePublished] length], 19)};
    
    // adjust the range to include dependent chars
    stringRange = [[v datePublished] rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *shortString = [[v datePublished] substringWithRange:stringRange];
    
    shortString = [shortString stringByAppendingString:@"Z"];
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [rfc3339DateFormatter dateFromString:shortString];

    NSString *userVisibleDateTimeString;
    if (date != nil) {
        // Convert the date object to a user-visible date string.
        NSDateFormatter *userVisibleDateFormatter = [[NSDateFormatter alloc] init];
        assert(userVisibleDateFormatter != nil);
        
        [userVisibleDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [userVisibleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        userVisibleDateTimeString = [userVisibleDateFormatter stringFromDate:date];
    }
    

    [dateCreated setText:userVisibleDateTimeString];
    
    
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://www.youtube.com/watch?v=%@",[v ytVideoCode]]];
    sourceURL = url;
    
    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *backImg = [UIImage imageNamed:@"backButton.png"];
    UIImage *backImgHighlight = [UIImage imageNamed:@"backButtonHighlight.png"];
    [button setImage:backImg forState:UIControlStateNormal];
    [button setImage:backImgHighlight forState:UIControlStateHighlighted];
    
    UIImage *buttonGrayImage;
    buttonGrayImage = [[UIImage imageNamed:@"buttonGray.png"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonGrayHighlightImage;
    buttonGrayHighlightImage = [[UIImage imageNamed:@"buttonGrayHighlight.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [[self sourceButton] setBackgroundImage:buttonGrayImage forState:UIControlStateNormal];
    [[self sourceButton] setBackgroundImage:buttonGrayHighlightImage forState:UIControlStateHighlighted];

    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, backImg.size.width, backImg.size.height);

    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];

    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    

}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setSourceButton:nil];
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

- (IBAction)openSourceLink:(id)sender {
    [[UIApplication sharedApplication] openURL:sourceURL];
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

@end
