//
//  WIZAudioProcessor.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
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


@end

NS_ASSUME_NONNULL_END
