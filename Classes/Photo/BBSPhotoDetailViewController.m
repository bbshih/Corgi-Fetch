//
//  PhotoDetailViewController.m
//  Corgi Fetch
//
//  Created by Billy Shih on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSPhotoDetailViewController.h"
#import "Photo.h"
#import "UIApplicationAddition.h"
#import "UILabel+VerticalAlign.h"

@interface BBSPhotoDetailViewController ()

@end

@implementation BBSPhotoDetailViewController
@synthesize sourceButton;
@synthesize thumbnailImage;
@synthesize titleLabel;
@synthesize owner_nameLabel;
@synthesize dateLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPhoto:(Photo *)p
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        photo = p;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]]];
    [self setTitle:@"Photo Details"];
    
    NSURL *thumbURL = [NSURL URLWithString:[photo thumbURL]];
    NSData *data = [NSData dataWithContentsOfURL:thumbURL];
    [thumbnailImage setImage:[UIImage imageWithData:data]];
    [titleLabel setText:[photo title]];
    [titleLabel alignTop];

    [owner_nameLabel setText:[photo owner_name]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[photo date] doubleValue]];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    [dateLabel setText:[dateFormatter stringFromDate:date]];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    [self setThumbnailImage:nil];
    [self setTitleLabel:nil];
    [self setOwner_nameLabel:nil];
    [self setDateLabel:nil];
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

- (IBAction)sourceButtonTouch:(id)sender {
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", photo.flickrID]];
    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:instagramURL];
    
    if(canOpenURL) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:photo.sourceURL]];
    }
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [[[self navigationController] navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                             [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22.0f],
                                                                             UITextAttributeFont,
                                                                             [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f],
                                                                             UITextAttributeTextShadowColor,
                                                                             [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5f)],
                                                                             UITextAttributeTextShadowOffset, nil]];
        [[[self navigationController] navigationBar] setTitleVerticalPositionAdjustment:-3.0f forBarMetrics:UIBarMetricsDefault];
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
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
