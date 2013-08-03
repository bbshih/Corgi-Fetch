//
//  YTVinappPurchase.m
//  CorgiFetch
//
//  Created by Billy Shih on 9/18/12.
//
//

#import "BBSinappPurchase.h"
#import "BBSAppDelegate.h"

@implementation BBSinappPurchase

- (id)init
{
    self = [super init];
    if (self) {
        purchase = [[EBPurchase alloc] init];
        purchase.delegate = self;
        
        isPurchased = NO;
    }
    return self;
}

+ (BBSinappPurchase *)sharedPurchase
{
    static BBSinappPurchase *sharedPurchase = nil;
    if (!sharedPurchase) {
        sharedPurchase = [[super allocWithZone:nil] init];
    }
    return sharedPurchase;
}

- (BOOL)requestProduct
{
    // Returned no if In-App Purchase is Disabled in user's Settings
    return [purchase requestProduct:SUB_PRODUCT_ID];
}

- (BOOL)purchaseProduct
{
    if (purchase.validProduct != nil)
    {
        // Then, call the purchase method.
        
        if ([purchase purchaseProduct:purchase.validProduct])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)restoreProduct
{
    return [purchase restorePurchase];
}


#pragma mark EBPurchaseDelegate Methods

- (void)requestedProduct:(EBPurchase*)ebp identifier:(NSString*)productId name:(NSString*)productName price:(NSString*)productPrice description:(NSString*)productDescription
{
    NSLog(@"sharedPurchase requestedProduct");
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:ebp, @"ebp", productId, @"productID", productName, @"productName", productPrice, @"productPrice", productDescription, @"productDescription", nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestedProduct" object:self userInfo:dictionary];
}

// Transition all of these into notifications

- (void)successfulPurchase:(EBPurchase*)ebp restored:(bool)isRestore identifier:(NSString*)productId receipt:(NSData*)transactionReceipt
{
    NSLog(@"sharedPurchase successfulPurchase");
    
    // Purchase or Restore request was successful, so...
    // 1 - Unlock the purchased content for your new customer! 
    // 2 - Notify the user that the transaction was successful.
    

    
//    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:ebp, @"ebp", [NSNumber numberWithBool:isRestore], @"isRestore", productId, @"productId", transactionReceipt, "@transactionReceipt", isPurchased, @"isPurchased", nil]; // need to pass isPurchased as well
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Saving in-app purchase");
    [defaults setBool:YES forKey:@"isPremiumPurchased"];
    [defaults synchronize];
    [(BBSAppDelegate*)[[UIApplication sharedApplication] delegate] setPremium:YES];
    
    if (!isPurchased) // do this after saving since need the logic later
    {
        // If paid status has not yet changed, then do so now. Checking
        // isPurchased boolean ensures user is only shown Thank You message
        // once even if multiple transaction receipts are successfully
        // processed (such as past subscription renewals).
        
        isPurchased = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"successfulPurchase" object:self userInfo:nil];

}

- (void)failedPurchase:(EBPurchase*)ebp error:(NSInteger)errorCode message:(NSString*)errorMessage
{
    NSLog(@"sharedPurchase failedPurchase");
    
//    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:ebp, @"ebp", errorCode, @"errorCode", errorMessage, @"errorMessage", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"failedPurchase" object:self userInfo:nil];
    // Purchase or Restore request failed or was cancelled, so notify the user.
}

- (void)incompleteRestore:(EBPurchase*)ebp
{
    NSLog(@"ViewController incompleteRestore");
    
    // Restore queue did not include any transactions, so either the user has not yet made a purchase
    // or the user's prior purchase is unavailable, so notify user to make a purchase within the app.
    // If the user previously purchased the item, they will NOT be re-charged again, but it should
    // restore their purchase.
    
//    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:ebp, @"ebp", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incompleteRestore" object:self userInfo:nil];
    
}

- (void)failedRestore:(EBPurchase*)ebp error:(NSInteger)errorCode message:(NSString*)errorMessage
{
    NSLog(@"ViewController failedRestore");
    
    // Restore request failed or was cancelled, so notify the user.
  //  NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:ebp, @"requestedProduct", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"failedRestore" object:self userInfo:nil];
}

@end
