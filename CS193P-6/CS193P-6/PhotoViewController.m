//
//  PhotoViewController.m
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"

#import "FlickrFetcher.h"
#import "Place.h"
#import "Photo.h"


@interface PhotoViewController ()
@property (readonly) NSString *favoritePhotoFilePath;
@property (readonly) NSData *imageData;
@end


@implementation PhotoViewController

@synthesize photo = _photo;

- (NSString *)favoritePhotoFilePath
{
	NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return [docsPath stringByAppendingPathComponent:_photo.unique_id];
}


- (id)initWithPhoto:(Photo *)aPhoto
{
	self = [super init];
	if (self) {
		_photo = [aPhoto retain];
		self.title = !_photo ? @"No photo" : [_photo.title length] == 0 ? @"No title" : _photo.title;
		
		if (_photo) {
			_photo.last_viewed = [NSDate date];
			NSError *error = nil;
			if (![_photo.managedObjectContext save:&error])
				NSLog(@"Error updating last viewed time: %@", error);
		}
	}
	return self;
}

- (void)dealloc
{
	[_scrollView release];
	[_imageView release];
	[_imageData release];
	[_photo release];
	[super dealloc];
}

#pragma mark - View lifecycle

- (NSData *)imageData
{
	if (!self.photo) {
		NSLog(@"Non-nil photo expected");
		return nil;
	}

	if (!_imageData) {
		if ([self.photo.favorite boolValue])
			_imageData = [[NSData alloc] initWithContentsOfFile:self.favoritePhotoFilePath];
		else {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			_imageData = [[FlickrFetcher imageDataForPhotoWithURLString:self.photo.url] retain];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
		
		if (!_imageData) {
			NSLog(@"Non-nil image data expected");
			return nil;
		}
	}
	
	return _imageData;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	NSData *data = self.imageData;
	if (!data) {
		NSLog(@"Could not load image data");
		// todo: Create plain label with text "Could not load image"
		return;
	}

	UIImage *image = [[UIImage alloc] initWithData:data];
	_imageView = [[UIImageView alloc] initWithImage:image];
	[image release];

	_scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.delegate = self;
	_scrollView.minimumZoomScale = 0.1;
	_scrollView.maximumZoomScale = 2.0;
	[_scrollView addSubview:_imageView];
	_scrollView.contentSize = _imageView.bounds.size;
	
	self.view = _scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{ return _imageView; }

- (void)updateZoomScalesAndResetZoom:(BOOL)reset
{
	CGSize scrollViewSize = _scrollView.bounds.size;
	double scrollAspect = scrollViewSize.width / scrollViewSize.height;
	CGSize imageViewSize = _imageView.bounds.size;
	double imageAspect = imageViewSize.width / imageViewSize.height;

	_scrollView.minimumZoomScale = imageAspect > scrollAspect
		? scrollViewSize.width / imageViewSize.width
		: scrollViewSize.height / imageViewSize.height;
	_scrollView.maximumZoomScale = 2.0;
	
	if (reset) {
		_scrollView.zoomScale = imageAspect > scrollAspect
			? scrollViewSize.height / imageViewSize.height
			: scrollViewSize.width / imageViewSize.width;
	}
}


- (void)updateFavoriteButton
{
	UIBarButtonItem *favButton = nil;
	if ([_photo.favorite boolValue])
		favButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																  target:self
																  action:@selector(removeButtonTapped)];
	else
		favButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																  target:self
																  action:@selector(addButtonTapped)];
	self.navigationItem.rightBarButtonItem = favButton;
	[favButton release];
}


- (void)addButtonTapped
{
	_photo.favorite = [NSNumber numberWithBool:YES];
	_photo.place.favorite = [NSNumber numberWithBool:YES];
	NSError *error = nil;
	if (![_photo.managedObjectContext save:&error]) {
		NSLog(@"Error setting favorite flag for photo with id %@: %@", _photo.unique_id, error);
		return;
	}
	
	[self.imageData writeToFile:self.favoritePhotoFilePath atomically:YES];
	
	[self updateFavoriteButton];
}


- (void)removeButtonTapped
{
	_photo.favorite = [NSNumber numberWithBool:NO];
	// unset flag on place if need be
	BOOL otherFavPhotoExists = NO;
	for (Photo *photo in _photo.place.photos) {
		if ([photo.favorite boolValue]) {
			otherFavPhotoExists = YES;
			break;
		}
	}
	_photo.place.favorite = [NSNumber numberWithBool:otherFavPhotoExists];
	
	NSError *error = nil;
	if (![_photo.managedObjectContext save:&error]) {
		NSLog(@"Error unsetting favorite flag for photo with id %@: %@", _photo.unique_id, error);
		return;
	}

	[[NSFileManager defaultManager] removeItemAtPath:self.favoritePhotoFilePath error:&error];
	if (error)
		NSLog(@"Error deleting locally cached data for photo with id %@", _photo.unique_id);
	
	[self updateFavoriteButton];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	[self updateFavoriteButton];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateZoomScalesAndResetZoom:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{ return YES; }


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self updateZoomScalesAndResetZoom:NO];
}

@end
