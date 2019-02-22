//
//  WIZSwitchCell.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 15/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZSwitchCell.h"

@interface WIZSwitchCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

@end

@implementation WIZSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters

-(void)setTitleText:(NSString *)titleText
{
    self.titleLabel.text = titleText;
}

- (IBAction)switchChange:(id)sender {
    
    if (_changeValue)
        _changeValue(self.switchControl.isOn);
    
}

@end
