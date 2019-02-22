//
//  WIZPlayerEssentials.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZPlayerEssentials.h"

@interface WIZFilterValue()
{
    float minVal;
    float maxVal;
    float curVal;
}
@end

@implementation WIZFilterValue

-(id)initFromMinimum:(float)min maximum:(float)max current:(float)current
{
    self = [super init];
    if (self) {
        if (min)
            minVal = min;
        
        if (max)
            maxVal = max;
        
        if (current)
            curVal = current;
    }
    return self;
}

-(float)minimumVal
{
    return minVal;
}

-(float)maximumVal
{
    return maxVal;
}

-(float)currentVal
{
    return curVal;
}

@end

@interface WIZMusicTrack()
{
    NSURL *trackUrl;
    NSString *trackArtist;
    NSString *trackTitle;
    UIImage *trackArtwork;
}

@end

@implementation WIZMusicTrack

-(id)initFromURL:(NSURL*)url artist:(NSString*)artist title:(NSString*)title image:(UIImage *)artwork
{
    self = [super init];
    if (self) {
        if (url)
            trackUrl = url;
        
        if (artist)
            trackArtist = artist;
        
        if (title)
            trackTitle = title;
        
        if (artwork)
            trackArtwork = artwork;
        
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

-(UIImage*)artwork
{
    return trackArtwork;
}

#pragma mark - code object

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.artwork forKey:@"artwork"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        trackUrl = [aDecoder decodeObjectOfClass:[NSURL class] forKey:@"url"];
        trackArtist = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"artist"];
        trackTitle = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"title"];
        trackArtwork = [aDecoder decodeObjectOfClass:[UIImage class] forKey:@"artwork"];
    }
    return self;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end

@implementation WIZEQFilterParameters

-(id)init
{
    self = [super init];
    return self;
}

@end
