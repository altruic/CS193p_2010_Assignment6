//
//  PhotoViewController.h
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;

@interface PhotoViewController : UIViewController <UIScrollViewDelegate>
{
	Photo *_photo;
	NSData *_imageData;
	UIImageView *_imageView;
	UIScrollView *_scrollView;
}

@property (readonly) Photo *photo;

- (id)initWithPhoto:(Photo *)aPhoto;

@end
