//
//  WIZAudioDataProvider.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 04/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WIZPlayerEssentials.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WIZAudioDataProviderDelegate <NSObject>

-(void)WIZAudioDataProviderChangeFilter;

@end

@interface WIZAudioDataProvider : NSObject

+(WIZAudioDataProvider*)sharedInstance;

-(void)loadPlaylist:(NSArray <WIZMusicTrack*>*)userPlayList;
-(void)appendPlaylist:(NSArray <WIZMusicTrack*>*)userPlayList;

//saveAndLoad
-(void)savePlaylistToFile;
-(void)loadPlaylistFromFile;

//playlist
@property (nonatomic, readonly) NSArray <WIZMusicTrack*> *playlist;

//filtres
-(void)changeFilter:(AVAudioUnitEQFilterType)type frequency:(float)frequency bandwidth:(float)bandwidth gain:(float)gain bypass:(BOOL)bypass;
@property (nonatomic, readonly) NSArray <WIZEQFilterParameters*> *currentFiltres;
@property (nonatomic, retain) id <WIZAudioDataProviderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
