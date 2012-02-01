//
//  Photo.h
//  CS193P-6
//
//  Created by Ed Sibbald on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;
@class DictPhoto;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSDate * last_viewed;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) NSString * url;

@property (nonatomic, retain) Place *place;

+ (Photo *)photoWithDictPhoto:(DictPhoto *)dictPhoto
					fromPlace:(Place *)place
	   inManagedObjectContext:(NSManagedObjectContext *)context;

@end
