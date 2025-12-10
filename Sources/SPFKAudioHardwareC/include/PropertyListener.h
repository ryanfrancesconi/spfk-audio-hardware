// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-audioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

#import <CoreAudio/AudioHardware.h>
#import <Foundation/Foundation.h>

#import "PropertyListenerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// objc bridging option with delegate
/// will likely delete this.
@interface PropertyListener : NSObject

@property (nonatomic) AudioObjectID inObjectID;
@property (nonatomic, readonly) BOOL isListening;
@property (nonatomic, nullable, weak) id<PropertyListenerDelegate> delegate;

typedef NS_ENUM(int, PropertyListenerErrorCode) {
    AlreadyListening = 0,
    AlreadyStopped = 1,
};

- (nonnull id)initWithObjectId:(AudioObjectID)inObjectID;
- (OSStatus)start;
- (OSStatus)stop;

@end

NS_ASSUME_NONNULL_END
