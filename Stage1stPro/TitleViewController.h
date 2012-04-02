//
//  TitleViewController.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ScrollableTabBar.h"
#import "MBProgressHUD.h"

@class ASIHTTPRequest, ScrollableTabBar, MBProgressHUD, RawdataParser;
@interface TitleViewController : UIViewController <ScrollableTabBarDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>
{
    UIView *_containerView;
    UITableView *_tableView;
    ScrollableTabBar *_tabBar;
    MBProgressHUD *_HUD;
    
    NSArray *_names;
    NSArray *_identifiers;
    
    NSArray *_contents;
    NSInteger _current;
    
    ASIHTTPRequest *_request;
    RawdataParser *_parser;
}

@end
