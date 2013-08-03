//
//  BBSVideoTableCell.h
//  CorgiFetch
//
//  Created by Billy Shih on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface BBSVideoTableCell : UITableViewCell
{
}

@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;

- (IBAction)showDetails:(id)sender;
- (IBAction)playVideo:(id)sender;
- (IBAction)shareVideo:(id)sender;
- (IBAction)addFavoriteVideo:(id)sender;

- (void)closeMovie:(NSNotification *)notification;

@end
