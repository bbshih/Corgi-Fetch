//
//  InAppPurchaseViewController.h
//  CorgiFetch
//
//  Created by Billy Shih on 9/8/12.
//
//

#import <UIKit/UIKit.h>

@interface BBSInAppPurchaseViewController : UIViewController {

}
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;

- (void)close:(id)sender;
- (IBAction)upgradeToPremium:(id)sender;
- (IBAction)restorePurchase:(id)sender;

-(void)setupViews;

- (void)requestedProduct:(id)sender;
- (void)successfulPurchase:(id)sender;
- (void)failedPurchase:(id)sender;
- (void)incompleteRestore:(id)sender;
- (void)failedRestore:(id)sender;
@end
