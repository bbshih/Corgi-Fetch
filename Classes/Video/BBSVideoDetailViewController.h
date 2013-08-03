//
//  YTVVideoDetailViewController.h
//  Corgi Fetch
//
//  Created by Billy Shih on 8/20/12.
//
//

#import <UIKit/UIKit.h>
#import "Video.h"

@interface BBSVideoDetailViewController : UIViewController
{
    NSURL *sourceURL;
    __weak IBOutlet UIImageView *videoThumbnail;
    __weak IBOutlet UILabel *videoTitle;
    __weak IBOutlet UILabel *author;
    __weak IBOutlet UILabel *dateCreated;

}

@property (weak, nonatomic) IBOutlet UIButton *sourceButton;
@property (nonatomic, strong) Video *v;

- (IBAction)openSourceLink:(id)sender;
- (void)back;
@end
