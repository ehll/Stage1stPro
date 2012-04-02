//
//  OptiTableViewCell.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptiTableViewCell : UITableViewCell
{
    UIView *contentView;
}

@property (retain, nonatomic) UIView *contentView;

- (void)drawContentView:(CGRect)rect;

@end
