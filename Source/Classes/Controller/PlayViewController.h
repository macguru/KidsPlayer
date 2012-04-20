//
//  PlayViewController.h
//  KidsPlayer
//
//  Created by max on 20.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "CoverView.h"

@class KidsPlayerAppDelegate;

@interface PlayViewController : UIViewController <CoverViewDataSource, CoverViewDelegate>
{
	IBOutlet KidsPlayerAppDelegate	*appDelegate;
	IBOutlet CoverView				*coverView;
	IBOutlet UILabel				*indexLabel;
	IBOutlet UIButton				*nextButton;
	IBOutlet UIButton				*playButton;
	IBOutlet UIButton				*previousButton;
	IBOutlet UIButton				*settingsButton;
}

- (IBAction)togglePlay:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;
- (IBAction)showSettings:(id)sender;

@end
