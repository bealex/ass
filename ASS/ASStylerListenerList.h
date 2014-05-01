//
//  Created by alex on 03.08.13.
//


#import <Foundation/Foundation.h>

@protocol ASStylerListener<NSObject>
    - (void)stylesWereReloaded;
@end

@interface ASStylerListenerListItem : NSObject
    @property (nonatomic, strong) id objectToUpdate;
    @property (nonatomic, copy) NSString *styleName;
@end

@interface ASStylerListenerListEnumeration : NSEnumerator
@end

@interface ASStylerListenerList : NSObject
    - (void)addListener:(id)aNewListener forStyle:(NSString *)aStyleName;
    - (void)reapplyAllStylesWithCallback:(void (^)(NSString *, id))aCallback;
@end
