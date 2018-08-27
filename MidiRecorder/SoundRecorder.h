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
//#include <AudioUnit/MusicDevice.h>
#include <AudioToolbox/AUGraph.h>
#include <CoreMIDI/MIDIServices.h>

//#import <AudioToolbox/MusicPlayer.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
//#import <AudioUnit/AudioUnitProperties.h>
#import <Accelerate/Accelerate.h>
//#include <CoreAudio/CoreAudioTypes.h>



@protocol SoundRecorderDelegate <NSObject>

@optional
- (void)engineWasInterrupted;
- (void)engineConfigurationHasChanged;
- (void)mixerOutputFilePlayerHasStopped;
- (void)recordingDone;
- (void)playerDone;

@end


@interface SoundRecorder : NSObject

@property (weak) id<SoundRecorderDelegate> delegate;

@property (readwrite) Float64              graphSampleRate;
@property (readwrite) BOOL                 recordingExists;

//@property (readwrite) struct MyRecorder    recorder;

- (void)startRecording;
- (void)stopRecording;
- (void)playRecording;
- (BOOL)checkRecordingExists;
//- (void)resumeSequence;

- (void)destroy;

- (void)handleInterruption:(NSNotification *)notification;
- (void)handleRouteChange:(NSNotification *)notification;
- (void)handleMediaServicesReset:(NSNotification *)notification;

@end
