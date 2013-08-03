//
//  Video.h
//  Corgi Fetch
//
//  Created by Billy Shih on 8/31/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, assign) double orderingValue;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * ytVideoCode;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * datePublished;
@property (nonatomic, retain) NSNumber * duration;

@end
