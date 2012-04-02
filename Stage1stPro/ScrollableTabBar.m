//
//  ScrollableTabBar.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScrollableTabBar.h"

@implementation ScrollableTabBar

@synthesize delegate;
@synthesize buttons = _buttons;

- (id)initWithFrame:(CGRect)frame AndItemNames:(NSArray *)names
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _currentSelectedButton = 0;
        //init a mutable array to store buttons
        self.buttons = [NSMutableArray arrayWithCapacity:[names count]];
        
        //configure the scroll view.        
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        self.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
        
        //add buttons as the contents of the scroll view
        //set the button width as constant 320/5
        #define kButtonWidth 64
        UIButton *button;
        for (int i=0; i<[names count]; i++) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(kButtonWidth*i, 0, kButtonWidth, frame.size.height);
            button.tag = i;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            [button setTitle:[names objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0] forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageNamed:@"TabSelected.png"] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttons addObject:button];
            [self addSubview:button];
        }
        
        //scollview content size equals to the constant button width multi buttons count
        self.contentSize = CGSizeMake(kButtonWidth*[names count], frame.size.height);
    }
    return self;
}

- (void)buttonClicked:(id)sender
{
    [[self.buttons objectAtIndex:_currentSelectedButton] setSelected:NO];
    UIButton *button = sender;
    button.highlighted = YES;
    button.selected = YES;
    _currentSelectedButton = button.tag;    
    if ([delegate respondsToSelector:@selector(tabBar:didSelectIndex:)])
    {
        [delegate tabBar:self didSelectIndex:button.tag];
    }
}

- (void)tabBarUserInteractionEnabled:(BOOL)enabled
{
    for (UIButton *b in self.buttons) {
        b.userInteractionEnabled = enabled;
    }
}

- (void)dealloc
{
    self.buttons = nil;
    [super dealloc];
}

@end
