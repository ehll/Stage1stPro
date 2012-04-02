//
//  RawdataParser.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RawdataParser.h"
#import <CoreText/CoreText.h>
#import "SDAttributedString.h"

#pragma mark - CTRunDelegate

static CGFloat ascentCallback( void *ref ){
    return 16.0f;
}
static CGFloat descentCallback( void *ref ){
    return 0.0f;
}
static CGFloat widthCallback( void* ref ){
    return 16.0f;
}


@interface RawdataParser ()
- (NSString *)unescapeHTMLEntityCharacter:(NSString *)htmlString;
- (NSString *)preprocessHTMLString:(NSString *)htmlString;
- (NSArray *)generateAttributedStringResult:(NSString *)markupString;
@end

@implementation RawdataParser


#pragma mark - Private class method

- (NSString *)unescapeHTMLEntityCharacter:(NSString *)htmlString
{
    NSMutableString *s = [[[NSMutableString alloc] initWithString:htmlString] autorelease];
    [s replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&#39;" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0, [s length])];
    return (NSString *)s;
}

- (NSString *)preprocessHTMLString:(NSString *)htmlString
{
    NSMutableString *s = [[NSMutableString alloc] initWithString:htmlString];
    //replace layout character and tags
    [s replaceOccurrencesOfString:@"\r\n"
                          withString:@""
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"img src=\"http://bbs.saraba1st.com/2b/images/back.gif\""
                          withString:@""
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"<div class=\"quote\">引用 </div>"
                          withString:@""
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"</blockquote>"
                          withString:@"\n－－－－－－－－－－－－－－－－－－－－－\n"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"<br>"
                       withString:@"\n"
                          options:NSLiteralSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n\n\n"
                       withString:@"\n\n"
                          options:NSLiteralSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"</h1>"
                       withString:@"\n\n"
                          options:NSLiteralSearch
                            range:NSMakeRange(0, [s length])]; 
        
    //use the format &emo filename; and &img src; to represent emotions and images for the following parsing.
    NSRegularExpression *emoPattern = [[NSRegularExpression alloc] 
                                       initWithPattern:@"<img src=\"images/post/smile/(.*?)/(\\d+)\\.(gif|png|jpg)\" />"
                                       options:NSRegularExpressionDotMatchesLineSeparators
                                       error:nil];
    NSRegularExpression *imgPattern = [[NSRegularExpression alloc] 
                                       initWithPattern:@"<img src=\"(.*?)\""
                                       options:NSRegularExpressionDotMatchesLineSeparators
                                       error:nil];
    [emoPattern replaceMatchesInString:s options:0 range:NSMakeRange(0, [s length]) withTemplate:@"&emo $1_$2;"];
    [imgPattern replaceMatchesInString:s options:0 range:NSMakeRange(0, [s length]) withTemplate:@"&img $1;<"];
    [emoPattern release]; [imgPattern release];

    //delete html tags
    NSScanner *theScanner;
    theScanner = [NSScanner scannerWithString:s];
    NSUInteger length = [s length];
    NSUInteger offset = 0;
    NSUInteger startPos, endPos, nextStartPos, nextEndPos;	
    [theScanner scanUpToString:@"<" intoString:NULL];
    startPos = [theScanner scanLocation];
    [theScanner scanUpToString:@">" intoString:NULL];
    endPos = [theScanner scanLocation];
    while ([theScanner isAtEnd] == NO) {
        [theScanner setScanLocation:endPos+1];
        [theScanner scanUpToString:@"<" intoString:NULL];
        nextStartPos = [theScanner scanLocation];
        if (nextStartPos == length) {
            [s replaceCharactersInRange:NSMakeRange(startPos-offset, endPos-startPos+1) withString:@""];
            break;
        }
        [theScanner setScanLocation:endPos+1];
        [theScanner scanUpToString:@">" intoString:NULL];
        nextEndPos = [theScanner scanLocation];		
        if (nextStartPos <= nextEndPos) {		
            [s replaceCharactersInRange:NSMakeRange(startPos-offset, endPos-startPos+1) withString:@""];
            offset += endPos-startPos+1;
            startPos = nextStartPos;
            endPos = nextEndPos;
        } else {
            endPos = nextEndPos;
        }
    }
    
    NSString *returnStr = [self unescapeHTMLEntityCharacter:s];
    [s release];

    return returnStr;
}

- (NSArray *)generateAttributedStringResult:(NSString *)markupString
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSMutableArray *imgInfos = [[NSMutableArray alloc] init];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(.*?)(&(emo|img) ([^;]+);|\\Z)" 
                                                                      options:NSRegularExpressionDotMatchesLineSeparators
                                                                        error:nil];
    UIColor *fontColor = [UIColor colorWithRed:0.01f green:0.17f blue:0.50f alpha:1.0f];
    NSString *font = @"STHeitiSC-Light";
    
    NSArray *chunks = [regex matchesInString:markupString options:0 range:NSMakeRange(0, [markupString length])];
    [regex release];
    
    //leave enough space for the images to draw
    for (NSTextCheckingResult *r in chunks) {
        if ([r rangeAtIndex:1].location != NSNotFound) {
            CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font, 13.0f, NULL);
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)fontColor.CGColor, kCTForegroundColorAttributeName,
                                   (id)fontRef, kCTFontAttributeName
                                   , nil];
            [attrStr appendAttributedString:[[[NSAttributedString alloc] initWithString:[markupString substringWithRange:[r rangeAtIndex:1]] attributes:attrs] autorelease]];
            CFRelease(fontRef);
        }
        if ([r rangeAtIndex:3].location != NSNotFound) {
            [imgInfos addObject:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [markupString substringWithRange:[r rangeAtIndex:3]], @"type",
              [markupString substringWithRange:[r rangeAtIndex:4]], @"src",
              [NSNumber numberWithInt:[attrStr length]], @"location",
              nil]];
            
            static CTRunDelegateCallbacks callbacks;
            callbacks.version = kCTRunDelegateVersion1;
            callbacks.getAscent = ascentCallback;
            callbacks.getDescent = descentCallback;
            callbacks.getWidth = widthCallback;
            CTRunDelegateRef delegate;
            delegate = CTRunDelegateCreate(&callbacks, NULL);
            
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)delegate, (NSString *)kCTRunDelegateAttributeName, nil];
            NSAttributedString *append = [[NSAttributedString alloc] initWithString:@" " attributes:attrs];
            [attrStr appendAttributedString:append];
            [append release];
            CFRelease(delegate);

        }
    }
    SDAttributedString *sdAttrStr = [[SDAttributedString alloc] initWithAttributedString:attrStr];
    NSArray *returnArray = [NSArray arrayWithObjects:sdAttrStr, imgInfos, nil];
    [sdAttrStr release]; [attrStr release]; [imgInfos release];    
    return returnArray; 
}

#pragma mark - Public class method

- (NSArray *)extractTitlesFromRawdata:(NSString *)htmlString
{
    NSString *s = [self unescapeHTMLEntityCharacter:htmlString];
    NSRegularExpression *pattern = [[NSRegularExpression alloc] 
                                  initWithPattern:@"<li><a href=\"simple/\\?t(.*?)\\.html\">(.*?)</a>   <span class=\"smalltxt\">\\((\\d+) 回复\\)<"
                                  options:NSRegularExpressionDotMatchesLineSeparators
                                  error:nil];
    NSArray *chunks = [pattern matchesInString:s options:0 range:NSMakeRange(0, [s length])];
    [pattern release];
    
    NSMutableArray *titles = [NSMutableArray array];
    for (NSTextCheckingResult *r in chunks)
    {
        NSDictionary *title = [NSDictionary dictionaryWithObjectsAndKeys:
                               [s substringWithRange:[r rangeAtIndex:1]], @"id",
                               [s substringWithRange:[r rangeAtIndex:2]], @"title",
                               [s substringWithRange:[r rangeAtIndex:3]], @"reply", nil];
        [titles addObject:title];
    }
    return (NSArray *)titles;    
}

- (NSArray *)extractContentsFromRawdata:(NSString *)htmlString
{
    //extract the author and content
    NSString *s = [htmlString copy];
    NSRegularExpression *contentPattern = [[NSRegularExpression alloc] 
                                    initWithPattern:@"<td colspan=\"2\" class=\"tpc_content\">(.*?)</td>"
                                    options:NSRegularExpressionDotMatchesLineSeparators
                                    error:nil];
    NSRegularExpression *authorPattern = [[NSRegularExpression alloc] 
                                          initWithPattern:@"class=\"head\">\\r\\n<td><b>(.*?)</b"
                                          options:NSRegularExpressionDotMatchesLineSeparators
                                          error:nil];
    NSArray *contentChunks = [contentPattern matchesInString:s options:0 range:NSMakeRange(0, [s length])];
    NSArray *authorChunks = [authorPattern matchesInString:s options:0 range:NSMakeRange(0, [s length])];
    
    [contentPattern release];
    [authorPattern release];
    
    NSMutableArray *contents = [NSMutableArray array];
    
    for (int i=0; i < [contentChunks count]; i++) {
        NSString *authorName = [s substringWithRange:[[authorChunks objectAtIndex:i] rangeAtIndex:1]];
        NSString *contentString = [s substringWithRange:[[contentChunks objectAtIndex:i] rangeAtIndex:0]];
        NSArray *attrStrResult =[self generateAttributedStringResult:[self preprocessHTMLString:contentString]];
        NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:authorName, @"author", attrStrResult, @"content", nil];
        [contents addObject:content];
    }    
    //contents: [{'author':@"", 'content':[SDAttrStr, ImgInfos{'type': , 'src': , 'location':}]}, ...]
    [s release];
    return (NSArray *)contents;
}

- (NSString *)extractPageNumberFromRawdata:(NSString *)htmlString
{
    NSRegularExpression *pattern = [[NSRegularExpression alloc] initWithPattern:@"Pages: \\( (\\d+) total \\)" options:NSRegularExpressionSearch error:nil];
    NSTextCheckingResult *matchedResult = [pattern firstMatchInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    NSString *returnStr = nil;
    if (matchedResult == nil) {
        returnStr = @"1";
    }
    else {
        returnStr = [htmlString substringWithRange:[matchedResult rangeAtIndex:1]];
    }
    [pattern release];
    return returnStr;
}









@end
