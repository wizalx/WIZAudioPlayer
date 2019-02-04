//
//  WIZAudioDataProvider.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 04/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZAudioDataProvider.h"

@interface WIZAudioDataProvider() {
    NSArray <WIZMusicTrack*>*playlist;
}

@end

@implementation WIZAudioDataProvider

+ (WIZAudioDataProvider *)sharedInstance {
    static WIZAudioDataProvider *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

-(void)loadPlaylist:(NSArray<WIZMusicTrack *> *)userPlayList
{
    playlist = userPlayList;
}

-(NSArray <WIZMusicTrack*>*)playlist
{
    return playlist;
}

@end
