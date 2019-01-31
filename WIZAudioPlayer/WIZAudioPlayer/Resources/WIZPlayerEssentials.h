//
//  WIZPlayerEssentials.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WIZMusicTrack : NSObject

-(id)initFromURL:(NSURL*)url artist:(NSString*)artist title:(NSString*)title;

@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, readonly) NSString* artist;
@property (nonatomic, readonly) NSString* title;

@end