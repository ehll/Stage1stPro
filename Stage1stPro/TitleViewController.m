//
//  TitleViewController.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TitleViewController.h"
#import "TitleTableViewCell.h"
#import "RawdataParser.h"
#import "ASIHTTPRequest.h"
#import "ScrollableTabBar.h"
#import "MBProgressHUD.h"
#import "SDAttributedString.h"
#import "ContentViewController.h"


@implementation TitleViewController

- (id)init
{
    self = [super init];
    if (self) {
        _names = [[NSArray arrayWithObjects:@"外野", @"动漫", @"游戏", @"数码", @"影视", @"文史", @"八体", @"彼岸", @"交易", @"马叉虫", nil] retain];
        _identifiers = [[NSArray arrayWithObjects:@"75", @"6", @"4", @"51", @"48", @"50", @"77", @"31", @"115", @"74", nil] retain];
        _parser = [[RawdataParser alloc] init];
        _contents = nil;
        self.title = @"Stage1st";
    }
    return self;
}

- (void)dealloc
{
    [_parser release];
    [_names release];
    [_identifiers release];
    [_contents release];
    
    self.view = nil;
    [super release];
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
    #define kTabBarHeight 44.0f
    [super loadView];
    CGRect rect = CGRectMake(0, 0, 320.0f, 416.0f);
    _containerView = [[UIView alloc] initWithFrame:rect];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-kTabBarHeight)];
    _tabBar = [[ScrollableTabBar alloc] initWithFrame:CGRectMake(rect.origin.x, rect.size.height-kTabBarHeight, rect.size.width, kTabBarHeight) 
                                         AndItemNames:_names];
    
    _containerView.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0];
    
    _tableView.rowHeight = 48.0f;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.hidden = YES;
    _tableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.92 alpha:1.0];

    _tabBar.delegate = self;
    
    [_containerView addSubview:_tabBar];
    [_containerView addSubview:_tableView];
    self.view = _containerView;
    
    [_tabBar release];
    [_tableView release];
    [_containerView release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Network Connection

- (void)refreshWithIndex:(NSInteger)index
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.saraba1st.com/2b/simple/?f%@.html", [_identifiers objectAtIndex:index]]];
    _request = [[ASIHTTPRequest requestWithURL:url] retain];
    
    [_tabBar tabBarUserInteractionEnabled:NO];
    CGRect rect = _containerView.frame;
    _HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-kTabBarHeight)];
    [self.view addSubview:_HUD];
    _HUD.delegate = self;
    _HUD.labelText = @"Loading...";
    [_HUD show:YES];
    
    [_request setCompletionBlock:^{
        NSString *responseString = [[NSString alloc] initWithData:[_request responseData] encoding:NSUTF8StringEncoding];
        [_contents release];
        _contents = [[_parser extractTitlesFromRawdata:responseString] retain];
        [responseString release];
        [_request release];
        _request = nil;
        if ([_contents count] > 0) {
            [_tableView reloadData];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0 ] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        [_HUD hide:YES afterDelay:0.3];
    }];
    
    [_request setFailedBlock:^{
        [_contents release];
        _contents = nil;
        [_tableView reloadData];
        if ([[_request error] code] == 1) {
            _HUD.detailsLabelText = @"No available network";
        } else if ([[_request error] code] == 2) {
            _HUD.detailsLabelText = @"Request timed out";
        } else {
            _HUD.detailsLabelText = @"Connection failed";
        }
        [_request release];
        _request = nil;
        _HUD.mode = MBProgressHUDModeText;
        _HUD.labelText = @"  Oops...  ";
        _HUD.detailsLabelFont = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
        [_HUD hide:YES afterDelay:1.2];
    }];
    [_request startAsynchronous];
}

#pragma mark - HUB delegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [_tabBar tabBarUserInteractionEnabled:YES];
    
    [_HUD removeFromSuperview];
    [_HUD release];
    _HUD = nil;
}


#pragma mark - Tabbar delegate

- (void)tabBar:(ScrollableTabBar *)tabBar didSelectIndex:(NSInteger)index
{
    _current = index;
    _tableView.hidden = NO;
    self.title = [_names objectAtIndex:index];
    [self refreshWithIndex:index];
}

#pragma mark - Tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TitleViewCell";
    
    TitleTableViewCell *cell = (TitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[TitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }    
    
    #define REPLY_OVERFLOW @"4294967295"
    [cell setTitleText:[[_contents objectAtIndex:indexPath.row] objectForKey:@"title"] 
        AndReplyNumber:[[[_contents objectAtIndex:indexPath.row] objectForKey:@"reply"] isEqualToString:REPLY_OVERFLOW]?
                  @"∞":[[_contents objectAtIndex:indexPath.row] objectForKey:@"reply"]]; 
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContentViewController *cvc = [[ContentViewController alloc] initWithFid:[_identifiers objectAtIndex:_current] andTid:[[_contents objectAtIndex:indexPath.row] objectForKey:@"id"]];
    [cvc setTitleLabelText:[[_contents objectAtIndex:indexPath.row] objectForKey:@"title"]];
    [self.navigationController pushViewController:cvc animated:YES];
    [cvc release];
}




@end
