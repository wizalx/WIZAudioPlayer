//
//  WIZPlayerMainScreen.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZPlayerMainScreen.h"
#import "../SourceView/WIZEqualizer.h"
#import "../Processors/WIZAudioProcessor.h"
#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

#import "../Resources/WIZPlayerEssentials.h"
#import "WIZPlayerPlaylistScreen.h"

@interface WIZPlayerMainScreen () <WIZAudioProcessorDelegate, MPMediaPickerControllerDelegate>
{
    bool playNow;
    float currentTrackSecond;
    MPMediaPickerController *mediaPicker;
    NSArray <WIZMusicTrack*> *playlist;
    bool startAfterRestart;
    
}

@property (weak, nonatomic) IBOutlet WIZEqualizer *equalizerView;

@property (nonatomic, strong) WIZEqualizer *equalizer;
@property (nonatomic) WIZAudioProcessor *audioProcessor;
@property (weak, nonatomic) IBOutlet UIButton *playStopBtn;
@property (weak, nonatomic) IBOutlet UILabel *trackName;

@property (weak, nonatomic) WIZMusicTrack *currentTrack;


@property (nonatomic) UIView *spinnerView;

@end

@implementation WIZPlayerMainScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioProcessor = [[WIZAudioProcessor alloc] initWithCountLines:20];
    self.audioProcessor.delegate = self;
    playNow = NO;
    startAfterRestart = NO;
}

- (IBAction)tapPlay:(id)sender {
    
    if (!playNow && _currentTrack) {
        playNow = YES;
        
        self.trackName.text = [NSString stringWithFormat:@"%@ - %@",_currentTrack.artist,_currentTrack.title];
        
        AVAudioFile *file = [[AVAudioFile alloc] initForReading:_currentTrack.url error:nil];
        
        AVAudioFormat *format = file.processingFormat;
        AVAudioFrameCount capacity = (AVAudioFrameCount)file.length;
        
        AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:capacity];
        
        [file readIntoBuffer:buffer error:nil];
        
        [self.audioProcessor.player scheduleBuffer:buffer completionHandler:nil];
        if (startAfterRestart) {
            
            
//            AVAudioFramePosition startingFrame = currentTrackSecond * file.processingFormat.sampleRate;
//            AVAudioFrameCount frameCount = (AVAudioFrameCount)(file.length - startingFrame);
            
//            [self.audioProcessor.player scheduleSegment:file
//                       startingFrame:startingFrame
//                          frameCount:frameCount
//                              atTime:self.audioProcessor.player.lastRenderTime
//                   completionHandler:^{
//                       NSLog(@"done playing");//actually done scheduling.
//                   }];
            
            unsigned long int startSample = (long int)floor(currentTrackSecond*file.processingFormat.sampleRate);
            unsigned long int lengthSamples = file.length-startSample;
            
            [self.audioProcessor.player scheduleSegment:file startingFrame:startSample frameCount:(AVAudioFrameCount)lengthSamples atTime:nil completionHandler:^{
                // do something (pause player)
            }];
            startAfterRestart = NO;
        } else {
            [self.audioProcessor.player scheduleBuffer:buffer completionHandler:nil];
        }
        
        [self.audioProcessor.player play];
        [_playStopBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    } else {
        playNow = NO;
        
        [self.audioProcessor.player stop];
        [self.audioProcessor.player reset];
        
        self.trackName.text = @"- empty -";
        
         [_playStopBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    
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

-(void)WIZAudioProcessorResetEngine
{
    playNow = NO;
    [self.audioProcessor.player pause];
    [self.audioProcessor.player reset];
    startAfterRestart = YES;
    [self tapPlay:nil];
}

-(void)WIZAudioProcessorCurrentSecond:(float)currentSecond
{
    currentTrackSecond = currentSecond;
}

#pragma mark - get music from iTunes

- (IBAction)getAudioList:(id)sender {
    mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES; // this is the default
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

#pragma mark - MPMediaPicker delegate

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    //dismiss picker
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.spinnerView = [[UIView alloc] initWithFrame:self.view.frame];
//    self.spinnerView.backgroundColor = [UIColor whiteColor];
//    self.spinnerView.alpha = 0.5;
//    [spinner setCenter:self.view.center];
//    [self.spinnerView addSubview:spinner];
//    [self.view addSubview:self.spinnerView];
    
//    [spinner startAnimating];
    
    
    // get selected item and play
    if (mediaItemCollection) {
        NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:0];
        for (MPMediaItem *song in [mediaItemCollection items]) {
            NSURL *urlTrack = [song valueForProperty:MPMediaItemPropertyAssetURL];
            NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
            NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
            WIZMusicTrack *track = [[WIZMusicTrack alloc] initFromURL:urlTrack artist:artist title:title];
            [tracks addObject:track];
        }
        playlist = tracks;
        
        if (playlist.count == 0)
            return;
        
        
        self.currentTrack = playlist[0];

        [self tapPlay:nil];
        
        return;
 
    }
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPlaylist"]) {
        WIZPlayerPlaylistScreen *playlistScreen = [segue destinationViewController];
        playlistScreen.playlist = playlist;
        playlistScreen.selectTrack = ^(WIZMusicTrack * _Nonnull track) {
            self.currentTrack = track;
            [self.audioProcessor.player stop];
            [self.audioProcessor.player reset];
            self->playNow = NO;
            [self tapPlay:nil];
        };
    }
}


@end
