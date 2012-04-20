//
//  PlaylistSelection.m
//  KidsPlayer
//
//  Created by max on 24.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "PlaylistSelection.h"


@implementation PlaylistSelection

- (id)init
{
	self = [super initWithStyle: UITableViewStylePlain];
	
	if (self) {
		_delegate = nil;
		_selected = nil;
		
		// Find playlist names
		NSArray *playlists = [[MPMediaQuery playlistsQuery] collections];
		NSMutableArray *names = [NSMutableArray arrayWithCapacity: [playlists count]];
		
		for (MPMediaPlaylist *list in playlists)
			[names addObject: [list valueForProperty: MPMediaPlaylistPropertyName]];
			
		_playlists = [playlists retain];
		_playlistNames = [names retain];
	}
	
	return self;
}

- (void)dealloc
{
	[_delegate autorelease];
	[_playlists autorelease];
	[_playlistNames autorelease];
	[_selected autorelease];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Accessors & Actions

@synthesize delegate=_delegate;
@synthesize selectedPlaylistName=_selected;

- (UIModalTransitionStyle)modalTransitionStyle
{
	return UIModalTransitionStyleFlipHorizontal;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"PlaylistTitle", nil);
	self.navigationItem.prompt = NSLocalizedString(@"PlaylistPrompt", nil);
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_playlistNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSString *name = [_playlistNames objectAtIndex: indexPath.row];
	MPMediaItemCollection *playlist = [_playlists objectAtIndex: indexPath.row];
	
	cell.imageView.image = [[[playlist.items lastObject] valueForProperty: MPMediaItemPropertyArtwork] imageWithSize: CGSizeMake(50, 50)];
	cell.textLabel.text = name;
	cell.accessoryType = ([name isEqual: _selected]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Deselect old
	NSUInteger index = [_playlistNames indexOfObject: _selected];
	if (index < _playlistNames.count)
		[tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:index inSection:0]].accessoryType = UITableViewCellAccessoryNone;
	
	// Select new
	UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	self.selectedPlaylistName = cell.textLabel.text;
	
	// Pop
	[self.navigationController.parentViewController dismissModalViewControllerAnimated: YES];
	
	// Delegate
	if ([self.delegate respondsToSelector: @selector(playlistSelectionDidFinish:)])
		[self.delegate playlistSelectionDidFinish: self];
}

@end

