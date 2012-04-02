//
//  ScrollableTabBar.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollableTabBarDelegate;

@interface ScrollableTabBar : UIScrollView
{
    id<ScrollableTabBarDelegate> delegate;
    NSMutableArray *_buttons;
    NSInteger _currentSelectedButton;
}

@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) NSMutableArray *buttons;

- (id)initWithFrame:(CGRect)frame AndItemNames:(NSArray *)names;
- (void)tabBarUserInteractionEnabled:(BOOL)enabled;

@end


@protocol ScrollableTabBarDelegate<NSObject>
@optional
- (void)tabBar:(ScrollableTabBar *)tabBar didSelectIndex:(NSInteger)index; 
@end

