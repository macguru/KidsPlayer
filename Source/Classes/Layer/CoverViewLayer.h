//
//  CoverViewLayer.h
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

@class CoverItemLayer;

@interface CoverViewLayer : CALayer
{
	BOOL			_animate;
	CoverItemLayer	*_centerLayer;
	BOOL			_focused;
	CoverItemLayer	*_leftLayer;
	CGFloat			_offset;
	CoverItemLayer	*_rightLayer;
}

@property(nonatomic, assign) CGFloat offset;
- (void)setOffset:(CGFloat)offset animated:(BOOL)animated;

@property(nonatomic, assign) BOOL focused;
- (void)setFocused:(CGFloat)focused animated:(BOOL)animated;

@property(nonatomic, retain) MPMediaItem *leftItem;
@property(nonatomic, retain) MPMediaItem *centerItem;
@property(nonatomic, retain) MPMediaItem *rightItem;

- (CGFloat)shiftLeft;
- (CGFloat)shiftRight;

@end
