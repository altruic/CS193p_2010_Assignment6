//
//  Place.h
//  CS193P-6
//
//  Created by Ed Sibbald on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;
@class DictPlace;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * unique_id;

@property (nonatomic, retain) NSSet *photos;

+ (Place *)placeFromDictPlace:(DictPlace *)dictPlace inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end
