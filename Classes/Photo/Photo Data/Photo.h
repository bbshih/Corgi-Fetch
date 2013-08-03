//
//  PhotoFavorites.h
//  Corgi Fetch
//
//  Created by Billy Shih on 8/22/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * flickrID;
@property (nonatomic, assign) double orderingValue;
@property (nonatomic, assign) BOOL detailPulled;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * sourceURL;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * owner_name;
@property (nonatomic, retain) NSString * views;

@end
