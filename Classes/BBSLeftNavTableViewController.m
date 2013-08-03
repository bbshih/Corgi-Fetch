//
//  OverviewViewController.m
//  CorgiFetch
//
//  Created by Billy Shih on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSLeftNavTableViewController.h"
#import "BBSVideoTableViewController.h"
#import "ZUUIRevealController.h"
#import "BBSPhotoFGalleryViewController.h"
#import "BBSAboutViewController.h"
#import "BBSPhotoStore.h"
#import "UIApplicationAddition.h"
#import "BBSWebBrowser.h"
#import "BBSInAppPurchaseViewController.h"
#import "BBSAppDelegate.h"
#import "BBSFeedbackUIViewController.h"
#import "Config.h"

@interface BBSLeftNavTableViewController ()

@end

@implementation BBSLeftNavTableViewController
@synthesize overviewTableView, photoGallery, videoGallery, revealController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setupRows];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"successfulPurchase" object:nil];
    
    [[self tableView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"retro_intro.png"]]];
     
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setOverviewTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)reloadData
{
    [self setupRows];
    [[self tableView] reloadData];
}

- (void)setupRows
{
    NSString *photosImage = [NSString stringWithFormat:@"42-photosgrey.png"];
    NSString *photosSelectedImage = [NSString stringWithFormat:@"42-photoswhite.png"];
    NSString *videosImage = [NSString stringWithFormat:@"280-clapboardgrey.png"];
    NSString *videosSelectedImage = [NSString stringWithFormat:@"280-clapboardwhite.png"];
    NSString *blogImage = [NSString stringWithFormat:@"stickynote.png"];
    NSString *blogSelectedImage = [NSString stringWithFormat:@"stickynotewhite.png"];
    NSString *aboutImage = [NSString stringWithFormat:@"42-infogrey.png"];
    NSString *aboutSelectedImage = [NSString stringWithFormat:@"42-infowhite.png"];
    NSString *feedbackImage = [NSString stringWithFormat:@"heart.png"];
    NSString *feedbackSelectedImage = [NSString stringWithFormat:@"heartwhite.png"];
    //        NSString *facebookImage = [NSString stringWithFormat:@"facebook.png"];
    //        NSString *facebookSelectedImage = [NSString stringWithFormat:@"facebookwhite.png"];
    //        NSString *twitterImage = [NSString stringWithFormat:@"twitter.png"];
    //        NSString *twitterSelectedImage = [NSString stringWithFormat:@"twitterwhite.png"];
    
    
    NSDictionary *photos = [[NSDictionary alloc] initWithObjectsAndKeys:@"Photos", @"text", photosImage, @"image", photosSelectedImage, @"selectedImage", nil];
    NSDictionary *videos = [[NSDictionary alloc] initWithObjectsAndKeys:@"Videos", @"text", videosImage, @"image", videosSelectedImage, @"selectedImage", nil];
    NSDictionary *blog = [[NSDictionary alloc] initWithObjectsAndKeys:@"Blog", @"text", blogImage, @"image", blogSelectedImage, @"selectedImage", nil];
    NSDictionary *about = [[NSDictionary alloc] initWithObjectsAndKeys:@"About", @"text", aboutImage, @"image", aboutSelectedImage, @"selectedImage", nil];
    NSDictionary *feedback = [[NSDictionary alloc] initWithObjectsAndKeys:@"Feedback", @"text", feedbackImage, @"image", feedbackSelectedImage, @"selectedImage", nil];
    //        NSDictionary *facebook = [[NSDictionary alloc] initWithObjectsAndKeys:@"Like Us", @"text", facebookImage, @"image", facebookSelectedImage, @"selectedImage", nil];
    //        NSDictionary *twitter = [[NSDictionary alloc] initWithObjectsAndKeys:@"Follow Us", @"text", twitterImage, @"image", twitterSelectedImage, @"selectedImage", nil];
    
    if ([(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium] ) {
        menuArray = [NSArray arrayWithObjects: photos, videos, blog, about, feedback, nil];
    } else {
        NSString *premiumImage = [NSString stringWithFormat:@"star.png"];
        NSString *premiumSelectedImage = [NSString stringWithFormat:@"starwhite.png"];
        
        NSDictionary *premium = [[NSDictionary alloc] initWithObjectsAndKeys:@"Premium Upgrade", @"text", premiumImage, @"image", premiumSelectedImage, @"selectedImage", nil];
        
        menuArray = [NSArray arrayWithObjects: premium, photos, videos, blog, about, feedback, nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsSupportedOrientation(toInterfaceOrientation);
}


-(BOOL)shouldAutorotate {
    return false;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *selection = [menuArray objectAtIndex:[indexPath row]];

    UIImage *image = [UIImage imageNamed:[selection objectForKey:@"image"]];
    UIImage *selectedImage = [UIImage imageNamed:[selection objectForKey:@"selectedImage"]];
    NSString *text = [selection objectForKey:@"text"];
    
    [[cell imageView] setImage:image];
    [[cell imageView] setHighlightedImage:selectedImage];
    [[cell textLabel] setText:text];

    UIView *bgView = [[UIView alloc] init];    
    [bgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"retro_introSelected.png"]]];
    [cell setSelectedBackgroundView:bgView];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath row];

    // If purchased, adjust index by 1 since the first choice (Premium upgrade) is deleted
    if ([(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium]) {
        index+=1;
    }
    
    switch (index)
    {
        case 0: {
            BBSInAppPurchaseViewController *purchaseVC = [[BBSInAppPurchaseViewController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:purchaseVC];
            [self presentViewController:navController animated:YES completion:nil];
            break;
        }
        case 1:
            if ([revealController.frontViewController isKindOfClass:[UINavigationController class]] && ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[BBSPhotoFGalleryViewController class]])
            {
                if(!photoGallery) {
                    BBSPhotoFGalleryViewController *frontViewController = [[BBSPhotoFGalleryViewController alloc] initWithPhotoSource:[BBSPhotoStore sharedStore]];
                    [frontViewController setBeginsInThumbnailView:YES];
                    
                    photoGallery = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                }
                [revealController setFrontViewController:photoGallery];
            } else {
                [revealController revealToggle:self];
            }
            break;
        case 2:
            if ([revealController.frontViewController isKindOfClass:[UINavigationController class]] && ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[BBSVideoTableViewController class]])
            {
                if (!videoGallery) {
                    BBSVideoTableViewController *frontViewController = [[BBSVideoTableViewController alloc] init];
                    videoGallery = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                }
                [revealController setFrontViewController:videoGallery];
            } else {
                [revealController revealToggle:self];
            }
            break;
        case 3: {
            BBSWebBrowser *webBrowser = [[BBSWebBrowser alloc] initWithUrl:[NSURL URLWithString:kBlogURL]];
            webBrowser.showPageTitleOnTitleBar = NO;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webBrowser];
            
            webBrowser.title = @"Fetch: Blog";
            
            [revealController setFrontViewController:navController];
            break;
        }
        case 4: {
            BBSAboutViewController *avc = [[BBSAboutViewController alloc] init];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:avc];
            [revealController setFrontViewController:navController];
            break;
        }
        case 5: {
            BBSFeedbackUIViewController *fvc = [[BBSFeedbackUIViewController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fvc];
            [revealController setFrontViewController:navController];
        }
//        case 5: {
//            
//            NSString *fbURL = @"fb://profile/153494528124839";
//            BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:fbURL]];
//            
//            if(canOpenURL) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbURL]];
//            } else {
//                
//                CFWebBrowser *webBrowser = [[CFWebBrowser alloc] initWithUrl:[NSURL URLWithString:kFacebookURL]];
//                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowser];
//                
//                [revealController setFrontViewController:navigationController];
//            }
//            
//        }
//        case 6: {
//            
//            NSString *twURL = @"twitter://user?screen_name=corgifetch";
//            BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:twURL]];
//            
//            if(canOpenURL) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twURL]];
//            } else {
//                CFWebBrowser *webBrowser = [[CFWebBrowser alloc] initWithUrl:[NSURL URLWithString:kTwitterURL]];
//                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowser];
//                
//                [revealController setFrontViewController:navigationController];
//            }
        default:
            break;
    }
    

    
}

@end
