//
//  SDAttributedString.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDAttributedString.h"

@implementation SDAttributedString

@synthesize attrStr;
@synthesize framesetter;
@synthesize textSize;

#define kContentWidth 280

- (id)initWithAttributedString:(NSAttributedString *)s
{
    self = [super init];
    if (self) {
        self.attrStr = s;
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)s);
        textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [s length]), NULL, CGSizeMake(kContentWidth, 200000.0f), NULL);
    }
    return self;
}

- (void)dealloc
{
    CFRelease(framesetter);
    [attrStr release];
    [super dealloc];
}

@end
