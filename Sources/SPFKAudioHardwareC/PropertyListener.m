// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKAudioHardware
// Based on SimplyCoreAudio by Ruben Nine (c) 2014-2023. Revision History at https://github.com/rnine/SimplyCoreAudio

#import <CoreAudio/CoreAudio.h>

#import "PropertyListener.h"
#import "PropertyListenerDelegate.h"

@implementation PropertyListener

- (nonnull id)initWithObjectId:(AudioObjectID)inObjectID {
    self = [super init];

    _inObjectID = inObjectID;

    return self;
}

OSStatus devicePropertyChangedListener(
    AudioObjectID                    inObjectID,
    UInt32                           inNumberAddresses,
    const AudioObjectPropertyAddress *inAddresses,
    void                             *inClientData) {
    PropertyListener *propertyListener = (__bridge PropertyListener *)inClientData;

    for (UInt32 i = 0; i < inNumberAddresses; i++) {
        [propertyListener handleEvent:inAddresses[i]];
    }

    return noErr;
}

- (OSStatus)start {
    if (_isListening) {
        printf("Error: already listening\n");
        return AlreadyListening;
    }

    AudioObjectPropertyAddress propertyAddress = {
        .mSelector = kAudioObjectPropertySelectorWildcard,
        .mScope    = kAudioObjectPropertyScopeWildcard,
        .mElement  = kAudioObjectPropertyElementWildcard
    };

    OSStatus status = AudioObjectAddPropertyListener(
        _inObjectID,
        &propertyAddress,
        devicePropertyChangedListener,
        (__bridge void *_Nullable)(self)
        );

    // printf("start, %i, status %i\n", _inObjectID, status);

    _isListening = true;

    return status;
}

- (OSStatus)stop {
    if (!_isListening) {
        printf("Error: wasn't listening\n");
        return AlreadyStopped;
    }

    AudioObjectPropertyAddress propertyAddress = {
        .mSelector = kAudioObjectPropertySelectorWildcard,
        .mScope    = kAudioObjectPropertyScopeWildcard,
        .mElement  = kAudioObjectPropertyElementWildcard
    };

    OSStatus status = AudioObjectRemovePropertyListener(
        _inObjectID,
        &propertyAddress,
        devicePropertyChangedListener,
        (__bridge void *_Nullable)(self)
        );

    // printf("stop, %i, status %i\n", _inObjectID, status);

    _isListening = false;

    return status;
}

- (void)handleEvent:(AudioObjectPropertyAddress)propertyAddress {
    [_delegate propertyListener:self eventReceived:propertyAddress];
}

- (void)dealloc {
    printf("dealloc PropertyListener\n");
}

@end
