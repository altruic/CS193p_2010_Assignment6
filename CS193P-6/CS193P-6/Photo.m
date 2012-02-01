//
//  Photo.m
//  CS193P-6
//
//  Created by Ed Sibbald on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "Place.h"

#import "DictPhoto.h"


@implementation Photo

@dynamic desc;
@dynamic favorite;
@dynamic last_viewed;
@dynamic title;
@dynamic unique_id;
@dynamic url;

@dynamic place;


+ (Photo *)photoWithDictPhoto:(DictPhoto *)dictPhoto
					fromPlace:(Place *)place
	   inManagedObjectContext:(NSManagedObjectContext *)context
{
	if (dictPhoto == nil)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"unique_id = %@", dictPhoto.uniqueId];
	
	NSError *error = nil;
	Photo *photo = [[context executeFetchRequest:request error:&error] lastObject];
	
	if (error) {
		NSLog(@"Error searching for photo with id %@: %@", dictPhoto.uniqueId, error);
		return nil;
	}
	
	if (!photo) {
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.desc = dictPhoto.desc;
		photo.title = dictPhoto.title;
		photo.unique_id = dictPhoto.uniqueId;
		photo.favorite = [NSNumber numberWithBool:NO];
		photo.url = dictPhoto.url;
		
		photo.place = place;
	}
	
	return photo;
}

@end
