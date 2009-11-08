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
    }
    return self;
}

- (void)awakeFromNib {
    [self showAnotherLetter];
}

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

- (void)checkThem:(NSTimer *)aTimer {
    
    if ([[inLetterView string] isEqual:[outLetterView string]]) {
        [self showAnotherLetter];
    }
    if (MAX_COUNT == count) {
        NSBeep();
        [self resetCount];
    }
    else {
        [self incrementCount];
    }
}

- (void)incrementCount {
    [self willChangeValueForKey:BSCountKey];
     count = count + COUNT_STEP;
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
    int x = lastIndex;
    while (x == lastIndex) {
        x = random() % [letters count];
    }
    lastIndex = x;
    [outLetterView setString:[letters objectAtIndex:x]];
    
    // Start the count again
    [self resetCount];
}


@end
