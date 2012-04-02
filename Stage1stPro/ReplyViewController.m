//
//  ReplyViewController.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReplyViewController.h"
#import "ASIFormDataRequest.h"


@implementation ReplyViewController

@synthesize parentController;
@synthesize fid, tid;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [super dealloc];
    self.fid = nil; self.tid = nil;
}

#pragma mark - View lifecycle


- (void)loadView
{
    CGRect mainframe = [UIScreen mainScreen].applicationFrame;
    _contentView = [[UIView alloc] initWithFrame:mainframe];
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(1, 44, 318, 200)];    
    _contentView.backgroundColor = [UIColor blackColor];
    
    _navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self.parentController action:@selector(dismissModalViewController)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(postReply)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"回复"];
    navigationItem.leftBarButtonItem = leftButton;
    navigationItem.rightBarButtonItem = rightButton;
    [_navigationBar pushNavigationItem:navigationItem animated:YES];
    [leftButton release]; [rightButton release]; [navigationItem release];
    
    _textView.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0];
    _textView.textColor = [UIColor colorWithRed:0.01f green:0.17f blue:0.50f alpha:1.0f];
    _textView.font = [UIFont systemFontOfSize:13.0f];
    _textView.contentSize = CGSizeMake(280, 200);
    _textView.layer.borderColor = [[UIColor colorWithRed:0.36f green:0.36f blue:0.36f alpha:1.0f] CGColor];
    _textView.layer.borderWidth = 1.0;
    _textView.layer.cornerRadius = 5.0;
    //_textView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    
    [_contentView addSubview:_navigationBar];
    [_contentView addSubview:_textView];
    
    self.view = _contentView;
    
    [_textView release];
    [_navigationBar release];
    [_contentView release];
    
}

- (void)postReply
{
    if (![_textView.text isEqualToString:@""]) {    
        NSString *timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
        NSString *urlString = [NSString stringWithFormat:@"http://bbs.saraba1st.com/2b/m/post.php?action=reply&tid=%@&tmp=%@", self.tid, timestamp];

        
        _navigationBar.userInteractionEnabled = NO;
        _HUD = [[MBProgressHUD alloc] initWithView:_textView];
        [_textView addSubview:_HUD];
        _HUD.mode = MBProgressHUDModeText;
        _HUD.delegate = self;
        _HUD.labelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
        _HUD.labelText = @"Sending reply";
        [_HUD show:YES];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setPostValue:self.fid forKey:@"fid"];
        [request setPostValue:_textView.text forKey:@"content"];
        [request setCompletionBlock:^{
            _HUD.mode = MBProgressHUDModeText;
            _HUD.labelText = @"Reply succeed";
            _HUD.labelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
            [_HUD hide:YES afterDelay:0.5];
            //NSLog(@"%@", [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease]);        
        }];
        [request setFailedBlock:^{
            _HUD.mode = MBProgressHUDModeText;
            _HUD.labelText = @"Reply may failed";
            _HUD.labelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
            [_HUD hide:YES afterDelay:0.5];

        }];
        [request startAsynchronous];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{    
    _navigationBar.userInteractionEnabled = YES;
    [_HUD removeFromSuperview];
    [_HUD release];
    _HUD = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_textView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_textView resignFirstResponder];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Keyboard

- (void)handleKeyboardDidShow:(NSNotification *)paramNotification
{
    NSValue *keyboardRectAsObject = [[paramNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    //CGRect textViewRect = CGRectMake(1, 44, 318, 200);
    if (keyboardRect.size.height == 216) {
        [UIView beginAnimations:@"fit" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [_textView setFrame:CGRectMake(1, 44, 318, 200-(keyboardRect.size.height-216))];
        [UIView commitAnimations];
    }
    else {
        [_textView setFrame:CGRectMake(1, 44, 318, 200-(keyboardRect.size.height-216))];
    }


}

@end
