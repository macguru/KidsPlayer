//
//  KidsPlayerAppDelegate.m
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright The Soulmen 2009. All rights reserved.
//

#import "KidsPlayerAppDelegate.h"

#import "PlayViewController.h"

NSString *KidsPlayerPlaylistNamePreference				= @"PlaylistName";
NSString *KidsPlayerEnablePlaylistSelectionPreference	= @"EnablePlaylistSelection";


@interface NSArray (KidsPlayerGrouping)

- (NSArray *)groupByType:(MPMediaGrouping)type;

@end

@interface KidsPlayerAppDelegate ()

- (void)fillPlayerQueueIfNeeded;

@end

@implementation KidsPlayerAppDelegate

- (id)init
{
	self = [super init];
	
	if (self) {
		_loadedPlaylistName = nil;
	}
	
	return self;
}

- (void)dealloc {
    [_player pause];
	[_player release];
	[_loadedPlaylistName autorelease];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Actions

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// Load view
	playController.view.frame = window.bounds;
	[window addSubview: playController.view];
	[window makeKeyAndVisible];
	
	// Load playlist
	[self reloadCollections];
	if (!_collections.count)
		[playController showSettings: self];
	
	// Set up audio session
	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setCategory:AVAudioSessionCategoryPlayback error:NULL];
	session.delegate = self;
	
	// Create player
	_player = [[AVQueuePlayer alloc] initWithItems: nil];
	_player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
	
	[_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionPrior context:@"currentItem"];
	[_player addObserver:self forKeyPath:@"items" options:0 context:@"items"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[self reloadCollections];
	if (!_collections.count)
		[playController showSettings: self];
}


#pragma mark -
#pragma mark Media Player

@synthesize collections=_collections;

- (MPMediaItemCollection *)currentCollection
{
	return _currentCollection;
}

- (void)setCurrentCollection:(MPMediaItemCollection *)aCollection
{
	if (_currentCollection == aCollection)
		return;
	
	[_currentCollection autorelease];
	_currentCollection = [aCollection retain];
	
	// Reset player
	[_player pause];
	[_player removeAllItems];
	_nextTrackIndex = 0;
}

- (void)reloadCollections
{
	[self willChangeValueForKey: @"collections"];
	
	// Get the name
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSString *playlistName = [[NSUserDefaults standardUserDefaults] objectForKey: KidsPlayerPlaylistNamePreference];
	
	// Only reload on change
	if (!playlistName || ![playlistName isEqual: _loadedPlaylistName]) {
		if (_collections) {
			[_collections autorelease];
			_collections = nil;
		}
		
		[_loadedPlaylistName autorelease];
		_loadedPlaylistName = [playlistName retain];
		
		// Find the playlist
		if (playlistName) {
			MPMediaQuery *query = [MPMediaQuery albumsQuery];
			[query addFilterPredicate: [MPMediaPropertyPredicate predicateWithValue:playlistName forProperty:MPMediaPlaylistPropertyName]];
			
			// Group by album
			NSArray *items = [query items];
			if (items && [items count])
				_collections = [[items groupByType: MPMediaGroupingAlbum] copy];
		}
	}
	
	// update current item
	if (!_collections || ![_collections containsObject: self.currentCollection])
		self.currentCollection = ((_collections && [_collections count])
								  ? [_collections objectAtIndex: 0] 
								  : nil);
	
	[self didChangeValueForKey: @"collections"];
}

- (void)fillPlayerQueueIfNeeded
{
	NSUInteger totalCount = [_currentCollection.items count];
	NSUInteger count = [_player.items count];
	
	NSUInteger fillIndex;
	if (count)
		fillIndex = (_currentTrackIndex + count) % totalCount;
	else
		fillIndex = _nextTrackIndex;
	
	NSUInteger tries = 0;
	
	while (count < totalCount && count < 2 && tries < totalCount) {
		@try {
			[_player insertItem:[AVPlayerItem playerItemWithURL:[[_currentCollection.items objectAtIndex: fillIndex] valueForProperty: MPMediaItemPropertyAssetURL]] afterItem:nil];
			count++;
		}
		@catch (NSException * e) {
			NSLog(@"%@", e);
		}
		
		fillIndex = (fillIndex + 1) % totalCount;
		tries++;
	}
}


#pragma mark -

- (BOOL)isPlaying
{
	return (_player.rate > 0.0);
}

- (void)setPlaying:(BOOL)play
{
	if (play) {
		[self fillPlayerQueueIfNeeded];
		
		if ([[_player items] count])
			[_player play];
		else
			[_player pause];
	} else {
		[_player pause];
	}
}

- (MPMediaItem *)currentItem
{
	if (_currentTrackIndex < [_currentCollection.items count])
		return [_currentCollection.items objectAtIndex: _currentTrackIndex];
	else
		return nil;
}

- (void)playNextItem
{
	[_player advanceToNextItem];
}

- (void)playPreviousItem
{
	if (_currentTrackIndex > 0)
		_nextTrackIndex = _currentTrackIndex-1;
	else
		_nextTrackIndex = [_currentCollection.items count]-1;
	
	[_player removeAllItems];
	[self fillPlayerQueueIfNeeded];
}
	 
	 
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"currentItem") {
		// Forward change
		if ([[change objectForKey: NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
			[self willChangeValueForKey: @"currentItem"];
		} else {
			_currentTrackIndex = _nextTrackIndex;
			_nextTrackIndex = (_currentTrackIndex + 1) % [_currentCollection.items count];
			
			[self didChangeValueForKey: @"currentItem"];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if (_player.currentItem)
					[self fillPlayerQueueIfNeeded];
			});
		}
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -
#pragma mark AudioSession

- (void)beginInterruption
{
	_wasPlaying = self.playing;
	self.playing = NO;
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
	if (_wasPlaying && (flags & AVAudioSessionInterruptionFlags_ShouldResume)) {
		self.playing = YES;
	}
}

@end

@implementation NSArray (KidsPlayerGrouping)

- (NSArray *)groupByType:(MPMediaGrouping)type
{
	NSMutableDictionary *groups;
	NSMutableSet *names;
	NSString *property;
	
	// Init
	groups = [NSMutableDictionary dictionary];
	names = [NSMutableSet set];
	
	// Get grouping property name
	switch (type) {
		case MPMediaGroupingTitle:
			property = MPMediaItemPropertyTitle;
			break;
		case MPMediaGroupingAlbum:
			property = MPMediaItemPropertyAlbumTitle;
			break;
		default:
			return nil;
	}
	
	// Group into arrays
	for (MPMediaItem *item in self) {
		NSMutableArray *group;
		NSString *name;
		
		name = [item valueForProperty: property];
		[names addObject: name];
		
		if ((group = [groups objectForKey: name]))
			[group addObject: item];
		else
			[groups setObject:[NSMutableArray arrayWithObject: item] forKey:name];
	}
	
	// Sort names
	NSArray *sortedNames = [[names allObjects] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
	
	// Build item collections
	NSMutableArray *collections = [NSMutableArray arrayWithCapacity: [sortedNames count]];
	
	for (NSString *name in sortedNames)
		[collections addObject: [MPMediaItemCollection collectionWithItems: [groups objectForKey: name]]];
	
	// Done
	return collections;
}

@end


