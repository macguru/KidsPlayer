//
//  CoverView.m
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "CoverView.h"

#import "CoverViewLayer.h"

#define CoverViewShiftOffset	75.0


@implementation CoverView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder: aDecoder];
	
    if (self) {
		_selectedItem = 0;
		
		// Create cover layer
		_coverLayer = [CoverViewLayer layer];
		[self.layer addSublayer: _coverLayer];
    }
	
    return self;
}

- (void)dealloc
{
	[dataSource autorelease];
	[delegate autorelease];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Accessors

@synthesize dataSource;
@synthesize delegate;

- (void)setDataSource:(id <CoverViewDataSource>)anObject
{
	[dataSource autorelease];
	dataSource = [anObject retain];
	
	[self reloadItems];
}

@synthesize selectedItemIndex=_selectedItem;

- (void)setSelectedItemIndex:(NSUInteger)index
{
	[self setSelectedItemIndex:index reloadItems:YES];
}

- (void)setSelectedItemIndex:(NSUInteger)index reloadItems:(BOOL)reload
{
	_selectedItem = index;
	
	if (reload)
		[self reloadItems];
	if ([self.delegate respondsToSelector: @selector(coverView:didSelectItemAtIndex:)])
		[self.delegate coverView:self didSelectItemAtIndex:index];
}

- (BOOL)focused
{
	return _coverLayer.focused;
}

- (void)setFocused:(BOOL)focused
{
	[_coverLayer setFocused:focused animated:YES];
}


#pragma mark -
#pragma mark Actions

- (void)reloadItems
{
	if (!self.dataSource)
		return;
	
	// Get the item count
	NSUInteger count = [self.dataSource numberOfItemsInCoverView: self];
	
	// Check the number of items
	if (_selectedItem > 0 && _selectedItem > count)
		self.selectedItemIndex = (count > 0) ? count - 1 : 0;
	
	_coverLayer.leftItem = (_selectedItem > 0) ? [self.dataSource coverView:self itemAtIndex:_selectedItem-1] : nil;
	_coverLayer.centerItem = (_selectedItem < count) ? [self.dataSource coverView:self itemAtIndex:_selectedItem] : nil;
	_coverLayer.rightItem = (_selectedItem+1 < count) ? [self.dataSource coverView:self itemAtIndex:_selectedItem+1] : nil;
}

- (void)layoutSubviews
{
	// Make sure the cover layer is in the right position
	_coverLayer.bounds = self.bounds;
	_coverLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}


#pragma mark -
#pragma mark Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_touchStart = [[touches anyObject] locationInView: self];
	_count = [self.dataSource numberOfItemsInCoverView: self];
	_shift = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint position;
	CGFloat offset;
	
	// Calculate offset
	position = [[touches anyObject] locationInView: self];
	offset = position.x - _touchStart.x;
	
	// Move layers
	[_coverLayer setOffset:offset + _shift animated:NO];
	
	// Switch to right
	if (_shift == 0 && offset < -CoverViewShiftOffset && _selectedItem+1 < _count) {
		_shift += [_coverLayer shiftRight];
		_coverLayer.rightItem = (_selectedItem+2 < _count) ? [self.dataSource coverView:self itemAtIndex:_selectedItem+2] : nil;
	}
	// Switch back to center
	else if (_shift > 0 && offset > -CoverViewShiftOffset) {
		_shift += [_coverLayer shiftLeft];
		_coverLayer.leftItem = (_selectedItem > 0) ? [self.dataSource coverView:self itemAtIndex:_selectedItem-1] : nil;
	}
	
	// Switch to left
	if (_shift == 0 && offset > CoverViewShiftOffset && _selectedItem > 0) {
		_shift += [_coverLayer shiftLeft];
		_coverLayer.leftItem = (_selectedItem > 1) ? [self.dataSource coverView:self itemAtIndex:_selectedItem-2] : nil;
	}
	// Switch back to center
	else if (_shift < 0 && offset < CoverViewShiftOffset) {
		_shift += [_coverLayer shiftRight];
		_coverLayer.rightItem = (_selectedItem+1 < _count) ? [self.dataSource coverView:self itemAtIndex:_selectedItem+1] : nil;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Snap to default location
	[_coverLayer setOffset:0 animated:YES];
	
	// Update selected index
	if (_shift > 0)
		[self setSelectedItemIndex:self.selectedItemIndex+1 reloadItems:NO];
	if (_shift < 0)
		[self setSelectedItemIndex:self.selectedItemIndex-1 reloadItems:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end



