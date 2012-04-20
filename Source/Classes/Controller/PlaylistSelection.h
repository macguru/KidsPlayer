//
//  PlaylistSelection.h
//  KidsPlayer
//
//  Created by max on 24.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

@interface PlaylistSelection : UITableViewController
{
	id			_delegate;
	NSArray		*_playlistNames;
	NSArray		*_playlists;
	NSString	*_selected;
}

@property(nonatomic,retain) NSString *selectedPlaylistName;
@property(nonatomic,retain) id delegate;

@end

@interface NSObject (PlaylistSelectionDelegate)

- (void)playlistSelectionDidFinish:(PlaylistSelection *)selection;

@end

