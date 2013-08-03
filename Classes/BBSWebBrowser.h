//
//  CFWebBrowser.h
//  CorgiFetch
//
//  Created by Billy Shih on 10/15/12.
//
//

#import "TSMiniWebBrowser.h"

@interface BBSWebBrowser : TSMiniWebBrowser
{
    UIImage *buttonImage;
    UIImage *buttonImageHighlight;
}
@property (nonatomic, retain) UIPanGestureRecognizer *panGestureRecognizer;
@end
