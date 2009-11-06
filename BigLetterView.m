//
//  BigLetterView.m
//  TypingTutor
//
//  Created by Steve Baker on 11/5/09.
//  Copyright 2009 Beepscore LLC. All rights reserved.
//

#import "BigLetterView.h"
#import "BSGlobalValues.h"

@implementation BigLetterView

#pragma mark Accessors
- (NSColor *)bgColor{
    return bgColor;
}

- (void)setBgColor:(NSColor *)c{
    [c retain];
    [bgColor release];
    bgColor = c;
    [self setNeedsDisplay:YES];
}

- (NSString *)string {
    return string;
}

- (void)setString:(NSString *)c{
    c = [c copy];
    [string release];
    string = c;
    DLog(@"The string is now %@", string);
}

@synthesize isHighlighted;

#pragma mark -
- (void)dealloc{
    self.bgColor = nil;
    self.string = nil;
    [super dealloc];
}

#pragma mark Initializers
// designated initializer
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        DLog(@"initializing view");
        bgColor = [[NSColor yellowColor] retain];
        string = @" ";
    }
    return self;
}

#pragma mark Drawimg methods
- (void)drawRect:(NSRect)dirtyRect {
    
    if (isHighlighted) {
        bgColor = [[NSColor blueColor] retain];
    }
    else {
        bgColor = [[NSColor yellowColor] retain];
    }         

    
    NSRect bounds = [self bounds];
    [bgColor set];
    [NSBezierPath fillRect:bounds];
    
    // Am I the window's first responder?
    if ([[self window] firstResponder] == self) {
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath setDefaultLineWidth:4.0];
        [NSBezierPath strokeRect:bounds];
    }
}

- (BOOL)isOpaque{
    return YES;
}

#pragma mark Rollover methods
// Ref Hillegass pg 274
- (void)viewDidMoveToWindow {
    int options = NSTrackingMouseEnteredAndExited |
    NSTrackingActiveAlways |
    NSTrackingInVisibleRect;
    NSTrackingArea *ta;
    ta = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                      options:options
                                        owner:self
                                     userInfo:nil];
    [self addTrackingArea:ta];
    [ta release];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

#pragma mark First Respoder methods
- (BOOL)acceptsFirstResponder {
    DLog(@"accepting First Responder");
    return YES;
}

- (BOOL)resignFirstResponder {
    DLog(@"resigning First Responder");
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)becomeFirstResponder {
    DLog(@"becoming First Responder");
    [self setNeedsDisplay:YES];
    return YES;
}

#pragma mark Keyboard methods
- (void)keyDown:(NSEvent *)theEvent {
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void)insertText:(NSString *)input {
    // Set string to be what the user typed
    [self setString:input];
}

- (void)insertTab:(id)sender {
    [[self window] selectKeyViewFollowingView:self];
}

// Be careful with capitalization here "backtab" is considered one word
- (void)insertBacktab:(id)sender {
    [[self window] selectKeyViewPrecedingView:self];
}

- (void)deleteBackward:(id)sender {
    [self setString:@" "];
}

@end
