//
//  WIZPlayerEssentials.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZPlayerEssentials.h"

@interface WIZMusicTrack()
{
    NSURL *trackUrl;
    NSString *trackArtist;
    NSString *trackTitle;
}

@end

@implementation WIZMusicTrack

-(id)initFromURL:(NSURL*)url artist:(NSString*)artist title:(NSString*)title
{
    self = [super init];
    if (self) {
        if (url)
            trackUrl = url;
        
        if (artist)
            trackArtist = artist;
        
        if (title)
            trackTitle = title;
    }
    return self;
}

-(NSURL*)url
{
    return trackUrl;
}

-(NSString*)artist
{
    return trackArtist;
}

-(NSString*)title
{
    return trackTitle;
}

@end
