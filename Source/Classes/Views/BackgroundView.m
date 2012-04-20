//
//  BackgroundView.m
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "BackgroundView.h"


@implementation BackgroundView


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame: frame];

    if (self) {
        _image = nil;
		self.layer.contents = nil;
		self.layer.delegate = self;
    }
	
    return self;
}

- (void)dealloc
{
	[_image autorelease];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors

@synthesize image=_image;

- (void)setImage:(UIImage *)aImage
{
	[_image autorelease];
	_image = [aImage retain];
	
	self.layer.contents = (id)_image.CGImage;
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if ([event isEqual: @"contents"])
		return [CABasicAnimation animationWithKeyPath: @"contents"];
	else
		return nil;
}

@end
