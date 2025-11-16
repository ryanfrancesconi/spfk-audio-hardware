// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

#import <CoreAudio/AudioHardware.h>
#import <Foundation/Foundation.h>

#import "PropertyListenerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PropertyListener : NSObject

@property (nonatomic) AudioObjectID inObjectID;
@property (nonatomic, readonly) BOOL isListening;
@property (nonatomic, weak) id<PropertyListenerDelegate> delegate;

- (nonnull id)initWithObjectId:(AudioObjectID)inObjectID;
- (OSStatus)start;
- (OSStatus)stop;

@end

NS_ASSUME_NONNULL_END
