// Created by James Tang
// Blog post at http://ioscodesnippet.tumblr.com

// Convert UIInterfaceOrientation to NSString, so we can compare it
static inline NSString *NSStringFromUIInterfaceOrientation(UIInterfaceOrientation orientation) {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:           return @"UIInterfaceOrientationPortrait";
        case UIInterfaceOrientationPortraitUpsideDown: return @"UIInterfaceOrientationPortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:      return @"UIInterfaceOrientationLandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:     return @"UIInterfaceOrientationLandscapeRight";
    }
    return @"Unexpected";
}

// Check info.plist for the UISupportedInterfaceOrientations key, it returns an array of NSString
#define UIInterfaceOrientationIsSupportedOrientation(orientation) ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"] indexOfObject:NSStringFromUIInterfaceOrientation(orientation)] != NSNotFound)
