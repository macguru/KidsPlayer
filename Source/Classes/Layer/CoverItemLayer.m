//
//  CoverItemLayer.m
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "CoverItemLayer.h"

#import "CGStringDrawing.h"


#define CoverItemLayerCoverInset	5.0
#define CoverItemLayerCoverOffset	2.0

#define CoverItemTextSideInset		45.0
#define CoverItemTextTopInset		25.0
#define CoverItemTextBottomInset	25.0

#define CoverItemFontSize			18

NSString *CoverItemLayerMissingCoverImage	= @"missingcover.png";
NSString *CoverItemLayerShadowImage			= @"shadow.png";


@implementation CoverItemLayer

+ (void)initialize
{
	[super initialize];
	srandom(time(NULL));
}

- (id)init
{
	self = [super init];
	
	if (self) {
		_item = nil;
		
		// Create cover layer
		_coverLayer = [CALayer layer];
		_coverLayer.delegate = self;
		_coverLayer.contentsScale = 2.0;
		[self addSublayer: _coverLayer];
	}
	
	return self;
}


#pragma mark -
#pragma mark Actions

- (void)updateArtwork
{
	if (_item) {
		MPMediaItemArtwork *artwork = [_item valueForProperty: MPMediaItemPropertyArtwork];
		UIImage *image = [artwork imageWithSize: _coverLayer.bounds.size];
		
		if (image) {
			_coverLayer.contents = (id)image.CGImage;
		} else {
			_coverLayer.contents = nil;
			[_coverLayer setNeedsDisplay];
		}
		
		self.contents = (id)[[self class] shadowImage];
	} else {
		_coverLayer.contents = nil;
		self.contents = nil;
	}
}

- (void)layoutSublayers
{
	CGRect bound;
	
	bound = self.bounds;
	bound = CGRectInset(bound, CoverItemLayerCoverInset, CoverItemLayerCoverInset);
	bound.origin.y -= CoverItemLayerCoverOffset;
	
	_coverLayer.frame = bound;
	[self updateArtwork];
}


#pragma mark -
#pragma mark Accessors

@synthesize item=_item;

- (void)setItem:(MPMediaItem *)aItem
{
	if (_item == aItem)
		return;
	
	[_item autorelease];
	_item = [aItem retain];
	
	[self updateArtwork];
}


#pragma mark -

+ (CGImageRef)shadowImage
{
	static UIImage *image = nil;
	if (!image)
		image = [[UIImage imageNamed: CoverItemLayerShadowImage] retain];
	return image.CGImage;
}

+ (CGImageRef)missingCoverImage
{
	static UIImage *image = nil;
	if (!image)
		image = [[UIImage imageNamed: CoverItemLayerMissingCoverImage] retain];
	return image.CGImage;
}

+ (UIColor *)randomDarkColor
{
	return [UIColor colorWithRed:(random()%150)/256. green:(random()%150)/256. blue:(random()%150)/256. alpha:1.0];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGImageRef missingCoverImg = [[self class] missingCoverImage];
	CGSize size = layer.bounds.size;
	
	// Draw background
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, 0, size.height);
	CGContextScaleCTM(ctx, 1, -1);
	
	CGContextDrawImage(ctx, layer.bounds, missingCoverImg);
	
	CGContextRestoreGState(ctx);
	
	// Rotate by -6 degree
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, size.width / 2, size.height / 2);
	CGContextRotateCTM(ctx, -6./180.*M_PI);
	CGContextTranslateCTM(ctx, - size.width / 2, - size.height / 2);
	
	// Artist
	UIFont *font = [UIFont fontWithName:@"Splurge" size:CoverItemFontSize];
	CGRect frame = CGRectMake(CoverItemTextSideInset, CoverItemTextTopInset, size.width - 2 * CoverItemTextSideInset, [font lineHeight] * 2);
	
	[[_item valueForProperty: MPMediaItemPropertyArtist] drawInContext:ctx inRect:frame withFont:font textColor:[[self class] randomDarkColor] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter centerVertically:YES];
	
	// Album
	frame.origin.y = size.height - frame.size.height - CoverItemTextBottomInset;
	[[_item valueForProperty: MPMediaItemPropertyAlbumTitle] drawInContext:ctx inRect:frame withFont:font textColor:[[self class] randomDarkColor] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter centerVertically:YES];
	
	CGContextRestoreGState(ctx);
}

@end
