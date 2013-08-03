//
//  PhotoGalleryViewController.h
//  YouTubeViewer
//
//  Created by Billy Shih on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"
#import "ObjectiveFlickr.h"

@interface PhotoGalleryViewController : UITableViewController <FGalleryViewControllerDelegate, OFFlickrAPIRequestDelegate> 
{
    NSMutableArray *networkCaptions;
    NSMutableArray *networkImages;
    FGalleryViewController *networkGallery;
    OFFlickrAPIContext *context;
    OFFlickrAPIRequest *request;
}

@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizer;

@end
