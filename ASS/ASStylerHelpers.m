#import <CoreText/CoreText.h>
#import "ASStylerHelpers.h"


#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

@implementation UIColor(DPLStyle)
    - (void)__getR__:(CGFloat *)r g:(CGFloat *)g b:(CGFloat *)b a:(CGFloat *)a {
        CGFloat red = 0;
        CGFloat green = 0;
        CGFloat blue = 0;
        CGFloat alpha = 0;

        BOOL ok;

        if (CGColorGetNumberOfComponents(self.CGColor) == 2) {
            ok = [self getWhite:&red alpha:&alpha];
            green = red;
            blue = red;
        } else {
            ok = [self getRed:&red green:&green blue:&blue alpha:&alpha];
        }

        if (ok) {
            *r = red;
            *g = green;
            *b = blue;
            *a = alpha;
        }
    }

    - (UIColor *)__mixWith__:(UIColor *)aAnotherColor withStrength:(CGFloat)aStrength {
        if (aStrength < 1e-6) {
            return self;
        } else if (aStrength > 1 - 1e-6) {
            return aAnotherColor;
        }

        CGFloat red = 0;
        CGFloat green = 0;
        CGFloat blue = 0;
        CGFloat alpha = 0;
        [self __getR__:&red g:&green b:&blue a:&alpha];

        CGFloat red2 = 0;
        CGFloat green2 = 0;
        CGFloat blue2 = 0;
        CGFloat alpha2 = 0;
        [aAnotherColor __getR__:&red2 g:&green2 b:&blue2 a:&alpha2];

        red = red*(1 - aStrength) + red2*aStrength;
        green = green*(1 - aStrength) + green2*aStrength;
        blue = blue*(1 - aStrength) + blue2*aStrength;
        alpha = alpha*(1 - aStrength) + alpha2*aStrength;

        return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }

    + (UIColor *)__colorFromHex__:(NSString *)aHexRepresentation {
        if ([aHexRepresentation hasPrefix:@"#"]) {
            aHexRepresentation = [aHexRepresentation substringFromIndex:1];
        }

        int red = 0;
        int green = 0;
        int blue = 0;
        int alpha = 255;

        if (aHexRepresentation.length == 8) {
            // RGBA
            sscanf([aHexRepresentation cStringUsingEncoding:NSASCIIStringEncoding], "%2x%2x%2x%2x", &red, &green, &blue, &alpha);
        } else if (aHexRepresentation.length == 6) {
            // RGB
            sscanf([aHexRepresentation cStringUsingEncoding:NSASCIIStringEncoding], "%2x%2x%2x", &red, &green, &blue);
        } else if (aHexRepresentation.length == 3) {
            // RGB
            sscanf([aHexRepresentation cStringUsingEncoding:NSASCIIStringEncoding], "%1x%1x%1x", &red, &green, &blue);
            red += red*16;
            green += green*16;
            blue += blue*16;
        }

        return [UIColor colorWithRed:((CGFloat) red)/255.0 green:((CGFloat) green)/255.0 blue:((CGFloat) blue)/255.0 alpha:((CGFloat) alpha)/255.0];
    }

    - (NSString *)__toHex__ {
        CGFloat red = 0;
        CGFloat green = 0;
        CGFloat blue = 0;
        CGFloat alpha = 0;
        BOOL ok = [self getRed:&red green:&green blue:&blue alpha:&alpha];

        if (ok) {
            if (alpha > 0.95) {
                return [NSString stringWithFormat:@"#%02x%02x%02x",
                                                  (unsigned int) (red*255), (unsigned int) (green*255),
                                                  (unsigned int) (blue*255)];
            } else {
                return [NSString stringWithFormat:@"#%02x%02x%02x%02x",
                                                  (unsigned int) (red*255), (unsigned int) (green*255),
                                                  (unsigned int) (blue*255), (unsigned int) (alpha*255)];
            }
        } else {
            return @"#000000ff";
        }
    }
@end

#endif


@implementation NSString(ASStylerAdditions)
    - (NSString *)__substringFromString__:(NSString *)aSubstring {
        NSUInteger from = [self rangeOfString:aSubstring].location;
        if (from == NSNotFound) {
            return nil;
        }

        return [self substringFromIndex:from + [aSubstring length]];
    }

    - (NSString *)__substringToString__:(NSString *)aSubstring {
        NSUInteger from = [self rangeOfString:aSubstring].location;
        if (from == NSNotFound) {
            return self;
        }

        return [self substringToIndex:from];
    }

    - (NSString *)__capitalizedFirstLetter__ {
        return [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
    }

    - (NSString *)__trim__ {
        return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    - (BOOL)__contains__:(NSString *)aSubstring {
        if (aSubstring == nil) {
            return YES;
        }

        return [self rangeOfString:aSubstring].location != NSNotFound;
    }
@end


NSString *__DPL_DirectoryApplication__() {
    static NSString *cachedValue;
    static BOOL cacheResolved;

    if (!cacheResolved) {
        cacheResolved = YES;
        cachedValue = [[NSBundle mainBundle] bundlePath];
    }

    return cachedValue;
}


NSString *__DPL_FileInCacheOrInBundle__(NSString *aFileName) {
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *fileName = nil;

    NSString *fileNameCache = [__DPL_DirectoryCache__() stringByAppendingPathComponent:aFileName];
    NSString *fileNameApp = [__DPL_DirectoryApplication__() stringByAppendingPathComponent:aFileName];
    if (![manager fileExistsAtPath:fileNameCache]) {
        if ([manager fileExistsAtPath:fileNameApp]) {
            fileName = fileNameApp;
        }
    } else {
        if ([manager fileExistsAtPath:fileNameApp]) {
            NSDictionary *attributesCache = [manager attributesOfItemAtPath:fileNameCache error:nil];
            NSDictionary *attributesApplication = [manager attributesOfItemAtPath:fileNameApp error:nil];

            NSDate *dateCache = attributesCache[NSFileModificationDate];
            NSDate *dateApp = attributesApplication[NSFileModificationDate];

            if ([dateCache compare:dateApp] == NSOrderedAscending) {
                fileName = fileNameApp;
            } else {
                fileName = fileNameCache;
            }
        } else {
            fileName = fileNameCache;
        }
    }

    return fileName;
}

NSString *__DPL_DirectoryCache__() {
    static NSString *cachedValue;
    static BOOL cacheResolved;

    if (!cacheResolved) {
        cacheResolved = YES;

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *cacheDirectories = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        cachedValue = [[cacheDirectories[0] absoluteURL] path];
    }

    return cachedValue;
}

NSInteger __DPL_OSVersionMajor__() {
#if TARGET_IPHONE_SIMULATOR == 1 || TARGET_OS_IPHONE == 1
    static NSInteger cachedValue;
    static BOOL cacheResolved;

    if (!cacheResolved) {
        cacheResolved = YES;
        cachedValue = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
    }

    return cachedValue;
#else
    // this code does not need to run correctly on desktop, only compile
    return 0;
#endif
}
