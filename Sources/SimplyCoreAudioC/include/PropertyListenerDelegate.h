// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

#import <CoreAudio/CoreAudio.h>
#import <Foundation/Foundation.h>

@class PropertyListener;

@protocol PropertyListenerDelegate <NSObject>

@required
- (void)propertyListener:(nonnull PropertyListener *)propertyListener
           eventReceived:(AudioObjectPropertyAddress)propertyAddress;

@end
