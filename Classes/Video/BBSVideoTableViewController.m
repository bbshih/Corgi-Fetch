//
//  YTVTableViewController.m
//  CorgiFetch
//
//  Created by Billy Shih on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSVideoTableViewController.h"
#import "BBSVideoTableCell.h"
#import "VideoStore.h"
#import "Video.h"
#import "BBSLeftNavTableViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "LBYouTubePlayerViewController.h"
#import "UILabel+VerticalAlign.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SHK.h"
#import "SVProgressHUD.h"
#import "BBSVideoDetailViewController.h"
#import "BBSInAppPurchaseViewController.h"
#import "UIApplicationAddition.h"
#import "BBSAppDelegate.h"

#define kNoPremiumLimit 61
NSString *const kVideoSortTypeDefault = @"relevance";
NSString *const kVideoSortTypePopular = @"relevance";
NSString *const kVideoSortTypeNewest = @"published";
NSString *const kVideoSortTypeViewCount = @"viewCount";
NSString *const kVideoSortTypeRating = @"rating";
NSString *const kVideoSortTypeFavorites = @"favorites";
NSInteger const kVideoDataIncrements = 30;

@interface BBSVideoTableViewController ()

@end

@implementation BBSVideoTableViewController

@synthesize panGestureRecognizer = _panGestureRecognizer;

- (id)init
{
    // only kind of init that should run unless saved
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        dataStartIndex = 1;
        buttonImage = [[UIImage imageNamed:@"button.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        buttonImageHighlight = [[UIImage imageNamed:@"buttonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
   }
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    // Ignore this kind of init and do the standard
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupPremium) name:@"successfulPurchase" object:nil];

    [[VideoStore sharedStore] deleteAllVideos];
    
    UINib *nib = [UINib nibWithNibName:@"BBSVideoTableCell" bundle:nil];
    
    [[self tableView] registerNib:nib
           forCellReuseIdentifier:@"BBSVideoTableCell"];
    
    UINib *nibLandscape = [UINib nibWithNibName:@"BBSVideoTableCellLandscape" bundle:nil];
    
    [[self tableView] registerNib:nibLandscape
           forCellReuseIdentifier:@"BBSVideoTableCellLandscape"];
    
    UINavigationItem *n = [self navigationItem];
    [n setTitle:@"Fetch: Videos"];
    
    [[self tableView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]]];
    
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
    
    // Adds sort button
    if ([self respondsToSelector:@selector(showSortMenu:)])
    {

        // Set the background for any states you plan to use

        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", @"") style:UIBarButtonItemStylePlain target:self action:@selector(showSortMenu:)];
        [btn setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [btn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [self.navigationItem setRightBarButtonItem:btn animated:YES];
    }
    
    [self addFetchButton];
    
    // Checks for blank values and sets them
    NSArray *keys = [NSArray arrayWithObjects:@"videoSortType", @"fetchVideoSortType", nil];
    NSArray *defaultValues = [NSArray arrayWithObjects:kVideoSortTypeDefault, kVideoSortTypeDefault, nil];
    for(NSInteger i = 0; i < [keys count]; i++){
        id object = [[NSUserDefaults standardUserDefaults] objectForKey:[keys objectAtIndex:i]];
        if(!object) {
            [[NSUserDefaults standardUserDefaults] setObject:[defaultValues objectAtIndex:i] forKey:[keys objectAtIndex:i]];
        }
    }
    
    // Loads values
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    sortType = [defaults objectForKey:@"videoSortType"];
    fetchSortType = [defaults objectForKey:@"fetchVideoSortType"];
    NSLog(@"Loading sortType: %@ - fetchSortType: %@", sortType, fetchSortType);
        
    firstLoad = YES;
}

- (void)viewDidUnload
{
    
    [[[self navigationController] navigationBar] removeGestureRecognizer:self.panGestureRecognizer];
    self.panGestureRecognizer = nil;
    [super viewDidUnload];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveDefaults];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupView:[self interfaceOrientation]];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (firstLoad) {
        [self fetchVideosWithNewSortType:YES];
    }
}

- (void)addFetchButton
{
    // Makes the moreButton nib a view and then by adding it to the footer view, causes its creation
    if (sortType != kVideoSortTypeFavorites) {
        UINib *showMoreNib = [UINib nibWithNibName:@"moreButton" bundle:[NSBundle mainBundle]];
        loadingView = [[showMoreNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        [loadingView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]]];
        [[self tableView] setTableFooterView:loadingView];
    }
}

- (void)saveDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Saving sortType: %@ - fetchSortType: %@", sortType, fetchSortType);
    [defaults setObject:sortType forKey:@"videoSortType"];
    [defaults setObject:fetchSortType forKey:@"fetchVideoSortType"];
    [defaults synchronize];
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

- (void)addFavoriteVideo:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    if ([[VideoStore sharedStore] showFavorites] == YES) {
        selectedVideo = [indexPath row];
        UIAlertView *removeAlert = [[UIAlertView alloc] initWithTitle:@"Remove Favorite" message:@"Are you sure you want to remove this video from your favorites?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [removeAlert show];
    } else {
        Video *videoToSave = [[[VideoStore sharedStore] allVideos] objectAtIndex:[indexPath row]];
        [[VideoStore sharedStore] addFavoriteVideo:videoToSave];
        
        [self saveChangesWithSuccessMessage:@"Favorite Added"];
    }
}

-(IBAction) showMoreRows {
    // Button action to load more rows
    if (!fetchingVideos)
    {
        [self fetchVideosWithNewSortType:NO];
    }
}

- (void)showDetails:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    Video *v = [[[VideoStore sharedStore] allVideos] objectAtIndex:[indexPath row]];
    
    BBSVideoDetailViewController *detailView = [[BBSVideoDetailViewController alloc] initWithNibName:@"YTVVideoDetailViewController" bundle:nil];
    
    [detailView setV:v];
    
    [[self navigationController] pushViewController:detailView animated:YES];
}


- (void)playVideo:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:@"Fetching Video" maskType:SVProgressHUDMaskTypeGradient];
    BBSVideoTableCell *cell = (BBSVideoTableCell*)[[self tableView] cellForRowAtIndexPath:indexPath];
    Video *v = [[[VideoStore sharedStore] allVideos] objectAtIndex:[indexPath row]];
    
    videoPlayer = [[LBYouTubePlayerViewController alloc] initWithYouTubeID:[v ytVideoCode]];
    videoPlayer.delegate = self;
    videoPlayer.quality = LBYouTubePlayerQualityLarge;
    videoPlayer.view.frame = CGRectMake( 0, 0, cell.thumbnailView.frame.size.width, cell.thumbnailView.frame.size.height);
    [[cell thumbnailView] addSubview:videoPlayer.view];
    
    [[cell playVideoButton] setHidden:YES];
    
    // Removes SVProgressHUD right when full screen enters, so that it doesn't flash briefly and then get removed once the movie ends
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeLoadingScreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:cell
                                             selector:@selector(closeMovie:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:cell
                                             selector:@selector(closeMovie:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeMovie:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeMovie:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)shareVideo:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    Video *v = [[[VideoStore sharedStore] allVideos] objectAtIndex:[indexPath row]];
    NSString *stringURL = [[NSString alloc] initWithFormat:@"http://www.youtube.com/watch?v=%@",[v ytVideoCode]];
    NSURL *url = [NSURL URLWithString:stringURL];
    
    SHKItem *shareItem = [SHKItem URL:url title:[v title] contentType:SHKURLContentTypeVideo];
    
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:shareItem];
    [actionSheet showFromToolbar:[[self navigationController] toolbar]];
}

- (void)removeLoadingScreen:(NSNotification *)notification{
    [SVProgressHUD dismiss];
}

- (void)closeMovie:(NSNotification *)notification {
    if(videoPlayer)
    {
        NSLog(@"closing movie");
        NSDictionary* userInfo = [notification userInfo];
        MPMovieFinishReason finishReason = [[userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (finishReason == MPMovieFinishReasonPlaybackError) {
            NSLog(@"video loading error");
            [SVProgressHUD dismiss];
        }
        
        [[[videoPlayer view] controller] setFullscreen:NO animated:YES];
        [[videoPlayer view] removeFromSuperview];
        videoPlayer = nil;
    }
}

- (void)showSortMenu:(id)sender
{
    // Adds checkmark to the currently selected sort
    NSString *checkmark = @"✔ ";
    
    NSString *favorites = @"Favorites";    
    NSString *popular = @"Popular";
    NSString *newest = @"Newest";
    NSString *mostViews = @"Most Views";
    NSString *rating = @"Rating";
    
    if ([sortType isEqualToString:kVideoSortTypePopular] ) {
        popular = [checkmark stringByAppendingString:popular];
    } else if ([sortType isEqualToString:kVideoSortTypeNewest]) {
        newest = [checkmark stringByAppendingString:newest];
    } else if ([sortType isEqualToString:kVideoSortTypeViewCount]) {
        mostViews = [checkmark stringByAppendingString:mostViews];
    } else if ([sortType isEqualToString:kVideoSortTypeRating]) {
        rating = [checkmark stringByAppendingString:rating];
    } else if ([sortType isEqualToString:kVideoSortTypeFavorites]) {
        favorites = [checkmark stringByAppendingString:favorites];
    }
    
    UIActionSheet *sortChooser = [[UIActionSheet alloc] initWithTitle:@"Sort by:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:favorites, popular, newest, mostViews, rating, nil];
    [sortChooser showFromBarButtonItem:sender animated:YES];
    
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupView:(toInterfaceOrientation)];
}

- (void)setupView:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(!toInterfaceOrientation) {
        toInterfaceOrientation = [self interfaceOrientation];
    }
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
        
        [[self tableView] setRowHeight:205.0f];
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
        
        [[self tableView] setRowHeight:170.0f];
    }
    [[self tableView] reloadData];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[VideoStore sharedStore] allVideos] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    if ([self interfaceOrientation] == UIInterfaceOrientationPortrait) {
        CellIdentifier = @"BBSVideoTableCell";
    } else {
        CellIdentifier = @"BBSVideoTableCellLandscape";
    }

    BBSVideoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[BBSVideoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setController:self];
    [cell setTableView:[self tableView]];
    
    Video *v = [[[VideoStore sharedStore] allVideos] objectAtIndex:[indexPath row]];;

    [[cell thumbnailView] setImageWithURL:[NSURL URLWithString:[v thumbURL] ] placeholderImage:[UIImage imageNamed:@"big-46-movie-2.png"]];
    [[cell titleLabel] setText:[v title]];
    [[cell titleLabel] alignBottom];
    
    NSString *durationString = [NSString stringWithFormat:@"%d:%.02d", [[v duration] intValue]/60, [[v duration] intValue]%60];
    [[cell timeLabel] setText:durationString];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    NSArray *buttonArray = [NSArray arrayWithObjects:[cell shareButton], [cell favoriteButton], [cell detailsButton], nil];
    UIImage *buttonGrayImage;
    buttonGrayImage = [[UIImage imageNamed:@"buttonGray.png"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonGrayHighlightImage;
    buttonGrayHighlightImage = [[UIImage imageNamed:@"buttonGrayHighlight.png"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    for(UIButton *btn in buttonArray) {
        [btn setBackgroundImage:buttonGrayImage forState:UIControlStateNormal];
        [btn setBackgroundImage:buttonGrayHighlightImage forState:UIControlStateHighlighted];
    }
    
    return cell;
}

- (void)saveChanges
{
    BOOL success = [[VideoStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all videos");
    } else {
        NSLog(@"Could not save videos");
    }
}

- (void)saveChangesWithSuccessMessage:(NSString *)message
{
    BOOL success = [[VideoStore sharedStore] saveChanges];
    if (success) {
        [SVProgressHUD showSuccessWithStatus:message];
        NSLog(@"Saved all videos");
    } else {
        NSLog(@"Could not videos");
    }
}

- (void)scrollViewDidScroll:(UIScrollView*) scroll {
    // UITableView only moves in one direction, y axis
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    // Change to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 1500.0 && !fetchingVideos && ![sortType isEqualToString:kVideoSortTypeFavorites]) {
        if (![(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium] && dataStartIndex >= kNoPremiumLimit) {
            UINib *buyPremiumFooterNib = [UINib nibWithNibName:@"buyPremiumFooter" bundle:[NSBundle mainBundle]];
            UIView *buyPremiumFooter = [[buyPremiumFooterNib instantiateWithOwner:self options:nil] objectAtIndex:0];;
            UIButton *learnMoreButton = (UIButton *)[buyPremiumFooter viewWithTag:1001];
            [learnMoreButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [learnMoreButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
            [[self tableView] setTableFooterView:buyPremiumFooter];
            return;
        }
        NSLog(@"Autofetching more videos");
        [self fetchVideosWithNewSortType:NO];
    }
}

- (void)setupPremium {
    [self addFetchButton];
    [self fetchVideosWithNewSortType:NO];
}

- (void)fetchVideosWithNewSortType:(BOOL)fetchNew
{
    if ([sortType isEqualToString:fetchSortType] && !firstLoad && fetchNew) { // Returns if asks for existing sort that is loaded
        return;
    } else if (fetchNew || firstLoad) { //Sets up first time view of a sort, whether its first time the app started or a new sort
        if ([fetchSortType isEqualToString:kVideoSortTypeFavorites]) {
            [[VideoStore sharedStore] setShowFavorites:YES];
            if ([[[VideoStore sharedStore] allVideos] count] == 0 ) {
                [SVProgressHUD showErrorWithStatus:@"You have not marked any favorites"];
                [[VideoStore sharedStore] setShowFavorites:NO];
                fetchSortType = sortType;
            } else {
                [SVProgressHUD showWithStatus:@"Fetching Videos" maskType:SVProgressHUDMaskTypeGradient];
                [[VideoStore sharedStore] setShowFavorites:NO];
                [[VideoStore sharedStore] deleteAllVideos];
                [[VideoStore sharedStore] setShowFavorites:YES];
                [[VideoStore sharedStore] loadAllVideos];
                [[self tableView] reloadData];
                [[[self tableView] tableFooterView] removeFromSuperview];
                [[self tableView] setTableFooterView:nil];

                [SVProgressHUD dismiss];
                sortType = fetchSortType;
                [self saveDefaults];
                [[self tableView] setContentOffset:CGPointZero animated:NO]; // Scroll back to top
            }
            return;
        } else {
            [[VideoStore sharedStore] setShowFavorites:NO];
                        NSLog(@"showFavorites:NO");
        }
        [SVProgressHUD showWithStatus:@"Fetching videos" maskType:SVProgressHUDMaskTypeGradient];
        fetchDataStartIndex = 1;
    } else {
        if (dataStartIndex>999) {
            UINib *showMoreNib = [UINib nibWithNibName:@"videoEnd" bundle:[NSBundle mainBundle]];
            loadingView = [[showMoreNib instantiateWithOwner:self options:nil] objectAtIndex:0];
            [loadingView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]]];
            [[self tableView] setTableFooterView:loadingView];
            return;
        }
        // Setup existing sort fetches
        fetchDataStartIndex = dataStartIndex;
    }
    
    fetchingVideos = YES;
    
    xmlData = [[NSMutableData alloc] init];
    
    // Example URL
    // http://gdata.youtube.com/feeds/api/videos?q=corgi&start-index=1&max-results=50&v=2&fields=entry%5Blink/@rel='http://gdata.youtube.com/schemas/2007%23mobile'%5D
    NSString *urlRequest = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?category=corgi%%2C%%2Dgaming&orderby=%@&start-index=%u&max-results=%u&v=2&fields=entry[link/@rel='http://gdata.youtube.com/schemas/2007%%23mobile']", fetchSortType, fetchDataStartIndex, kVideoDataIncrements];
    
    NSURL *url = [NSURL URLWithString:urlRequest];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req
                                                 delegate:self
                                         startImmediately:YES];
    NSLog(@"Connected to Youtube feed");
}

- (IBAction)learnMore:(id)sender{
    [self showPremiumView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]];
}

#pragma mark NSXMLParserDelegate Methods
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{

    if(![fetchSortType isEqualToString:sortType]) {
        [[self tableView] setContentOffset:CGPointZero animated:NO]; // Scroll back to top
        sortType = fetchSortType;
        [[VideoStore sharedStore] deleteAllVideos];
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];
    xmlData = nil;
    connection = nil;
    
    [[self tableView] reloadData];
    [self addFetchButton];
    [SVProgressHUD dismiss];
    fetchingVideos = NO;
    dataStartIndex += kVideoDataIncrements;
    firstLoad = NO;
    [self saveDefaults];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    if ([sortType isEqualToString:kVideoSortTypeFavorites]) {
        [[VideoStore sharedStore] setShowFavorites:YES];
                    NSLog(@"showFavorites:YES");
    }
    
    connection = nil;
    xmlData = nil;
    
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", [error localizedDescription]];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
    fetchingVideos = NO;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // NSLog(@"%@ found a %@ element", self, elementName);

    // Need a way to assign the title and videoid to the same YTVVideo
    // Since title is before video id, I set it up one after another relying on lastObject to find
    // the same item
    if ([elementName isEqual:@"name"]) {
        currentString = [[NSMutableString alloc] init];
        Video *v = [[VideoStore sharedStore] createVideo];
        [v setAuthor:currentString];
    } else if ([elementName isEqual:@"media:thumbnail"] && [[attributeDict valueForKey:@"yt:name"] isEqual:@"mqdefault"]) {
        currentString = [[NSMutableString alloc] initWithString:[attributeDict valueForKey:@"url"]];
        Video *v = [[[VideoStore sharedStore] allVideos] lastObject];
        [v setThumbURL:currentString];
    } else if ([elementName isEqual:@"media:title"]) {
        currentString = [[NSMutableString alloc] init];
        Video *v = [[[VideoStore sharedStore] allVideos] lastObject];
        [v setTitle:currentString];
    } else if([elementName isEqual:@"yt:duration"]) {
        Video *v = [[[VideoStore sharedStore] allVideos] lastObject];
        NSNumber *duration = [NSNumber numberWithInt:[[attributeDict valueForKey:@"seconds"] intValue] - 1]; // Time is off by 1 second
        [v setDuration:duration];
    } else if([elementName isEqual:@"yt:uploaded"]) {
        currentString = [[NSMutableString alloc] init];
        Video *v = [[[VideoStore sharedStore] allVideos] lastObject];
        [v setDatePublished:currentString];
    } else if([elementName isEqual:@"yt:videoid"]) {
        currentString = [[NSMutableString alloc] init];
        Video *v = [[[VideoStore sharedStore] allVideos] lastObject]; 
        [v setYtVideoCode:currentString];
    } 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    [currentString appendString:str];
//    if(currentString)
//        NSLog(@"Adding: %@", currentString);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    currentString = nil;
}


#pragma mark UIActionSheet methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if ([sortType isEqualToString:kVideoSortTypeFavorites]) {
                [SVProgressHUD showErrorWithStatus:@"Sort already selected"];
                return;
            } else {
                fetchSortType = kVideoSortTypeFavorites;
                NSLog(kVideoSortTypeFavorites);
            }
            break;
        case 1:
            if ([sortType isEqualToString:kVideoSortTypePopular] ) {
                [SVProgressHUD showErrorWithStatus:@"Sort already selected"];
                return;
            } else {
                fetchSortType = kVideoSortTypePopular;
                NSLog(@"Sort by popular");
            }
            break;
        case 2:
            if ([sortType isEqualToString:kVideoSortTypeNewest]) {
                [SVProgressHUD showErrorWithStatus:@"Sort already selected"];
                return;
            } else {
                if (![(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium]) {
                    [self showPremiumView];
                    return;
                }
                fetchSortType = @"published";
                NSLog(@"Sort by newest");
            }
            break;
        case 3:
            if ([sortType isEqualToString:kVideoSortTypeViewCount ]) {
                [SVProgressHUD showErrorWithStatus:@"Sort already selected"];
                return;
            } else {
                if (![(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium]) {
                    [self showPremiumView];
                    return;
                }
                fetchSortType = kVideoSortTypeViewCount;
                NSLog(@"Sort by view count");
            }
            break;
        case 4:
            if ([sortType isEqualToString:kVideoSortTypeRating]) {
                [SVProgressHUD showErrorWithStatus:@"Sort already selected"];
                return;
            } else {
                if (![(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium]) {
                    [self showPremiumView];
                    return;
                }
                fetchSortType = kVideoSortTypeRating;
                NSLog(@"Sort by rating");
            }
            break;
        default:
            break;
    }
    [self fetchVideosWithNewSortType:YES];
}

- (void)showPremiumView {
    BBSInAppPurchaseViewController *purchaseVC = [[BBSInAppPurchaseViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:purchaseVC];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark LBYouTubePlayerViewControllerDelegate

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    NSLog(@"Did extract video source:%@", videoURL);
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    NSLog(@"Failed loading video due to error:%@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Problem connecting" message:@"Please try playing the video again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    Video *v = [[[VideoStore sharedStore] allVideos] objectAtIndex:selectedVideo];
    switch (buttonIndex) {
        case 0: // Cancel
            break;
        case 1: // Yes to remove

            [[VideoStore sharedStore] removeVideo:v];
            [[VideoStore sharedStore] loadAllVideos];
            [self saveChangesWithSuccessMessage:@"Favorite removed"];
            [[self tableView]reloadData];
            
            break;
        default:
            break;
    }
}

@end
