//
//  Created by alex on 01.05.14.
//

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedPropertyInspection"


@interface ASStylerTextAttributes : NSMutableDictionary
    @property (nonatomic) UIFont *font;
    @property (nonatomic) UIColor *foregroundColor;
    @property (nonatomic) UIColor *backgroundColor;

    @property (nonatomic) CGFloat superscript;
    @property (nonatomic) CGFloat lineSpacing;
    @property (nonatomic) CGFloat paragraphSpacing;
    @property (nonatomic) NSTextAlignment alignment;
    @property (nonatomic) CGFloat firstLineHeadIndent;
    @property (nonatomic) CGFloat headIndent;
    @property (nonatomic) CGFloat tailIndent;
    @property (nonatomic) NSLineBreakMode lineBreakMode;
    @property (nonatomic) CGFloat minimumLineHeight;
    @property (nonatomic) CGFloat maximumLineHeight;
    @property (nonatomic) NSWritingDirection baseWritingDirection;
    @property (nonatomic) CGFloat lineHeightMultiple;
    @property (nonatomic) CGFloat paragraphSpacingBefore;
    @property (nonatomic) float hyphenationFactor;

    @property (nonatomic) NSArray *tabStops;
    @property (nonatomic) CGFloat defaultTabInterval;

    @property (nonatomic) BOOL useLigatures;
    @property (nonatomic) BOOL isVertical;
    @property (nonatomic) CGFloat kerning;

    @property (nonatomic) NSArray *writingDirections;

    @property (nonatomic) CGFloat obliqueness;
    @property (nonatomic) CGFloat expansion;

    @property (nonatomic) BOOL strikethrough;
    @property (nonatomic) UIColor *strikethroughColor;
    @property (nonatomic) BOOL underline;
    @property (nonatomic) UIColor *underlineColor;
    @property (nonatomic) UIColor *strokeColor;
    @property (nonatomic) CGFloat strokeWidth;

    @property (nonatomic) NSShadow *shadow;

    @property (nonatomic) NSString *textEffect;

    @property (nonatomic) CGFloat baselineOffset;
@end

#pragma clang diagnostic pop
