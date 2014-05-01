#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@interface UIColor(DPLStyle)
    + (UIColor *)__colorFromHex__:(NSString *)aHexRepresentation;

    - (void)__getR__:(CGFloat *)r g:(CGFloat *)g b:(CGFloat *)b a:(CGFloat *)a;
    - (UIColor *)__mixWith__:(UIColor *)aAnotherColor withStrength:(CGFloat)aStrength;
@end
#endif


@interface NSString(ASStylerAdditions)
    - (NSString *)__substringFromString__:(NSString *)aSubstring;
    - (NSString *)__substringToString__:(NSString *)aSubstring;

    - (NSString *)__capitalizedFirstLetter__;

    - (BOOL)__contains__:(NSString *)aSubstring;

    - (NSString *)__trim__;
@end


extern NSString *__DPL_DirectoryCache__();
extern NSString *__DPL_FileInCacheOrInBundle__(NSString *aFileName);

extern NSInteger __DPL_OSVersionMajor__();
