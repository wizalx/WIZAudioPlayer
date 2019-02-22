//
//  WIZSliderCell.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 13/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZSliderCell.h"

@interface WIZSliderCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation WIZSliderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.text = @"";
    
    
    [self.slider setThumbImage:[self resizeImage:[UIImage imageNamed:@"sliderPoint"] withSize:CGSizeMake(15.0, 15.0)] forState:UIControlStateNormal];
    
    self.slider.minimumTrackTintColor = [UIColor blackColor];
    
    CGFloat red   = 181/255.0;
    CGFloat blu   = 135/255.0;
    CGFloat green = 156/255.0;
    UIColor *maxColor = [UIColor colorWithRed:red green:green blue:blu alpha:1.0];
    
    self.slider.maximumTrackTintColor = maxColor;
//    [self.slider setContinuous:NO];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.enabled = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters

-(void)setValuesFromSliderMin:(float)min Max:(float)max Current:(float)current
{
    self.slider.minimumValue = min;
    self.slider.maximumValue = max;
    self.slider.value = current;
}

-(void)setTitleText:(NSString *)titleText
{
    self.titleLabel.text = titleText;
}

-(void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.slider.enabled = enabled;
    if (enabled)
        self.titleLabel.textColor = [UIColor blackColor];
    else
        self.titleLabel.textColor = [UIColor grayColor];
}

#pragma mark - helper

-(UIImage*)resizeImage:(UIImage*)image withSize:(CGSize)size
{
    UIImage *tempImage = nil;
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = size.width;
    thumbnailRect.size.height = size.height;
    
    [image drawInRect:thumbnailRect];
    
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tempImage;
}

#pragma mark - slider change value

- (IBAction)changeValue:(id)sender {
    if (_changeValue)
        _changeValue(self.slider.value);
}


@end
