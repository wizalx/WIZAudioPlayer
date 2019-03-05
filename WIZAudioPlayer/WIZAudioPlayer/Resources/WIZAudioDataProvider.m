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
    NSMutableArray <WIZEQFilterParameters*> *audioFiltres;
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

#pragma mark - init playlist

-(void)loadPlaylist:(NSArray<WIZMusicTrack *> *)userPlayList
{
    playlist = userPlayList;
    [self savePlaylistToFile];
}

-(void)appendPlaylist:(NSArray <WIZMusicTrack*>*)userPlayList
{
    NSMutableArray *tempPlaylist = [NSMutableArray arrayWithArray:playlist];
    [tempPlaylist addObjectsFromArray:userPlayList];
    playlist = tempPlaylist;
    [self savePlaylistToFile];
}

-(void)savePlaylistToFile
{
    NSError *error;
    NSData *dataPlaylist = [NSKeyedArchiver archivedDataWithRootObject:playlist requiringSecureCoding:NO error:&error];
    if (error)
        NSLog(@"ERROR TO CONVERT PLAYLIST: %@",error.description);
    
    [dataPlaylist writeToFile:[self filePathList] atomically:YES];

}

-(void)loadPlaylistFromFile
{
    NSData *dataPlaylist = [NSData dataWithContentsOfFile:[self filePathList]];
    
    NSSet *classes = [NSSet setWithObjects:[NSArray class], [WIZMusicTrack class], [NSURL class], [NSString class],[UIImage class], nil];
    
    NSError *error;
    playlist = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:dataPlaylist error:&error];
    if (playlist.count == 0) {
        playlist = nil;
    }
    if (error)
        NSLog(@"ERROR TO LOAD PLAYLIST: %@",error.description);

}

-(NSString*)filePathList
{
    NSString *docsDir;
    NSArray *dirPaths;
    NSString *fileName = [NSString stringWithFormat:@"playlist.wzplst"];
    
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
   return [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:fileName]];
}

#pragma mark - get playlist

-(NSArray <WIZMusicTrack*>*)playlist
{
    return playlist;
}

#pragma mark - filtres

-(void)changeFilter:(AVAudioUnitEQFilterType)type frequency:(float)frequency bandwidth:(float)bandwidth gain:(float)gain bypass:(BOOL)bypass
{
    if (!audioFiltres)
    {
        audioFiltres = [NSMutableArray arrayWithCapacity:11];
        for (int i = 0; i < 11; i++) {
            WIZEQFilterParameters *audioParameters = [[WIZEQFilterParameters alloc] init];
            audioParameters.filterType = type;
            audioParameters.bypass = YES;
            
            [audioFiltres addObject:audioParameters];
        }
    }
    
    WIZEQFilterParameters *audioParameters = [[WIZEQFilterParameters alloc] init];
    audioParameters.filterType = type;
    audioParameters.frequency = frequency;
    audioParameters.bandwidth = bandwidth;
    audioParameters.gain = gain;
    audioParameters.bypass = bypass;
    
    [audioFiltres removeObjectAtIndex:type];
    [audioFiltres insertObject:audioParameters atIndex:type];
    
    [_delegate WIZAudioDataProviderChangeFilter];
}

-(NSArray <WIZEQFilterParameters*> *)currentFiltres
{
    return audioFiltres;
}

@end
