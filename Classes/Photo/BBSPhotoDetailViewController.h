//
//  PhotoDetailViewController.h
//  Corgi Fetch
//
//  Created by Billy Shih on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;
@interface BBSPhotoDetailViewController : UIViewController
{
    Photo *photo;
}

@property (weak, nonatomic) IBOutlet UIButton *sourceButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *owner_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
- (IBAction)sourceButtonTouch:(id)sender;

- (void)back;
- (id)initWithPhoto:(Photo *)p;

@end
