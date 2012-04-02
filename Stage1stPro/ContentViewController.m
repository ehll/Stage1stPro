//
//  ContentViewController.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentViewController.h"
#import "ReplyViewController.h"
#import "RawdataParser.h"
#import "SDAttributedString.h"
#import "AppDelegate.h"

@interface ContentViewController() 
- (void)refreshContentOfPage:(NSInteger)pageNumber withScrolledToTop:(BOOL)scrolled;
@end

@implementation ContentViewController

- (id)initWithFid:(NSString *)fid andTid:(NSString *)tid
{
    self = [super init];
    if (self) {
        _currentPage = 1; _totalPage = 1;
        _fid = [fid copy];
        _tid = [tid copy];
        _contents = nil;
        _parser = [[RawdataParser alloc] init];
        _titleLabel = [[UILabel alloc] init];
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 15)];
        _pageLabel.text = @" ";
        _pageLabel.textAlignment = UITextAlignmentCenter; _titleLabel.textAlignment = UITextAlignmentCenter;
        _pageLabel.textColor = [UIColor whiteColor]; _titleLabel.textColor = [UIColor whiteColor];
        _pageLabel.backgroundColor = [UIColor clearColor]; _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _titleLabel.numberOfLines = 0;
        _pageLabel.font = [UIFont boldSystemFontOfSize:12.0f]; _titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];

    }
    return self;
}

- (void)setTitleLabelText:(NSString *)titleString
{
    _titleLabel.text = titleString;
}

- (void)dealloc
{
    [_pageLabel release];
    [_titleLabel release];
    [_contents release];
    [_parser release];
    [_fid release];
    [_tid release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    #define kToolBarHeight 44.0f
    [super loadView];
    CGRect rect = CGRectMake(0, 0, 320.0f, 416.0f);
    _containerView = [[UIView alloc] initWithFrame:rect];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width , rect.size.height-kToolBarHeight)];
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(rect.origin.x, rect.size.height-kToolBarHeight, rect.size.width, kToolBarHeight)];
    
    _containerView.backgroundColor = [UIColor blackColor];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    #define BACK_TAG 1
    #define FORWORD_TAG 2
    

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [backBtn setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [backBtn setTag:BACK_TAG];
    [backBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *backBtnGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
    [backBtnGr setMinimumPressDuration:0.5];
    [backBtn addGestureRecognizer:backBtnGr];
    [backBtnGr release];
    
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [forwardBtn setImage:[UIImage imageNamed:@"Forward.png"] forState:UIControlStateNormal];
    [forwardBtn setTag:FORWORD_TAG];
    [forwardBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *forwardBtnGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
    [forwardBtnGr setMinimumPressDuration:0.5];
    [forwardBtn addGestureRecognizer:forwardBtnGr];
    [forwardBtnGr release];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
    UIBarButtonItem *pageNumber = [[UIBarButtonItem alloc] initWithCustomView:_pageLabel];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed)];
    
    [_toolbar setItems:[NSArray arrayWithObjects:back, flex, forward, flex, pageNumber, flex, refresh, nil] animated:YES];
    [flex release]; [back release]; [forward release]; [pageNumber release]; [refresh release];
    _toolbar.barStyle = UIBarStyleBlack;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
    titleView.backgroundColor = [UIColor clearColor];
    [_titleLabel setFrame:CGRectMake(0, 0, 160, 30)];
    [titleView addSubview:_titleLabel];
    self.navigationItem.titleView = titleView;
    [titleView release];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"回复" style:UIBarButtonItemStyleBordered target:self action:@selector(presentModalViewController)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    [_containerView addSubview:_toolbar];
    [_containerView addSubview:_tableView];
    self.view = _containerView;
    
    [_toolbar release];
    [_tableView release];
    [_containerView release];
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

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshContentOfPage:_currentPage withScrolledToTop:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_request && _request.inProgress == YES) {
        [_request cancel];
        [_request release];
        _request = nil;
    }
    if (_HUD) {
        //just wait 0.5 second
        //usleep(500000);
        [_HUD release];
        _HUD = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Modal View Controller

- (void)presentModalViewController
{
    _rvc = [[ReplyViewController alloc] init];
    _rvc.parentController = self;
    _rvc.tid = _tid;
    _rvc.fid = _fid;
    [self presentModalViewController:_rvc animated:YES];
}

- (void)dismissModalViewController
{
    [_rvc release];
    _rvc = nil;
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Paging logic

- (void)buttonClicked:(id)sender
{
    if (((UIButton *)sender).tag == BACK_TAG) {
        if (_currentPage > 1) {
            if (!_request)
                [self refreshContentOfPage:_currentPage-1 withScrolledToTop:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (((UIButton *)sender).tag == FORWORD_TAG) {
        if (_currentPage < _totalPage) {
            if (!_request) 
                [self refreshContentOfPage:_currentPage+1 withScrolledToTop:YES];
        } else {
            if (!_HUD) {
                CGRect rect = _containerView.frame;
                _HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-kToolBarHeight)];
                [self.view addSubview:_HUD];
                _HUD.mode = MBProgressHUDModeText;
                _HUD.delegate = self;
                _HUD.labelText = @"Already last page.";
                _HUD.labelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
                [_HUD show:YES];
                [_HUD hide:YES afterDelay:0.5f];
            }
        }
    }
}

- (void)buttonLongPressed:(UILongPressGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        UIButton *b = (UIButton *)gr.view;
        if (b.tag == BACK_TAG) {
            if (_currentPage > 1) {
                if (!_request)
                    [self refreshContentOfPage:1 withScrolledToTop:YES];
            } else {
                if (!_HUD) {
                    CGRect rect = _containerView.frame;
                    _HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-kToolBarHeight)];
                    [self.view addSubview:_HUD];
                    _HUD.mode = MBProgressHUDModeText;
                    _HUD.delegate = self;
                    _HUD.labelText = @"Already first page.";
                    _HUD.labelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
                    [_HUD show:YES];
                    [_HUD hide:YES afterDelay:0.5f];
                }
            }
        } else if (b.tag == FORWORD_TAG) {
            if (_currentPage < _totalPage) {
                if (!_request)
                    [self refreshContentOfPage:_totalPage withScrolledToTop:YES];
            } else {
                if (!_HUD) {
                    CGRect rect = _containerView.frame;
                    _HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-kToolBarHeight)];
                    [self.view addSubview:_HUD];
                    _HUD.mode = MBProgressHUDModeText;
                    _HUD.delegate = self;
                    _HUD.labelText = @"Already last page.";
                    _HUD.labelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
                    [_HUD show:YES];
                    [_HUD hide:YES afterDelay:0.5f];
                }
            }
        }    
    }
}

-(void)refreshButtonPressed
{
    [self refreshContentOfPage:_currentPage withScrolledToTop:NO];
}



#pragma mark - Network

- (void)refreshContentOfPage:(NSInteger)pageNumber withScrolledToTop:(BOOL)scrolled
{
    if (!_request) {
        
        CGRect rect = _containerView.frame;
        _toolbar.userInteractionEnabled = NO;
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        _HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-kToolBarHeight)];
        [self.view addSubview:_HUD];
        _HUD.delegate = self;
        _HUD.labelText = @"Loading...";
        [_HUD show:YES];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.saraba1st.com/2b/simple/?t%@_%d.html", _tid, pageNumber]];
        _request = [[ASIHTTPRequest requestWithURL:url] retain];
        [_request setCompletionBlock:^{
            NSString *responseString = [[NSString alloc] initWithData:[_request responseData] encoding:NSUTF8StringEncoding];
            [_contents release];
            _contents = nil;
            _contents = [[_parser extractContentsFromRawdata:responseString] retain];
            _totalPage = [[_parser extractPageNumberFromRawdata:responseString] integerValue];
            [responseString release];
            [_request release];
            _request = nil;
            
            if ([_contents count] > 0) {
                _currentPage = pageNumber;
                _pageLabel.text = [NSString stringWithFormat:@"Page: %d/%d", _currentPage, _totalPage];
                [_tableView reloadData];
                if (scrolled) {
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                //total page;
            }
            [_HUD hide:YES];
        }];
        
        [_request setFailedBlock:^{
            if ([[_request error] code] == 1) {
                _HUD.detailsLabelText = @"No available network";
            } else if ([[_request error] code] == 2) {
                _HUD.detailsLabelText = @"Request timed out";
            } else {
                _HUD.detailsLabelText = @"Connection failed";
            }
            _HUD.mode = MBProgressHUDModeText;
            _HUD.labelText = @"  Oops...  ";
            _HUD.detailsLabelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
            [_request release];
            _request = nil;
            [_HUD hide:YES afterDelay:0.5];
            
        }];
        
        [_request startAsynchronous];
    }
}

#pragma mark - HUB delegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{   
    _toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [_HUD removeFromSuperview];
    [_HUD release];
    _HUD = nil;
}

#if 0

- (void)addButtonInCell:(ContentTableViewCell *)cell withPosition:(CGRect)rect
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [b setFrame:rect];
    [b setImage:[UIImage imageNamed:@"ImagePlaceholder.png"] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(displayImage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:b];
}

- (void)displayImage:(id)sender
{
    NSLog(@"Image Display");
}

#endif



#pragma mark - Tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_contents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContentViewCell";
    ContentTableViewCell *cell = (ContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    [cell setDisplayContent:(NSDictionary *)[_contents objectAtIndex:indexPath.section]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #define kPadding 10.0f
    return MAX(((SDAttributedString *)[[[_contents objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:0]).textSize.height+2*kPadding+4, 48);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)] autorelease];
    headerView.backgroundColor = [UIColor colorWithRed:0.82 green:0.85 blue:0.76 alpha:0.8];
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, 300, 18)];
    authorLabel.text = [NSString stringWithFormat:@"#%d %@", 50*(_currentPage-1)+section, [[_contents objectAtIndex:section] objectForKey:@"author"]];
    authorLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    authorLabel.textColor = [UIColor colorWithRed:0.36f green:0.36f blue:0.36f alpha:1.0f];
    authorLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:authorLabel];
    [authorLabel release];
    return headerView;
}
    
@end
