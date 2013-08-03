//
//  YTVAppDelegate.h
//  CorgiFetch
//
//  Created by Billy Shih on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reachability;
@class Instagram;

@interface BBSAppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability* internetReachable;
    Reachability* hostReachable;
}
@property (strong, nonatomic) UIWindow *window;
@property BOOL premium;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) Instagram *instagram;

@property BOOL internetWorking;

-(void) checkNetworkStatus:(NSNotification *)notice;

@end
