//
//  WIZPlayerMainScreen.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZPlayerMainScreen.h"
#import "SourceView/WIZEqualizer.h"
#import "Processors/WIZAudioProcessor.h"
#import <AVFoundation/AVFoundation.h>

@interface WIZPlayerMainScreen () <WIZAudioProcessorDelegate>

@property (weak, nonatomic) IBOutlet WIZEqualizer *equalizerView;


@property (nonatomic, strong) WIZEqualizer *equalizer;
@property (nonatomic) WIZAudioProcessor *audioProcessor;

@end

@implementation WIZPlayerMainScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioProcessor = [[WIZAudioProcessor alloc] initWithCountLines:20];
    self.audioProcessor.delegate = self;
}

- (IBAction)tapPlay:(id)sender {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Sum 41" withExtension:@"mp3"];
    
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:url error:nil];
    
    AVAudioFormat *format = file.processingFormat;
    AVAudioFrameCount capacity = (AVAudioFrameCount)file.length;
    
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:capacity];
    
    [file readIntoBuffer:buffer error:nil];
    
    [self.audioProcessor.player scheduleBuffer:buffer completionHandler:nil];
    //    [_player scheduleFile:file atTime:nil completionHandler:nil];
    [self.audioProcessor.player play];
}

#pragma mark - audio processor delegate

-(void)WIZAudioProcessorGetValues:(NSArray *)values
{
    if (!_equalizer) {
        self.equalizer = [[WIZEqualizer alloc] initWithFrame:_equalizerView.frame countLines:20 countTop:30];
        [_equalizerView addSubview:self.equalizer];
    }
    
    self.equalizer.values = values;
}


@end
