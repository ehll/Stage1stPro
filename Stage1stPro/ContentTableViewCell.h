//
//  ContentTableViewCell.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "OptiTableViewCell.h"

@class SDAttributedString;
@protocol ContentTableViewCellDelegate;

@interface ContentTableViewCell : OptiTableViewCell
{
    NSString *author;
    SDAttributedString *attrStr;
    NSArray *imgInfos;
}

@property (retain, nonatomic) NSString *author;
@property (retain, nonatomic) SDAttributedString *attrStr;
@property (retain, nonatomic) NSArray *imgInfos;
@property (assign, nonatomic) id delegate;

- (void)setDisplayContent:(NSDictionary *)content;

@end

@protocol ContentTableViewCellDelegate
- (void)addButtonInCell:(ContentTableViewCell *)cell withPosition:(CGRect)rect;
@end