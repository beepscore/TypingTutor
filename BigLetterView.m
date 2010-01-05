//
//  BigLetterView.m
//  TypingTutor
//
//  Created by Steve Baker on 11/5/09.
//  Copyright 2009 Beepscore LLC. All rights reserved.
//

#import "BigLetterView.h"
#import "BSGlobalValues.h"
#import "FirstLetter.h"

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

// TODO: why is this written like a setter for mouseDownEvent
// but not titled setMouseDownEvent ?
- (void)mouseDown:(NSEvent *)event {
    [event retain];
    [mouseDownEvent release];
    mouseDownEvent = event;
}

@synthesize isHighlighted;
@synthesize myShadow;
@synthesize attributes;

#pragma mark -
- (void)dealloc{
    [bgColor release], bgColor = nil;
    [string release], string = nil;
    [attributes release], attributes = nil;
    [myShadow release], myShadow = nil;
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
        [self registerForDraggedTypes:
         [NSArray arrayWithObject:NSStringPboardType]];
    }
    return self;
}

#pragma mark Drawimg methods
- (void)drawRect:(NSRect)dirtyRect {
    
    NSRect bounds = [self bounds];
    
    if (isHighlighted) {
        NSGradient *gr;
        gr = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] 
                                           endingColor:bgColor];
        [gr drawInRect:bounds relativeCenterPosition:NSZeroPoint];
        [gr release];
    }
    else {
        [bgColor set];
        [NSBezierPath fillRect:bounds];
    }         
    
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

#pragma mark Pasteboard methods
- (void)writeToPasteboard:(NSPasteboard *)pb
{
    // Declare types
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] 
               owner:self];
    
    // Copy data to the pasteboard
    [pb setString:string forType:NSStringPboardType];
}

- (BOOL)readFromPasteboard:(NSPasteboard *)pb {
    
    // Is a string on the pasteboard?
    NSArray *types = [pb types];
    if ([types containsObject:NSStringPboardType]) {
        
        // Read the string from the pasteboard
        NSString *value = [pb stringForType:NSStringPboardType];
        
        [self setString:[value BNR_firstLetter]];
        return YES;
    }
    return NO;
}

- (IBAction)cut:(id)sender {
    [self copy:sender];
    [self setString:@""];
}

- (IBAction)copy:(id)sender {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [self writeToPasteboard:pb];
}

- (IBAction)paste:(id)sender {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    if (![self readFromPasteboard:pb]) {
        NSBeep();
    }
}

// BigLetterView may be used as a source for a drag copy or delete.
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    return NSDragOperationCopy | NSDragOperationDelete;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    
    NSPoint down = [mouseDownEvent locationInWindow];
    NSPoint drag = [theEvent locationInWindow];
    float distance = hypot(down.x - drag.x,  down.y - drag.y);
    if (distance < 3) {
        return;
    }
    
    // Get the size of the string
    NSSize s = [string sizeWithAttributes:attributes];
    
    // Create the image that will be dragged
    NSImage *anImage =  [[NSImage alloc] initWithSize:s];
    
    // Create a rect in which you will draw the letter in the image
    NSRect imageBounds;
    imageBounds.origin = NSZeroPoint;
    imageBounds.size = s;
    
    // Draw the letter on the image
    [anImage lockFocus];
    [self drawStringCenteredIn:imageBounds];
    [anImage unlockFocus];
    
    // Get the location of the mouseDown event
    NSPoint p = [self convertPoint:down fromView:nil];
    
    // Drag from the center of the image
    p.x = p.x - s.width/2;
    p.y = p.y - s.height/2;
    
    // Get the pasteboard
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    
    // Put the string on the pasteboard
    [self writeToPasteboard:pb];
    
    // Start the drag
    [self dragImage:anImage
                 at:p 
             offset:NSMakeSize(0, 0)
              event:mouseDownEvent
         pasteboard:pb 
             source:self 
          slideBack:YES];
    [anImage release];
}

- (void)draggedImage:(NSImage *)image
             endedAt:(NSPoint)screenPoint
           operation:(NSDragOperation)operation {
    if (operation == NSDragOperationDelete) {
        [self setString:@""];
    }
}

- (NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender {
    DLog(@"draggingEntered:");
    if ([sender draggingSource] == self) {
        return NSDragOperationNone;
    }
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    DLog(@"draggingExited:");
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    NSDragOperation op = [sender draggingSourceOperationMask];
    DLog(@"operation mask = %d", op);
    if ([sender draggingSource] == self) {
        return NSDragOperationNone;
    }
    return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pb = [sender draggingPasteboard];
    if (![self readFromPasteboard:pb]) {
        DLog(@"Error: Could not read from dragging pasteboard");
        return NO;
    }
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    DLog(@"concludeDragOperation:");
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

@end
