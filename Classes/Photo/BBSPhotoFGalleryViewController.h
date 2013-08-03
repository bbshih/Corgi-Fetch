#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"
#import "IGConnect.h"

@class BBSAppDelegate;
@class BBSPhotoDetailViewController;

typedef enum
{
	GalleryStateLoading,
	GalleryStateComplete
} GalleryState;

extern NSString *const kSortTypeNewest;
extern NSString *const kSortTypeFavorite;
extern NSString *const kSortTypeCorgiFetch;
extern NSInteger const kDataIncrements;

@interface BBSPhotoFGalleryViewController : FGalleryViewController <IGRequestDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    BBSPhotoDetailViewController *photoDetailViewController;
    
    UIView *loadingView;
    __weak IBOutlet UIActivityIndicatorView *fetchActivityIndicator;
    __weak IBOutlet UIImageView *refreshIcon;
    __weak IBOutlet UIButton *fetchButton;
    __weak IBOutlet UIButton *backButton;
    
    NSInteger dataStartIndex;

    BOOL firstLoad;

    NSString *fetchSortType;
    BOOL fetchingNext; // Tracks if fetching next or previous photos
    UIImage *buttonImage;
    UIImage *buttonImageHighlight;
}

@property (nonatomic, strong) NSString *max_id;
@property (nonatomic, strong) NSString *min_id;
@property GalleryState state;
@property (nonatomic, strong) NSString *sortType;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

//Instagram
@property (nonatomic, strong) BBSAppDelegate *appDelegate;
@property (nonatomic, strong) NSArray *instagramData;


- (IBAction)showMorePhotosButton:(id)sender;
- (IBAction)showPreviousPhotosButton:(id)sender;

- (void)loadDefaults;
- (void)saveDefaults;

- (void)handleInfoButtonTouch:(id)sender;
- (void)handleShareButtonTouch:(id)sender;
- (void)handleFavButtonTouch:(id)sender; 

- (void)fetchPhotosWithNewSortType:(BOOL)fetchNew;

- (void)showSortMenu:(id)sender;

- (void)addRevealButton;
- (void)setupFetchButtons;

- (void)prepareThumbsView;

- (void)saveChanges;
- (void)saveChangesWithSuccessMessage:(NSString *)message;

- (IBAction)learnMore:(id)sender;
- (void)showPremiumView;

- (void)resizeLoadingView;
- (void)setupNavigationOrientation:(UIInterfaceOrientation)orientation;
@end
