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

typedef enum
{
    kPlayerStatePlay,
    kPlayerStatePause,
    kPlayerStateStop
} kPlayerState;

@interface WIZPlayerMainScreen () <WIZAudioProcessorDelegate, MPMediaPickerControllerDelegate>
{
    float currentTrackSecond;
    MPMediaPickerController *mediaPicker;
    NSArray <WIZMusicTrack*> *playlist;
    bool startAfterRestart;
    NSInteger currentIndex;
}

@property (weak, nonatomic) IBOutlet WIZEqualizer *equalizerView;

@property (nonatomic, strong) WIZEqualizer *equalizer;
@property (nonatomic) WIZAudioProcessor *audioProcessor;
@property (weak, nonatomic) IBOutlet UIButton *playStopBtn;
@property (weak, nonatomic) IBOutlet UILabel *trackName;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) WIZMusicTrack *currentTrack;
@property (nonatomic) kPlayerState playerState;

@property (nonatomic) UIView *spinnerView;

@end

@implementation WIZPlayerMainScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioProcessor = [[WIZAudioProcessor alloc] initWithCountLines:20];
    self.audioProcessor.delegate = self;

    startAfterRestart = NO;
    _playerState = kPlayerStateStop;
    
    [self.slider setThumbImage:[self resizeImage:[UIImage imageNamed:@"sliderPoint"] withSize:CGSizeMake(15.0, 15.0)] forState:UIControlStateNormal];
    
    [self.slider setContinuous:NO];
}

#pragma mark - control btn

- (IBAction)tapPlay:(id)sender {
    
    switch (_playerState) {
        case kPlayerStatePlay:
        {
            [self.audioProcessor.player pause];
            [_playStopBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            _playerState = kPlayerStatePause;
        }
            break;
        case kPlayerStateStop:
        {
            if (_currentTrack)
                [self playNewTrack];
            break;
        }
        case kPlayerStatePause:
        {
            [self.audioProcessor.player play];
            [_playStopBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            _playerState = kPlayerStatePlay;
        }
        default:
            break;
    }
    
}

-(void)playNewTrack
{
    _playerState = kPlayerStatePlay;
    
    self.trackName.text = [NSString stringWithFormat:@"%@ - %@",_currentTrack.artist,_currentTrack.title];
    
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:_currentTrack.url error:nil];
    
    AVAudioFormat *format = file.processingFormat;
    AVAudioFrameCount capacity = (AVAudioFrameCount)file.length;
    
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:capacity];
    
    [file readIntoBuffer:buffer error:nil];
    
    [self.audioProcessor.player scheduleBuffer:buffer completionHandler:nil];
    if (startAfterRestart) {
        NSLog(@"currentTrackSecond = %.2f",currentTrackSecond);
        unsigned long int startSample = (long int)floor(currentTrackSecond*file.processingFormat.sampleRate);
        unsigned long int lengthSamples = file.length-startSample;
        
        [self.audioProcessor.player scheduleSegment:file startingFrame:startSample frameCount:(AVAudioFrameCount)lengthSamples atTime:nil completionHandler:^{
            // do something (pause player)
        }];
        startAfterRestart = NO;
    } else {
        [self.audioProcessor.player scheduleBuffer:buffer completionHandler:nil];
        self.slider.maximumValue = capacity/44100;
        self.slider.value = 0;
    }
    
    self.slider.minimumValue = 0;
    
    
    [self.audioProcessor.player play];
    [_playStopBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (IBAction)nextTrack:(id)sender {
    
    [self.audioProcessor.player stop];
    [self.audioProcessor.player reset];
    if (currentIndex+1 >= playlist.count) {
        currentIndex = 0;
        self.currentTrack = playlist[0];
    } else {
        currentIndex++;
        self.currentTrack = playlist[currentIndex];
    }
    [self playNewTrack];
}

- (IBAction)previousTrack:(id)sender {
    [self.audioProcessor.player stop];
    [self.audioProcessor.player reset];
    if (currentIndex-1 < 0) {
        currentIndex = playlist.count - 1;
        self.currentTrack = playlist[currentIndex];
    } else {
        currentIndex--;
        self.currentTrack = playlist[currentIndex];
    }
    [self playNewTrack];
}

#pragma mark - slider

- (IBAction)valueCanged:(id)sender {
    currentTrackSecond = self.slider.value;
    NSLog(@"currentTrackSecond = %.2f",currentTrackSecond);
    [self WIZAudioProcessorResetEngine];
}

- (IBAction)sliderTouchDown:(id)sender {
    [self tapPlay:nil];
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
    [self.audioProcessor.player pause];
    [self.audioProcessor.player reset];
    startAfterRestart = YES;
    [self playNewTrack];
}

-(void)WIZAudioProcessorCurrentSecond:(float)currentSecond
{
    [self.slider setValue:currentSecond];
    currentTrackSecond = currentSecond;
    NSLog(@"cts = %.2f",currentTrackSecond);
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
        currentIndex = 0;

        [self playNewTrack];
        
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
            [self playNewTrack];
        };
    }
}

#pragma mark - helper

-(UIImage*)resizeImage:(UIImage*)image withSize:(CGSize)size
{
    UIImage *tempImage = nil;
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = size.width;
    thumbnailRect.size.height = size.height;
    
    [image drawInRect:thumbnailRect];
    
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tempImage;
}


@end
