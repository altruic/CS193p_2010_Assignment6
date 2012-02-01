//
//  PhotosTableViewController.m
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MostPopularPhotosTVC.h"

#import "FlickrFetcher.h"
#import "DictPlace.h"
#import "DictPhoto.h"
#import "Photo.h"
#import "Place.h"
#import "PhotoViewController.h"


@implementation MostPopularPhotosTVC

- (void)setup
{
	self.title = @"Photos";
	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:0] autorelease];

	if (!_place)
		return;

	self.title = _place.name;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSArray *photosAtPlace = [FlickrFetcher photosAtPlace:_place.uniqueId];
	//NSLog(@"photosAtPlace returned: %@", photosAtPlace);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSMutableArray *photos = [NSMutableArray arrayWithCapacity:[photosAtPlace count]];
	for (id obj in photosAtPlace) {
		if (![obj isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Non-dictionary returned from +photosAtPlace");
			continue;
		}
		NSDictionary *photoDict = (NSDictionary *)obj;
		DictPhoto *photo = [[DictPhoto alloc] initWithDictionary:photoDict];
		if (photo)
			[photos addObject:photo];
		[photo release];
	}

	// Copy to immutable ivar
	_photos = [[NSArray arrayWithArray:photos] retain];
}


// fixme: I forgot which method is called when loaded from a nib, but we have to make sure -setup is called then as well
// fixme: does that also mess with our (new) designated initializer here?
- (id)initWithPlace:(DictPlace *)place manageObjectContext:(NSManagedObjectContext *)context
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		_place = place;
		_context = context;
		[self setup];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
	[_photos release];
	[super dealloc];
}


#pragma mark - View lifecycle

- (void)updateFooter
{
	self.tableView.tableFooterView = [_photos count] > 0 ? nil : _footerLabel;
}


- (void)loadView
{
	[super loadView];
	_footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	_footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_footerLabel.textAlignment = UITextAlignmentCenter;
	_footerLabel.text = @"No photos found";
	[self updateFooter];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
	[_footerLabel release];
	_footerLabel = nil;
}


- (void)resizeFooter
{
	CGRect labelFrame = _footerLabel.frame;
	labelFrame.size.height = self.tableView.frame.size.height;
	_footerLabel.frame = labelFrame;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self updateFooter];
	[self resizeFooter];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{ return YES; }


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self resizeFooter];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{ return 1; }


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ return [_photos count]; }


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section > 0 || indexPath.row >= [_photos count]) {
		NSLog(@"Invalid index path: %@", indexPath);
		return nil;
	}
	
	id possPhoto = [_photos objectAtIndex:indexPath.row];
	DictPhoto *photo = [possPhoto isKindOfClass:[DictPhoto class]] ? (DictPhoto *)possPhoto : nil;
	if (!photo) {
		NSLog(@"Non-nil photo expected at index: %i", indexPath.row);
		return nil;
	}

	BOOL requiresSubTitle = [photo.title length] > 0 && [photo.desc length] > 0;
	NSString *cellId = requiresSubTitle ? @"CellWithSubtitle" : @"Cell";
	UITableViewCellStyle cellStyle = requiresSubTitle ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellId] autorelease];
    }
    
    cell.textLabel.text = [photo.title length] > 0 ? photo.title
		: [photo.desc length] > 0 ? photo.desc
		: @"Unknown";
	if (requiresSubTitle)
		cell.detailTextLabel.text = photo.desc;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section > 0 || indexPath.row >= [_photos count]) {
		NSLog(@"Invalid index path: %@", indexPath);
		return;
	}

	id possPhoto = [_photos objectAtIndex:indexPath.row];
	if (![possPhoto isKindOfClass:[DictPhoto class]]) {
		NSLog(@"Non-DictPhoto (%@) at specified index path: %@", possPhoto, indexPath);
		return;
	}
	DictPhoto *dictPhoto = (DictPhoto *)possPhoto;

	Place *place = [Place placeFromDictPlace:_place inManagedObjectContext:_context];
	Photo *photo = [Photo photoWithDictPhoto:dictPhoto fromPlace:place inManagedObjectContext:_context];
	if (!photo) {
		NSLog(@"Could not create photo with id %@ in CoreData", dictPhoto.uniqueId);
		return;
	}
	
	NSError *error = nil;
	if ([_context hasChanges] && ![_context save:&error]) {
		NSLog(@"Error saving changes to managed object context: %@", error);
		return;
	}

    PhotoViewController *photoVC = [[PhotoViewController alloc] initWithPhoto:photo];
	[self.navigationController pushViewController:photoVC animated:YES];
	[photoVC release];
}


#pragma mark - Recent photos support

+ (NSArray *)recentPhotosFromUserDefaults
{
	NSMutableArray *retArray = [NSMutableArray array];
	id possRecentPhotos = [[NSUserDefaults standardUserDefaults] objectForKey:@"RecentPhotos"];
	if ([possRecentPhotos isKindOfClass:[NSArray class]]) {
		NSArray *recentPhotos = (NSArray *)possRecentPhotos;
		for (id possPhotoPlist in recentPhotos) {
			DictPhoto *photo = [DictPhoto photoFromPropertyList:possPhotoPlist];
			if (photo)
				[retArray addObject:photo];
		}
	}

	// return immutable copy
	return [NSArray arrayWithArray:retArray];
}

@end
