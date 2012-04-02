//
//  OptiTableViewCell.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptiTableViewCell.h"

@interface OptiTableViewCellView : UIView
@end

@implementation OptiTableViewCellView

- (void)drawRect:(CGRect)rect
{
    [(OptiTableViewCell *)[self superview] drawContentView:rect];
}

@end

@implementation OptiTableViewCell

@synthesize contentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        contentView = [[OptiTableViewCellView alloc] initWithFrame:CGRectZero];
        contentView.opaque = YES;
        [self addSubview:contentView];
        [contentView release];
    }
    return self;
}

- (void)drawContentView:(CGRect)rect;
{
    
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [contentView setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
