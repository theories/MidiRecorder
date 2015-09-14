//
//  ViewController.h
//  MidiRecorder
//
//  Created by Thierry on 9/10/15.
//  Copyright (c) 2015 Thierry Sansaricq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundRecorder.h"

@interface ViewController : UIViewController{
    SoundRecorder *_recorder;
}



@property (unsafe_unretained, nonatomic) IBOutlet UIButton *startRecordButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *stopRecordButton;
//@property (unsafe_unretained, nonatomic) IBOutlet UIButton *resumeButton;

- (IBAction) startRecording:(id)sender;
- (IBAction) stopRecording:(id)sender;
//- (IBAction) resumeSequence:(id)sender;

-(void)destroy;

@end

