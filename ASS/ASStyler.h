//
//  Created by alex on 05.07.13.
//


#import "ASStyleObject.h"
#import "ASStylerTextAttributes.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedClassInspection"
#pragma ide diagnostic ignored "OCUnusedMethodInspection"

@interface ASStyler : NSObject
    // Object that will contain all the styles. To use it, you first must add styles to the styler with addStylesFromURL:toClass:pathForSimulatorGeneratedCache: method
    @property (nonatomic, readonly) ASStyleObject *stylesObject;
    // Can be used before release. Removes attempts to load remote parts of the @include
    @property (nonatomic) BOOL disableRemoteIncludes;

    + (ASStyler *)sharedInstance;

    // You can add this enum and then use enum names in style rules. aEnumData can look like this:
    // [styler addEnumWithName:@"CONConfigAnimationType" data:@{
    //      @"linear"                        : @(ANGConfigAnimationTypeLinear),
    //      @"easeIn"                        : @(ANGConfigAnimationTypeEaseIn)
    //}];
    - (void)addEnumWithName:(NSString *)aEnumName data:(NSDictionary *)aEnumData;

    // Loads style from aStyleFileURL, parses it and stores to the instance of aClass.
    // If aSimulatorSavePath != nil, stores binary form of the styles to the "[aClass].styleCache.data" file in this directory.
    - (void)addStylesFromURL:(NSString *)aURL;
    - (void)addStylesFromURL:(NSString *)styleFileURL toClass:(Class)aClass;
    - (void)addStylesFromURL:(NSString *)aStyleFileURL toClass:(Class)aClass pathForSimulatorGeneratedCache:(NSString *)aSimulatorSavePath;

    // You can send this message to update all loaded styles
    - (void)updateStyleFromOriginalURLs;

    // Can be used for skins. Removes all loaded styles and reloads them from another URL
    - (void)reloadStylesFromURL:(NSString *)loadURL;

    // Generates ProjectStyles.h/.m files that contain Objective-C classes that are built from JSON.
    // isEnumImportNeeded includes "ProjectEnums.h" to these files (you must create it manually)
    - (void)generateStyleClassesForClassPrefix:(NSString *)aClassPrefix savePath:(NSString *)aSaveStyleClassesTo needEnumImport:(BOOL)isEnumImportNeeded;
@end


@interface NSObject(DPStyler)
    // obsolete method of applying styles
    - (void)applyDPStyle:(NSString *)aStyleName;
@end


#pragma clang diagnostic pop
