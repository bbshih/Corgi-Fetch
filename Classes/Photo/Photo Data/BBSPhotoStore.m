//
//  PhotoStore.m
//  CorgiFetch
//
//  Created by Billy Shih on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSPhotoStore.h"
#import "Photo.h"

@implementation BBSPhotoStore


- (id)init
{
    self = [super init];
    if (self) {
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        [context setUndoManager:nil];
        
        [self loadAllPhotos];
    }
    return self;
}

- (NSArray *)allPhotos
{
    if ([self showFavorites]) {
        return allFavorites;
    }
    return allPhotos;
}

- (Photo *)createPhoto
{
    double order;
    if ([[self allPhotos] count] == 0) {
        order = 1.0;
    } else {
        order = [[[self allPhotos] lastObject] orderingValue] + 1.0;
    }
    
    NSString *entityStr;
    if ([self showFavorites]) {
        entityStr = @"PhotoFavorites";
    } else {
        entityStr = @"Photo";
    }
    // Adding a new row to the Photo entity/table and returning it so that it can be added to the allItems array
    Photo *p = [NSEntityDescription insertNewObjectForEntityForName:entityStr
                                             inManagedObjectContext:context];
    [p setOrderingValue:order];
    
    if ([self showFavorites]) {
        [allFavorites addObject:p];
    } else {
        [allPhotos addObject:p];
    }

    return p;
}

- (void)addFavoritePhoto:(Photo *)photo
{
    double order;
    if ([allFavorites count] == 0) {
        order = 1.0;
    } else {
        order = [[allFavorites lastObject] orderingValue] + 1.0;
    }

    // Adding a new row to the Photo entity/table and returning it so that it can be added to the allItems array
    Photo *p = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoFavorites"
                                             inManagedObjectContext:context];
    [p setOrderingValue:order];
    
    [p setPhotoURL:[photo photoURL]];
    [p setThumbURL:[photo thumbURL]];
    [p setSourceURL:[photo sourceURL]];
    [p setFlickrID:[photo flickrID]];
    [p setTitle:[photo title]];
    [p setDate:[photo date]];
    [p setOwner_name:[photo owner_name]];
    
    [allFavorites addObject:p];
}

+ (BBSPhotoStore *)sharedStore
{
    static BBSPhotoStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (void)removePhoto:(Photo *)p
{
    [context deleteObject:p];
    if ([self showFavorites]) {
        [allFavorites removeObjectIdenticalTo:p];
    } else {
        [allPhotos removeObjectIdenticalTo:p];
    }
}

- (void)movePhotoAtIndex:(int)from
                toIndex:(int)to
{
    if (from == to) {
        return;
    }
    
    Photo *p = [[self allPhotos] objectAtIndex:from];
    
    if ([self showFavorites]) {
        [allFavorites removeObjectAtIndex:from];
        [allFavorites insertObject:p atIndex:to];
    } else {
        [allPhotos removeObjectAtIndex:from];
        [allPhotos insertObject:p atIndex:to];
    }
    
    //Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to >0) {
        lowerBound = [[[self allPhotos] objectAtIndex:to-1] orderingValue];
    } else {
        lowerBound = [[[self allPhotos] objectAtIndex:1] orderingValue] + 2.0;
    }
    
    double upperBound = 0.0;
    
    if (to < [allPhotos count] - 1) {
        upperBound = [[[self allPhotos] objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[[self allPhotos] objectAtIndex:to - 1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    [p setOrderingValue:newOrderValue];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

- (void)loadAllPhotos
{
    if (!allPhotos) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Photo"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                             ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request
                                                 error:&error];
        if(!result) {
            [NSException raise:@"Photo Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }

        allPhotos = [[NSMutableArray alloc] initWithArray:result];

        // Do the same for PhotoFavorites
        NSFetchRequest *requestF = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *eF = [[model entitiesByName] objectForKey:@"PhotoFavorites"];
        [requestF setEntity:eF];
        
        NSSortDescriptor *sdF = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                             ascending:YES];
        [requestF setSortDescriptors:[NSArray arrayWithObject:sdF]];
        
        NSError *errorF;
        NSArray *resultF = [context executeFetchRequest:requestF
                                                 error:&errorF];
        if(!resultF) {
            [NSException raise:@"Photo Favorites Fetch failed" format:@"Reason: %@", [errorF localizedDescription]];
        }
        
        allFavorites = [[NSMutableArray alloc] initWithArray:resultF];
    }
}

- (void)deleteAllPhotos
{
    for (Photo *p in [allPhotos copy]) {
        [self removePhoto:p];
    }
}

#pragma mark - FGalleryViewControllerDelegate Methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    return [[[BBSPhotoStore sharedStore] allPhotos] count];
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    return [[[[BBSPhotoStore sharedStore] allPhotos] objectAtIndex:index] title];
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    if (size == FGalleryPhotoSizeFullsize) {
        return [[[[BBSPhotoStore sharedStore] allPhotos] objectAtIndex:index] photoURL];
    } else if (size == FGalleryPhotoSizeThumbnail) {
        return [[[[BBSPhotoStore sharedStore] allPhotos] objectAtIndex:index] thumbURL];
    }

    return nil;
}

@end
