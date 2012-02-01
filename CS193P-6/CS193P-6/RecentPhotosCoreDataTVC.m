//
//  MostRecentCoreDataTVC.m
//  CS193P-6
//
//  Created by Ed Sibbald on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotosCoreDataTVC.h"

#import "PhotoViewController.h"

@class Photo;


@interface RecentPhotosCoreDataTVC ()
@property (readonly) NSTimeInterval timeIntervalToShow;
@end


@implementation RecentPhotosCoreDataTVC

- (NSTimeInterval)timeIntervalToShow
	{ return 60 * 60 * 24 * 2; } // 2 days


- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
{
	self = [self initWithStyle:UITableViewStylePlain];
	if (self) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
		// to get this totally correct, we should recalc this predicate each time we load the page.
		request.predicate = [NSPredicate predicateWithFormat:@"last_viewed > %@",
							 [NSDate dateWithTimeIntervalSinceNow:-self.timeIntervalToShow]];
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"last_viewed"
																						 ascending:NO]];
		
		NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																			  managedObjectContext:context
																				sectionNameKeyPath:nil
																						 cacheName:@"RecentPhotosCache"];
		[request release];
		
		self.fetchedResultsController = frc;
		[frc release];
		
		self.titleKey = @"title";
		self.subtitleKey = @"desc";
		self.searchKey = @"title";
		
		self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:0] autorelease];
		self.title = @"Recent Photos";
	}
	return self;
}


- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    PhotoViewController *photoVC = [[PhotoViewController alloc] initWithPhoto:(Photo *)managedObject];
	[self.navigationController pushViewController:photoVC animated:YES];
	[photoVC release];
}


- (void)viewWillAppear:(BOOL)animated
{
	NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
	NSPredicate *oldPredicate = [NSPredicate predicateWithFormat:@"last_viewed < %@",
								 [NSDate dateWithTimeIntervalSinceNow:-self.timeIntervalToShow]];
	NSPredicate *notFavoritePredicate = [NSPredicate predicateWithFormat:@"favorite = NO"];
	request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
						 [NSArray arrayWithObjects:oldPredicate, notFavoritePredicate, nil]];
	
	NSError *error = nil;
	NSArray *oldPhotos = [context executeFetchRequest:request error:&error];
	
	if (error)
		NSLog(@"Error searching for old photos to delete: %@", error);
	else {
		for (NSManagedObject *oldPhoto in oldPhotos)
			[context deleteObject:oldPhoto];
	}
	
	[request release];

	[super viewWillAppear:animated];
}

@end
