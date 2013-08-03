//
//  ItemStore.m
//  CorgiFetch
//
//  Created by Billy Shih on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoStore.h"
#import "Video.h"

@implementation VideoStore

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
        
        [self loadAllVideos];

    }
    return self;
}

- (NSArray *)allVideos
{
    if ([self showFavorites]) {
        return allFavorites;
    }
    return allVideos;
}

- (Video *)createVideo
{
    double order;
    NSString *entityStr;
    if ([self showFavorites])
    {
        entityStr = @"VideoFavorites";
        if ([[self allVideos] count] == 0) {
            order = 1.0;
        } else {
            order = [[[self allVideos] lastObject] orderingValue] + 1.0;
        }
    } else {
        entityStr = @"Video";
        order = 1.0;
    }
    // Adding a new row to the Video entity/table and returning it so that it can be added to the allItems array
    Video *v = [NSEntityDescription insertNewObjectForEntityForName:entityStr
                                             inManagedObjectContext:context];
    [v setOrderingValue:order];
    
    if ([self showFavorites]) {
        [allFavorites addObject:v];
    } else {
        [allVideos addObject:v];
    }
    
    return v;
}

- (void)addFavoriteVideo:(Video *)video
{
    double order;
    if ([allFavorites count] == 0) {
        order = 1.0;
    } else {
        order = [[allFavorites lastObject] orderingValue] + 1.0;
    }
    
    // Adding a new row to the Video entity/table and returning it so that it can be added to the allItems array
    Video *v = [NSEntityDescription insertNewObjectForEntityForName:@"VideoFavorites"
                                             inManagedObjectContext:context];
    [v setOrderingValue:order];
    
    [v setYtVideoCode:[video ytVideoCode]];
    [v setThumbURL:[video thumbURL]];
    [v setAuthor:[video author]];
    [v setTitle:[video title]];
    [v setDatePublished:[video datePublished]];
    [v setDuration:[video duration]];
    
    [allFavorites addObject:v];
}

+ (VideoStore *)sharedStore
{
    static VideoStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (void)removeVideo:(Video *)v
{
    [context deleteObject:v];
    if ([self showFavorites]) {
        [allFavorites removeObjectIdenticalTo:v];
    } else {
        [allVideos removeObjectIdenticalTo:v];
    }
}

- (void)moveVideoAtIndex:(int)from
                toIndex:(int)to
{
    if (from == to) {
        return;
    }
    
    Video *v = [[self allVideos] objectAtIndex:from];
    
    if ([self showFavorites]) {
        [allFavorites removeObjectAtIndex:from];
        [allFavorites insertObject:v atIndex:to];
    } else {
        [allVideos removeObjectAtIndex:from];
        [allVideos insertObject:v atIndex:to];
    }
    
    //Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to >0) {
        lowerBound = [[[self allVideos] objectAtIndex:to-1] orderingValue];
    } else {
        lowerBound = [[[self allVideos] objectAtIndex:1] orderingValue] + 2.0;
    }
    
    double upperBound = 0.0;
    
    if (to < [allVideos count] - 1) {
        upperBound = [[[self allVideos] objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[[self allVideos] objectAtIndex:to - 1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    [v setOrderingValue:newOrderValue];
}

- (NSString *)getYouTubeURL:(Video *)video
{
    return [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", [video ytVideoCode]];
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

- (void)loadAllVideos
{
    if (!allVideos) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Video"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                             ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request
                                                 error:&error];
        if(!result) {
            [NSException raise:@"Video Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        allVideos = [[NSMutableArray alloc] initWithArray:result];
        
        // Do the same for VideoFavorites
        NSFetchRequest *requestF = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *eF = [[model entitiesByName] objectForKey:@"VideoFavorites"];
        [requestF setEntity:eF];
        
        NSSortDescriptor *sdF = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                              ascending:YES];
        [requestF setSortDescriptors:[NSArray arrayWithObject:sdF]];
        
        NSError *errorF;
        NSArray *resultF = [context executeFetchRequest:requestF
                                                  error:&errorF];
        if(!resultF) {
            [NSException raise:@"Video Favorites Fetch failed" format:@"Reason: %@", [errorF localizedDescription]];
        }
        
        allFavorites = [[NSMutableArray alloc] initWithArray:resultF];
    }
}


- (void)deleteAllVideos
{
    NSLog(@"Deleting all videos");
    for (Video *v in [allVideos copy]) {
        [self removeVideo:v];
    }
}
@end
