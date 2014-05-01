//
//  Created by alex on 01.05.14.
//


#import "ASStylerHelpers.h"
#import <CoreText/CoreText.h>
#include "ASStylerTextAttributes.h"


@implementation ASStylerTextAttributes {
        NSMutableDictionary *_data;
    }

    - (instancetype)init {
        self = [super init];
        if (self) {
            _data = [NSMutableDictionary dictionary];
        }

        return self;
    }

    - (NSUInteger)count {
        return [_data count];
    }

    - (NSEnumerator *)keyEnumerator {
        return [_data keyEnumerator];
    }

    - (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
        if (anObject != nil) {
            [_data setObject:anObject forKey:aKey];
        }
    }

    - (id)objectForKey:(id)aKey {
        return [_data objectForKey:aKey];
    }

    - (id)objectForKeyedSubscript:(id)key {
        return [_data objectForKeyedSubscript:key];
    }

    - (UIFont *)font {
        return self[NSFontAttributeName];
    }

    - (void)setFont:(UIFont *)font {
        self[NSFontAttributeName] = font;
    }

    - (UIColor *)foregroundColor {
        return self[NSForegroundColorAttributeName];
    }

    - (void)setForegroundColor:(UIColor *)foregroundColor {
        self[NSForegroundColorAttributeName] = foregroundColor;
    }

    - (UIColor *)backgroundColor {
        return self[NSBackgroundColorAttributeName];
    }

    - (void)setBackgroundColor:(UIColor *)backgroundColor {
        self[NSBackgroundColorAttributeName] = backgroundColor;
    }

    - (NSMutableParagraphStyle *)paragraphStyle {
        NSMutableParagraphStyle *style = self[NSParagraphStyleAttributeName];
        if (style == nil) {
            style = [[NSMutableParagraphStyle alloc] init];
            self[NSParagraphStyleAttributeName] = style;
        }

        return style;
    }

    - (CGFloat)lineSpacing {
        return [self paragraphStyle].lineSpacing;
    }

    - (CGFloat)superscript {
        return [self[(NSString *) kCTSuperscriptAttributeName] floatValue];
    }

    - (void)setSuperscript:(CGFloat)superscript {
        self[(NSString *)kCTSuperscriptAttributeName] = @(superscript);
    }

    - (void)setLineSpacing:(CGFloat)lineSpacing {
        [self paragraphStyle].lineSpacing = lineSpacing;
    }

    - (CGFloat)paragraphSpacing {
        return [self paragraphStyle].paragraphSpacing;
    }

    - (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
        [self paragraphStyle].paragraphSpacing = paragraphSpacing;
    }

    - (NSTextAlignment)alignment {
        return [self paragraphStyle].alignment;
    }

    - (void)setAlignment:(NSTextAlignment)alignment {
        [self paragraphStyle].alignment = alignment;
    }

    - (CGFloat)firstLineHeadIndent {
        return [self paragraphStyle].firstLineHeadIndent;
    }

    - (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent {
        [self paragraphStyle].firstLineHeadIndent = firstLineHeadIndent;
    }

    - (CGFloat)headIndent {
        return [self paragraphStyle].headIndent;
    }

    - (void)setHeadIndent:(CGFloat)headIndent {
        [self paragraphStyle].headIndent = headIndent;
    }

    - (CGFloat)tailIndent {
        return [self paragraphStyle].tailIndent;
    }

    - (void)setTailIndent:(CGFloat)tailIndent {
        [self paragraphStyle].tailIndent = tailIndent;
    }

    - (NSLineBreakMode)lineBreakMode {
        return [self paragraphStyle].lineBreakMode;
    }

    - (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
        [self paragraphStyle].lineBreakMode = lineBreakMode;
    }

    - (CGFloat)minimumLineHeight {
        return [self paragraphStyle].minimumLineHeight;
    }

    - (void)setMinimumLineHeight:(CGFloat)minimumLineHeight {
        [self paragraphStyle].minimumLineHeight = minimumLineHeight;
    }

    - (CGFloat)maximumLineHeight {
        return [self paragraphStyle].maximumLineHeight;
    }

    - (void)setMaximumLineHeight:(CGFloat)maximumLineHeight {
        [self paragraphStyle].maximumLineHeight = maximumLineHeight;
    }

    - (NSWritingDirection)baseWritingDirection {
        return [self paragraphStyle].baseWritingDirection;
    }

    - (void)setBaseWritingDirection:(NSWritingDirection)baseWritingDirection {
        [self paragraphStyle].baseWritingDirection = baseWritingDirection;
    }

    - (CGFloat)lineHeightMultiple {
        return [self paragraphStyle].lineHeightMultiple;
    }

    - (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple {
        [self paragraphStyle].lineHeightMultiple = lineHeightMultiple;
    }

    - (CGFloat)paragraphSpacingBefore {
        return [self paragraphStyle].paragraphSpacingBefore;
    }

    - (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
        [self paragraphStyle].paragraphSpacingBefore = paragraphSpacingBefore;
    }

    - (float)hyphenationFactor {
        return [self paragraphStyle].hyphenationFactor;
    }

    - (void)setHyphenationFactor:(float)hyphenationFactor {
        [self paragraphStyle].hyphenationFactor = hyphenationFactor;
    }

    - (NSArray *)tabStops {
        return [self paragraphStyle].tabStops;
    }

    - (void)setTabStops:(NSArray *)tabStops {
        [self paragraphStyle].tabStops = [tabStops copy];
    }

    - (CGFloat)defaultTabInterval {
        return [self paragraphStyle].defaultTabInterval;
    }

    - (void)setDefaultTabInterval:(CGFloat)defaultTabInterval {
        [self paragraphStyle].defaultTabInterval = defaultTabInterval;
    }

    - (BOOL)useLigatures {
        return [self[NSLigatureAttributeName] boolValue];
    }

    - (void)setUseLigatures:(BOOL)useLigatures {
        self[NSLigatureAttributeName] = @(useLigatures);
    }

    - (BOOL)isVertical {
        return [self[NSVerticalGlyphFormAttributeName] boolValue];
    }

    - (void)setIsVertical:(BOOL)isVertical {
        self[NSVerticalGlyphFormAttributeName] = @(isVertical);
    }

    - (CGFloat)kerning {
        return [self[NSKernAttributeName] floatValue];
    }

    - (void)setKerning:(CGFloat)kerning {
        self[NSKernAttributeName] = @(kerning);
    }

    - (NSArray *)writingDirections {
        return self[NSWritingDirectionAttributeName];
    }

    - (void)setWritingDirections:(NSArray *)writingDirections {
        self[NSWritingDirectionAttributeName] = [writingDirections copy];
    }

    - (CGFloat)obliqueness {
        return [self[NSObliquenessAttributeName] floatValue];
    }

    - (void)setObliqueness:(CGFloat)obliqueness {
        self[NSObliquenessAttributeName] = @(obliqueness);
    }

    - (CGFloat)expansion {
        return [self[NSExpansionAttributeName] floatValue];
    }

    - (void)setExpansion:(CGFloat)expansion {
        self[NSExpansionAttributeName] = @(expansion);
    }

    - (BOOL)strikethrough {
        return [self[NSStrikethroughStyleAttributeName] boolValue];
    }

    - (void)setStrikethrough:(BOOL)strikethrough {
        self[NSStrikethroughStyleAttributeName] = @(strikethrough);
    }

    - (UIColor *)strikethroughColor {
        return self[NSStrikethroughColorAttributeName];
    }

    - (void)setStrikethroughColor:(UIColor *)strikethroughColor {
        self[NSStrikethroughColorAttributeName] = strikethroughColor;
    }

    - (BOOL)underline {
        return [self[NSUnderlineStyleAttributeName] boolValue];
    }

    - (void)setUnderline:(BOOL)underline1 {
        self[NSUnderlineStyleAttributeName] = @(underline1);
    }

    - (UIColor *)underlineColor {
        return self[NSUnderlineColorAttributeName];
    }

    - (void)setUnderlineColor:(UIColor *)underlineColor {
        self[NSUnderlineColorAttributeName] = underlineColor;
    }

    - (UIColor *)strokeColor {
        return self[NSStrokeColorAttributeName];
    }

    - (void)setStrokeColor:(UIColor *)strokeColor {
        self[NSStrokeColorAttributeName] = strokeColor;
    }

    - (CGFloat)strokeWidth {
        return [self[NSStrokeWidthAttributeName] floatValue];
    }

    - (void)setStrokeWidth:(CGFloat)strokeWidth {
        self[NSStrokeWidthAttributeName] = @(strokeWidth);
    }

    - (NSShadow *)shadow {
        return self[NSShadowAttributeName];
    }

    - (void)setShadow:(NSShadow *)shadow1 {
        self[NSShadowAttributeName] = shadow1;
    }

    - (NSString *)textEffect {
        return self[NSTextEffectAttributeName];
    }

    - (void)setTextEffect:(NSString *)textEffect {
        self[NSTextEffectAttributeName] = textEffect;
    }

    - (CGFloat)baselineOffset {
        return [self[NSBaselineOffsetAttributeName] floatValue];
    }

    - (void)setBaselineOffset:(CGFloat)baselineOffset {
        self[NSBaselineOffsetAttributeName] = @(baselineOffset);
    }
@end
