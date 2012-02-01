//
//  PlacesTableViewController.h
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MostPopularPlacesTVC : UITableViewController
{
	NSArray *_places;
	NSManagedObjectContext *_context;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;


@end
