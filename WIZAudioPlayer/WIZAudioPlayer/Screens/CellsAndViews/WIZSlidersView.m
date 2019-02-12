//
//  WIZSlidersView.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 11/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZSlidersView.h"

@interface WIZSlidersView()
{
    int countSlider;
    NSMutableArray *currentValues;
}

@end

@implementation WIZSlidersView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame sliderCount:(int)count
{
    countSlider = count;
    return [self initWithFrame:frame];
}

-(void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    
    currentValues = [NSMutableArray arrayWithCapacity:countSlider];
    
    float height = self.frame.size.height/countSlider;
    float heightSlider = height-10;
    for (int i=0; i < countSlider; i++) {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0,i*height+5,self.frame.size.width,heightSlider)];
        
        slider.tag = i+1;
        
        slider.minimumTrackTintColor = [UIColor blackColor];
        
        CGFloat red   = 181/255.0;
        CGFloat blu   = 135/255.0;
        CGFloat green = 156/255.0;
        UIColor *maxColor = [UIColor colorWithRed:red green:green blue:blu alpha:1.0];
        
        slider.maximumTrackTintColor = maxColor;
        
        [slider setThumbImage:[self resizeImage:[UIImage imageNamed:@"sliderPoint"] withSize:CGSizeMake(15.0, 15.0)] forState:UIControlStateNormal];
        
        switch (i) {
            case 0:
                slider.minimumValue = 100;
                slider.maximumValue = 16000;
                slider.value = 16000;
                break;
            case 1:
                slider.minimumValue = 0;
                slider.maximumValue = 1000;
                slider.value = 0;
                break;
            case 2:
                slider.minimumValue = 100;
                slider.maximumValue = 10000;
                slider.value = 10000;
                break;
            case 3:
                slider.minimumValue = 0;
                slider.maximumValue = 5000;
                slider.value = 0;
                break;
            case 4:
                slider.minimumValue = 0;
                slider.maximumValue = 10000;
                slider.value = 0;
                break;
            default:
                break;
        }
        
        [currentValues addObject:[NSNumber numberWithFloat:slider.value]];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:slider];
        
    }
}

-(void)sliderAction:(UISlider*)slider
{
    [currentValues removeObjectAtIndex:slider.tag-1];
    [currentValues insertObject:[NSNumber numberWithFloat:slider.value] atIndex:slider.tag-1];
    
    if (_selectEqValues)
        _selectEqValues(currentValues);
    
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


@end
