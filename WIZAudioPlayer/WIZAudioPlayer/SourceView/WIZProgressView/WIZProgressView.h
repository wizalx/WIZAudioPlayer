//
//  WIZProgressView.h
//  customElementh
//
//  Created by a.vorozhishchev on 25/01/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface WIZProgressView : UIView

@property (nonatomic) IBInspectable NSInteger countCircle;
@property (nonatomic) IBInspectable NSInteger countLoaded;

@property (nonatomic) IBInspectable UIColor *fillColor;
@property (nonatomic) IBInspectable float distanceSize;

@property (nonatomic) IBInspectable UIImage *emptyImage;
@property (nonatomic) IBInspectable UIImage *fillImage;

@property (nonatomic) IBInspectable BOOL verticalLine;
@property (nonatomic) IBInspectable BOOL reverseFill;
@property (nonatomic) IBInspectable BOOL cleanEmpty;

@property (nonatomic) float percent;

@end

