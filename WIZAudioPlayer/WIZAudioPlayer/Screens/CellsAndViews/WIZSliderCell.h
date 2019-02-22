//
//  WIZSliderCell.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 13/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WIZSliderCellChangeValue)(float value);
@interface WIZSliderCell : UITableViewCell

@property (nonatomic) NSString *titleText;
-(void)setValuesFromSliderMin:(float)min Max:(float)max Current:(float)current;

@property (nonatomic, strong) WIZSliderCellChangeValue changeValue;
@property (nonatomic) BOOL enabled;

@end

