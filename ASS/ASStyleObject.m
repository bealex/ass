//
//  Created by alex on 07.01.14.
//


#import "ASStyleObject.h"
#import "ASStyler.h"


@implementation ASStyleObject {
        void(^_reloadCallback)();
    }

    - (instancetype)initWithStyle:(NSString *)aStyleName styleReloadedCallback:(void (^)())aCallback {
        self = [super init];
        if (self) {
            [self applyStyle:aStyleName withCallback:aCallback];
        }

        return self;
    }

    - (void)applyStyle:(NSString *)aStyleName withCallback:(void (^)())aCallback {
        [self applyDPStyle:aStyleName];
        _reloadCallback = [aCallback copy];
    }

    - (void)stylesWereReloaded {
        if (_reloadCallback != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _reloadCallback();
            });
        }
    }
@end
