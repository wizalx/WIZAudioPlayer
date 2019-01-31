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

#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface WIZPlayerMainScreen () <WIZAudioProcessorDelegate, MPMediaPickerControllerDelegate>
{
    bool playNow;
    MPMediaPickerController *mediaPicker;
    
}

@property (weak, nonatomic) IBOutlet WIZEqualizer *equalizerView;


@property (nonatomic, strong) WIZEqualizer *equalizer;
@property (nonatomic) WIZAudioProcessor *audioProcessor;
@property (weak, nonatomic) IBOutlet UIButton *playStopBtn;
@property (weak, nonatomic) IBOutlet UILabel *trackName;
@property (nonatomic) NSURL *urlAudioFile;
@property (nonatomic) NSString *audioTitle;

@property (nonatomic) UIView *spinnerView;

@end

@implementation WIZPlayerMainScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioProcessor = [[WIZAudioProcessor alloc] initWithCountLines:20];
    self.audioProcessor.delegate = self;
    playNow = NO;
}

- (IBAction)tapPlay:(id)sender {
    
    if (!playNow && self.urlAudioFile) {
        playNow = YES;
        
        self.trackName.text = self.audioTitle;
        
        AVAudioFile *file = [[AVAudioFile alloc] initForReading:_urlAudioFile error:nil];
        
        AVAudioFormat *format = file.processingFormat;
        AVAudioFrameCount capacity = (AVAudioFrameCount)file.length;
        
        AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:capacity];
        
        [file readIntoBuffer:buffer error:nil];
        
        [self.audioProcessor.player scheduleBuffer:buffer completionHandler:nil];
        //    [_player scheduleFile:file atTime:nil completionHandler:nil];
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

#pragma mark - get music from iTunes

- (IBAction)getAudioList:(id)sender {
    mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES; // this is the default
    mediaPicker.prompt = @"Select songs to play";
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
        MPMediaItem *song = [[mediaItemCollection items] objectAtIndex:0];
        
        if (!song)
            return;
        
        self.urlAudioFile = [song valueForProperty:MPMediaItemPropertyAssetURL];
        
        self.audioTitle = [NSString stringWithFormat:@"%@ - %@",[song valueForProperty:MPMediaItemPropertyArtist],[song valueForProperty:MPMediaItemPropertyTitle]];

        [self tapPlay:nil];
        
        return;
        
        
       
        
    }
}

@end
