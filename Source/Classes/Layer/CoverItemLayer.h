//
//  CoverItemLayer.h
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

@interface CoverItemLayer : CALayer
{
	CALayer		*_coverLayer;
	MPMediaItem	*_item;
}

@property(nonatomic,retain) MPMediaItem *item;

// Utilities
+ (CGImageRef)shadowImage;
+ (CGImageRef)missingCoverImage;

@end
