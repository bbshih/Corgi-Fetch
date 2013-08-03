//
//  YTVSettingsTableViewController.h
//  CorgiFetch
//
//  Created by Billy Shih on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZUUIRevealController;
@interface BBSLeftNavTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *menuArray;
}

@property (weak, nonatomic) IBOutlet UITableView *overviewTableView;
@property (strong, nonatomic) UINavigationController *photoGallery;
@property (strong, nonatomic) UINavigationController *videoGallery;
@property (strong, nonatomic) ZUUIRevealController *revealController;

- (void)setupRows;

@end
