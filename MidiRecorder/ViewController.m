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

-(void)destroy{
    NSLog(@"ViewController: destroy called");
    [_recorder destroy];
}

@end
