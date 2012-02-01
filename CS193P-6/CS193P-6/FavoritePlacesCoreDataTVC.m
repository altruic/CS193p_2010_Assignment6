//
//  PlacesCoreDataTableViewController.m
//  CS193P-6
//
//  Created by Ed Sibbald on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoritePlacesCoreDataTVC.h"

#import "FavoritePhotosCoreDataTVC.h"

@class Place;


@implementation FavoritePlacesCoreDataTVC

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
		request.predicate = [NSPredicate predicateWithFormat:@"favorite = YES"];
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
																						 ascending:YES]];

		NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																			  managedObjectContext:context
																				sectionNameKeyPath:nil
																						 cacheName:@"FavoritePlacesCache"];
		[request release];
		
		self.fetchedResultsController = frc;
		[frc release];
		
		self.titleKey = @"name";
		self.subtitleKey = @"desc";
		self.searchKey = @"name";

		self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0] autorelease];
		self.title = @"Favorite Places";
	}
	return self;
}


- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    FavoritePhotosCoreDataTVC *favPhotosCDTVC = [[FavoritePhotosCoreDataTVC alloc] initWithPlace:(Place *)managedObject
																			managedObjectContext:managedObject.managedObjectContext];
	[self.navigationController pushViewController:favPhotosCDTVC animated:YES];
	[favPhotosCDTVC release];
}

@end
