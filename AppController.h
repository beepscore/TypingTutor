//
//  AppController.h
//  TypingTutor
//  Ref Hillegass Ch 19, 20, 21, 22, 23, 24, 25, 26
//
//  Created by Steve Baker on 11/6/09.
//  Copyright 2009 Beepscore LLC. All rights reserved.
//

// Ref Hillegass pg 310
#import <Cocoa/Cocoa.h>
@class BigLetterView;


@interface AppController : NSObject {
#pragma mark Outlets
    IBOutlet BigLetterView *inLetterView;
    IBOutlet BigLetterView *outLetterView;
    IBOutlet NSWindow *speedSheet;
    
    // Data
    NSArray *letters;
    NSUInteger lastIndex;
    
    // Time
    NSTimer *timer;
    NSUInteger count;
    NSUInteger stepSize;
}
- (IBAction)stopGo:(id)sender;
- (IBAction)showSpeedSheet:(id)sender;
- (IBAction)endSpeedSheet:(id)sender;
- (void)incrementCount;
- (void)resetCount;
- (void)showAnotherLetter;
@end
