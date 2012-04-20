//
//  CoverViewLayer.m
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "CoverViewLayer.h"

#import "CoverItemLayer.h"


#define CoverViewLayerCoverSize		240
#define CoverViewLayerCoverSpace	20


@implementation CoverViewLayer

- (id)init
{
	self = [super init];
	
	if (self) {
		_offset = 0;
		_focused = NO;
		
		_leftLayer = [CoverItemLayer layer];
		_leftLayer.delegate = self;
		[self addSublayer: _leftLayer];
		
		_centerLayer = [CoverItemLayer layer];
		_centerLayer.delegate = self;
		[self addSublayer: _centerLayer];
		
		_rightLayer = [CoverItemLayer layer];
		_rightLayer.delegate = self;
		[self addSublayer: _rightLayer];
	}
	
	return self;
}


#pragma mark -
#pragma mark Accessors

@synthesize offset=_offset;

- (void)setOffset:(CGFloat)offset
{
	[self setOffset:offset animated:NO];
}

- (void)setOffset:(CGFloat)offset animated:(BOOL)animated
{
	_animate = animated;
	_offset = offset;
	
	[self setNeedsLayout];
}

@synthesize focused=_focused;

- (void)setFocused:(BOOL)focused
{
	[self setFocused:focused animated:NO];
}

- (void)setFocused:(CGFloat)focused animated:(BOOL)animated
{
	_animate = animated;
	_focused = focused;
	
	[self setNeedsLayout];
}

- (MPMediaItem *)leftItem
{
	return _leftLayer.item;
}

- (void)setLeftItem:(MPMediaItem *)anItem
{
	_leftLayer.item = anItem;
}

- (MPMediaItem *)centerItem
{
	return _centerLayer.item;
}

- (void)setCenterItem:(MPMediaItem *)anItem
{
	_centerLayer.item = anItem;
}

- (MPMediaItem *)rightItem
{
	return _rightLayer.item;
}

- (void)setRightItem:(MPMediaItem *)anItem
{
	_rightLayer.item = anItem;
}


#pragma mark -
#pragma mark Actions

- (CGFloat)shiftLeft
{
	// Shift layers
	CoverItemLayer *layer = _rightLayer;
	
	_rightLayer = _centerLayer;
	_centerLayer = _leftLayer;
	_leftLayer = layer;
	
	// Shift offset
	CGFloat shift = - (CoverViewLayerCoverSize + CoverViewLayerCoverSpace);
	_offset += shift;
	_animate = NO;
	
	// Update
	[self setNeedsLayout];
	
	return shift;
}

- (CGFloat)shiftRight
{
	// Shift layers
	CoverItemLayer *layer = _leftLayer;
	
	_leftLayer = _centerLayer;
	_centerLayer = _rightLayer;
	_rightLayer = layer;
	
	// Shift offset
	CGFloat shift = + (CoverViewLayerCoverSize + CoverViewLayerCoverSpace);
	_offset += shift;
	_animate = NO;
	
	// Update
	[self setNeedsLayout];
	
	return shift;
}


#pragma mark -
#pragma mark Layout

- (void)layoutSublayers
{
	CGPoint center, point;
	CGRect bound;
	
	// Compute center
	center.y = self.bounds.size.height / 2;
	center.x = self.bounds.size.width / 2;
	center.x += self.offset;
	
	// Size
	bound.origin = CGPointZero;
	bound.size.width = CoverViewLayerCoverSize;
	bound.size.height = CoverViewLayerCoverSize;
	
	// Left layer
	point = center;
	point.x -= CoverViewLayerCoverSize + CoverViewLayerCoverSpace;
	_leftLayer.position = point;
	_leftLayer.bounds = bound;
	_leftLayer.opacity = (_focused) ? 0.0 : 1.0;
	
	// Left layer
	point = center;
	_centerLayer.position = point;
	_centerLayer.bounds = bound;
	_centerLayer.opacity = 1;
	
	// Left layer
	point = center;
	point.x += CoverViewLayerCoverSize + CoverViewLayerCoverSpace;
	_rightLayer.position = point;
	_rightLayer.bounds = bound;
	_rightLayer.opacity = (_focused) ? 0.0 : 1.0;
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	return (_animate) ? nil : (id)[NSNull null];
}

@end


