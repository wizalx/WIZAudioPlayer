//
//  WIZPlayerEssentials.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WIZMusicTrack : NSObject <NSSecureCoding>

-(id)initFromURL:(NSURL*)url artist:(NSString*)artist title:(NSString*)title image:(UIImage*)artwork;

@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, readonly) NSString* artist;
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) UIImage* artwork;

@end


