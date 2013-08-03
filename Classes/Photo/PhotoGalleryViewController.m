//
//  PhotoGalleryViewController.m
//  YouTubeViewer
//
//  Created by Billy Shih on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoGalleryViewController.h"
#import "ObjectiveFlickr.h"
#import "BBSPhotoStore.h"
#import "Photo.h"

@interface PhotoGalleryViewController ()

@end

@implementation PhotoGalleryViewController
#pragma mark - View lifecycle

@synthesize  panGestureRecognizer = _panGestureRecognizer;

- (void)loadView {
	[super loadView];
    
	self.title = @"Photos";
    
    networkCaptions = [[NSMutableArray alloc] init];
    networkImages = [[NSMutableArray alloc] init];
     
    
    // For the reveal button
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)]) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reveal" 
                                                                                 style:UIBarButtonItemStylePlain 
                                                                                target:self.navigationController.parentViewController 
                                                                                action:@selector(revealToggle:)];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController 
                                                                            action:@selector(revealGesture:)];
        [self.navigationController.navigationBar addGestureRecognizer:self.panGestureRecognizer];
        
    } else {
        abort();
    }
    
    context = [[OFFlickrAPIContext alloc] initWithAPIKey:@"33afdfab897384718da6c14cf96b3d83" sharedSecret:@"3e1babcdfb918cfc"];
    request = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
    
    [request setDelegate:self];
    
    // This is the flickr search query
    // try this with tags instead of text for better quality?
    // http://www.flickr.com/services/api/flickr.photos.search.html
    [request callAPIMethodWithGET:@"flickr.photos.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"corgi dog", @"text", @"interestingness-desc", @"sort", nil]]; 
}

#pragma mark - Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	// Configure the cell.

		cell.textLabel.text = @"Network Images";
    
    return cell;
}


#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
	return [networkImages count];
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
	return [networkCaptions objectAtIndex:index];
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [networkImages objectAtIndex:index];
}

- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}


- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
		networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        networkGallery.beginsInThumbnailView = YES;
        [self.navigationController pushViewController:networkGallery animated:YES];
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

//#pragma mark - ObjectiveFlickr delegate methods
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
//    NSLog(@"%@", [inResponseDictionary description]);
//
//    
//    NSArray *photos = [inResponseDictionary objectForKey:@"photos"];
    
    
    int requestedPhotoTotal = [[[inResponseDictionary objectForKey:@"photos"] valueForKey:@"perpage"] intValue];
    
    //    NSLog(@"%@", [photos description]);
    for (int i=0; i< requestedPhotoTotal; i++) 
    {
        NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:i];
        
        NSURL *staticPhotoURL = [context photoSourceURLFromDictionary:photoDict size:OFFlickrSmallSize];
        NSURL *photoSourcePage = [context photoWebPageURLFromDictionary:photoDict];
        Photo *p = [[BBSPhotoStore sharedStore] createPhoto];
        
        [p setPhotoURL:[staticPhotoURL absoluteString]];
        [p setTitle:[photoSourcePage absoluteString]];
        [networkCaptions addObject:[photoSourcePage absoluteString]];
        [networkImages addObject:[staticPhotoURL absoluteString]];
        i++;
        
    }
    
   
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"Code: %@\nDomain: %@\nuserInfo: %@", inError.code, inError.domain, inError.userInfo);
}

//- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
//{
//
//}



@end

