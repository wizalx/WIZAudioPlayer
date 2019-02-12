//
//  WIZEQScreen.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 07/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Processors/WIZAudioProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@interface WIZEQScreen : UIViewController

@property (nonatomic) WIZAudioProcessor *audioProcessor;

@end

NS_ASSUME_NONNULL_END
