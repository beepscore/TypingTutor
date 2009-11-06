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
    DLog(@"The string: %@", string);
    [self setNeedsDisplay:YES];
}

@synthesize isHighlighted;
@synthesize myShadow;
@synthesize attributes;

#pragma mark -
- (void)dealloc{
    self.bgColor = nil;
    self.string = nil;
    self.attributes = nil;
    self.myShadow = nil;
    [super dealloc];
}

#pragma mark Initializers
// designated initializer
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        DLog(@"initializing view");
        // must instantiate myShadow before prepareAttributes with it
        myShadow = [[NSShadow alloc] init];
        [self prepareAttributes];
        bgColor = [[NSColor yellowColor] retain];
        string = @" ";
    }
    return self;
}

#pragma mark Drawimg methods
- (void)drawRect:(NSRect)dirtyRect {
    
    if (isHighlighted) {
        bgColor = [[NSColor orangeColor] retain];
    }
    else {
        bgColor = [[NSColor yellowColor] retain];
    }         

    
    NSRect bounds = [self bounds];
    [bgColor set];
    [NSBezierPath fillRect:bounds];
    [self drawStringCenteredIn:bounds];
    
    // Am I the window's first responder?
    if (([[self window] firstResponder] == self) &&
                [NSGraphicsContext currentContextDrawingToScreen]) {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [NSBezierPath fillRect:bounds];
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (BOOL)isOpaque{
    return YES;
}

- (void)drawStringCenteredIn:(NSRect)rect {
    NSSize strSize = [string sizeWithAttributes:attributes];
    NSPoint strOrigin;
    strOrigin.x = rect.origin.x + ((rect.size.width - strSize.width)/2);
    strOrigin.y = rect.origin.y + ((rect.size.height - strSize.height)/2);
    [string drawAtPoint:strOrigin withAttributes:attributes];    
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
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
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

#pragma mark Text methods
- (void)prepareAttributes {
    attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:75]
                   forKey:NSFontAttributeName];
    [attributes setObject:[NSColor redColor]
                   forKey:NSForegroundColorAttributeName];
    
    [myShadow setShadowOffset:NSMakeSize(4, -4)];
    [myShadow setShadowBlurRadius:3.0];
    [myShadow setShadowColor:[NSColor blackColor]];
    // NSShadowAttributeName is a standard attribute key.
    [attributes setObject:myShadow
                   forKey:NSShadowAttributeName];
}


- (IBAction)savePDF:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:@"pdf"];
    [panel beginSheetForDirectory:nil
                             file:nil
                   modalForWindow:[self window]
                    modalDelegate:self
                   didEndSelector:@selector(didEnd:returnCode:contextInfo:)
                      contextInfo:NULL];
}

- (void)didEnd:(NSSavePanel *)sheet
    returnCode:(int)code
   contextInfo:(void *)contextInfo {
    
    if (code != NSOKButton) {
        return;
    }
    
    NSRect rect = [self bounds];
    NSData *data = [self dataWithPDFInsideRect:rect];
    NSString *path = [sheet filename];
    NSError *error;
    BOOL successful = [data writeToFile:path
                                options:0
                                  error:&error];
    
    if (!successful){
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }
}

@end
