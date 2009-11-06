//
//  BigLetterView.h
//  TypingTutor
//  Ref Hillegass Ch 19
//  Created by Steve Baker on 11/5/09.
//  Copyright 2009 Beepscore LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BigLetterView : NSView {
#pragma mark Instance variables
    NSColor *bgColor;
    NSString *string;
}
#pragma mark Accessors
@property (readwrite, retain) NSColor *bgColor;
@property (readwrite, copy) NSString *string;

@end
