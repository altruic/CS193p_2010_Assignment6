//
//  FavoritePhotosCoreDataTVC.h
//  CS193P-6
//
//  Created by Ed Sibbald on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class Place;


@interface FavoritePhotosCoreDataTVC : CoreDataTableViewController

- (id) initWithPlace:(Place *)place managedObjectContext:(NSManagedObjectContext *)context;

@end
