//
//  WIZSwitchCell.h
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 15/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^WIZSwitchCellChangeValue)(BOOL isON);

@interface WIZSwitchCell : UITableViewCell

@property (nonatomic) NSString *titleText;
@property (nonatomic, strong) WIZSwitchCellChangeValue changeValue;

@end

NS_ASSUME_NONNULL_END
