//
//  ItemStore.h
//  CorgiFetch
//
//  Created by Billy Shih on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Video;

@interface VideoStore : NSObject
{
    NSMutableArray *allVideos;
    NSMutableArray *allFavorites;
    NSMutableArray *allAssetTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

@property (nonatomic) BOOL showFavorites;

+ (VideoStore *)sharedStore;

- (void)removeVideo:(Video *)p;

- (NSArray *)allVideos;
- (Video *)createVideo;
- (void)addFavoriteVideo:(Video *)video;
- (void)moveVideoAtIndex:(int)from
                toIndex:(int)to;
- (NSString *)getYouTubeURL:(Video *)video;

- (void)deleteAllVideos;

- (NSString *)itemArchivePath;
- (BOOL)saveChanges;
- (void)loadAllVideos;
@end
