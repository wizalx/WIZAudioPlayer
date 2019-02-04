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

#pragma mark - init playlist

-(void)loadPlaylist:(NSArray<WIZMusicTrack *> *)userPlayList
{
    playlist = userPlayList;
}

-(void)savePlaylistToFile
{
    NSLog(@"save?");

    NSError *error;
    NSData *dataPlaylist = [NSKeyedArchiver archivedDataWithRootObject:playlist requiringSecureCoding:NO error:&error];
    if (error)
        NSLog(@"ERROR TO CONVERT PLAYLIST: %@",error.description);
    
    [dataPlaylist writeToFile:[self filePathList] atomically:YES];

}

-(void)loadPlaylistFromFile
{
    NSLog(@"load?");
    
    NSData *dataPlaylist = [NSData dataWithContentsOfFile:[self filePathList]];
    
    NSSet *classes = [NSSet setWithObjects:[NSArray class], [WIZMusicTrack class], [NSURL class], [NSString class],[UIImage class], nil];
    
    NSError *error;
    playlist = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:dataPlaylist error:&error];
    
    if (error)
        NSLog(@"ERROR TO LOAD PLAYLIST: %@",error.description);
    
    NSLog(@"playlist.count = %lu",(unsigned long)playlist.count);
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

@end
