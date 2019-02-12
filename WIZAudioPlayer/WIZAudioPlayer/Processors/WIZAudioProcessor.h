//
//  WIZAudioProcessor.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


NS_ASSUME_NONNULL_BEGIN


@protocol WIZAudioProcessorDelegate <NSObject>

-(void)WIZAudioProcessorGetValues:(NSArray*)values;
-(void)WIZAudioProcessorResetEngine;
-(void)WIZAudioProcessorCurrentSecond:(float)currentSecond;

@end

@interface WIZAudioProcessor : NSObject

-(instancetype)initWithCountLines:(int)lines;
@property (nonatomic) AVAudioPlayerNode* player;
@property (nonatomic, retain) id <WIZAudioProcessorDelegate> delegate;
@property (nonatomic) MPRemoteCommandCenter *commandCenter;

@property (nonatomic) BOOL byPass;
@property (nonatomic) NSArray* eqArray;



@end

NS_ASSUME_NONNULL_END
