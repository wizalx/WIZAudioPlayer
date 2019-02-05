//
//  WIZPlayerMainScreen.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZPlayerMainScreen.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>

#import "../SourceView/WIZEqualizer.h"
#import "../Processors/WIZAudioProcessor.h"
#import "../Resources/WIZPlayerEssentials.h"
#import "../Resources/WIZAudioDataProvider.h"
#import "../SourceView/WIZMarqueeTextView/WIZMarqueeTextView.h"

#import "WIZPlayerPlaylistScreen.h"
#import <MediaPlayer/MediaPlayer.h>

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
    bool startAfterRestart;
    NSInteger currentIndex;
}

@property (weak, nonatomic) IBOutlet WIZEqualizer *equalizerView;

@property (nonatomic, strong) WIZEqualizer *equalizer;
@property (nonatomic) WIZAudioProcessor *audioProcessor;
@property (weak, nonatomic) IBOutlet UIButton *playStopBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) WIZMusicTrack *currentTrack;
@property (nonatomic) kPlayerState playerState;
@property (weak, nonatomic) IBOutlet WIZMarqueeTextView *marqueeTextView;

@property (nonatomic) UIView *spinnerView;

@end

@implementation WIZPlayerMainScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //prepate screen
    self.audioProcessor = [[WIZAudioProcessor alloc] initWithCountLines:20];
    self.audioProcessor.delegate = self;

    startAfterRestart = NO;
    _playerState = kPlayerStateStop;
    
    currentTrackSecond = 0;
    
    [self.slider setThumbImage:[self resizeImage:[UIImage imageNamed:@"sliderPoint"] withSize:CGSizeMake(15.0, 15.0)] forState:UIControlStateNormal];
    
    [self.slider setContinuous:NO];
    
    
    if ([WIZAudioDataProvider sharedInstance].playlist)
    {
        self.currentTrack = [WIZAudioDataProvider sharedInstance].playlist[0];
        currentIndex = 0;
        
        [self playNewTrack];
    }
    else
        [self createTitleTrack:@" - empty - "];

    
    [self prepareRemoteCenter];
    
    self.marqueeTextView.fontSize = 15;
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
   
    
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:_currentTrack.url error:nil];
    
    AVAudioFormat *format = file.processingFormat;
    AVAudioFrameCount capacity = (AVAudioFrameCount)file.length;
    
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:capacity];
    
    [file readIntoBuffer:buffer error:nil];
    if (startAfterRestart) {
        [self.audioProcessor.player reset];
        NSLog(@"SELECT = %.2f",currentTrackSecond);
        unsigned long int startSample = (long int)floor(currentTrackSecond*file.processingFormat.sampleRate);
        unsigned long int lengthSamples = file.length-startSample;
        
        [self.audioProcessor.player scheduleSegment:file startingFrame:startSample frameCount:(AVAudioFrameCount)lengthSamples atTime:nil completionHandler:^{
            // do something (pause player)
        }];
        startAfterRestart = NO;
    } else {
        [self createTitleTrack:[NSString stringWithFormat:@"%@ - %@",_currentTrack.artist,_currentTrack.title]];
        [self.audioProcessor.player scheduleBuffer:buffer completionHandler:nil];
        self.slider.maximumValue = capacity/44100;
        self.slider.value = 0;
    }
    
    self.slider.minimumValue = 0;
    
    
    [self.audioProcessor.player play];
    
    MPMediaItemArtwork *controlArtwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(128, 128) requestHandler:^UIImage * _Nonnull(CGSize size) {
        return self.currentTrack.artwork;
    }];
 
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 self.currentTrack.title, MPMediaItemPropertyTitle,
                                                                 self.currentTrack.artist, MPMediaItemPropertyArtist,
                                                                controlArtwork, MPMediaItemPropertyArtwork,
                                                                 [NSNumber numberWithDouble:0.0], MPNowPlayingInfoPropertyPlaybackRate, nil];
    
    [_playStopBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (IBAction)nextTrack:(id)sender {
    
    [self.audioProcessor.player stop];
    [self.audioProcessor.player reset];
    if (currentIndex+1 >= [WIZAudioDataProvider sharedInstance].playlist.count) {
        currentIndex = 0;
        self.currentTrack = [WIZAudioDataProvider sharedInstance].playlist[0];
    } else {
        currentIndex++;
        self.currentTrack = [WIZAudioDataProvider sharedInstance].playlist[currentIndex];
    }
    currentTrackSecond = 0;
    [self playNewTrack];
}

- (IBAction)previousTrack:(id)sender {
    [self.audioProcessor.player stop];
    [self.audioProcessor.player reset];
    if (currentIndex-1 < 0) {
        currentIndex = [WIZAudioDataProvider sharedInstance].playlist.count - 1;
        self.currentTrack = [WIZAudioDataProvider sharedInstance].playlist[currentIndex];
    } else {
        currentIndex--;
        self.currentTrack = [WIZAudioDataProvider sharedInstance].playlist[currentIndex];
    }
    [self playNewTrack];
}

#pragma mark - slider

- (IBAction)valueCanged:(id)sender {
    currentTrackSecond = self.slider.value;
    [self.audioProcessor.player stop];
    [self.audioProcessor.player reset];
    startAfterRestart = YES;
    [self playNewTrack];
}

- (IBAction)sliderTouchDown:(id)sender {
    [self tapPlay:nil];
}

#pragma mark - track title

-(void)createTitleTrack:(NSString*)title
{
    [self.marqueeTextView setText:title];
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
    [self.slider setValue:currentTrackSecond + currentSecond];
    if (self.slider.value == self.slider.maximumValue)
        [self nextTrack:nil];
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
            
            MPMediaItemArtwork *itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
            
            WIZMusicTrack *track = [[WIZMusicTrack alloc] initFromURL:urlTrack artist:artist title:title image:[itemArtwork imageWithSize:CGSizeMake(128, 128)]];
            
            [tracks addObject:track];
        }
        [[WIZAudioDataProvider sharedInstance] loadPlaylist:tracks];
        
        if ([WIZAudioDataProvider sharedInstance].playlist.count == 0)
            return;
        
        
        self.currentTrack = [WIZAudioDataProvider sharedInstance].playlist[0];
        currentIndex = 0;

        [self playNewTrack];
        
        return;
 
    }
}

#pragma mark - prepare remote

-(void)prepareRemoteCenter
{
    
    [self.audioProcessor.commandCenter.togglePlayPauseCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self tapPlay:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [self.audioProcessor.commandCenter.nextTrackCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self nextTrack:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [self.audioProcessor.commandCenter.previousTrackCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self previousTrack:nil];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPlaylist"]) {
        WIZPlayerPlaylistScreen *playlistScreen = [segue destinationViewController];
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
