//
//  WIZEQScreen.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 07/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZEQScreen.h"
#import "CellsAndViews/WIZSlidersView.h"

@interface WIZEQScreen ()
@property (weak, nonatomic) IBOutlet UIView *containView;

@property (weak, nonatomic) IBOutlet UISwitch *switchBP;

@end

@implementation WIZEQScreen

- (void)viewDidLoad {
    [super viewDidLoad];

    //FIXME: load failure position
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self createSliders];
    });
    
}

#pragma mark - create interface

-(void)createSliders
{
    WIZSlidersView *sliders = [[WIZSlidersView alloc] initWithFrame:CGRectMake(0, 0, self.containView.frame.size.width, self.containView.frame.size.height) sliderCount:5];
    [self.containView addSubview:sliders];
    
    self.containView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    sliders.selectEqValues = ^(NSArray * _Nonnull eqArray) {
        [self.audioProcessor setEqArray:eqArray];
    };
}


- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)byPassSwitch:(id)sender {
    [self.audioProcessor setByPass:self.switchBP.isOn];
}

@end
