//
//  CoverView.h
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

@protocol CoverViewDataSource, CoverViewDelegate;
@class CoverViewLayer;

@interface CoverView : UIView
{
	IBOutlet id <CoverViewDataSource>	dataSource;
	IBOutlet id <CoverViewDelegate>		delegate;
	
	NSUInteger		_count;
	CoverViewLayer	*_coverLayer;
	NSUInteger		_selectedItem;
	CGFloat			_shift;
	CGPoint			_touchStart;
}

@property(nonatomic,retain) id <CoverViewDataSource> dataSource;
@property(nonatomic,retain) id <CoverViewDelegate> delegate;

- (void)reloadItems;

@property(nonatomic,assign) NSUInteger selectedItemIndex;
- (void)setSelectedItemIndex:(NSUInteger)index reloadItems:(BOOL)reload;

@property(nonatomic,assign) BOOL focused;

@end

@protocol CoverViewDataSource <NSObject>

- (NSUInteger)numberOfItemsInCoverView:(CoverView *)coverView;
- (MPMediaItem *)coverView:(CoverView *)coverView itemAtIndex:(NSUInteger)index;

@end

@protocol CoverViewDelegate <NSObject>
@optional

- (void)coverView:(CoverView *)coverView didSelectItemAtIndex:(NSUInteger)index;

@end