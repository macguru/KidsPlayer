//
//  PlayViewController.m
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "PlayViewController.h"

#import "BackgroundView.h"
#import "KidsPlayerAppDelegate.h"
#import "PlaylistSelection.h"


NSString *PlayViewControllerActiveImage			= @"background_active.png";
NSString *PlayViewControllerInactiveImage		= @"background_inactive.png";

NSString *PlayViewControllerPlayImage			= @"play.png";
NSString *PlayViewControllerPauseImage			= @"pause.png";

@interface PlayViewController ()

- (void)updateDisplay:(BOOL)animated;

@end

@implementation PlayViewController

#pragma mark -
#pragma mark Actions

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Init
	[self updateDisplay: NO];
	[coverView reloadItems];
	
	settingsButton.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey: KidsPlayerEnablePlaylistSelectionPreference];
	
	// Observe
	[appDelegate addObserver:self forKeyPath:@"collections" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"collections"];
	[appDelegate addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"currentItem"];
	[appDelegate addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"playing"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// End observation
	[appDelegate removeObserver:self forKeyPath:@"collections"];
	[appDelegate removeObserver:self forKeyPath:@"currentItem"];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	[self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)updateDisplay:(BOOL)animated
{
	BOOL playing = appDelegate.playing;
	
	// Animations!
	if (animated)
		[UIView beginAnimations:nil context:NULL];
	
	// Background
	NSString *imageName = (appDelegate.playing) ? PlayViewControllerActiveImage : PlayViewControllerInactiveImage;
	((BackgroundView *)self.view).image = [UIImage imageNamed: imageName];
	
	// Cover view
	coverView.selectedItemIndex = [appDelegate.collections indexOfObject: appDelegate.currentCollection];
	coverView.userInteractionEnabled = !playing;
	coverView.focused = playing;
	
	// Play button
	if (!playing)
		[playButton setImage:[UIImage imageNamed: PlayViewControllerPlayImage] forState:UIControlStateNormal];
	else
		[playButton setImage:[UIImage imageNamed: PlayViewControllerPauseImage] forState:UIControlStateNormal];
	
	// Index label
	indexLabel.alpha = (playing) ? 1.0 : 0.0;
	indexLabel.text = [NSString stringWithFormat: @"%d", [appDelegate.currentCollection.items indexOfObject: appDelegate.currentItem] + 1];
	
	// Other buttons
	nextButton.alpha = (playing) ? 1.0 : 0.0;
	previousButton.alpha = (playing) ? 1.0 : 0.0;
	settingsButton.alpha = (playing) ? 0.0 : 0.25;
	
	// Commit animation
	if (animated)
		[UIView commitAnimations];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"currentItem") {
		if ([change objectForKey: NSKeyValueChangeNewKey] != [change objectForKey: NSKeyValueChangeOldKey])
			[self updateDisplay: YES];
    } else if (context == @"playing") {
		if ([[change objectForKey: NSKeyValueChangeNewKey] boolValue] != [[change objectForKey: NSKeyValueChangeOldKey] boolValue])
			[self updateDisplay: YES];
    } else if (context == @"collections") {
		if (![[change objectForKey: NSKeyValueChangeNewKey] isEqual: [change objectForKey: NSKeyValueChangeOldKey]])
			[self updateDisplay: NO];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	settingsButton.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey: KidsPlayerEnablePlaylistSelectionPreference];
}


#pragma mark -
#pragma mark Interface Actions

- (IBAction)togglePlay:(id)sender
{
	appDelegate.playing = !appDelegate.playing;
}

- (IBAction)nextTrack:(id)sender
{
	[appDelegate playNextItem];
}

- (IBAction)previousTrack:(id)sender
{
	[appDelegate playPreviousItem];
}

#pragma mark -

- (IBAction)showSettings:(id)sender
{
	PlaylistSelection *selection = [[PlaylistSelection alloc] init];
	selection.selectedPlaylistName = [[NSUserDefaults standardUserDefaults] objectForKey: KidsPlayerPlaylistNamePreference];
	selection.delegate = self;
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: selection];
	[selection release];
	
	[self presentModalViewController:navigation animated:YES];
	[navigation release];
}

- (void)playlistSelectionDidFinish:(PlaylistSelection *)selection
{
	[[NSUserDefaults standardUserDefaults] setObject:selection.selectedPlaylistName forKey:KidsPlayerPlaylistNamePreference];
	[appDelegate reloadCollections];
	[self updateDisplay: YES];
}

#pragma mark -

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	if (event.type == UIEventTypeRemoteControl) {
		
		switch (event.subtype) {
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[self togglePlay: self];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				[self nextTrack: self];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[self previousTrack: self];
				break;
				
			default:
				break;
		}
	}
}


#pragma mark -
#pragma mark Cover View

- (NSUInteger)numberOfItemsInCoverView:(CoverView *)coverView
{
	return appDelegate.collections.count;
}

- (MPMediaItem *)coverView:(CoverView *)coverView itemAtIndex:(NSUInteger)index
{
	return [[appDelegate.collections objectAtIndex: index] representativeItem];
}

- (void)coverView:(CoverView *)coverView didSelectItemAtIndex:(NSUInteger)index
{
	if ([appDelegate.collections count] > index)
		appDelegate.currentCollection = [appDelegate.collections objectAtIndex: index];
}

@end


