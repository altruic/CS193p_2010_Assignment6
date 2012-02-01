//
//  FavoritePhotosCoreDataTVC.m
//  CS193P-6
//
//  Created by Ed Sibbald on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoritePhotosCoreDataTVC.h"

#import "Place.h"
#import "Photo.h"
#import "PhotoViewController.h"


@implementation FavoritePhotosCoreDataTVC

- (id)initWithPlace:(Place *)place managedObjectContext:(NSManagedObjectContext *)context
{
	self = [self initWithStyle:UITableViewStylePlain];
	if (self) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
		NSPredicate *placePredicate = [NSPredicate predicateWithFormat:@"place = %@", place];
		NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"favorite = YES"];
		request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
							 [NSArray arrayWithObjects:placePredicate, favoritePredicate, nil]];
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title"
																						 ascending:YES]];
		
		NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																			  managedObjectContext:context
																				sectionNameKeyPath:nil
																						 cacheName:nil];
		[request release];
		
		self.fetchedResultsController = frc;
		[frc release];
		
		self.titleKey = @"title";
		self.subtitleKey = @"desc";
		self.searchKey = @"title";
		
		self.title = place.name;
	}
	return self;
}


- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    PhotoViewController *photoVC = [[PhotoViewController alloc] initWithPhoto:(Photo *)managedObject];
	[self.navigationController pushViewController:photoVC animated:YES];
	[photoVC release];
}

@end
