//
//  PhotosTableViewController.h
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DictPlace;


@interface MostPopularPhotosTVC : UITableViewController
{
	DictPlace *_place;
	NSArray *_photos;
	NSManagedObjectContext *_context;
	UILabel *_footerLabel;
}

- (id)initWithPlace:(DictPlace *)place manageObjectContext:(NSManagedObjectContext *)context;

//- (void)didSelectPhoto:(DictPhoto *)photo;

//+ (NSArray *)recentPhotosFromUserDefaults;

@end
