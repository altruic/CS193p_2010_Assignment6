//
//  PlacesCoreDataTableViewController.h
//  CS193P-6
//
//  Created by Ed Sibbald on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreDataTableViewController.h"


@interface FavoritePlacesCoreDataTVC : CoreDataTableViewController

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
