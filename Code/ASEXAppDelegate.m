//
//  ASEXAppDelegate.m
//  ExampleProject
//
//  Created by Alexander Babaev on 01.05.14.
//  Copyright (c) 2014 LonelyBytes. All rights reserved.
//

#import "ASEXAppDelegate.h"
#import "ASStyler.h"
#import "ProjectStyles.h"


@implementation ASEXAppDelegate

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [self prepareStyler];

        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

        [self useStylerALittle];

        [self.window makeKeyAndVisible];
        return YES;
    }

    - (void)prepareStyler {
        ASStyler *styler = [ASStyler sharedInstance];

        // You will need to fix this path to where you've placed an example
        NSString *pathToSources = @"/Users/alex/Programming/2014/ASS/";

        // add styles. If you use simple file name, it will be taken from Application bundle. If you want it from somewhere else, use URL string.
        [styler addStylesFromURL:@"styles.json" toClass:[ASEXStyle class] pathForSimulatorGeneratedCache:[pathToSources stringByAppendingPathComponent:@"Resources/Styles"]];

#if TARGET_IPHONE_SIMULATOR
        // This line will regenerate ProjectStyles.h/.m. We want it to run only in simulator
        [styler generateStyleClassesForClassPrefix:@"ASEX" savePath:[pathToSources stringByAppendingPathComponent:@"Code/Styles"] needEnumImport:NO];
#endif
    }

    - (void)useStylerALittle {
        ASStyler *styler = [ASStyler sharedInstance];

        // This whole class was generated from JSON
        ASEXStyle *style = ((ASEXStyle *) styler.stylesObject);

        // use a value from JSON!
        self.window.backgroundColor = style.window.backgroundColor;

        UILabel *label = [[UILabel alloc] initWithFrame:self.window.bounds];
        label.attributedText = [[NSAttributedString alloc] initWithString:style.helloLabel.text attributes:style.helloLabelTextAttributes];

        [self.window addSubview:label];
    }

    - (void)applicationWillResignActive:(UIApplication *)application {
    }

    - (void)applicationDidEnterBackground:(UIApplication *)application {
    }

    - (void)applicationWillEnterForeground:(UIApplication *)application {
    }

    - (void)applicationDidBecomeActive:(UIApplication *)application {
    }

    - (void)applicationWillTerminate:(UIApplication *)application {
    }

@end
