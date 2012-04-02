//
//  ReplyViewController.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"


@class ContentViewController;
@interface ReplyViewController : UIViewController <MBProgressHUDDelegate>
{
    UIView *_contentView;
    UINavigationBar *_navigationBar;
    UITextView *_textView;
    MBProgressHUD *_HUD;
    
    ContentViewController *parentController;
    
    NSString *fid, *tid;
}

@property (assign, nonatomic) ContentViewController *parentController;
@property (copy, nonatomic) NSString *fid;
@property (copy, nonatomic) NSString *tid;


@end
