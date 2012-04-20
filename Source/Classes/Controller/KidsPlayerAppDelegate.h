//
//  KidsPlayerAppDelegate.h
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright The Soulmen 2009. All rights reserved.
//

extern NSString *KidsPlayerPlaylistNamePreference;
extern NSString *KidsPlayerEnablePlaylistSelectionPreference;

@class PlayViewController;

@interface KidsPlayerAppDelegate : NSObject <UIApplicationDelegate, AVAudioSessionDelegate>
{
	IBOutlet PlayViewController	*playController;
	IBOutlet UIWindow			*window;
	
	NSArray					*_collections;
	MPMediaItemCollection	*_currentCollection;
	NSUInteger				_currentTrackIndex;
	NSUInteger				_nextTrackIndex;
	NSString				*_loadedPlaylistName;
	AVQueuePlayer			*_player;
	BOOL					_wasPlaying;
}

@property(readonly) NSArray *collections;
@property(nonatomic,retain) MPMediaItemCollection *currentCollection;
- (void)reloadCollections;

@property(assign,getter=isPlaying) BOOL playing;

@property(readonly) MPMediaItem *currentItem;
- (void)playNextItem;
- (void)playPreviousItem;

@end

