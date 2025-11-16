// Copyright SimplyCoreAudio. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SimplyCoreAudio

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
        printf("already listening\n");
        return noErr;
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

    printf("start, status %i\n", status);

    _isListening = true;
    
    return status;
}

- (OSStatus)stop {
    if (!_isListening) {
        printf("wasn't listening\n");
        return noErr;
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

    printf("stop, status %i\n", status);

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
