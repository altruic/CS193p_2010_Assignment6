//
//  Place.m
//  CS193P-6
//
//  Created by Ed Sibbald on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

#import "Photo.h"
#import "DictPlace.h"


@implementation Place

@dynamic desc;
@dynamic favorite;
@dynamic name;
@dynamic unique_id;

@dynamic photos;


+ (Place *)placeFromDictPlace:(DictPlace *)dictPlace inManagedObjectContext:(NSManagedObjectContext *)context
{
	if (!dictPlace)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"unique_id = %@", dictPlace.uniqueId];
	
	NSError *error = nil;
	Place *place = [[context executeFetchRequest:request error:&error] lastObject];
	
	if (error) {
		NSLog(@"Error searching for place with id %@: %@", dictPlace.uniqueId, error);
		return nil;
	}
	
	if (!place) {
		place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
		place.desc = dictPlace.desc;
		place.favorite = [NSNumber numberWithBool: NO];
		place.name = dictPlace.name;
		place.unique_id = dictPlace.uniqueId;
	}
	
	return place;
}

@end
