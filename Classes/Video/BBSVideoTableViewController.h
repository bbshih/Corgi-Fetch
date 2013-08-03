//
//  YTVTableViewController.h
//  CorgiFetch
//
//  Created by Billy Shih on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBYouTubePlayerViewController.h"

extern NSString *const kVideoSortTypeDefault;
extern NSString *const kVideoSortTypePopular;
extern NSString *const kVideoSortTypeNewest;
extern NSString *const kVideoSortTypeViewCount;
extern NSString *const kVideoSortTypeRating;
extern NSString *const kVideoSortTypeFavorites;
extern NSInteger const kVideoDataIncrements;

@class Video;

@interface BBSVideoTableViewController : UITableViewController <NSXMLParserDelegate, LBYouTubePlayerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    NSURLConnection *connection;
    NSURLRequest *request;
    NSMutableData *xmlData;
    
    NSMutableString *currentString;
    
    NSInteger dataStartIndex;
    NSInteger fetchDataStartIndex;
    NSInteger dataIncrements;
    NSInteger selectedVideo;
    
    BOOL firstLoad;
    BOOL fetchingVideos;
    LBYouTubePlayerViewController *videoPlayer;
    
    NSString *fetchSortType;
    NSString *sortType;
    
    UIView *loadingView;

    UIImage *buttonImage;
    UIImage *buttonImageHighlight;


}

@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizer;

- (IBAction)showMoreRows;
- (IBAction)learnMore:(id)sender;

- (void)setupPremium;
- (void)addFetchButton;

- (void)saveDefaults;

- (void)addFavoriteVideo:(Video *)video atIndexPath:(NSIndexPath *)indexPath;

- (void)fetchVideosWithNewSortType:(BOOL)fetchNew;
- (void)showDetails:(id)sender atIndexPath:(NSIndexPath *)indexPath;
- (void)playVideo:(id)sender atIndexPath:(NSIndexPath *)indexPath;
- (void)shareVideo:(id)sender atIndexPath:(NSIndexPath *)indexPath;
- (void)closeMovie:(NSNotification *)notification;
- (void)removeLoadingScreen:(NSNotification *)notification;

- (void)showSortMenu:(id)sender;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)showPremiumView;
- (void)setupView:(UIInterfaceOrientation)toInterfaceOrientation;

@end
