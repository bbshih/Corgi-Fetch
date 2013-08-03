#import "BBSPhotoFGalleryViewController.h"
#import "ZUUIRevealController.h"
#import "BBSPhotoStore.h"
#import "Photo.h"
#import "BBSPhotoDetailViewController.h"
#import "SHK.h"
#import "SVProgressHUD.h"
#import "UIApplicationAddition.h"
#import "BBSInAppPurchaseViewController.h"
#import "BBSAppDelegate.h"
#import "GallerySizing.h"

#define kNoPremiumLimit 3

NSString *const kSortTypeNewest = @"corgi";
NSString *const kSortTypeCorgiFetch = @"corgifetch";
NSString *const kSortTypeFavorite = @"favorites";

#define kSortTypeDefault [NSString stringWithString:kSortTypeNewest]

#define kInstagramTagSearchMethod [NSString stringWithString:@"tags/%@/media/recent"]

NSInteger const kDataIncrements = 48;

@interface BBSPhotoFGalleryViewController ()

@end

@implementation BBSPhotoFGalleryViewController

@synthesize sortType;
@synthesize panGestureRecognizer = _panGestureRecognizer;

- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate> *)photoSrc
{
    self = [super initWithPhotoSource:photoSrc];
    if (self)
    {
        buttonImage = [[UIImage imageNamed:@"button.png"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        buttonImageHighlight = [[UIImage imageNamed:@"buttonHighlight.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
    return self;
}

- (void)loadView //setup for the single image viewer
{
    
    UIImage *favIcon = [UIImage imageNamed:@"82-dog-paw.png"];
    UIBarButtonItem *favButton = [[UIBarButtonItem alloc] initWithImage:favIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleFavButtonTouch:)];
    [_barItems insertObject:favButton atIndex:0];
    
    UIImage *infoIcon = [UIImage imageNamed:@"42-infowhite.png"];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:infoIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleInfoButtonTouch:)];
    [_barItems insertObject:infoButton atIndex:1];     // added first means it shows up on the right, right/left arrows added after this in [super loadview]

    [super loadView];

    _thumbsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]];
    _thumbsView.delegate = self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.state = GalleryStateComplete;
    
    // Use this delegate.instagram property to access instagram data later
    [self setAppDelegate:(BBSAppDelegate*)[[UIApplication sharedApplication] delegate]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDefaults) name:@"UIApplicationDidBecomeActiveNotification" object:nil];


    // Used to load updates and one time actions when a user has no or old data, like a sort type that doesn't exist
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL loadedPhotosOnce = [defaults boolForKey:@"loadedPhotosOnce"];
    if (!loadedPhotosOnce) {
        [defaults setBool:YES forKey:@"loadedPhotosOnce"];
    }
    
    // Checks for blank values and sets them
    NSArray *keys = [NSArray arrayWithObjects:@"sortType", @"fetchSortType", nil];
    NSArray *defaultValues = [NSArray arrayWithObjects:kSortTypeDefault, kSortTypeDefault, nil];
    for(NSInteger i = 0; i < [keys count]; i++){
        id object = [[NSUserDefaults standardUserDefaults] valueForKey:[keys objectAtIndex:i]];
        if(!object || !loadedPhotosOnce) {
            [[NSUserDefaults standardUserDefaults] setObject:[defaultValues objectAtIndex:i] forKey:[keys objectAtIndex:i]];
        }
    }
    
    firstLoad = YES;
    [self loadDefaults];
    [self fetchPhotosWithNewSortType:YES];
}

- (void)viewDidUnload
{
    [[[self navigationController] navigationBar] removeGestureRecognizer:self.panGestureRecognizer];
    self.panGestureRecognizer = nil;
    loadingView = nil;
    fetchActivityIndicator = nil;
    refreshIcon = nil;
    fetchButton = nil;
    backButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)loadDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    sortType = [defaults valueForKey:@"sortType"];
    fetchSortType = [defaults valueForKey:@"fetchSortType"];

}

- (void)saveDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sortType forKey:@"sortType"];
    [defaults setObject:fetchSortType forKey:@"fetchSortType"];
    [defaults synchronize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addRevealButton];
    [self setTitle: @"Fetch: Photos"];

    [self setupFetchButtons];
    [self setupNavigationOrientation:[self interfaceOrientation]];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self setHasMovedToOtherView:NO];    
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

- (void)handleInfoButtonTouch:(id)sender
{
    [self setHasMovedToOtherView:YES];
    Photo *p = [[[BBSPhotoStore sharedStore] allPhotos] objectAtIndex:[self currentIndex]];
    photoDetailViewController  = [[BBSPhotoDetailViewController alloc] initWithPhoto:p];
    [[self navigationController] pushViewController:photoDetailViewController animated:YES];

}

- (void)handleFavButtonTouch:(id)sender
{
    if ([[BBSPhotoStore sharedStore] showFavorites] == YES) {
        UIAlertView *removeAlert = [[UIAlertView alloc] initWithTitle:@"Remove Favorite" message:@"Are you sure you want to remove this photo from your favorites?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [removeAlert setTag:2]; // to differentiate between other alerts
        [removeAlert show];
    } else {
        Photo *photoToSave = [[[BBSPhotoStore sharedStore] allPhotos] objectAtIndex:[self currentIndex]];
        
        [[BBSPhotoStore sharedStore] addFavoritePhoto:photoToSave];
        
        [self saveChangesWithSuccessMessage:@"Favorite Added"];
    }
    
}

- (void)handleShareButtonTouch:(id)sender
{
    // Create url to share
    Photo *p = [[[BBSPhotoStore sharedStore] allPhotos] objectAtIndex:[self currentIndex]];
    NSURL *url =  [NSURL URLWithString:[p sourceURL]];
    NSString *title = [p title];

    SHKItem *item = [SHKItem URL:url title:title contentType:SHKURLContentTypeWebpage];

    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:self];
    
    // Display the action sheet
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)fetchPhotosWithNewSortType:(BOOL)fetchNew
{
    if ([sortType isEqualToString:fetchSortType] && !firstLoad && fetchNew) { // Returns if asks for existing sort that is loaded
        return;
    } else if([fetchSortType isEqualToString:kSortTypeFavorite]) {
        [[BBSPhotoStore sharedStore] setShowFavorites:YES];
        if ([[[BBSPhotoStore sharedStore] allPhotos] count] == 0 ) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"No Favorites Saved" message:@"Press the Paw icon on an individual photo to save as a favorite" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            [[BBSPhotoStore sharedStore] setShowFavorites:NO];
            fetchSortType = sortType;
        } else {
            [SVProgressHUD showWithStatus:@"Fetching Photos" maskType:SVProgressHUDMaskTypeGradient];
            [[BBSPhotoStore sharedStore] loadAllPhotos];
            [self reloadGallery];
            [SVProgressHUD dismiss];
            sortType = fetchSortType;
            [self saveDefaults];
        }
        return;
    }
    
    if (fetchNew || firstLoad) { //Sets up first time view of a sort, whether its first time the app started or a new sort
        fetchingNext = YES;
        dataStartIndex = 0;
        [self setMax_id:nil];
    }
    
    [[BBSPhotoStore sharedStore] setShowFavorites:NO];
    
    [SVProgressHUD showWithStatus:@"Fetching Photos" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *methodStr = [NSString stringWithFormat:kInstagramTagSearchMethod, fetchSortType];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if ([self max_id] && fetchingNext) {
        // Sort type = tag name
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:methodStr, @"method", [self max_id], @"max_id", nil];
    } else {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:methodStr, @"method", nil];
    }
    
    [self.appDelegate.instagram requestWithParams:params
                                    delegate:self];
}

- (void)showSortMenu:(id)sender
{
    // Adds checkmark to the currently loaded sort
    NSString *checkmark = @"✔ ";
    
    NSString *favorites = @"Favorites";
    NSString *newest = @"Newest";
    NSString *corgiFetch = @"Corgi Fetch Community";
    
    if ([sortType isEqualToString:kSortTypeNewest]) {
        newest = [checkmark stringByAppendingString:newest];
    } else if ([sortType isEqualToString:kSortTypeCorgiFetch]) {
        corgiFetch = [checkmark stringByAppendingString:corgiFetch];
    } else if ([sortType isEqualToString:kSortTypeFavorite]) {
        favorites = [checkmark stringByAppendingString:favorites];
    }
    UIActionSheet *sortChooser = [[UIActionSheet alloc] initWithTitle:@"Sort by:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:favorites, newest, corgiFetch, nil];

    [sortChooser showFromBarButtonItem:sender animated:YES];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            fetchSortType = kSortTypeFavorite;
            break;
        case 1:
            fetchSortType = kSortTypeNewest;
            break; 
        case 2:
            fetchSortType = kSortTypeCorgiFetch;
            break;
        default:
            return;
            break;
    }
    [self fetchPhotosWithNewSortType:YES];
}


- (void)showThumbnailViewWithAnimation:(BOOL)animation
{
    [super showThumbnailViewWithAnimation:animation];

    [self setupNavigationOrientation:[self interfaceOrientation]];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", @"") style:UIBarButtonItemStylePlain target:self action:@selector(showSortMenu:)];
    [btn setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [btn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [self.navigationItem setRightBarButtonItem:btn animated:YES];
    
    
    [self addRevealButton];
}


- (void)hideThumbnailViewWithAnimation:(BOOL)animation
{
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [[[self navigationController] navigationBar] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[[self navigationController] navigationBar] setTintColor:nil];
    [super hideThumbnailViewWithAnimation:animation];
 
    [[self.navigationItem leftBarButtonItem] setImage:nil];
    [[self.navigationItem leftBarButtonItem] setTitle:@"Done"];
    [[self.navigationItem leftBarButtonItem] setTarget:self];
    [[self.navigationItem leftBarButtonItem] setAction:@selector(handleSeeAllTouch:)];  
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"212-action2.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButtonTouch:)];
    [self.navigationItem setRightBarButtonItem:btn animated:YES];
    
}

- (IBAction)showMorePhotosButton:(id)sender
{
        if (![(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] premium] && dataStartIndex >= kNoPremiumLimit) {
            [self showPremiumView];
            return;
        }
        fetchingNext = YES;
        firstLoad = NO;
        [self fetchPhotosWithNewSortType:NO];
        [fetchActivityIndicator startAnimating];
        [refreshIcon setHidden:YES];
}

- (IBAction)showPreviousPhotosButton:(id)sender {
    [self setMax_id:[self min_id]];
    fetchingNext = NO;
    firstLoad = NO;
    [self fetchPhotosWithNewSortType:NO];
    [fetchActivityIndicator startAnimating];
    [refreshIcon setHidden:YES];
}

- (IBAction)learnMore:(id)sender{
    [self showPremiumView];
}

- (void)addRevealButton
{
    // actions to load the background navigation view
    if (_isThumbViewShowing && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)])
    {
        UIImage *revealIcon = [UIImage imageNamed:@"menu-icon.png"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithImage:revealIcon
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

- (void)arrangeThumbs
{
	float dx = 0.0;
	float dy = 0.0;
    BOOL spaceAdded = NO; // Added this because the logic of adding a line is off (adds an extra row if the last row of photos fill the last row)
	// loop through all thumbs to size and place them
	NSUInteger i, count = [_photoThumbnailViews count];
	for (i = 0; i < count; i++) {
        spaceAdded = NO;
		FGalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:i];
        //		[thumbView setBackgroundColor:[UIColor grayColor]];
		
		// create new frame
		thumbView.frame = CGRectMake( dx, dy, [self thumbnailSize], [self thumbnailSize]);
		
		// increment position
		dx += [self thumbnailSize] + [self thumbnailsSpacingSize];
		
		// check if we need to move to a different row
		if( dx + [self thumbnailSize] + [self thumbnailsSpacingSize] > _thumbsView.frame.size.width )
		{
			dx = 0.0;
			dy += [self thumbnailSize] + [self thumbnailsSpacingSize];
            spaceAdded = YES;
		}
	}
	
    // Corgi Fetch: Use this to add space for the fetch button
	// set the content size of the thumbnail view scroller
    
    if (spaceAdded) {
        [_thumbsView setContentSize:CGSizeMake( _thumbsView.frame.size.width - ( [self thumbnailsSpacingSize]*2 ), dy + [self thumbnailSize] + [self thumbnailsSpacingSize])];
    } else {
        [_thumbsView setContentSize:CGSizeMake( _thumbsView.frame.size.width - ( [self thumbnailsSpacingSize]*2 ), dy + ([self thumbnailSize] + [self thumbnailsSpacingSize])*2)];
    }

    // Adds fetch button
    if (![fetchSortType isEqualToString:kSortTypeFavorite]) {
        if(!loadingView) {
            UINib *showMoreNib = [UINib nibWithNibName:@"morePhotosButton" bundle:[NSBundle mainBundle]];
            loadingView = [[showMoreNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        }

        [self resizeLoadingView];
        [_thumbsView addSubview:loadingView];
        
        UIImage *buttonGrayImage;
        buttonGrayImage = [[UIImage imageNamed:@"buttonGray.png"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *buttonGrayHighlightImage;
        buttonGrayHighlightImage = [[UIImage imageNamed:@"buttonGrayHighlight.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        [fetchButton setBackgroundImage:buttonGrayImage forState:UIControlStateNormal];
        [fetchButton setBackgroundImage:buttonGrayHighlightImage forState:UIControlStateHighlighted];


        [fetchActivityIndicator stopAnimating];
        [refreshIcon setHidden:NO];

        
        [backButton setBackgroundImage:buttonGrayImage forState:UIControlStateNormal];
        [backButton setBackgroundImage:buttonGrayHighlightImage forState:UIControlStateHighlighted];
    } else {
        [loadingView removeFromSuperview];
    }
}

- (void)saveChanges
{
    BOOL success = [[BBSPhotoStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all of the photos");
    } else {
        NSLog(@"Could not save any of the photos");
    }
}
- (void)saveChangesWithSuccessMessage:(NSString *)message
{
    BOOL success = [[BBSPhotoStore sharedStore] saveChanges];
    if (success) {
        [SVProgressHUD showSuccessWithStatus:message];
        NSLog(@"Saved all of the photos");
    } else {
        NSLog(@"Could not save any of the photos");
    }
}

- (void)showPremiumView {
    BBSInAppPurchaseViewController *purchaseVC = [[BBSInAppPurchaseViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:purchaseVC];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self loadDefaults];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    [self resizeLoadingView];
    if (_isThumbViewShowing) {
        [self setupNavigationOrientation:toInterfaceOrientation];
    }
}

- (void)setupFetchButtons
{
    if (dataStartIndex >= 2) {
        [backButton setEnabled:YES];
        [backButton setAlpha:1.0f];
    } else {
        [backButton setEnabled:NO];
        [backButton setAlpha:0.0f];
    }
    
    // hides the fetch button if there is no next page
    if (![self max_id]) {
        [fetchButton setEnabled:NO];
        [fetchButton setAlpha:0.0f];
        [refreshIcon setAlpha:0.0f];
    } else {
        [fetchButton setEnabled:YES];
        [fetchButton setAlpha:1.0f];
        [refreshIcon setAlpha:1.0f];
    }
}

- (void)setupNavigationOrientation:(UIInterfaceOrientation)orientation
{
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (_isThumbViewShowing) {
            [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
        }
        [[[self navigationController] navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                             [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22.0f],
                                                                             UITextAttributeFont,
                                                                             [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f],
                                                                             UITextAttributeTextShadowColor,
                                                                             [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5f)],
                                                                             UITextAttributeTextShadowOffset, nil]];
        [[[self navigationController] navigationBar] setTitleVerticalPositionAdjustment:-3.0f forBarMetrics:UIBarMetricsDefault];
    } else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        if (_isThumbViewShowing) {
            [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"landscapeNav.png"] forBarMetrics:UIBarMetricsLandscapePhone];
        }
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

- (void)resizeLoadingView
{
    if (loadingView) {
        [loadingView setFrame:CGRectMake(
                                         0,
                                         self.thumbsView.contentSize.height - loadingView.frame.size.height,
                                         _container.frame.size.width,
                                         loadingView.frame.size.height)];
    }
}

- (void)prepareThumbsView
{
    // if enough photos are loaded then preps thumbsview, otherwise it keeps running
    if ([[[BBSPhotoStore sharedStore] allPhotos] count] > kDataIncrements || ![self max_id])
    {
        [self reloadGallery];
        
        sortType = fetchSortType;
        
        if (fetchingNext) {
            if (!firstLoad || dataStartIndex == 0) {
                dataStartIndex += 1;
            }
        } else {
            dataStartIndex -= 1;
        }
        
        NSLog(@"Instagram data loaded");
        
        [SVProgressHUD dismiss];
        
        [self setupFetchButtons];
        
        firstLoad = NO;
        [self saveDefaults];
        
        self.state = GalleryStateComplete;
    } else {
        
        NSString *methodStr = [NSString stringWithFormat:kInstagramTagSearchMethod, fetchSortType];
        
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            params = [NSMutableDictionary dictionaryWithObjectsAndKeys:methodStr, @"method", [self max_id], @"max_id", nil];
        
        [self.appDelegate.instagram requestWithParams:params
                                             delegate:self];
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 1) { // Alert for request failure
        switch (buttonIndex) {
            case 0: // Cancel
                break;
            case 1: // Yes to reload
                [self fetchPhotosWithNewSortType:NO];
                break;
            default:
                break;
        }
    } else if ([alertView tag] == 2) { // Alert for favorite photo removal
        Photo *p = [[[BBSPhotoStore sharedStore] allPhotos] objectAtIndex:[self currentIndex]];
        switch (buttonIndex) {
            case 0: // Cancel
                break;
            case 1: // Yes to remove
                [[BBSPhotoStore sharedStore] removePhoto:p];
                [[BBSPhotoStore sharedStore] loadAllPhotos];
                [self showThumbnailViewWithAnimation:YES];
                [self saveChangesWithSuccessMessage:@"Favorite removed"];
                [self reloadGallery];
                

                break;
            default:
                break;
        }
    }
}


#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
    
    [SVProgressHUD dismiss];
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Problem connecting" message:@"Would you like to try loading more photos again?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [errorAlert setTag:1]; // to differentiate between other alerts
    [errorAlert show];
    
    if ([sortType isEqualToString:kSortTypeFavorite]) {
        [[BBSPhotoStore sharedStore] setShowFavorites:YES];
    }
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    if (self.state == GalleryStateComplete)
    {
        [[BBSPhotoStore sharedStore] deleteAllPhotos];
        [self saveChanges];
        
        self.state = GalleryStateLoading;
    }
    
    self.instagramData = (NSArray*)[result valueForKey:@"data"];
    
    int requestedPhotoTotal = [self.instagramData count];
    
    for (int i=0; i < requestedPhotoTotal; i++)
    {

        
        
        NSDictionary *photoDict = [self.instagramData objectAtIndex:i];
        
        NSString *owner_name = [[photoDict valueForKey:@"user"] valueForKey:@"username"];
        
        // Filter out people who don't want to be included in app by instagram username
        if ([owner_name isEqualToString:@"kitkatherine"]) {
            continue;
        }
        
        Photo *p = [[BBSPhotoStore sharedStore] createPhoto];
        
        if ([[photoDict valueForKey:@"caption"] valueForKey:@"text"] != [NSNull null])
        {
            [p setTitle:[[photoDict valueForKey:@"caption"] valueForKey:@"text"]];
        } else {
            [p setTitle:@"Untitled"];
        }
        NSString *flickrID = [photoDict valueForKey:@"id"];
        
        
        NSString *date = [photoDict valueForKey:@"created_time"];
        
        NSString *photoURL = [[[photoDict valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"];
        NSString *thumbURL = [[[photoDict valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"];
        
        if ([photoDict valueForKey:@"link"] != [NSNull null]) {
            [p setSourceURL:[photoDict valueForKey:@"link"]];
        } else {
            [p setSourceURL:photoURL];
        }
        
        [p setPhotoURL:photoURL];
        [p setDate:date];
        [p setThumbURL:thumbURL];

        [p setFlickrID:flickrID];
        [p setOwner_name:owner_name];
        
        
    }

    if ([[result valueForKey:@"pagination"] valueForKey:@"next_max_tag_id"]) {
        [self setMax_id:[(NSDictionary*)[result valueForKey:@"pagination"] valueForKey:@"next_max_tag_id"]];
    } else {
        [self setMax_id:nil];
    }
    
    [self setMin_id:[(NSDictionary*)[result valueForKey:@"pagination"] valueForKey:@"next_min_tag_id"]];

    [self prepareThumbsView];
}

@end
