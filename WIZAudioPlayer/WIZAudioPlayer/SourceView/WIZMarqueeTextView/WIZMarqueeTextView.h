//
//  WIZMarqueeTextView.h
//  customElementh
//
//  Created by a.vorozhishchev on 05/02/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WIZMarqueeTextView : UIView


@property (nonatomic) IBInspectable float fontSize;
@property (nonatomic) IBInspectable NSString* text;

@property (nonatomic) IBInspectable float duration;

@property (nonatomic) IBInspectable BOOL isBounced;

@end

NS_ASSUME_NONNULL_END
