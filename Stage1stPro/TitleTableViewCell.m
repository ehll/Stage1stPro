//
//  TitleTableViewCell.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TitleTableViewCell.h"

@implementation TitleTableViewCell


- (void)dealloc
{
    [titleText release];
    [replyNumber release];
    [super dealloc];
}

- (void)setTitleText:(NSString *)tt AndReplyNumber:(NSString *)rn
{
    [titleText release]; [replyNumber release];
    titleText = [tt copy]; replyNumber = [rn copy];
    [self setNeedsDisplay];
}


- (void)layoutSubviews
{
	CGRect b = [self bounds];
	b.size.height -= 1; // leave room for the separator line
	//b.size.width += 30; // allow extra width to slide for editing
	//b.origin.x -= (self.editing && !self.showingDeleteConfirmation) ? 0 : 30; // start 30px left unless editing
	[contentView setFrame:b];
    [super layoutSubviews];
}

- (void)drawContentView:(CGRect)rect
{

    #define FONT_SIZE 14
    #define REPLY_FONT_SIZE 12
        
    #define LEFT_COLUMN_OFFSET 20
        
    #define RIGHT_COLUMN_WIDTH 240
    #define RIGHT_COLUMN_OFFSET 60
        
    #define UP_AND_DOWN_OFFSET 6	
    #define RECT_UP_AND_DOWN_OFFSET 11
	
    // Drawing code
	UIColor *textColor = nil;
	UIColor *replyColor = nil;
    UIColor *replySquareColor = nil;
    UIColor *bgColor = nil;
    
	UIFont *textFont = [UIFont boldSystemFontOfSize:FONT_SIZE];
	UIFont *replyFont = [UIFont boldSystemFontOfSize:REPLY_FONT_SIZE];
    if ([replyNumber length] >= 4) {
        replyFont = [UIFont boldSystemFontOfSize:MAX(9, REPLY_FONT_SIZE+3-[replyNumber length])];
    }
	
	if (self.highlighted) {
		textColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0];
		replyColor = [UIColor colorWithRed:0.01f green:0.17f blue:0.50f alpha:1.0f];
        bgColor = [UIColor clearColor];
	}
	else {
		textColor = [UIColor colorWithRed:0.01f green:0.17f blue:0.50f alpha:1.0f];
		replyColor = [UIColor colorWithRed:0.01f green:0.17f blue:0.50f alpha:1.0f];
        replySquareColor = [UIColor colorWithRed:0.82 green:0.85 blue:0.76 alpha:1.0];
        bgColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0];
	}
    
	
	CGRect contentRect = self.bounds;
	CGFloat boundsOriginX = contentRect.origin.x;
	CGFloat boundsHeight = contentRect.size.height;
	
	//the right text column
    [bgColor set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, contentRect);
    CGContextFillPath(context);
    
	[textColor set];
	CGRect textRect = CGRectMake(boundsOriginX + RIGHT_COLUMN_OFFSET, UP_AND_DOWN_OFFSET, RIGHT_COLUMN_WIDTH, boundsHeight - 2*UP_AND_DOWN_OFFSET);
	[titleText drawInRect:textRect withFont:textFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	//the left square
    [replySquareColor set];
	CGFloat rectWidth = boundsHeight-2*RECT_UP_AND_DOWN_OFFSET;
	context = UIGraphicsGetCurrentContext();
	CGRect rectFrame = CGRectMake(LEFT_COLUMN_OFFSET, RECT_UP_AND_DOWN_OFFSET, rectWidth, rectWidth);
	CGContextAddRect(context, rectFrame);
	CGContextFillPath(context);
	
	//the left reply text
	[replyColor set];
	CGSize replyStringSize = [replyNumber sizeWithFont:replyFont];
	CGPoint replyStringDrawPoint = CGPointMake(LEFT_COLUMN_OFFSET+(rectWidth-replyStringSize.width)/2,
											   RECT_UP_AND_DOWN_OFFSET+(rectWidth-replyStringSize.height)/2);
	[replyNumber drawAtPoint:replyStringDrawPoint withFont:replyFont];


}


@end
