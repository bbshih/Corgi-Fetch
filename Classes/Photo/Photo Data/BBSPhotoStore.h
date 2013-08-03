//
//  PhotoStore.h
//  CorgiFetch
//
//  Created by Billy Shih on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FGalleryViewController.h"

@class Photo;

@interface BBSPhotoStore : NSObject <FGalleryViewControllerDelegate>
{
    NSMutableArray *allPhotos;
    NSMutableArray *allFavorites;
    NSMutableArray *allAssetTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

@property (nonatomic) BOOL showFavorites;

+ (BBSPhotoStore *)sharedStore;

- (void)removePhoto:(Photo *)p;

- (NSArray *)allPhotos;

- (Photo *)createPhoto;
- (void)addFavoritePhoto:(Photo *)photo;

- (void)movePhotoAtIndex:(int)from
                toIndex:(int)to;

- (void)deleteAllPhotos;

- (NSString *)itemArchivePath;
- (BOOL)saveChanges;
- (void)loadAllPhotos;
@end