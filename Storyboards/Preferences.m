//
//  Preferences.m
//  MasterAPI
//
//  Created by sim on 18/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "Preferences.h"

@interface Preferences ()

@end

@implementation Preferences

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (void)setupToolbar
{

    [self addView:_tokensView label:@"Tokens" image:[NSImage imageNamed:NSImageNameAdvanced]];
    [self addView:_generalsView label:@"Generals" image:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
    
    //[self addView:playbackPreferenceView label:@"Playback"];
    //[self addView:updatePreferenceView label:@"Update"];
    //[self addView:advancedPreferenceView label:@"Advanced"];
}

@end
