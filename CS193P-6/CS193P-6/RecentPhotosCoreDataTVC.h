//
//  MostRecentCoreDataTVC.h
//  CS193P-6
//
//  Created by Ed Sibbald on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface RecentPhotosCoreDataTVC : CoreDataTableViewController

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
