//
//  WIZAudioDataProvider.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 04/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WIZPlayerEssentials.h"

NS_ASSUME_NONNULL_BEGIN

@interface WIZAudioDataProvider : NSObject

+(WIZAudioDataProvider*)sharedInstance;

-(void)loadPlaylist:(NSArray <WIZMusicTrack*>*)userPlayList;

//saveAndLoad
-(void)savePlaylistToFile;
-(void)loadPlaylistFromFile;

//playlist
@property (nonatomic, readonly) NSArray <WIZMusicTrack*> *playlist;

@end

NS_ASSUME_NONNULL_END
