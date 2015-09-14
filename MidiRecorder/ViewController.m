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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    //[_recorder destroy];
}

- (void)didEnterBackground
{
    NSLog( @"Entering background now" );
    [_recorder destroy];
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
    [_recorder startRecording];
    //[_resumeButton setEnabled:NO];
}


- (IBAction)stopRecording:(id)sender{
    [_startRecordButton setEnabled:YES];
    [_stopRecordButton setEnabled:NO];
    [_recorder stopRecording];
    //[_resumeButton setEnabled:NO];
}

-(void)destroy{
    NSLog(@"ViewController: destroy called");
    [_recorder destroy];
}

@end
