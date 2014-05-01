//
//  Created by alex on 05.07.13.
//


#import <objc/runtime.h>
#import <CoreText/CoreText.h>
#import "ASStylerHelpers.h"
#import "ASStyler.h"

#ifndef CREATE_LOGGER
    #define CREATE_LOGGER

    #define DPL_EXCEPTION(aMessage, ...) NSLog(@"Exception: %@", ([NSString stringWithFormat:aMessage, ##__VA_ARGS__]));

    #define DPL_DEBUG(aMessage, ...)
    #define DPL_DEBUG_DATA(aMessage, aFileName)
    #define DPL_INFO(aMessage, ...)
    #define DPL_WARNING(aMessage, ...)
    #define DPL_ERROR(aMessage, ...) NSLog(@"Error: %@", ([NSString stringWithFormat:aMessage, ##__VA_ARGS__]));
#endif

// This define removes all simulator preprocessing. Application in the simulator will run as on the device
#define TEST_BINARY_LOADING 0

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedClassInspection"
#pragma ide diagnostic ignored "OCUnusedMethodInspection"

@interface ASStylerGeneratedClass : NSObject
    @property (nonatomic) NSString *type;
    @property (nonatomic) NSString *styleName;
    @property (nonatomic) NSString *name;

    - (instancetype)initWithName:(NSString *)name type:(NSString *)type styleName:(NSString *)styleName;

    - (NSString *)description;
@end


@implementation ASStylerGeneratedClass
    - (instancetype)initWithName:(NSString *)name type:(NSString *)type styleName:(NSString *)styleName {
        self = [super init];
        if (self) {
            self.type = type;
            self.name = name;
            self.styleName = styleName;
        }

        return self;
    }


    - (NSString *)description {
        NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
        [description appendFormat:@"type=%@", self.type];
        [description appendFormat:@", name=%@", self.name];
        [description appendString:@">"];
        return description;
    }
@end


@interface ASStyler()
    - (void)applyStyle:(NSString *)aStyleName to:(NSObject *)aObject notAListener:(BOOL)notAListener;
    - (id)styleValueForKey:(NSString *)aKey;
#ifndef CREATE_LOGGER
    + (DPLLogger *)logger;
#endif
@end


@implementation NSObject(DPStyler)
    - (void)applyDPStyle:(NSString *)aStyleName {
        [[ASStyler sharedInstance] applyStyle:aStyleName to:self notAListener:NO];
    }
@end

@implementation ASStyler {
        NSString *_name;
        NSMutableDictionary *_enums;

        NSMutableArray *_externalLoadedURLs;
        NSMutableArray *_loadedStyleURLs;

        NSDictionary *_styles;
        NSDictionary *_stylesUnExpanded;

        ASStyleObject *_stylesObject;

        Class _stylesObjectClass;
        NSString *_simulatorPathForSavingBinaryCache;

        ASStylerListenerList *_styledObjects;

        dispatch_queue_t _backgroundLoadingSerialThread;

        NSCache *_cachedStylesForExpanding;
    }

    CREATE_LOGGER

    + (ASStyler *)sharedInstance {
        static ASStyler *sharedInstance = nil;

        static dispatch_once_t predicate = 0;
        dispatch_once(&predicate, ^{
            sharedInstance = [[ASStyler alloc] init];
            sharedInstance->_name = @"Shared";
        });

        return sharedInstance;
    }

    + (NSString *)typeStringForProperty:(NSString *)aPropertyName inObject:(id)aObject {
        objc_property_t property = class_getProperty([aObject class], [aPropertyName UTF8String]);
        if (property == nil) {
            DPL_ERROR(@"Object of class %@ does not have property %@", NSStringFromClass([aObject class]), aPropertyName);
            return nil;
        } else {
            const char *attributes = property_getAttributes(property);
            NSString *attributesString = [NSString stringWithUTF8String:attributes];
            NSString *typeString = [[attributesString __substringToString__:@","] substringFromIndex:1];
            return typeString;
        }
    }

    + (Class)classForPropertyTypeString:(NSString *)typeString {
        unichar ch = [typeString characterAtIndex:0];

        if (ch == @encode(id)[0] && [typeString length] > 1) {
            NSString *name = [typeString substringWithRange:NSMakeRange(2, [typeString length] - 3)];
            Class theClass = NSClassFromString(name);
            return theClass;
        }

        return nil;
    }

    + (BOOL)isPropertyTypeStringNumber:(NSString *)typeString {
        unichar ch = [typeString characterAtIndex:0];
        return ch == @encode(int)[0] || ch == @encode(float)[0] ||
                ch == @encode(long)[0] || ch == @encode(short)[0] ||
                ch == @encode(char)[0] || ch == @encode(double)[0];
    }

    + (BOOL)isPropertyTypeStringCGPoint:(NSString *)typeString {
        static NSString *specificTypeString = nil;
        static dispatch_once_t predicate = 0;
        _dispatch_once(&predicate, ^{
            specificTypeString = [NSString stringWithCString:@encode(CGPoint) encoding:NSASCIIStringEncoding];
        });
        return [typeString hasPrefix:specificTypeString];
    }

    + (BOOL)isPropertyTypeStringCGSize:(NSString *)typeString {
        static NSString *specificTypeString = nil;
        static dispatch_once_t predicate = 0;
        _dispatch_once(&predicate, ^{
            specificTypeString = [NSString stringWithCString:@encode(CGSize) encoding:NSASCIIStringEncoding];
        });
        return [typeString hasPrefix:specificTypeString];
    }

    + (BOOL)isPropertyTypeStringCGRect:(NSString *)typeString {
        static NSString *specificTypeString = nil;
        static dispatch_once_t predicate = 0;
        _dispatch_once(&predicate, ^{
            specificTypeString = [NSString stringWithCString:@encode(CGRect) encoding:NSASCIIStringEncoding];
        });
        return [typeString hasPrefix:specificTypeString];
    }

    + (BOOL)isPropertyTypeStringUIEdgeInsets:(NSString *)typeString {
        static NSString *specificTypeString = nil;
        static dispatch_once_t predicate = 0;
        _dispatch_once(&predicate, ^{
            specificTypeString = [NSString stringWithCString:@encode(UIEdgeInsets) encoding:NSASCIIStringEncoding];
        });
        return [typeString hasPrefix:specificTypeString];
    }

    - (id)init {
        self = [super init];
        if (self) {
            _name = @"Unknown";
            [self initEnums];
            _styledObjects = [[ASStylerListenerList alloc] init];
            _loadedStyleURLs = [NSMutableArray array];
            _externalLoadedURLs = [NSMutableArray array];

            _cachedStylesForExpanding = [[NSCache alloc] init];
            _cachedStylesForExpanding.countLimit = 1000;

            _backgroundLoadingSerialThread = dispatch_queue_create("_backgroundLoadingSerialThread", DISPATCH_QUEUE_SERIAL);
            dispatch_set_target_queue(_backgroundLoadingSerialThread, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        }

        return self;
    }

    - (void)updateStyleFromOriginalURLs {
        NSArray *loadURLs = [NSArray arrayWithArray:_externalLoadedURLs];
        [self reloadStylesFromURLs:loadURLs];
    }

    - (void)reloadStylesFromURL:(NSString *)loadURL {
        NSURL *styleFileURL = [self getFileURLForFile:loadURL];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[styleFileURL path]]) {
            [self reloadStylesFromURLs:@[loadURL]];
        }
    }

    - (void)reloadStylesFromURLs:(NSArray *)loadURLs {
        dispatch_async(_backgroundLoadingSerialThread, ^{
            _styles = [NSDictionary dictionary];
            _stylesUnExpanded = [NSDictionary dictionary];

            _stylesObject = nil;

            _loadedStyleURLs = [NSMutableArray array];
            _externalLoadedURLs = [NSMutableArray array];

            [_cachedStylesForExpanding removeAllObjects];

            for (NSString *styleURL in loadURLs) {
                if (![_externalLoadedURLs containsObject:styleURL]) {
                    [_externalLoadedURLs addObject:styleURL];
                    [self addStylesFromURL:styleURL updateStyles:NO];
                }
            }

            [self updateStylesObjectBinaryCacheForceSave:YES];
            [self updateStyledObjectsWithNotification:YES];
        });
    }

    - (void)updateStyledObjectsWithNotification:(BOOL)isNotificationNeeded {
        dispatch_async(dispatch_get_main_queue(), ^{
            void (^callback)(NSString *, id) =
                    ^(NSString *aStyleName, id aObjectToApplyTo) {
                        [self applyStyle:aStyleName to:aObjectToApplyTo notAListener:YES];
                    };
            [_styledObjects reapplyAllStylesWithCallback:callback];


#ifdef DPL_STYLER_NOTIFICATIONS
            if (isNotificationNeeded && !_disableRemoteIncludes) {
                if (NSClassFromString(@"DPLStylerMessageOverlayView") != nil) {
                    id copiedMessage = [[NSClassFromString(@"DPLStylerMessageOverlayView") alloc] init];
                    if (copiedMessage != nil &&
                            [copiedMessage respondsToSelector:@selector(setMessage:)] &&
                            [copiedMessage respondsToSelector:@selector(show)] &&
                            [copiedMessage respondsToSelector:@selector(hide)]) {
                        [copiedMessage performSelector:@selector(setMessage:) withObject:@"Styles reloaded"];

                        [copiedMessage performSelector:@selector(show)];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*2), dispatch_get_main_queue(), ^{
                            [copiedMessage performSelector:@selector(hide)];
                        });
                    }
                }
            }
#endif
        });
    }

    - (void)addStylesFromURL:(NSString *)styleFileURL {
        if (![_externalLoadedURLs containsObject:styleFileURL]) {
            [_externalLoadedURLs addObject:styleFileURL];
            [self addStylesFromURL:styleFileURL updateStyles:YES];
        }
    }

    - (void)addStylesFromURL:(NSString *)aStyleFileURL updateStyles:(BOOL)needUpdateStyles {
        NSURL *styleFileURL = [self getFileURLForFile:aStyleFileURL];

        @synchronized (_loadedStyleURLs) {
            if (![_loadedStyleURLs containsObject:[styleFileURL absoluteString]]) {
                [self loadStylesFrom:[styleFileURL absoluteString] needExpandValues:YES];
            } else {
                needUpdateStyles = NO;
            }
        }

        if (needUpdateStyles) {
            dispatch_async(_backgroundLoadingSerialThread, ^{
                [self updateStyledObjectsWithNotification:NO];
            });
        }
    }

    - (NSURL *)getFileURLForFile:(NSString *)aFileURL {
        NSURL *url = nil;

        if ([aFileURL rangeOfString:@"://"].location == NSNotFound && ![aFileURL hasPrefix:@"/"]) {
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            url = [NSURL fileURLWithPath:[[bundle resourcePath] stringByAppendingPathComponent:aFileURL]];
        } else if ([aFileURL hasPrefix:@"/"]) {
            url = [NSURL fileURLWithPath:aFileURL];
        } else {
            url = [NSURL URLWithString:aFileURL];
        }

        return url;
    }

    - (BOOL)loadStylesFrom:(NSString *)aStyleURL needExpandValues:(BOOL)isExpandingNeeded {
        BOOL result = NO;

        BOOL isMerging = ([_loadedStyleURLs count] != 0);

        NSURL *styleFileURL = [self getFileURLForFile:aStyleURL];
        if (styleFileURL == nil) {
            DPL_ERROR(@"[%@] File URL can't be found: %@", _name, aStyleURL);
            return result;
        }

        NSString *absoluteURLString = [styleFileURL absoluteString];

        NSString *debugFileName = absoluteURLString;
        if ([debugFileName length] > 90) {
            debugFileName = [NSString stringWithFormat:@"%@...%@", [debugFileName substringToIndex:20],
                                                       [debugFileName substringFromIndex:[debugFileName length] - 67]];
        }

        if ([_loadedStyleURLs containsObject:absoluteURLString]) {
            result = YES;
        } else {
            [_loadedStyleURLs addObject:absoluteURLString];

            NSError *error = nil;
            NSData *stylesData = [[NSData alloc] initWithContentsOfURL:styleFileURL options:NSDataReadingUncached error:&error];

            if (stylesData != nil && error == nil) {
                DPL_INFO(@"[%@] %@ styles: %@", _name, isMerging ? @"Merging" : @"Loading", debugFileName);

                error = nil;
                NSDictionary *styles = [NSJSONSerialization JSONObjectWithData:stylesData options:NSJSONReadingAllowFragments error:&error];
                if (error != nil) {
                    DPL_ERROR(@"[%@] Error (%@) parsing styles file: %@", _name, error, debugFileName);
                } else {
                    if (styles != nil && [styles count] != 0) {
                        if (isMerging) {
                            _stylesUnExpanded = [self mergeDictionary:_stylesUnExpanded with:styles];
                        } else {
                            _stylesUnExpanded = styles;
                        }
                    }
                }

                // сохраним инклуды, потом поинклудим, потом восстановим. Восстановим чтобы потом перезагрузить можно было.
                // удалим, чтобы рекурсия их не видела
                NSMutableDictionary *includes = [NSMutableDictionary dictionary];
                for (NSString *styleName in _stylesUnExpanded) {
                    if ([styleName hasPrefix:@"@include"]) {
                        DPL_DEBUG(@"[%@] Found @include key: %@", _name, styleName);
                        includes[styleName] = _stylesUnExpanded[styleName];
                    }
                }

                NSMutableDictionary *mutableStylesUnexpanded = [_stylesUnExpanded mutableCopy];
                [mutableStylesUnexpanded removeObjectsForKeys:[includes allKeys]];
                _stylesUnExpanded = [mutableStylesUnexpanded copy];

                for (NSString *styleName in includes) {
                    if ([includes[styleName] isKindOfClass:[NSDictionary class]]) {
                        if (![self loadedInAppOrLocalUrl:styleName include:includes[styleName]] && !_disableRemoteIncludes) {
                            [self loadRemoteStyle:includes[styleName][@"remote"]];
                        }
                    } else if ([includes[styleName] isKindOfClass:[NSString class]]) {
                        [self loadedInAppOrLocalUrl:styleName include:includes[styleName]];
                    }
                }

                mutableStylesUnexpanded = [_stylesUnExpanded mutableCopy];
                [mutableStylesUnexpanded addEntriesFromDictionary:includes];
                _stylesUnExpanded = [mutableStylesUnexpanded copy];

                NSMutableArray *toRemove = [NSMutableArray array];
                NSMutableArray *toRemoveFromUnExpanded = [NSMutableArray array];
                for (NSString *styleName in _stylesUnExpanded) {
                    if ([styleName hasPrefix:@"@include"]) {
                        [toRemove addObject:styleName];
                    } else if ([styleName isEqualToString:@"@animationSpeedCoefficient"]) {
                        DPL_DEBUG(@"[%@] Found @animationSpeedCoefficient key: %@", _name, styleName);

#if TARGET_IPHONE_SIMULATOR == 0
                        CGFloat speed = [_stylesUnExpanded[styleName] floatValue];
                        UIApplication *application = [UIApplication sharedApplication];
                        if (application != nil) {
                            NSArray *windows = [application windows];
                            for (UIWindow *window in windows) {
                                if (window != nil) {
                                    id layer = [window layer];
                                    if (layer != nil && [layer respondsToSelector:@selector(setSpeed:)]) {
                                        [layer performSelector:@selector(setSpeed:) withObject:@(speed)];
                                    }
                                }
                            }
                        }
#else
                        DPL_ERROR(@"[%@] @animationSpeedCoefficient key does NOT work in simulator yet :(", _name);
#endif

                        [toRemove addObject:styleName];
                    } else if ([styleName hasPrefix:@"@"]) {
                        // с @ — начинаются спец-поля, управляющие
                        [toRemove addObject:styleName];
                    } else if ([styleName hasPrefix:@"//"]) {
                        // с // — начинаются комментарии
                        [toRemove addObject:styleName];
                        [toRemoveFromUnExpanded addObject:styleName];
                    } else if ([styleName hasPrefix:@"#"]) {
                        // с # — начинаются комментарии
                        [toRemove addObject:styleName];
                        [toRemoveFromUnExpanded addObject:styleName];
                    }
                }

                NSMutableDictionary *newUnexpandedStyles = [_stylesUnExpanded mutableCopy];
                for (NSString *key in toRemoveFromUnExpanded) {
                    [newUnexpandedStyles removeObjectForKey:key];
                }
                _stylesUnExpanded = [newUnexpandedStyles copy];

                NSMutableDictionary *newStyles = [_stylesUnExpanded mutableCopy];
                for (NSString *key in toRemove) {
                    [newStyles removeObjectForKey:key];
                }

                _styles = [newStyles copy];

                if (isExpandingNeeded) {
                    [_cachedStylesForExpanding removeAllObjects];
                    _styles = [self expandStyles:_styles];
                }

                result = YES;
            } else {
                DPL_WARNING(@"[%@] Style file was not found: %@ (error, if any: %@)", _name, debugFileName, error);
            }
        }

        return result;
    }

    - (BOOL)loadedInAppOrLocalUrl:(NSString *)styleName include:(id)styleURLOrDictionary {
        NSString *inAppURL = nil;
        if ([styleURLOrDictionary isKindOfClass:[NSString class]]) {
            inAppURL = styleURLOrDictionary;
        } else {
            inAppURL = styleURLOrDictionary[@"inApp"];
        }

        if (inAppURL != nil) {
            [self loadStylesFrom:[[self getFileURLForFile:inAppURL] absoluteString] needExpandValues:NO];
        }

        BOOL localIsLoaded = NO;

#if TARGET_IPHONE_SIMULATOR
        if ([styleURLOrDictionary isKindOfClass:[NSDictionary class]]) {
            NSString *localURL = styleURLOrDictionary[@"local"];
            if (!_disableRemoteIncludes && localURL != nil) {
                localIsLoaded = [self loadStylesFrom:localURL needExpandValues:NO];
            }
        }
#endif

        return localIsLoaded;
    }

    - (void)loadRemoteStyle:(NSString *)remoteURL {
        if (remoteURL != nil) {
            __block __strong NSString *remoteURLForBlock = remoteURL;

            dispatch_async(
//                    dispatch_time(DISPATCH_TIME_NOW, (int64_t) (NSEC_PER_SEC*0.5)),
                    _backgroundLoadingSerialThread,
                    ^{
                        [self loadStylesFrom:remoteURLForBlock needExpandValues:YES];
                    });
        }
    }

#pragma mark -
#pragma mark Styles Object

    - (ASStyleObject *)stylesObject {
        if (_stylesObject == nil) {
            [self loadedStylesFromBinaryCache];
        }
        return _stylesObject;
    }

    - (void)addStylesFromURL:(NSString *)styleFileURL toClass:(Class)aClass {
        [self addStylesFromURL:styleFileURL toClass:aClass pathForSimulatorGeneratedCache:nil];
    }

    - (void)addStylesFromURL:(NSString *)styleFileURL toClass:(Class)aClass pathForSimulatorGeneratedCache:(NSString *)aSimulatorPathForSavingBinaryCache {
        _stylesObjectClass = aClass;
        if (aSimulatorPathForSavingBinaryCache != nil) {
            _simulatorPathForSavingBinaryCache = aSimulatorPathForSavingBinaryCache;
        }

        if (!_disableRemoteIncludes || ![self loadedStylesFromBinaryCache]) {
            [self addStylesFromURL:styleFileURL];
#if TARGET_IPHONE_SIMULATOR
            [self updateStylesObjectBinaryCacheForceSave:NO];
#endif
        } else {
            if (![_externalLoadedURLs containsObject:styleFileURL]) {
                [_externalLoadedURLs addObject:styleFileURL];
            }
        }
    }

    - (BOOL)loadedStylesFromBinaryCache {
#if TARGET_IPHONE_SIMULATOR && !TEST_BINARY_LOADING
        return NO;
#else
        NSString *fileName = __DPL_FileInCacheOrInBundle__([NSString stringWithFormat:@"%@.styleCache.data", NSStringFromClass(_stylesObjectClass)]);
        if (fileName != nil) {
            NSData *data = [NSData dataWithContentsOfFile:fileName];
            NSKeyedUnarchiver *archiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            _stylesObject = [archiver decodeObject];

            return _stylesObject != nil;
        } else {
            return NO;
        }
#endif
    }

    - (void)updateStylesObjectBinaryCacheForceSave:(BOOL)isSavingForced {
        ASStyleObject *tempStylesObject = [[_stylesObjectClass alloc] init];
        [self applyStyle:@"" to:tempStylesObject notAListener:YES];

        if ([tempStylesObject conformsToProtocol:@protocol(NSCoding)]) {
            NSMutableData *data = [[NSMutableData alloc] init];
            NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [coder setOutputFormat:NSPropertyListBinaryFormat_v1_0];
            [coder encodeObject:((id<NSCoding>) tempStylesObject)];
            [coder finishEncoding];

            NSString *fileName = nil;

            if (isSavingForced || !_disableRemoteIncludes) {
                fileName = [__DPL_DirectoryCache__() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.styleCache.data", NSStringFromClass(_stylesObjectClass)]];
                [data writeToFile:fileName atomically:YES];
            }

#if TARGET_IPHONE_SIMULATOR && !TEST_BINARY_LOADING
            if (_simulatorPathForSavingBinaryCache != nil) {
                fileName = [_simulatorPathForSavingBinaryCache stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.styleCache.data", NSStringFromClass(_stylesObjectClass)]];
                [data writeToFile:fileName atomically:YES];
            }

            _stylesObject = nil;
#endif
        }

        _stylesObject = tempStylesObject;
    }

#pragma mark -
#pragma mark Optimize styles

    - (NSDictionary *)expandStyles:(NSDictionary *)aStyle {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];

        if ([[aStyle allKeys] containsObject:@"@parent"]) {
            id parentValue = [self findAliasedStyleValue:aStyle[@"@parent"]];
            if ([parentValue isKindOfClass:[NSDictionary class]]) {
                [result addEntriesFromDictionary:[self expandStyles:parentValue]];
            } else {
                DPL_ERROR(@"[%@] Can't find a style that is referenced in @parent: %@", _name, aStyle[@"@parent"]);
            }
        }

        for (NSString *key in aStyle) {
            if (![key isEqualToString:@"@parent"]) {
                if ([aStyle[key] isKindOfClass:[NSDictionary class]]) {
                    result[key] = [self expandStyles:aStyle[key]];
                } else {
                    result[key] = aStyle[key];
                }
            }
        }

        NSMutableDictionary *unaliasedResult = [NSMutableDictionary dictionary];

        for (NSString *key in result) {
            if (key == nil) {
                continue;
            }

            id value = result[key];
            if ([value isKindOfClass:[NSString class]] && ([value hasPrefix:@"@"] || [value hasPrefix:@"~"])) {
                value = [self getAliasedStyleValueOrMethodCallResult:value];
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                value = [self expandStyles:value];
            }

            if (value != nil) {
                unaliasedResult[key] = value;
            } else {
                DPL_ERROR(@"Can't find style \"%@\" to expand", key);
            }
        }

        return [unaliasedResult copy];
    }

    - (id)getResultOfAMethodCall:(NSString *)aMethodCallString {
        id result = nil;

        if ([aMethodCallString hasPrefix:@"~~"]) {
            result = [aMethodCallString substringFromIndex:1];
        } else {
            // ~color.alpha(@colors.backgroundSelectedColor, 0.0)
            static NSRegularExpression *typeAndMethodRegExp = nil;
            static NSRegularExpression *typeOnlyRegExp = nil;
            static dispatch_once_t predicate = 0;
            dispatch_once(&predicate, ^{
                typeAndMethodRegExp = [[NSRegularExpression alloc]
                        initWithPattern:@"~([^\\.]+)\\.([^\\.]+)\\(([^\\)]+)\\)" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
                typeOnlyRegExp = [[NSRegularExpression alloc]
                        initWithPattern:@"~([^\\.]+)\\(([^\\)]+)\\)" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
            });

            NSString *type;
            NSString *method = @"__default";
            NSArray *parameters;

            NSTextCheckingResult *match = [typeAndMethodRegExp firstMatchInString:aMethodCallString options:NSMatchingAnchored range:NSMakeRange(0, [aMethodCallString length])];
            if (match == nil) {
                match = [typeOnlyRegExp firstMatchInString:aMethodCallString options:NSMatchingAnchored range:NSMakeRange(0, [aMethodCallString length])];

                type = [[aMethodCallString substringWithRange:[match rangeAtIndex:1]] lowercaseString];
                parameters = [[aMethodCallString substringWithRange:[match rangeAtIndex:2]] componentsSeparatedByString:@","];
            } else {
                type = [[aMethodCallString substringWithRange:[match rangeAtIndex:1]] lowercaseString];
                method = [[aMethodCallString substringWithRange:[match rangeAtIndex:2]] lowercaseString];
                parameters = [[aMethodCallString substringWithRange:[match rangeAtIndex:3]] componentsSeparatedByString:@","];
            }

            if ([type isEqualToString:@"color"]) {
                if ([method isEqualToString:@"alpha"]) {
                    NSString *colorToAddAlphaTo = [parameters[0] __trim__];
                    if ([colorToAddAlphaTo hasPrefix:@"@"]) {
                        colorToAddAlphaTo = [self findAliasedStyleValue:[colorToAddAlphaTo substringFromIndex:1]];
                    }

                    UIColor *color = [self parseColor:colorToAddAlphaTo];
                    float alpha = [[parameters[1] __trim__] floatValue];
                    color = [color colorWithAlphaComponent:alpha];
                    result = color;
                } else if ([method isEqualToString:@"mix"]) {
                    NSString *color1 = [parameters[0] __trim__];
                    if ([color1 hasPrefix:@"@"]) {
                        color1 = [self findAliasedStyleValue:[color1 substringFromIndex:1]];
                    }

                    NSString *color2 = [parameters[1] __trim__];
                    if ([color2 hasPrefix:@"@"]) {
                        color2 = [self findAliasedStyleValue:[color2 substringFromIndex:1]];
                    }

                    CGFloat part = 0.5;
                    if ([parameters count] > 2) {
                        part = [parameters[2] floatValue];
                    }

                    UIColor *color = [[self parseColor:color1] __mixWith__:[self parseColor:color2] withStrength:part];
                    result = color;
                } else {
                    NSString *color = [parameters[0] __trim__];
                    if ([color hasPrefix:@"@"]) {
                        color = [self findAliasedStyleValue:[color substringFromIndex:1]];
                    }

                    result = [UIColor __colorFromHex__:color];
                }
            }
        }

        return result;
    }

    - (NSDictionary *)mergeDictionary:(NSDictionary *)aDictionary1 with:(NSDictionary *)aDictionary2 {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:aDictionary1];

        for (NSString *key in aDictionary2) {
            if ([result[key] isKindOfClass:[NSDictionary class]] && [aDictionary2[key] isKindOfClass:[NSDictionary class]]) {
                result[key] = [self mergeDictionary:result[key] with:aDictionary2[key]];
            } else {
                result[key] = aDictionary2[key];
            }
        }

        return [result copy];
    }

    - (void)initEnums {
        _enums = [@{
                @"UIViewContentMode"    : @{
                        @"UIViewContentModeScaleToFill"     : @(UIViewContentModeScaleToFill),
                        @"UIViewContentModeScaleAspectFit"  : @(UIViewContentModeScaleAspectFit),
                        @"UIViewContentModeScaleAspectFill" : @(UIViewContentModeScaleAspectFill),
                        @"UIViewContentModeRedraw"          : @(UIViewContentModeRedraw),
                        @"UIViewContentModeCenter"          : @(UIViewContentModeCenter),
                        @"UIViewContentModeTop"             : @(UIViewContentModeTop),
                        @"UIViewContentModeBottom"          : @(UIViewContentModeBottom),
                        @"UIViewContentModeLeft"            : @(UIViewContentModeLeft),
                        @"UIViewContentModeRight"           : @(UIViewContentModeRight),
                        @"UIViewContentModeTopLeft"         : @(UIViewContentModeTopLeft),
                        @"UIViewContentModeTopRight"        : @(UIViewContentModeTopRight),
                        @"UIViewContentModeBottomLeft"      : @(UIViewContentModeBottomLeft),
                        @"UIViewContentModeBottomRight"     : @(UIViewContentModeBottomRight)
                },
                @"NSTextAlignment"      : @{
                        @"NSTextAlignmentLeft"      : @(NSTextAlignmentLeft),
                        @"NSTextAlignmentCenter"    : @(NSTextAlignmentCenter),
                        @"NSTextAlignmentRight"     : @(NSTextAlignmentRight),
                        @"NSTextAlignmentJustified" : @(NSTextAlignmentJustified),
                        @"NSTextAlignmentNatural"   : @(NSTextAlignmentNatural)
                },
                @"NSLineBreakMode"      : @{
                        @"NSLineBreakByWordWrapping"     : @(NSLineBreakByWordWrapping),
                        @"NSLineBreakByCharWrapping"     : @(NSLineBreakByCharWrapping),
                        @"NSLineBreakByClipping"         : @(NSLineBreakByClipping),
                        @"NSLineBreakByTruncatingHead"   : @(NSLineBreakByTruncatingHead),
                        @"NSLineBreakByTruncatingTail"   : @(NSLineBreakByTruncatingTail),
                        @"NSLineBreakByTruncatingMiddle" : @(NSLineBreakByTruncatingMiddle)
                },
                @"UIBaselineAdjustment" : @{
                        @"UIBaselineAdjustmentAlignBaselines" : @(UIBaselineAdjustmentAlignBaselines),
                        @"UIBaselineAdjustmentAlignCenters"   : @(UIBaselineAdjustmentAlignCenters),
                        @"UIBaselineAdjustmentNone"           : @(UIBaselineAdjustmentNone)
                },
                @"UIButtonType"         : @{
                        @"UIButtonTypeCustom"           : @(UIButtonTypeCustom),
                        @"UIButtonTypeRoundedRect"      : @(UIButtonTypeRoundedRect),
                        @"UIButtonTypeDetailDisclosure" : @(UIButtonTypeDetailDisclosure),
                        @"UIButtonTypeInfoLight"        : @(UIButtonTypeInfoLight),
                        @"UIButtonTypeInfoDark"         : @(UIButtonTypeInfoDark),
                        @"UIButtonTypeContactAdd"       : @(UIButtonTypeContactAdd)
                },
                @"UIControlState"       : @{
                        @"UIControlStateNormal"      : @(UIControlStateNormal),
                        @"UIControlStateHighlighted" : @(UIControlStateHighlighted),
                        @"UIControlStateDisabled"    : @(UIControlStateDisabled),
                        @"UIControlStateSelected"    : @(UIControlStateSelected),
                        @"UIControlStateApplication" : @(UIControlStateApplication),
                        @"UIControlStateReserved"    : @(UIControlStateReserved)
                }
        } mutableCopy];
    }

    - (void)addEnumWithName:(NSString *)aEnumName data:(NSDictionary *)aEnumData {
        [_enums setObject:aEnumData forKey:aEnumName];
    }

    - (NSNumber *)valueForEnumValueName:(NSString *)aValueName {
        for (NSString *enumType in _enums) {
            NSDictionary *enumValues = _enums[enumType];
            for (NSString *enumValueName in enumValues) {
                if ([enumValueName isEqualToString:aValueName]) {
                    return enumValues[enumValueName];
                }
            }
        }

        return nil;
    }

    - (NSString *)enumNameForValue:(NSString *)aValueName {
        for (NSString *enumType in _enums) {
            NSDictionary *enumValues = _enums[enumType];
            for (NSString *enumValueName in enumValues) {
                if ([enumValueName isEqualToString:aValueName]) {
                    return enumType;
                }
            }
        }

        return nil;
    }

    - (void)applyStyle:(NSString *)aStyleName to:(NSObject *)aObject notAListener:(BOOL)notAListener {
        BOOL needAddListener = !notAListener;

        if (_stylesObject != nil && [aStyleName length] != 0 && [aObject isKindOfClass:[ASStyleObject class]]) {
            id<ASStyleObjectApplyable> style = [_stylesObject valueForKeyPath:aStyleName];
            [style applyTo:(ASStyleObject *) aObject];
        } else {
            NSDictionary *style = ([aStyleName length] == 0 ? _styles : _styles[aStyleName]);

            if (style == nil && [aStyleName rangeOfString:@"."].location != NSNotFound) {
                NSArray *styleParts = [aStyleName componentsSeparatedByString:@"."];
                style = _styles;
                for (NSString *part in styleParts) {
                    style = style[part];
                }
            }

            if (style == nil) {
                DPL_ERROR(@"[%@] Can't find style \"%@\" to apply to an object \"%@\"", _name, aStyleName, aObject);
                needAddListener = NO;
            } else {
                [self applyStyle:style named:aStyleName toObject:aObject];
            }
        }

        if (needAddListener) {
            [_styledObjects addListener:aObject forStyle:aStyleName];
        }
    }

    - (void)applyStyle:(NSDictionary *)aStyle named:(NSString *)aStyleName toObject:(NSObject *)aObject {
        for (NSString *propertyName in aStyle) {
            NSObject *objectToUpdate = aObject;
            NSString *propertyNameToUseInKVO = propertyName;

            id propertyObject = aStyle[propertyName];

            if ([propertyNameToUseInKVO hasPrefix:@"//"]) {
                continue;
            }

            if ([propertyNameToUseInKVO rangeOfString:@"("].location != NSNotFound) {
                // установка параметров кнопок, set###:forState:###

                NSString *state = [[propertyNameToUseInKVO __substringFromString__:@"("] __substringToString__:@")"];
                NSString *property = [propertyNameToUseInKVO __substringToString__:@"("];

                NSString *firstLetter = [[property substringToIndex:1] uppercaseString];
                NSString *otherLetters = [[property substringFromIndex:1] lowercaseString];

                NSString *selectorString = [NSString stringWithFormat:@"set%@%@:forState:", firstLetter, otherLetters];
                SEL selector = NSSelectorFromString(selectorString);

                if ([aObject respondsToSelector:selector]) {
                    id styleValue = aStyle[propertyName];
                    NSString *typeString = [ASStyler typeStringForProperty:propertyNameToUseInKVO inObject:objectToUpdate];
                    if (typeString != nil) {
                        id propertyValue = [self getRealValueForJSONValue:styleValue typeString:typeString];

                        NSNumber *enumValue = [self valueForEnumValueName:state];

                        NSMethodSignature *signature = [[aObject class] instanceMethodSignatureForSelector:selector];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                        [invocation setTarget:aObject];
                        [invocation setSelector:selector];
                        [invocation setArgument:&propertyValue atIndex:2];
                        [invocation setArgument:&enumValue atIndex:3];
                        [invocation invoke];
                    }
                }
            } else {
                if ([propertyNameToUseInKVO rangeOfString:@"."].location != NSNotFound) {
                    NSArray *keyComponents = [propertyNameToUseInKVO componentsSeparatedByString:@"."];
                    for (NSString *keyComponent in keyComponents) {
                        if (![keyComponent isEqualToString:[keyComponents lastObject]]) {
                            objectToUpdate = [objectToUpdate valueForKey:keyComponent];
                        }

                        propertyNameToUseInKVO = keyComponent;
                    }
                }

                id styleValue = aStyle[propertyName];
                NSString *typeString = [ASStyler typeStringForProperty:propertyNameToUseInKVO inObject:objectToUpdate];
                if (typeString != nil) {
                    id propertyValue = [self getRealValueForJSONValue:styleValue typeString:typeString];

                    if (propertyValue != nil) {
                        [objectToUpdate setValue:propertyValue forKeyPath:propertyNameToUseInKVO];
                    } else {
                        if ([[propertyObject class] isSubclassOfClass:[NSDictionary class]]) {
                            if ([typeString length] < 2) {
                                DPL_EXCEPTION(@"[%@] Something wrong with styler type %@ (%@)", _name, aStyleName, propertyNameToUseInKVO);
                            }

                            id nextObjectInHierarchy = [[NSClassFromString(
                                    [[[typeString substringFromIndex:1] substringFromIndex:1] __substringToString__:@"\""]) alloc] init];
                            [aObject setValue:nextObjectInHierarchy forKey:propertyNameToUseInKVO];

                            ASStyler *styler = [[ASStyler alloc] init];
                            styler->_enums = _enums;
                            styler->_styles = @{
                                    @"__style__" : propertyObject
                            };

                            [styler applyStyle:@"__style__" to:nextObjectInHierarchy notAListener:NO];
                        } else {
                            DPL_ERROR(@"[%@] Don't know how to apply style \"%@\" to \"%@\"", _name, propertyNameToUseInKVO, aObject);
                        }
                    }
                }
            }
        }
    }

    - (id)getRealValueForJSONValue:(id)aStyleValue typeString:(NSString *)aTypeString {
        Class propertyClass = [ASStyler classForPropertyTypeString:aTypeString];

        if ([aStyleValue isKindOfClass:[NSString class]] && ([aStyleValue hasPrefix:@"@"] || [aStyleValue hasPrefix:@"~"])) {
            aStyleValue = [self getAliasedStyleValueOrMethodCallResult:aStyleValue];
        }

        id propertyValue = nil;

        if (propertyClass == nil) {
            if ([ASStyler isPropertyTypeStringCGPoint:aTypeString]) {
                NSArray *components = aStyleValue;
                propertyValue = [NSValue valueWithCGPoint:CGPointMake([components[0] floatValue], [components[1] floatValue])];
            } else if ([ASStyler isPropertyTypeStringCGSize:aTypeString]) {
                NSArray *components = aStyleValue;
                propertyValue = [NSValue valueWithCGSize:CGSizeMake([components[0] floatValue], [components[1] floatValue])];
            } else if ([ASStyler isPropertyTypeStringCGRect:aTypeString]) {
                NSArray *components = aStyleValue;
                propertyValue = [NSValue valueWithCGRect:CGRectMake(
                        [components[0] floatValue], [components[1] floatValue],
                        [components[2] floatValue], [components[3] floatValue])];
            } else if ([ASStyler isPropertyTypeStringUIEdgeInsets:aTypeString]) {
                NSArray *components = aStyleValue;
                propertyValue = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(
                        [components[0] floatValue], [components[1] floatValue],
                        [components[2] floatValue], [components[3] floatValue])];
            } else if ([aStyleValue isKindOfClass:[NSString class]]) {
                propertyValue = [self valueForEnumValueName:aStyleValue];
            } else if ([aStyleValue isKindOfClass:[NSNumber class]]) {
                propertyValue = aStyleValue;
            }
        } else {
            if (propertyClass == [UIColor class]) {
                propertyValue = [self parseColor:aStyleValue];
            } else if (propertyClass == [UIFont class]) {
                propertyValue = [self parseFont:aStyleValue];
            } else if (propertyClass == [ASStylerTextAttributes class]) {
                propertyValue = [self parseStringAttributes:aStyleValue];
            } else if (propertyClass == [UIImage class]) {
                propertyValue = [self parseImage:aStyleValue];
            } else if (propertyClass == [NSString class]) {
                propertyValue = aStyleValue;
            } else {
                // general object
                if ([aStyleValue isKindOfClass:[NSDictionary class]]) {
                    propertyValue = [[propertyClass alloc] init];
                    [self applyStyle:aStyleValue named:[NSString stringWithFormat:@"(Class %@)", NSStringFromClass(propertyClass)]
                            toObject:propertyValue];
                } else {
                    DPL_ERROR(@"[%@] Can't extract Object (must be dictionary) from value \"%@\"", _name, aStyleValue);
                }
            }
        }
        return propertyValue;
    }

    - (id)parseColor:(id)aStyleValue {
        if ([aStyleValue isKindOfClass:[UIColor class]]) {
            return aStyleValue;
        }

        id propertyValue;
        if ([aStyleValue hasPrefix:@"#"]) {
            propertyValue = [UIColor __colorFromHex__:[self getValueFor:aStyleValue]];
        } else {
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Color", [self getValueFor:aStyleValue]]);
            if ([UIColor respondsToSelector:selector]) {
                propertyValue = [UIColor performSelector:selector];
            } else {
                propertyValue = [UIColor blackColor];
            }
        }
        return propertyValue;
    }

    - (id)parseImage:(id)aStyleValue {
        if ([aStyleValue isKindOfClass:[UIImage class]]) {
            return aStyleValue;
        }

        id propertyValue;
        NSURL *imageFileURL = [self getFileURLForFile:aStyleValue];
        NSData *imageData = [NSData dataWithContentsOfURL:imageFileURL];
        propertyValue = [UIImage imageWithData:imageData];
        return propertyValue;
    }

    - (UIFont *)parseFont:(id)aStyleValue {
        if ([aStyleValue isKindOfClass:[UIFont class]]) {
            return aStyleValue;
        }

        NSDictionary *fontParameters = aStyleValue;

        if (![fontParameters isKindOfClass:[NSDictionary class]]) {
            DPL_EXCEPTION(@"[%@] Parameter '%@' must be an object for it to be a font", _name, aStyleValue);
        }

        NSString *fontName = [self getValueFor:fontParameters[@"name"]];
        CGFloat fontSize = [[self getValueFor:fontParameters[@"size"]] floatValue];
        BOOL isBold = [[self getValueFor:fontParameters[@"bold"]] boolValue];
        BOOL isItalic = [[self getValueFor:fontParameters[@"italic"]] boolValue];

        UIFont *font = nil;

        if ([fontName isEqualToString:@"system"] || [fontName isEqualToString:@"standard"]) {
            if (isBold && !isItalic) {
                font = [UIFont boldSystemFontOfSize:fontSize];
            } else if (!isBold && isItalic) {
                font = [UIFont italicSystemFontOfSize:fontSize];
            } else if (!isBold && !isItalic) {
                font = [UIFont systemFontOfSize:fontSize];
            }
        } else {
            NSString *fontNameToCheck = nil;

            if (isBold && isItalic) {
                fontNameToCheck = [fontName __contains__:@"-"] ? [NSString stringWithFormat:@"%@BoldItalic", fontName] : [NSString stringWithFormat:@"%@-BoldItalic", fontName];
                font = [UIFont fontWithName:fontNameToCheck size:fontSize];

                if (font == nil) {
                    fontNameToCheck = [fontName __contains__:@"-"] ? [NSString stringWithFormat:@"%@BoldItalicMT", fontName] : [NSString stringWithFormat:@"%@-BoldItalicMT", fontName];
                    font = [UIFont fontWithName:fontNameToCheck size:fontSize];
                }

                if (font == nil) {
                    fontNameToCheck = [fontName __contains__:@"-"] ? [NSString stringWithFormat:@"%@BoldOblique", fontName] : [NSString stringWithFormat:@"%@-BoldOblique", fontName];
                    font = [UIFont fontWithName:fontNameToCheck size:fontSize];
                }
            } else if (isBold) {
                fontNameToCheck = [NSString stringWithFormat:@"%@-Bold", fontName];
                font = [UIFont fontWithName:fontNameToCheck size:fontSize];
            } else if (isItalic) {
                fontNameToCheck = [NSString stringWithFormat:@"%@-Italic", fontName];
                font = [UIFont fontWithName:fontNameToCheck size:fontSize];

                if (font == nil) {
                    fontNameToCheck = [NSString stringWithFormat:@"%@-ItalicMT", fontName];
                    font = [UIFont fontWithName:fontNameToCheck size:fontSize];
                }

                if (font == nil) {
                    fontNameToCheck = [NSString stringWithFormat:@"%@-Oblique", fontName];
                    font = [UIFont fontWithName:fontNameToCheck size:fontSize];
                }
            }

            if (font == nil) {
                font = [UIFont fontWithName:fontName size:fontSize];
                if (font == nil && [fontName isEqualToString:@"HelveticaNeue-Italic"]) {
                    if (([UIFontDescriptor class] != nil)) {
                        font = (__bridge_transfer UIFont *) CTFontCreateWithName(CFSTR("HelveticaNeue-Italic"), fontSize, NULL);
                    }
                }
            }
        }
        return font;
    }

    - (ASStylerTextAttributes *)parseStringAttributes:(id)aStyleValue {
        ASStylerTextAttributes *result = nil;
        if ([aStyleValue isKindOfClass:[ASStylerTextAttributes class]]) {
            result = aStyleValue;
        } else if ([aStyleValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *styleDictionary = aStyleValue;

            UIFont *font = nil;

            result = [[ASStylerTextAttributes alloc] init];
            if (styleDictionary[@"font"] != nil) {
                font = [self parseFont:styleDictionary[@"font"]];
                result.font = font;
            }
            if (styleDictionary[@"color"] != nil) {
                result.foregroundColor = [self parseColor:styleDictionary[@"color"]];
            }
            if (styleDictionary[@"foregroundColor"] != nil) {
                result.foregroundColor = [self parseColor:styleDictionary[@"foregroundColor"]];
            }
            if (styleDictionary[@"backgroundColor"] != nil) {
                result.backgroundColor = [self parseColor:styleDictionary[@"backgroundColor"]];
            }
            if (styleDictionary[@"lineHeight"] != nil && font != nil) {
                CGFloat lineHeight = [styleDictionary[@"lineHeight"] floatValue];
                result.lineHeightMultiple = lineHeight/font.pointSize;
            }
            if (styleDictionary[@"superscript"] != nil) {
                result.superscript = [styleDictionary[@"superscript"] floatValue];
            }
            if (styleDictionary[@"alignment"] != nil) {
                result.alignment = (NSTextAlignment) [[self valueForEnumValueName:styleDictionary[@"alignment"]] intValue];
            }
            if (styleDictionary[@"textAlignment"] != nil) {
                result.alignment = (NSTextAlignment) [[self valueForEnumValueName:styleDictionary[@"textAlignment"]] intValue];
            }
            if (styleDictionary[@"lineBreakMode"] != nil) {
                result.lineBreakMode = (NSLineBreakMode) [[self valueForEnumValueName:styleDictionary[@"lineBreakMode"]] intValue];
            }
            if (styleDictionary[@"firstTab"] != nil) {
                if (__DPL_OSVersionMajor__() >= 7) {
                    result.tabStops = @[[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:[styleDictionary[@"firstTab"] floatValue] options:nil]];
                }
            }
            if (styleDictionary[@"indent"] != nil) {
                result.headIndent = [styleDictionary[@"indent"] floatValue];
            }
        }

        return result;
    }

    - (NSString *)getValueFor:(id)aValueOrAlias {
        if ([aValueOrAlias isKindOfClass:[NSString class]] && ([aValueOrAlias hasPrefix:@"@"] || [aValueOrAlias hasPrefix:@"~"])) {
            return [self getAliasedStyleValueOrMethodCallResult:aValueOrAlias];
        } else {
            return aValueOrAlias;
        }
    }

    - (id)getAliasedStyleValueOrMethodCallResult:(NSString *)aValue {
        if ([aValue isKindOfClass:[NSString class]]) {
            if ([aValue hasPrefix:@"@"]) {
                return [self getAliasedStyleValueOrMethodCallResult:[self findAliasedStyleValue:[aValue substringFromIndex:1]]];
            } else if ([aValue hasPrefix:@"~"]) {
                if ([aValue hasPrefix:@"~~"]) {
                    return [aValue substringFromIndex:1];
                } else {
                    return [self getAliasedStyleValueOrMethodCallResult:[self getResultOfAMethodCall:aValue]];
                }
            }
        }

        return aValue;
    }

    - (id)findAliasedStyleValue:(NSString *)aAliasName {
        id result = [_cachedStylesForExpanding objectForKey:aAliasName];
        if (result != nil) {
            return result;
        } else {
            NSDictionary *style = _styles;

            NSArray *styleParts = [aAliasName componentsSeparatedByString:@"."];
            int index = 0;
            for (NSString *part in styleParts) {
                if (result != nil) {
                    DPL_ERROR(@"[%@] Can't file value for an alias %@", _name, aAliasName);
                }

                if (index != [styleParts count] - 1) {
                    style = style[part];
                } else {
                    result = style[part];
                }

                index++;
            }

            if ([result isKindOfClass:[NSString class]] && ([result hasPrefix:@"@"] || [result hasPrefix:@"~"])) {
                result = [self getAliasedStyleValueOrMethodCallResult:result];
            }

            if (result == nil) {
                DPL_ERROR(@"[%@] Can't file value for an alias %@", _name, aAliasName);
            } else {
                [_cachedStylesForExpanding setObject:result forKey:aAliasName];
            }
        }

        return result;
    }

    - (id)styleValueForKey:(NSString *)aKey {
        if (_stylesObject != nil) {
            return [_stylesObject valueForKeyPath:aKey];
        } else {
            return [self findAliasedStyleValue:aKey];
        }
    }

#pragma mark -
#pragma mark Generating style classes by JSON

    - (void)generateStyleClassesForClassPrefix:(NSString *)aClassPrefix savePath:(NSString *)aSaveStyleClassesTo needEnumImport:(BOOL)isEnumImportNeeded {
        NSMutableDictionary *resultedClasses = [NSMutableDictionary dictionary];

        ASStyler *styler = [[ASStyler alloc] init];
        styler->_name = @"Generator";
        styler->_styles = [NSMutableDictionary dictionaryWithDictionary:_styles];
        styler->_enums = [NSMutableDictionary dictionaryWithDictionary:_enums];
        styler->_loadedStyleURLs = [[NSMutableArray alloc] initWithArray:_loadedStyleURLs];

        NSMutableDictionary *classNameToStyleName = [NSMutableDictionary dictionary];

        NSString *newPrefix = [NSString stringWithFormat:@"%@", aClassPrefix];
        NSString *className = [NSString stringWithFormat:@"%@Style", aClassPrefix];
        resultedClasses[className] = [styler getClassPropertiesFor:styler->_styles classesPrefix:newPrefix];
        classNameToStyleName[className] = @"";

        NSDictionary *childClasses = [styler generateChildClassesForStyle:styler->_styles prefix:newPrefix classNameToStyleNames:classNameToStyleName styleNamePrefix:@""];
        [resultedClasses addEntriesFromDictionary:childClasses];

        [styler saveGeneratedClasses:resultedClasses classNameToStyleNames:classNameToStyleName to:aSaveStyleClassesTo needEnumImport:isEnumImportNeeded];
    }

    - (void)saveGeneratedClasses:(NSDictionary *)aGeneratedClassInfo classNameToStyleNames:(NSMutableDictionary *)aClassNameToStyleNames to:(NSString *)aPathToSaveTo needEnumImport:(BOOL)isEnumImportNeeded {
        NSArray *keys = [[aGeneratedClassInfo allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];

        NSString *fileName = @"ProjectStyles";

        NSMutableString *hFile = [NSMutableString stringWithString:@""
                "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
                "// This file was autogenerated. Please do not fix it manually\n"
                "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
                "\n"
//                "#import \"ASStyler.h\"\n"
                "\n"
                "#pragma clang diagnostic push\n"
                "#pragma ide diagnostic ignored \"OCUnusedPropertyInspection\"\n"
                "#pragma ide diagnostic ignored \"OCUnusedClassInspection\"\n"
                "||||"
                "\n"
                "############\n"
                "\n"];

        if (isEnumImportNeeded) {
            [hFile replaceOccurrencesOfString:@"||||" withString:@"#import \"ProjectEnums.h\"\n"
                                      options:0 range:NSMakeRange(0, [hFile length])];
        } else {
            [hFile replaceOccurrencesOfString:@"||||" withString:@"#import \"ASStyleObject.h\"\n"
                                      options:0 range:NSMakeRange(0, [hFile length])];
        }

        NSMutableString *classDefinitions = [NSMutableString stringWithString:@"@class ASStylerTextAttributes;\n"];

        NSMutableString *mFile = [NSMutableString
                stringWithFormat:@""
                                         "#pragma clang diagnostic push\n"
                                         "#pragma ide diagnostic ignored \"UnusedImportStatement\"\n"
                                         "#pragma ide diagnostic ignored \"UnavailableInDeploymentTarget\"\n"
                                         "\n"
                                         "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
                                         "// This file was autogenerated. Please do not fix it manually\n"
                                         "// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
                                         "\n"
                                         "#import \"%@.h\"\n"
                                         "#import \"ASStylerHelpers.h\"\n"
                                         "#import \"ASStylerTextAttributes.h\"\n"
                                         "\n", fileName];

        for (NSString *className in keys) {
            NSString *classNameNoAsteriks = [className stringByReplacingOccurrencesOfString:@" *" withString:@""];
            NSArray *properties = aGeneratedClassInfo[className];

            [classDefinitions appendFormat:@"@class %@;\n", classNameNoAsteriks];
            [hFile appendFormat:@"@interface %@ : ASStyleObject <NSCoding, ASStyleObjectApplyable>\n", classNameNoAsteriks];
            [hFile appendFormat:@"    - (id)initWithReloadedCallback:(void (^)())aCallback;\n\n"];
            for (ASStylerGeneratedClass *property in properties) {
                [hFile appendFormat:@"    @property (nonatomic) %@%@;\n", property.type,
                                    [property.name stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
            }
            [hFile appendString:@"@end\n\n"];

            NSString *styleName = aClassNameToStyleNames[className];
            NSObject *codingMethods = [self prepareCodingMethodsForClass:className styleName:styleName properties:properties];
            [mFile appendFormat:@"@implementation %@\n%@\n@end\n\n\n", classNameNoAsteriks, codingMethods];
        }

        NSError *error = nil;
        [hFile replaceOccurrencesOfString:@"############" withString:classDefinitions options:0 range:NSMakeRange(0, [hFile length])];
        [hFile appendString:@""
                "\n"
                "#pragma clang diagnostic pop\n"
                "\n"];

        NSString *hPath = [aPathToSaveTo stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", fileName]];
        [hFile writeToFile:hPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DPL_ERROR(@"Error during writing autogenerated file: %@ (%@)", hPath, error);
        }

        error = nil;
        NSString *mPath = [aPathToSaveTo stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", fileName]];
        [mFile writeToFile:mPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DPL_ERROR(@"Error during writing autogenerated file: %@ (%@)", mPath, error);
        }
    }

    - (NSObject *)prepareCodingMethodsForClass:(NSString *)aClassName styleName:(NSString *)aStyleName properties:(NSArray *)aProperties {
        NSMutableString *encoder = [NSMutableString string];
        NSMutableString *apply = [NSMutableString string];
        NSMutableString *init = [NSMutableString stringWithFormat:@""
                "        if (self) {\n"];
        NSMutableString *decoder = [NSMutableString stringWithFormat:@""
                "        self = [super init];\n"
                "        if (self) {\n"];

        for (ASStylerGeneratedClass *property in aProperties) {
            BOOL isEnum = [[_enums allKeys] containsObject:[property.type __trim__]];
//            BOOL applyViaEquals = YES;

            if ([property.type hasPrefix:@"CGFloat"]) {
                [encoder appendFormat:@"        [coder encodeDouble:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = (CGFloat) [coder decodeDoubleForKey:@\"%@\"];\n", property.name, property.name];
            } else if (isEnum || [property.type hasPrefix:@"NSInteger"]) {
                [encoder appendFormat:@"        [coder encodeInteger:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = (%@) [coder decodeIntegerForKey:@\"%@\"];\n", property.name, [property.type __trim__], property.name];
            } else if ([property.type hasPrefix:@"BOOL"]) {
                [encoder appendFormat:@"        [coder encodeBool:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = [coder decodeBoolForKey:@\"%@\"];\n", property.name, property.name];
            } else if ([property.type hasPrefix:@"UIEdgeInsets"]) {
                [encoder appendFormat:@"        [coder encodeUIEdgeInsets:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = [coder decodeUIEdgeInsetsForKey:@\"%@\"];\n", property.name, property.name];
            } else if ([property.type hasPrefix:@"CGPoint"]) {
                [encoder appendFormat:@"        [coder encodeCGPoint:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = [coder decodeCGPointForKey:@\"%@\"];\n", property.name, property.name];
            } else if ([property.type hasPrefix:@"CGRect"]) {
                [encoder appendFormat:@"        [coder encodeCGRect:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = [coder decodeCGRectForKey:@\"%@\"];\n", property.name, property.name];
            } else if ([property.type hasPrefix:@"CGSize"]) {
                [encoder appendFormat:@"        [coder encodeCGSize:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = [coder decodeCGSizeForKey:@\"%@\"];\n", property.name, property.name];
            } else if ([property.type hasPrefix:@"UIColor"]) {
                [encoder appendFormat:@"        [coder encodeObject:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = [coder decodeObjectForKey:@\"%@\"];\n", property.name, property.name];
                [init appendFormat:@"            _%@ = [UIColor cyanColor];\n", property.name];
            } else if ([property.type hasPrefix:@"UIFont"]) {
                [encoder appendFormat:@"        if (__DPL_OSVersionMajor__() >= 7) {\n"];
                [encoder appendFormat:@"            [coder encodeObject:[_%@ fontDescriptor] forKey:@\"%@\"];\n", property.name, property.name];
                [encoder appendFormat:@"        }\n"];
                [encoder appendFormat:@"        [coder encodeObject:[_%@ fontName] forKey:@\"%@.name\"];\n", property.name, property.name];
                [encoder appendFormat:@"        [coder encodeFloat:[_%@ pointSize] forKey:@\"%@.size\"];\n", property.name, property.name];

                [decoder appendFormat:@"            CGFloat _%@_size = [coder decodeFloatForKey:@\"%@.size\"];\n", property.name, property.name];
                [decoder appendFormat:@"            if (__DPL_OSVersionMajor__() >= 7) {\n"];
                [decoder appendFormat:@"                id _%@_descriptor = [coder decodeObjectForKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"                if (_%@_descriptor != nil) {\n", property.name];
                [decoder appendFormat:@"                    _%@ = [UIFont fontWithDescriptor:_%@_descriptor size:_%@_size];\n", property.name, property.name, property.name];
                [decoder appendFormat:@"                } else {\n"];
                [decoder appendFormat:@"                    _%@ = [UIFont fontWithName:[coder decodeObjectForKey:@\"%@.name\"] size:_%@_size];\n", property.name, property.name,
                                      property.name];
                [decoder appendFormat:@"                }\n"];
                [decoder appendFormat:@"            } else {\n"];
                [decoder appendFormat:@"                _%@ = [UIFont fontWithName:[coder decodeObjectForKey:@\"%@.name\"] size:_%@_size];\n", property.name, property.name,
                                      property.name];
                [decoder appendFormat:@"            }\n"];

                [init appendFormat:@"            _%@ = [UIFont systemFontOfSize:16];\n", property.name];
            } else {
                [encoder appendFormat:@"        [coder encodeObject:_%@ forKey:@\"%@\"];\n", property.name, property.name];
                [decoder appendFormat:@"            _%@ = [coder decodeObjectForKey:@\"%@\"];\n", property.name, property.name];
                [init appendFormat:@"            _%@ = [[%@ alloc] init];\n",
                                   property.name, [[property.type stringByReplacingOccurrencesOfString:@"*" withString:@""] __trim__]];

//                applyViaEquals = NO;
            }

//            if (applyViaEquals) {
            [apply appendFormat:@"        ((%@ *) aAnotherObject).%@ = _%@;\n",
                                [[aClassName stringByReplacingOccurrencesOfString:@"*" withString:@""] __trim__], property.name, property.name];
//            } else {
//                [encoder appendFormat:@"        [_%@ applyTo:aAnotherObject->_%@];\n", property.name, property.name];
//            }
        }

        NSMutableString *initCallback = [NSMutableString stringWithString:init];

        [init appendString:@""
                "        }\n"
                "        return self;"];

        [initCallback appendFormat:@""
                "            [self applyStyle:@\"%@\" withCallback:aCallback];\n"
                "        }\n"
                "        return self;", aStyleName];

        [decoder appendString:@""
                "        }\n"
                "        return self;"];

        return [NSString stringWithFormat:@""
                                                  "    - (id)init {\n"
                                                  "        self = [super init];\n"
                                                  "%@\n"
                                                  "    }\n"
                                                  "\n"
                                                  "    - (id)initWithReloadedCallback:(void (^)())aCallback {\n"
                                                  "        self = [super init];\n"
                                                  "%@\n"
                                                  "    }\n"
                                                  "\n"
                                                  "    - (void)applyTo:(ASStyleObject *)aAnotherObject {\n"
                                                  "%@"
                                                  "    }\n"
                                                  "\n"
                                                  "    - (void)encodeWithCoder:(NSCoder *)coder {\n"
                                                  "%@"
                                                  "    }\n"
                                                  "\n"
                                                  "    - (id)initWithCoder:(NSCoder *)coder {\n"
                                                  "%@\n"
                                                  "    }",
                                          init,
                                          initCallback,
                                          apply,
                                          encoder,
                                          decoder];
    }

    - (NSArray *)getClassPropertiesFor:(NSDictionary *)aStyle classesPrefix:(NSString *)aPrefix {
        NSMutableArray *result = [NSMutableArray array];

        for (NSString *propertyName in aStyle) {
            if (![propertyName hasPrefix:@"@"] && ![propertyName hasPrefix:@"//"] && ![propertyName hasPrefix:@"#"]) {
                id value = aStyle[propertyName];
                NSString *type = [self detectValueTypeByName:propertyName andValue:value classesPrefix:aPrefix];
                NSString *name = [self getNameFromPropertyName:propertyName];
                [result addObject:[[ASStylerGeneratedClass alloc] initWithName:name type:type styleName:propertyName]];
            }
        }

        [result sortUsingComparator:^NSComparisonResult(ASStylerGeneratedClass *info1, ASStylerGeneratedClass *info2) {
            NSComparisonResult comparisonResult = [info1.type compare:info2.type];
            if (comparisonResult == NSOrderedSame) {
                comparisonResult = [info1.name compare:info2.name];
            }

            return comparisonResult;
        }];

        return [result copy];
    }

    - (NSString *)getNameFromPropertyName:(NSString *)name {
        return name;
    }

    - (NSString *)detectValueTypeByName:(NSString *)name andValue:(id)value classesPrefix:(NSString *)aPrefix {
        if ([value isKindOfClass:[NSString class]] && ([value hasPrefix:@"@"] || [value hasPrefix:@"~"])) {
            value = [self getAliasedStyleValueOrMethodCallResult:value];
        }

        NSString *result = nil;

        NSString *lowercasedName = [name lowercaseString];

        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *number = value;
            char const *cType = number.objCType;

            //ToDo: научиться таки различать целые и вещественные, булевы научились (считаем char именно ими)

            if (strcmp(cType, @encode(int)) == 0) {
                result = @"CGFloat"; // we do not have ints here
//                result = @"NSInteger";
            } else if (strcmp(cType, @encode(long)) == 0) {
                result = @"CGFloat"; // we do not have ints here
//                result = @"long";
            } else if (strcmp(cType, @encode(long long)) == 0) {
                result = @"CGFloat"; // we do not have ints here
//                result = @"long long";
            } else if (strcmp(cType, @encode(char)) == 0) {
                result = @"BOOL";
//                result = @"char";
            } else if (strcmp(cType, @encode(unsigned int)) == 0) {
                result = @"CGFloat"; // we do not have ints here
//                result = @"NSUInteger";
            } else if (strcmp(cType, @encode(unsigned long)) == 0) {
                result = @"CGFloat"; // we do not have ints here
//                result = @"unsigned long";
            } else if (strcmp(cType, @encode(unsigned long long)) == 0) {
                result = @"CGFloat"; // we do not have ints here
//                result = @"unsigned long long";
            } else if (strcmp(cType, @encode(unsigned char)) == 0) {
                result = @"CGFloat"; // we do not have ints here
//                result = @"unsigned char";
            } else if (strcmp(cType, @encode(float)) == 0) {
                result = @"CGFloat";
            } else if (strcmp(cType, @encode(double)) == 0) {
                result = @"CGFloat";
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            if ([lowercasedName hasSuffix:@"color"]) {
                result = @"UIColor *";
            } else if ([lowercasedName hasSuffix:@"image"]) {
                result = @"UIImage *";
            } else if ([self enumNameForValue:value] != nil) {
                result = [self enumNameForValue:value];
            } else {
                result = @"NSString *";
            }
        } else if ([value isKindOfClass:[UIColor class]]) {
            result = @"UIColor *";
        } else if ([value isKindOfClass:[UIImage class]]) {
            result = @"UIImage *";
        } else if ([value isKindOfClass:[UIFont class]]) {
            result = @"UIFont *";
        } else if ([value isKindOfClass:[ASStylerTextAttributes class]]) {
            result = @"ASStylerTextAttributes *";
        } else if ([value isKindOfClass:[NSArray class]]) {
            if ([lowercasedName hasSuffix:@"point"] || [lowercasedName hasSuffix:@"origin"] ||
                    [lowercasedName hasSuffix:@"location"] || [lowercasedName hasSuffix:@"position"] || [lowercasedName hasSuffix:@"center"]) {
                result = @"CGPoint";
            } else if ([lowercasedName hasSuffix:@"size"] || [lowercasedName hasSuffix:@"dimensions"]) {
                result = @"CGSize";
            } else if ([lowercasedName hasSuffix:@"rect"] || [lowercasedName hasSuffix:@"frame"] || [lowercasedName hasSuffix:@"bounds"]) {
                result = @"CGRect";
            } else if ([lowercasedName hasSuffix:@"margin"] || [lowercasedName hasSuffix:@"margins"] ||
                    [lowercasedName hasSuffix:@"padding"] || [lowercasedName hasSuffix:@"paddings"] || [name hasSuffix:@"border"]) {
                result = @"UIEdgeInsets";
            } else {
                result = @"NSArray *";
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            if ([lowercasedName hasSuffix:@"font"]) {
                result = @"UIFont *";
            } else if ([lowercasedName hasSuffix:@"textattributes"]) {
                result = @"ASStylerTextAttributes *";
            } else {
                result = [NSString stringWithFormat:@"%@%@Style *", aPrefix, [name __capitalizedFirstLetter__]];
            }
        }

        if (![result hasSuffix:@"*"]) {
            result = [NSString stringWithFormat:@"%@ ", result];
        }

        return result;
    }

    - (NSDictionary *)generateChildClassesForStyle:(NSDictionary *)aStyle prefix:(NSString *)aPrefix classNameToStyleNames:(NSMutableDictionary *)aClassNameToStyleNames styleNamePrefix:(NSString*)aStyleNamePrefix {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];

            for (NSString *propertyName in aStyle) {
                if (![propertyName hasPrefix:@"@"] && ![propertyName hasPrefix:@"//"] && ![propertyName hasPrefix:@"#"]) {
                    id value = aStyle[propertyName];
                    NSString *name = [self getNameFromPropertyName:propertyName];

                    if ([value isKindOfClass:[NSDictionary class]]) {
                        NSString *newStyleNamePrefix = [NSString stringWithFormat:@"%@%@", [aStyleNamePrefix length] == 0 ? @"" : [NSString stringWithFormat:@"%@.", aStyleNamePrefix], name];
                        NSString *newPrefix = [NSString stringWithFormat:@"%@%@", aPrefix, [name __capitalizedFirstLetter__]];

                        if (![[name lowercaseString] hasSuffix:@"font"]) {
                            NSString *className = [NSString stringWithFormat:@"%@Style *", newPrefix];
                            result[className] = [self getClassPropertiesFor:value classesPrefix:newPrefix];

                            aClassNameToStyleNames[className] = newStyleNamePrefix;
                        }

                        [result addEntriesFromDictionary:[self generateChildClassesForStyle:value prefix:newPrefix classNameToStyleNames:aClassNameToStyleNames styleNamePrefix:newStyleNamePrefix]];
                    }
                }
            }

            return result;
        }
@end

#pragma clang diagnostic pop
