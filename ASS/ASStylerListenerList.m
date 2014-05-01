//
//  Created by alex on 03.08.13.
//


#import "ASStylerListenerList.h"
#import "ASStyler.h"


@implementation ASStylerListenerListItem {
    @package
        ASStylerListenerListItem *_previousItem;
        ASStylerListenerListItem *_nextItem;
    }

    - (id)initWithObjectToUpdate:(__weak id)objectToUpdate styleName:(NSString *)styleName
                        nextItem:(ASStylerListenerListItem *)nextItem previousItem:(ASStylerListenerListItem *)previousItem {
        self = [super init];
        if (self) {
            self.objectToUpdate = objectToUpdate;
            self.styleName = styleName;

            _nextItem = nextItem;
            _previousItem = previousItem;
        }

        return self;
    }

    - (void)reapplyStyleWithCallback:(void (^)(NSString *, id))aCallback {
        if (_objectToUpdate != nil) {
            aCallback(_styleName, _objectToUpdate);

            if ([_objectToUpdate conformsToProtocol:@protocol(ASStylerListener)]) {
                [_objectToUpdate stylesWereReloaded];
            }
        }
    }
@end

@implementation ASStylerListenerListEnumeration {
        ASStylerListenerListItem *_currentItem;
        ASStylerListenerListItem *_firstItem;
    }

    - (id)initWithFirstItem:(ASStylerListenerListItem *)firstItem {
        self = [super init];
        if (self) {
            _firstItem = firstItem;
        }

        return self;
    }

    - (id)nextObject {
        if (_currentItem == nil) {
            _currentItem = _firstItem;
        } else {
            _currentItem = _currentItem->_nextItem;
        }

        // remove weak nilled references
        while (_currentItem.objectToUpdate == nil && _currentItem != nil) {
            _currentItem->_previousItem->_nextItem = _currentItem->_nextItem;
            _currentItem = _currentItem->_nextItem;
        }

        return _currentItem;
    }
@end

@implementation ASStylerListenerList {
        ASStylerListenerListItem *_firstItem;
        ASStylerListenerListItem *_lastItem;
    }

    - (void)addListener:(id)aNewListener forStyle:(NSString *)aStyleName {
        BOOL alreadyApplied = NO;

        NSEnumerator *enumerator = [self enumerator];
        ASStylerListenerListItem *currentItem = [enumerator nextObject];
        while (currentItem != nil) {
            if (currentItem.objectToUpdate == aNewListener && [currentItem.styleName isEqualToString:aStyleName]) {
                alreadyApplied = YES;
                break;
            }
            currentItem = [enumerator nextObject];
        }

        if (!alreadyApplied) {
            ASStylerListenerListItem *newItem = [[ASStylerListenerListItem alloc]
                    initWithObjectToUpdate:aNewListener styleName:aStyleName
                                  nextItem:nil previousItem:nil];

            if (_firstItem == nil) {
                _firstItem = newItem;
                _lastItem = _firstItem;
            } else {
                newItem->_previousItem = _lastItem;
                _lastItem->_nextItem = newItem;
                _lastItem = newItem;
            }
        }
    }

    - (void)reapplyAllStylesWithCallback:(void (^)(NSString *, id))aCallback {
        NSEnumerator *enumerator = [self enumerator];
        ASStylerListenerListItem *currentItem = [enumerator nextObject];
        while (currentItem != nil) {
            [currentItem reapplyStyleWithCallback:aCallback];
            currentItem = [enumerator nextObject];
        }
    }

    - (NSEnumerator *)enumerator {
        return [[ASStylerListenerListEnumeration alloc] initWithFirstItem:_firstItem];
    }
@end
