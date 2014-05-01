//
//  Created by alex on 07.01.14.
//



#import "ASStylerListenerList.h"


@class ASStyleObject;

@protocol ASStyleObjectApplyable<NSObject>
    - (void)applyTo:(ASStyleObject *)aAnotherObject;
@end

@interface ASStyleObject : NSObject <ASStylerListener>
    - (instancetype)initWithStyle:(NSString*)aStyleName styleReloadedCallback:(void (^)())aCallback;
    - (void)applyStyle:(NSString *)aStyleName withCallback:(void (^)())aCallback;
@end
