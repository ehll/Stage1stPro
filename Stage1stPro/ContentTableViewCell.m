//
//  ContentTableViewCell.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentTableViewCell.h"
#import "SDAttributedString.h"

@implementation ContentTableViewCell
@synthesize author;
@synthesize attrStr;
@synthesize imgInfos;
@synthesize delegate;

- (void)dealloc
{
    self.author = nil;
    self.attrStr = nil;
    self.imgInfos = nil;
    [super dealloc];
}

- (void)setDisplayContent:(NSDictionary *)content
{
    self.author = [content objectForKey:@"author"];
    self.attrStr = [[content objectForKey:@"content"] objectAtIndex:0];
    self.imgInfos = [[content objectForKey:@"content"] objectAtIndex:1];
    [self setNeedsDisplay];
    return;
}


- (void)layoutSubviews
{
    CGRect b = [self bounds];
	[contentView setFrame:b];
    [super layoutSubviews];
}

- (void)drawContentView:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    

    CGRect contentRect = self.bounds;
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0];
    [self.backgroundColor set];
    CGContextAddRect(context, contentRect);
    CGContextFillPath(context);
    
    CGRect textFrame = CGRectInset(self.bounds, 20.0f, 10.0f);
    //CGRect textFrame = self.bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textFrame);
    
    CTFrameRef frame = CTFramesetterCreateFrame(self.attrStr.framesetter, CFRangeMake(0, [self.attrStr.attrStr length]), path, NULL);
    
    CTFrameDraw(frame, context);
    
    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    if ([self.imgInfos count] > 0) {
        int imgIndex = 0;
        int imgLocation = [[[self.imgInfos objectAtIndex:imgIndex] objectForKey:@"location"] intValue];
        NSUInteger lineIndex = 0;
        
        for (id lineObj in lines) {
            CTLineRef line = (CTLineRef)lineObj;
            for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) {
                CTRunRef run = (CTRunRef)runObj;
                CFRange runRange = CTRunGetStringRange(run);
                if (runRange.location <= imgLocation &&
                    runRange.location+runRange.length > imgLocation) {
                    CGRect runBounds;
                    CGFloat ascent;
                    CGFloat descent;
                    runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    runBounds.size.height = ascent + descent;
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                    runBounds.origin.x = origins[lineIndex].x + self.frame.origin.x + xOffset;
                    runBounds.origin.y = origins[lineIndex].y + self.frame.origin.y - descent;
                    UIImage *img = nil;
                    CGRect colRect = CGPathGetBoundingBox(path);
					CGRect imageBounds = CGRectOffset(runBounds, colRect.origin.x - self.frame.origin.x, colRect.origin.y - self.frame.origin.y);
                    if ([[[self.imgInfos objectAtIndex:imgIndex] objectForKey:@"type"] isEqualToString:@"emo"]) {
                        img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [[self.imgInfos objectAtIndex:imgIndex] objectForKey:@"src"]]];
                    } else if ([[[self.imgInfos objectAtIndex:imgIndex] objectForKey:@"type"] isEqualToString:@"img"]) {
                        img = [UIImage imageNamed:[NSString stringWithFormat:@"ImagePlaceholder.png", [[self.imgInfos objectAtIndex:imgIndex] objectForKey:@"src"]]];
                    }
                    CGContextDrawImage(context, imageBounds, img.CGImage);


                    if (imgIndex < [self.imgInfos count] - 1) {
                        imgIndex ++;
                        imgLocation = [[[self.imgInfos objectAtIndex:imgIndex] objectForKey:@"location"] intValue];  
                    }
                }
            }
            lineIndex++;
        }
    }
    CFRelease(frame);
    CFRelease(path); 
    
    
}



@end
