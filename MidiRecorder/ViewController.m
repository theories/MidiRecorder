//
//  ViewController.m
//  MidiRecorder
//
//  Created by Thierry on 9/10/15.
//  Copyright (c) 2015 Thierry Sansaricq. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <SoundRecorderDelegate>



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _recorder = [[SoundRecorder alloc] init];
    _recorder.delegate = self;
    
    [_startRecordButton setEnabled:YES];
    [_stopRecordButton setEnabled:NO];
    [_playRecordButton setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    //[_recorder destroy];
}

- (void)didEnterBackground
{
    NSLog( @"Entering background now" );
    [_recorder stopRecording];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecording:(id)sender{
    [_startRecordButton setEnabled:NO];
    [_stopRecordButton setEnabled:YES];
    [_playRecordButton setEnabled:NO];
    [_recorder startRecording];
    //[_resumeButton setEnabled:NO];
}


- (IBAction)stopRecording:(id)sender{
    [_startRecordButton setEnabled:YES];
    [_stopRecordButton setEnabled:NO];
    [_recorder stopRecording];
    //[_resumeButton setEnabled:NO];
}

- (IBAction)playRecording:(id)sender{
    NSLog(@"playRecording() called");
    [_playRecordButton setEnabled:NO];
    [_stopRecordButton setEnabled:NO];
    [_startRecordButton setEnabled:NO];
    [_recorder playRecording];
}

#pragma mark delegate methods
- (void)recordingDone{

    NSLog(@"ViewController->recordingDone() called");
    [_playRecordButton setEnabled:YES];
}

- (void)playerDone{
    [_startRecordButton setEnabled:YES];
    [_stopRecordButton setEnabled:NO];
    [_playRecordButton setEnabled:YES];
}


-(void)destroy{
    NSLog(@"ViewController: destroy called");
    [_recorder destroy];
    
}

@end
