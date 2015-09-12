//
//  SoundRecorder.h
//  MidiRecorder
//
//  Created by Thierry on 9/10/15.
//  Copyright (c) 2015 Thierry Sansaricq. All rights reserved.
//



#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <Availability.h>
#include <CoreFoundation/CoreFoundation.h>
#include <AudioUnit/MusicDevice.h>
#include <AudioToolbox/AUGraph.h>
#include <CoreMIDI/MIDIServices.h>

//#import <AudioToolbox/MusicPlayer.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnitProperties.h>
#import <Accelerate/Accelerate.h>
//#include <CoreAudio/CoreAudioTypes.h>


typedef struct MyRecorder {
    AudioFileID					recordFile; // reference to your output file
    SInt64						recordPacket; // current packet index in output file
    Boolean						running; // recording state
} MyRecorder;



@protocol SoundRecorderDelegate <NSObject>

@optional
- (void)engineWasInterrupted;
- (void)engineConfigurationHasChanged;
- (void)mixerOutputFilePlayerHasStopped;

@end


@interface SoundRecorder : NSObject

@property (weak) id<SoundRecorderDelegate> delegate;

@property (readwrite) Float64              graphSampleRate;
@property (readwrite) struct MyRecorder    recorder;


- (void)handleInterruption:(NSNotification *)notification;
- (void)handleRouteChange:(NSNotification *)notification;
- (void)handleMediaServicesReset:(NSNotification *)notification;

@end
