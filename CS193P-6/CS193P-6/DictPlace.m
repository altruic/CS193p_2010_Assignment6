//
//  Place.m
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DictPlace.h"

@implementation DictPlace

@synthesize uniqueId = _uniqueId;
@synthesize name = _name;
@synthesize desc = _desc;

- (id)initWithDictionary:(NSDictionary *)dict
{
	self = [super init];
	if (!self)
		return self;
	
	id possId = [dict objectForKey:@"place_id"];
	NSString *placeId = [possId isKindOfClass:[NSString class]] ? (NSString *)possId : nil;
	if ([placeId length] == 0) {
		NSLog(@"Non-empty string expected at key \"place_id\"");
		[self release];
		return nil;
	}
	self.uniqueId = placeId;

	id possContent = [dict objectForKey:@"_content"];
	NSString *content = [possContent isKindOfClass:[NSString class]] ? (NSString *)possContent : nil;
	if ([content length] == 0) {
		// parse into name, description
		NSLog(@"Non-empty string expected at key \"_content\"");
		[self release];
		return nil;
	}

	NSRange range = [content rangeOfString:@","];
	if (range.location == NSNotFound) {
		self.name = content;
	}
	else {
		self.name = [content substringToIndex:range.location];
		if ([content length] > range.location + 2)
			self.desc = [content substringFromIndex:range.location + 2];
	}

	return self;
}

- (void)dealloc
{
	self.name = nil;
	self.desc = nil;
	self.uniqueId = nil;
	[super dealloc];
}

@end
