//
//  RawdataParser.h
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//


#import <Foundation/Foundation.h>

@interface RawdataParser : NSObject

- (NSArray *)extractTitlesFromRawdata:(NSString *)htmlString;
- (NSArray *)extractContentsFromRawdata:(NSString *)htmlString;
- (NSString *)extractPageNumberFromRawdata:(NSString *)htmlString;

@end
