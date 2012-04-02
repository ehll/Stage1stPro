//
//  SDAttributedString.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/26/12.
//


/*
 This is a wrapper of a NSAttributedString and a CTFramesetter
 in order to get the size of the text to draw 
 and provide the tableview cell the height of the text.
 */

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface SDAttributedString : NSObject
{
    NSAttributedString *attrStr;
    CTFramesetterRef framesetter;
    CGSize textSize;
}

@property (retain, nonatomic) NSAttributedString *attrStr;
@property (readonly, nonatomic) CTFramesetterRef framesetter;
@property (readonly, nonatomic) CGSize textSize;

- (id)initWithAttributedString:(NSAttributedString *)attrStr;

@end
