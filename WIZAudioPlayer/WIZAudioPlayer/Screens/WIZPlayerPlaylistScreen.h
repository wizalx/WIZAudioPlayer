//
//  WIZPlayerPlaylistScreen.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Resources/WIZPlayerEssentials.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^WIZPlayerPlaylistScreenSelectTrack)(WIZMusicTrack* track);
@interface WIZPlayerPlaylistScreen : UITableViewController

@property (nonatomic, strong) WIZPlayerPlaylistScreenSelectTrack selectTrack;

@end

NS_ASSUME_NONNULL_END
