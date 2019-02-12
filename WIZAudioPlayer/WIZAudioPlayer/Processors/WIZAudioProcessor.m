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

@property (nonatomic) AVAudioUnitEQ *unitEq;


@end

@implementation WIZAudioProcessor

#pragma mark - init and run

-(instancetype)initWithCountLines:(int)lines
{
    self = [super init];
    if (self) {
        self.audioLinesCount = lines;
        [self runProcessor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
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
    
    [self createRemoteCenter];
    
    //prepare engine
    [self.engine attachNode:_player];

    [self prepareEq];
    
    
    AVAudioMixerNode *mixer = self.engine.mainMixerNode;
    
    [self.engine connect:_player to:self.unitEq format:[mixer outputFormatForBus:0]];
    [self.engine connect:self.unitEq to:mixer format:[mixer outputFormatForBus:0]];

    mixer = [self.engine mainMixerNode];
    
    //get lines
    [mixer installTapOnBus:0 bufferSize:1024 format:[mixer outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        if ([self.player playerTimeForNodeTime:self.player.lastRenderTime]) {
            AVAudioTime *audioTime = [self.player playerTimeForNodeTime:self.player.lastRenderTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate WIZAudioProcessorCurrentSecond:audioTime.sampleTime / audioTime.sampleRate];
            });
        }
        
        
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

-(void)prepareEq
{
    
    self.unitEq = [[AVAudioUnitEQ alloc] initWithNumberOfBands:6];
    
    AVAudioUnitEQFilterParameters *filterParameters;
    
    for (int i=0; i<6; i++) {
        filterParameters = self.unitEq.bands[i];
        filterParameters.filterType = i < 4 ? i+1 : i > 4 ? i+5 : i+2;
        filterParameters.frequency = 3000;
        
        filterParameters.bypass = YES;
    }
    
    [self.engine attachNode:self.unitEq];
}


-(void)setByPass:(BOOL)byPass
{
    _byPass = byPass;
    [self setEqArray:_eqArray];
}

-(void)setEqArray:(NSArray*)eqArray
{
    _eqArray = eqArray;
    for (int i=0; i<eqArray.count; i++) {
        AVAudioUnitEQFilterParameters *filterParameters = self.unitEq.bands[i];
        filterParameters.filterType = i < 4 ? i+1 : i > 4 ? i+5 : i+2;
        filterParameters.frequency =  [eqArray[i] floatValue];
        filterParameters.bypass = _byPass;

        [self.engine attachNode:self.unitEq];
    }
}

#pragma mark - create remote centr

-(void)createRemoteCenter
{
    self.commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [self.commandCenter.togglePlayPauseCommand setEnabled:YES];
    [self.commandCenter.playCommand setEnabled:YES];
    [self.commandCenter.pauseCommand setEnabled:YES];
    [self.commandCenter.nextTrackCommand setEnabled:YES];
    [self.commandCenter.previousTrackCommand setEnabled:YES];

}

#pragma mark - change devices

- (void)audioHardwareRouteChanged:(NSNotification *)notification {
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    [self.engine reset];
    NSError* error;
    if (![self.engine startAndReturnError:&error]) {
        NSLog(@"RUN ENGINE ERROR! %@",error.description);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate WIZAudioProcessorResetEngine];
    });
}

@end
