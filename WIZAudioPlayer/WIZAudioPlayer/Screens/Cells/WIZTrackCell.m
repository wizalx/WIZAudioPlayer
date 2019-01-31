//
//  WIZTrackCell.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZTrackCell.h"

@interface WIZTrackCell()
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation WIZTrackCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.artistLabel sizeToFit];
    [self.titleLabel sizeToFit];
    
    CGFloat red   = 248/255.0;
    CGFloat green = 212/255.0;
    CGFloat blu   = 182/255.0;
    
    UIColor *bgColor = [UIColor colorWithRed:red green:green blue:blu alpha:1.0];
    self.backgroundColor = bgColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTrack:(WIZMusicTrack *)track
{
    _track = track;

    self.artistLabel.text = track.artist;
    self.titleLabel.text = track.title;
}

@end
