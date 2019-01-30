//
//  WIZAudioProcessor.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZAudioProcessor.h"
#import <Accelerate/Accelerate.h>

@interface WIZAudioProcessor()

@property (nonatomic) AVAudioEngine *engine;
@property (nonatomic) NSMutableArray <NSNumber*> *linesPosition;
@property (nonatomic) NSInteger audioLinesCount;

@end

@implementation WIZAudioProcessor

-(instancetype)initWithCountLines:(int)lines
{
    self = [super init];
    if (self) {
        self.audioLinesCount = lines;
        [self runProcessor];
    }
    return self;
}

-(void)runProcessor
{
    //prepare data
    _linesPosition = [NSMutableArray arrayWithCapacity:self.audioLinesCount];
    for (int j = 0; j<self.audioLinesCount; j++)
        [_linesPosition addObject:@(0.1)];
    
    self.engine = [[AVAudioEngine alloc] init];
    self.player = [[AVAudioPlayerNode alloc] init];
    
    //select output main speaker
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //prepare engine
    [self.engine attachNode:_player];
    AVAudioMixerNode *mixer = self.engine.mainMixerNode;
    [self.engine connect:_player to:mixer format:[mixer outputFormatForBus:0]];
    
    mixer = [self.engine mainMixerNode];
    
    //get lines
    [mixer installTapOnBus:0 bufferSize:1024 format:[mixer outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        
        [buffer setFrameLength:1024];
        UInt32 inNumberFrames = buffer.frameLength;
        if(buffer.format.channelCount>0)
        {
            Float32* samples = (Float32*)buffer.floatChannelData[0];
            Float32 avgValue = 0;
            
            vDSP_meamgv((Float32*)samples, 1, &avgValue, inNumberFrames);
            
            for (NSInteger lowPassTrig = 1; lowPassTrig < self.audioLinesCount+1; lowPassTrig++) {
                float correctLowPassTrig = (float)lowPassTrig/self.audioLinesCount;
                float averagePowerForChannel = (correctLowPassTrig*((avgValue==0)?-100:20.0*log10f(avgValue))) + ((1-correctLowPassTrig)* [self.linesPosition[lowPassTrig-1] integerValue]);
                self.linesPosition[lowPassTrig-1] = @(averagePowerForChannel);

            }
            
        }
        
        if(buffer.format.channelCount>1)
        {
            Float32* samples = (Float32*)buffer.floatChannelData[1];
            Float32 avgValue = 0;
            
            vDSP_meamgv((Float32*)samples, 1, &avgValue, inNumberFrames);
            
            for (int lowPassTrig = 1; lowPassTrig < self.audioLinesCount+1; lowPassTrig++) {
                float correctLowPassTrig = lowPassTrig/self.audioLinesCount;
                float averagePowerForChannel = (correctLowPassTrig*((avgValue==0)?-100:20.0*log10f(avgValue))) + ((1-correctLowPassTrig)*[self.linesPosition[lowPassTrig-1] integerValue]) ;
                self.linesPosition[lowPassTrig-1] = @(averagePowerForChannel);
            }
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate WIZAudioProcessorGetValues:[self.linesPosition copy]];
        });
    }];
    
    NSError* error;
    if (![self.engine startAndReturnError:&error]) {
        NSLog(@"RUN ENGINE ERROR! %@",error.description);
    }
}

@end
