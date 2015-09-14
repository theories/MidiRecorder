//
//  SoundRecorder.m
//  MidiRecorder
//
//  Created by Thierry on 9/10/15.
//  Copyright (c) 2015 Thierry Sansaricq. All rights reserved.
//

#import "SoundRecorder.h"




@implementation SoundRecorder

MyRecorder  _recorder;
AudioQueueRef _queue;

//@synthesize recorder            = _recorder;

@synthesize graphSampleRate     = _graphSampleRate;

- (instancetype)init
{
    if (self = [super init]) {
        
        if(![self initAVAudioSession]){
            NSLog(@"Error creating AVAudioSession");
            return nil;
        }
        
        //[self initRecorder];
    
    }
    
    return self;

}

- (void)destroy{
 
    NSLog(@"MidiRecorder: destroying...");
    [self stopRecording];
}

-(void)initRecorder{

    //MyRecorder recorder = {0};
    //MyRecorder theRecorder = {0};// = _recorder;
    //theRecorder = {0};
    //memset(&_recorder, 0, sizeof(_recorder));
    AudioStreamBasicDescription recordFormat = {0};
    memset(&recordFormat, 0, sizeof(recordFormat));
    
    // Configure the output data format to be AAC
    recordFormat.mFormatID = kAudioFormatMPEG4AAC;
    recordFormat.mChannelsPerFrame = 2;
    
    // get the sample rate of the default input device
    // we use this to adapt the output data format to match hardware capabilities
    
    
    
#pragma mark TODO get the sample rate from the AudioSession!!!!
    //MyGetDefaultInputDeviceSampleRate(&recordFormat.mSampleRate);
    recordFormat.mSampleRate = self.graphSampleRate;//44100.0;
    
    // ProTip: Use the AudioFormat API to trivialize ASBD creation.
    //         input: atleast the mFormatID, however, at this point we already have
    //                mSampleRate, mFormatID, and mChannelsPerFrame
    //         output: the remainder of the ASBD will be filled out as much as possible
    //                 given the information known about the format
    UInt32 propSize = sizeof(recordFormat);
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL,
                                      &propSize, &recordFormat), "AudioFormatGetProperty failed");
    
    // create a input (recording) queue
    AudioQueueRef queue = {0};
    CheckError(AudioQueueNewInput(&recordFormat, // ASBD
                                  MyAQInputCallback, // Callback
                                  (void *)&_recorder, // user data
                                  NULL, // run loop
                                  NULL, // run loop mode
                                  0, // flags (always 0)
                                  // &recorder.queue), // output: reference to AudioQueue object
                                  &queue),
               "AudioQueueNewInput failed");
    
    // since the queue is now initilized, we ask it's Audio Converter object
    // for the ASBD it has configured itself with. The file may require a more
    // specific stream description than was necessary to create the     audio queue.
    //
    // for example: certain fields in an ASBD cannot possibly be known until it's
    // codec is instantiated (in this case, by the AudioQueue's Audio Converter object)
    UInt32 size = sizeof(recordFormat);
    CheckError(AudioQueueGetProperty(queue, kAudioConverterCurrentOutputStreamDescription,
                                     &recordFormat, &size), "couldn't get queue's format");
    
    
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    NSString *pathToSave = [documentPath_ stringByAppendingPathComponent:@"output.caf"];
    
    
    // create the audio file
    CFURLRef myFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)pathToSave, kCFURLPOSIXPathStyle, false);
    CFShow (myFileURL);
    CheckError(AudioFileCreateWithURL(myFileURL, kAudioFileCAFType, &recordFormat,
                                      kAudioFileFlags_EraseFile, &_recorder.recordFile), "AudioFileCreateWithURL failed");
    
    //AudioFileOpenURL(myFileURL, <#SInt8 inPermissions#>, <#AudioFileTypeID inFileTypeHint#>, <#AudioFileID *outAudioFile#>)
    CFRelease(myFileURL);
    
    // many encoded formats require a 'magic cookie'. we set the cookie first
    // to give the file object as much info as we can about the data it will be receiving
    [self copyEncoderCookieToFile: queue theFile:_recorder.recordFile];
    
    // allocate and enqueue buffers
    //int bufferByteSize = MyComputeRecordBufferSize(&recordFormat, queue, 0.5);	// enough bytes for half a second
    
    int bufferByteSize = [self computeRecordBufferSize:&recordFormat queue:queue seconds:0.5];	// enough bytes for half a second
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < kNumberRecordBuffers; ++bufferIndex)
    {
        AudioQueueBufferRef buffer;
        
        CheckError(AudioQueueAllocateBuffer(queue, bufferByteSize, &buffer),
                   "AudioQueueAllocateBuffer failed");
        CheckError(AudioQueueEnqueueBuffer(queue, buffer, 0, NULL),
                   "AudioQueueEnqueueBuffer failed");
    }
    
    _queue = queue;
    //[self startRecording];

}


-(void)startRecording{

    [self initRecorder];
    // start the queue. this function return immedatly and begins
    // invoking the callback, as needed, asynchronously.
    _recorder.running = TRUE;
    CheckError(AudioQueueStart(_queue, NULL), "AudioQueueStart failed");
    // and wait
    printf("Recording...:\n");
    //getchar();
    
    
}


-(void)stopRecording{
    
    // end recording
    printf("* recording done *\n");
    _recorder.running = FALSE;
    CheckError(AudioQueueStop(_queue, TRUE), "AudioQueueStop failed");
    
    // a codec may update its magic cookie at the end of an encoding session
    // so reapply it to the file now
    [self copyEncoderCookieToFile:_queue theFile:_recorder.recordFile ];
    
    
    AudioQueueDispose(_queue, TRUE);
    AudioFileClose(_recorder.recordFile);
    
    
}



#pragma mark AVAudioSession

- (BOOL)initAVAudioSession
{
    // For complete details regarding the use of AVAudioSession see the AVAudioSession Programming Guide
    // https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html
    
    // Configure the audio session
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    NSError *error;
    
    // set the session category
    bool success = [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success){
        NSLog(@"Error setting AVAudioSession category! %@\n", [error localizedDescription]);
        return NO;
    }
    
    //double hwSampleRate = 44100.0;
    // Request a desired hardware sample rate.
    self.graphSampleRate = 44100.0;    // Hertz
    
    success = [sessionInstance setPreferredSampleRate:self.graphSampleRate error:&error];
    if (!success){ NSLog(@"Error setting preferred sample rate! %@\n", [error localizedDescription]);
        return NO;
    }
    
    NSTimeInterval ioBufferDuration = 0.0029;
    success = [sessionInstance setPreferredIOBufferDuration:ioBufferDuration error:&error];
    if (!success) {
        NSLog(@"Error setting preferred io buffer duration! %@\n", [error localizedDescription]);
        return NO;
    }
    
    
    // add interruption handler
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:sessionInstance];
    
    // we don't do anything special in the route change notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:sessionInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMediaServicesReset:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:sessionInstance];
    
    
    // activate the audio session
    success = [sessionInstance setActive:YES error:&error];
    if (!success){ NSLog(@"Error setting session active! %@\n", [error localizedDescription]);
        return NO;
    }
    
    self.graphSampleRate = [sessionInstance sampleRate];
    
    return YES;
}

#pragma mark CoreAudio Helper Methods

// Copy a queue's encoder's magic cookie to an audio file.
-(void) copyEncoderCookieToFile:(AudioQueueRef) queue theFile:(AudioFileID) theFile
{
    UInt32 propertySize;
    
    // get the magic cookie, if any, from the queue's converter
    OSStatus result = AudioQueueGetPropertySize(queue,
                                                kAudioConverterCompressionMagicCookie, &propertySize);
    
    if (result == noErr && propertySize > 0)
    {
        // there is valid cookie data to be fetched;  get it
        Byte *magicCookie = (Byte *)malloc(propertySize);
        CheckError(AudioQueueGetProperty(queue, kAudioQueueProperty_MagicCookie, magicCookie,
                                         &propertySize), "get audio queue's magic cookie");
        
        // now set the magic cookie on the output file
        CheckError(AudioFileSetProperty(theFile, kAudioFilePropertyMagicCookieData, propertySize, magicCookie),
                   "set audio file's magic cookie");
        free(magicCookie);
    }
}

// Determine the size, in bytes, of a buffer necessary to represent the supplied number
// of seconds of audio data.
-(int) computeRecordBufferSize:(const AudioStreamBasicDescription*) format  queue:(AudioQueueRef) queue  seconds:(float) seconds
{

    int packets, frames, bytes;
    
    frames = (int)ceil(seconds * format->mSampleRate);
    
    if (format->mBytesPerFrame > 0)						// 1
        bytes = frames * format->mBytesPerFrame;
    else
    {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0)				// 2
            maxPacketSize = format->mBytesPerPacket;
        else
        {
            // get the largest single packet size possible
            UInt32 propertySize = sizeof(maxPacketSize);	// 3
            CheckError(AudioQueueGetProperty(queue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize,
                                             &propertySize), "couldn't get queue's maximum output packet size");
        }
        if (format->mFramesPerPacket > 0)
            packets = frames / format->mFramesPerPacket;	 // 4
        else
            // worst-case scenario: 1 frame in a packet
            packets = frames;							// 5
        
        if (packets == 0)		// sanity check
            packets = 1;
        bytes = packets * maxPacketSize;				// 6
    }
    return bytes;

}


#pragma mark notifications

- (void)handleInterruption:(NSNotification *)notification
{
    UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    NSLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
    
    if (theInterruptionType == AVAudioSessionInterruptionTypeBegan) {
        //[_drumPlayer stop];
        //[_marimbaPlayer stop];
        //[self stopPlayingRecordedFile];
        //[self stopRecordingMixerOutput];
        
        if ([self.delegate respondsToSelector:@selector(engineWasInterrupted)]) {
            [self.delegate engineWasInterrupted];
        }
        
    }
    if (theInterruptionType == AVAudioSessionInterruptionTypeEnded) {
        // make sure to activate the session
        NSError *error;
        bool success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (!success) NSLog(@"AVAudioSession set active failed with error: %@", [error localizedDescription]);
        
        // start the engine once again
        //[self startEngine];
    }
}

- (void)handleRouteChange:(NSNotification *)notification
{
    UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    AVAudioSessionRouteDescription *routeDescription = [notification.userInfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    NSLog(@"Route change:");
    switch (reasonValue) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"     NewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"     OldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"     CategoryChange");
            NSLog(@" New Category: %@", [[AVAudioSession sharedInstance] category]);
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"     Override");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"     WakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"     NoSuitableRouteForCategory");
            break;
        default:
            NSLog(@"     ReasonUnknown");
    }
    
    NSLog(@"Previous route:\n");
    NSLog(@"%@", routeDescription);
}

- (void)handleMediaServicesReset:(NSNotification *)notification
{
    // if we've received this notification, the media server has been reset
    // re-wire all the connections and start the engine
    NSLog(@"Media services have been reset!");
    NSLog(@"Re-wiring connections and starting once again");
    
    
#pragma mark TODO: Put In Some Re-wiring code here
    //[self createEngineAndAttachNodes];
    //[self initAVAudioSession];
    //[self makeEngineConnections];
    //self startEngine];
    
    
    
    
    // post notification
    if ([self.delegate respondsToSelector:@selector(engineConfigurationHasChanged)]) {
        [self.delegate engineConfigurationHasChanged];
    }
    
    
}



@end
