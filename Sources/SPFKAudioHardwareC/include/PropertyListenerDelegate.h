// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2024. Revision History at https://github.com/rnine/SimplyCoreAudio

#import <CoreAudio/CoreAudio.h>
#import <Foundation/Foundation.h>

@class PropertyListener;

@protocol PropertyListenerDelegate <NSObject>

@required
- (void)propertyListener:(nonnull PropertyListener *)propertyListener
           eventReceived:(AudioObjectPropertyAddress)propertyAddress;

@end
