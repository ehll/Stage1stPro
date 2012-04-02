//
//  ContentViewController.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ContentTableViewCell.h"


@class RawdataParser, ReplyViewController;
@interface ContentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>
{
    UIView *_containerView;
    UITableView *_tableView;
    UIToolbar *_toolbar;
    MBProgressHUD *_HUD;
    UILabel *_titleLabel;
    UILabel *_pageLabel;
    
    ReplyViewController *_rvc;
    
    NSString *_fid;
    NSString *_tid;
    NSInteger _currentPage, _totalPage;
    
    NSArray *_contents;
    
    ASIHTTPRequest *_request;
    RawdataParser *_parser;
    
}

- (id)initWithFid:(NSString *)fid andTid:(NSString *)tid;
- (void)setTitleLabelText:(NSString *)titleString;

@end
