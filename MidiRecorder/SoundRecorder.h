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


#define kNumberRecordBuffers	3

typedef struct MyRecorder {
    AudioFileID					recordFile; // reference to your output file
    SInt64						recordPacket; // current packet index in output file
    Boolean						running; // recording state
} MyRecorder;




#pragma mark - utility functions -

// generic error handler - if error is nonzero, prints error message and exits program.
static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(errorString, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    
    exit(1);
}

#pragma mark - audio queue -

// Audio Queue callback function, called when an input buffer has been filled.
static void MyAQInputCallback(void *inUserData, AudioQueueRef inQueue,
                              AudioQueueBufferRef inBuffer,
                              const AudioTimeStamp *inStartTime,
                              UInt32 inNumPackets,
                              const AudioStreamPacketDescription *inPacketDesc)
{
    MyRecorder *recorder = (MyRecorder *)inUserData;
    
    // if inNumPackets is greater then zero, our buffer contains audio data
    // in the format we specified (AAC)
    if (inNumPackets > 0)
    {
        // write packets to file
        CheckError(AudioFileWritePackets(recorder->recordFile, FALSE, inBuffer->mAudioDataByteSize,
                                         inPacketDesc, recorder->recordPacket, &inNumPackets,
                                         inBuffer->mAudioData), "AudioFileWritePackets failed");
        // increment packet index
        recorder->recordPacket += inNumPackets;
    }
    
    // if we're not stopping, re-enqueue the buffer so that it gets filled again
    if (recorder->running)
        CheckError(AudioQueueEnqueueBuffer(inQueue, inBuffer,
                                           0, NULL), "AudioQueueEnqueueBuffer failed");
}




@protocol SoundRecorderDelegate <NSObject>

@optional
- (void)engineWasInterrupted;
- (void)engineConfigurationHasChanged;
- (void)mixerOutputFilePlayerHasStopped;

@end


@interface SoundRecorder : NSObject

@property (weak) id<SoundRecorderDelegate> delegate;

@property (readwrite) Float64              graphSampleRate;
//@property (readwrite) struct MyRecorder    recorder;

- (void)startRecording;
- (void)stopRecording;
//- (void)resumeSequence;

- (void)destroy;

- (void)handleInterruption:(NSNotification *)notification;
- (void)handleRouteChange:(NSNotification *)notification;
- (void)handleMediaServicesReset:(NSNotification *)notification;

@end
