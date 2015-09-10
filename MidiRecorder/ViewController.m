//
//  ViewController.m
//  MidiRecorder
//
//  Created by Thierry on 9/10/15.
//  Copyright (c) 2015 Thierry Sansaricq. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SoundRecorder *recorder = [[SoundRecorder alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
