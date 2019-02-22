//
//  WIZPlayerEssentials.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface WIZFilterValue : NSObject

-(id)initFromMinimum:(float)min maximum:(float)max current:(float)current;

@property (nonatomic, readonly) float minimumVal;
@property (nonatomic, readonly) float maximumVal;
@property (nonatomic, readonly) float currentVal;

@end

@interface WIZMusicTrack : NSObject <NSSecureCoding>

-(id)initFromURL:(NSURL*)url artist:(NSString*)artist title:(NSString*)title image:(UIImage*)artwork;

@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, readonly) NSString* artist;
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) UIImage* artwork;

@end

@interface WIZEQFilterParameters : NSObject

@property (nonatomic) AVAudioUnitEQFilterType filterType;
@property (nonatomic) float frequency;
@property (nonatomic) float bandwidth;
@property (nonatomic) float gain;
@property (nonatomic) BOOL bypass;

@end
