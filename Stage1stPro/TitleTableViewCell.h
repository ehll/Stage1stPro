//
//  TitleTableViewCell.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptiTableViewCell.h"

@interface TitleTableViewCell : OptiTableViewCell
{
    NSString *titleText;
    NSString *replyNumber;
}

- (void)setTitleText:(NSString *)tt AndReplyNumber:(NSString *)rn;

@end
