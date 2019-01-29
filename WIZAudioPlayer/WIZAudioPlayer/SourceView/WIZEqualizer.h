//
//  WIZEqualizer.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIZEqualizer : UIView

-(id)initWithFrame:(CGRect)frame countLines:(int)countLines countTop:(int)countTop;

@property (nonatomic) NSArray <NSNumber*> *values;

@end

NS_ASSUME_NONNULL_END
