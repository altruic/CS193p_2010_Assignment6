//
//  Photo.m
//  CS193P-5
//
//  Created by Ed Sibbald on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DictPhoto.h"

#import "FlickrFetcher.h"

@implementation DictPhoto

@synthesize uniqueId = _uniqueId;
@synthesize title = _title;
@synthesize desc = _description;
@synthesize url = _url;

- (id)initWithDictionary:(NSDictionary *)dict
{
	self = [self init];
	if (!self)
		return self;

	id possId = [dict objectForKey:@"id"];
	NSString *photoId = [possId isKindOfClass:[NSString class]] ? (NSString *)possId : nil;
	if (!photoId) {
		NSLog(@"Non-nil string expected at key \"id\"");
		[self release];
		return nil;
	}
	self.uniqueId = photoId;

	id possTitle = [dict objectForKey:@"title"];
	NSString *title = [possTitle isKindOfClass:[NSString class]] ? (NSString *)possTitle : nil;
	if (!title) {
		NSLog(@"Non-nil string expected at key \"title\"");
		[self release];
		return nil;
	}
	self.title = title;
	
	id possDescriptionDict = [dict objectForKey:@"description"];
	NSDictionary *descriptionDict = [possDescriptionDict isKindOfClass:[NSDictionary class]]
		? (NSDictionary *)possDescriptionDict : nil;
	if (!descriptionDict) {
		NSLog(@"Non-nil dictionary expected at key \"description\"");
		[self release];
		return nil;
	}
	id possDescription = [descriptionDict objectForKey:@"_content"];
	NSString *description = [possDescription isKindOfClass:[NSString class]] ? (NSString *)possDescription : nil;
	if (!description) {
		NSLog(@"Non-nil string expected at key \"description/\"_content\"\"");
		[self release];
		return nil;
	}
	self.desc = description;
	
	self.url = [FlickrFetcher urlStringForPhotoWithFlickrInfo:dict format:FlickrFetcherPhotoFormatLarge];
	
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.desc = nil;
	self.url = nil;
	[super dealloc];
}

+ (id)propertyListFromPhoto:(DictPhoto *)photo
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:photo.title forKey:@"title"];
	[dict setObject:photo.desc forKey:@"description"];
	[dict setObject:photo.url forKey:@"url"];
	return [NSDictionary dictionaryWithDictionary:dict];
}

+ (DictPhoto *)photoFromPropertyList:(id)plist
{
	NSDictionary *dict = [plist isKindOfClass:[NSDictionary class]] ? (NSDictionary *)plist : nil;
	if (!dict) {
		NSLog(@"Incorrectly formatted property list");
		return nil;
	}
	
	id possTitle = [dict objectForKey:@"title"];
	NSString *title = [possTitle isKindOfClass:[NSString class]] ? (NSString *)possTitle : nil;
	id possDescription = [dict objectForKey:@"description"];
	NSString *description = [possDescription isKindOfClass:[NSString class]] ? (NSString *)possDescription : nil;
	id possUrl = [dict objectForKey:@"url"];
	NSString *url = [possUrl isKindOfClass:[NSString class]] ? (NSString *)possUrl : nil;

	if (!title || !description || !url || [url length] == 0) {
		NSLog(@"Incorrectly formatted property list");
		return nil;
	}

	DictPhoto *photo = [[DictPhoto alloc] init];
	photo.title = title;
	photo.desc = description;
	photo.url = url;
	return [photo autorelease];
}

@end
