//
//  Place.h
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictPlace : NSObject
{
	NSString *_uniqueId;
	NSString *_name;
	NSString *_desc;
}

@property (copy) NSString *uniqueId;
@property (copy) NSString *name;
@property (copy) NSString *desc;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
