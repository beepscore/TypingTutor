//
//  AppController.m
//  TypingTutor
//
//  Created by Steve Baker on 11/6/09.
//  Copyright 2009 Beepscore LLC. All rights reserved.
//

#import "AppController.h"
#import "BSGlobalValues.h"
#import "BigLetterView.h"


@implementation AppController

#pragma mark Initializers
- (id)init {
    self = [super init];
    if (self) {
        
        // Create an array of letters
        letters = [[NSArray alloc] initWithObjects:@"a", @"s",
                   @"d", @"f", @"j", @"k", @"l", @";", nil];
        
        // Seed the random number generator
        srandom(time(NULL));
        stepSize = 5;
    }
    return self;
}

- (void)awakeFromNib {
    [self showAnotherLetter];
}

#pragma mark IBActions
- (IBAction)stopGo:(id)sender {
    
    if (nil == timer) {
        DLog(@"Starting");
        
        // Create a timer
        timer = [[NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self 
                                                selector:@selector(checkThem:)
                                                userInfo:nil 
                                                 repeats:YES] retain];
    }
    else {
        DLog(@"Stopping");
        // Invalidate and release the timer
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

- (IBAction)showSpeedSheet:(id)sender {
    
    [NSApp beginSheet:speedSheet
       modalForWindow:[inLetterView window]
        modalDelegate:nil
       didEndSelector:NULL
          contextInfo:NULL];
}

- (IBAction)endSpeedSheet:(id)sender {
    
    // Return to normal event handling
    [NSApp endSheet:speedSheet];
    
    // Hide the sheet
    [speedSheet orderOut:sender];
}


- (void)checkThem:(NSTimer *)aTimer {
    
    if ([[inLetterView string] isEqual:[outLetterView string]]) {
        [self showAnotherLetter];
    }
    if (MAX_COUNT == count) {
        [self resetCount];
    }
    else {
        [self incrementCount];
    }
}

- (void)incrementCount {
    [self willChangeValueForKey:BSCountKey];
    count = count + stepSize;
    
    // Play sound like a metronome
    if (count % 50 == 0) {
        NSBeep();
    }
    
    if (count > MAX_COUNT) {
        count = MAX_COUNT;
    }
    [self didChangeValueForKey:BSCountKey];
}

- (void)resetCount {
    [self willChangeValueForKey:BSCountKey];
    count = 0;
    [self didChangeValueForKey:BSCountKey];
}

- (void)showAnotherLetter {
    
    // Choose random numbers until you get a different number than last time
    NSUInteger x = lastIndex;
    while (x == lastIndex) {
        x = random() % [letters count];
    }
    lastIndex = x;
    [outLetterView setString:[letters objectAtIndex:x]];
    
    // Start the count again
    [self resetCount];
}

- (BOOL)control:(NSControl *)control
    didFailToFormatString:(NSString *)string
         errorDescription:(NSString *)error {
    
    DLog(@"AppController told that formatting of %@ failed: %@", 
         string, error);
    return NO;
}

@end
