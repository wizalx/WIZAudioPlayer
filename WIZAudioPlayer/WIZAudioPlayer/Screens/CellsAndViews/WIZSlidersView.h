//
//  WIZSlidersView.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 11/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^WIZSlidersViewSelectValues)(NSArray* eqArray);
@interface WIZSlidersView : UIView

-(id)initWithFrame:(CGRect)frame sliderCount:(int)count;
@property (nonatomic, strong) WIZSlidersViewSelectValues selectEqValues;

@end

NS_ASSUME_NONNULL_END
