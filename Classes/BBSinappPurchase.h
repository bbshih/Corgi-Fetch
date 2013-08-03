//
//  YTVinappPurchase.h
//  CorgiFetch
//
//  Created by Billy Shih on 9/18/12.
//
//

#import <Foundation/Foundation.h>
#import "EBPurchase.h"
#import "Config.h"

@interface BBSinappPurchase : NSObject <EBPurchaseDelegate> {
    EBPurchase* purchase;
    BOOL isPurchased;
}

+ (BBSinappPurchase *)sharedPurchase;

- (BOOL)requestProduct;
- (BOOL)purchaseProduct;
- (BOOL)restoreProduct;
@end
