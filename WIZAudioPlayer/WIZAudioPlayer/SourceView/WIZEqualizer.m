//
//  WIZEqualizer.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 29/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZEqualizer.h"
#import "WIZProgressView/WIZProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface WIZEqualizer()
{
    int _countLines;
    int _countTop;
}

@property (nonatomic) NSArray <WIZProgressView*> *audioLines;

@end

@implementation WIZEqualizer

#pragma mark - initialization

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self customInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame countLines:(int)countLines countTop:(int)countTop
{
    _countLines = countLines;
    _countTop = countTop;
    
    return [self initWithFrame:frame];
}

-(void)customInit
{
    float width = self.frame.size.width;
    //    float height = [UIScreen mainScreen].bounds.size.height;
    float widthAudioLine = width/_countLines;
    
    NSMutableArray *linesArray = [NSMutableArray arrayWithCapacity:_countLines];
    
    CGFloat red   = 99/255.0;
    CGFloat blu   = 77/255.0;
    CGFloat green = 66/255.0;
    UIColor *randColor = [UIColor colorWithRed:red green:green blue:blu alpha:1.0];
    
    for (int i = 0; i < _countLines; i++) {
        WIZProgressView *progressView = [[WIZProgressView alloc] initWithFrame:CGRectMake(i*widthAudioLine, 0, widthAudioLine, self.frame.size.height)];
        progressView.countCircle = _countTop;
        progressView.verticalLine = YES;
        progressView.reverseFill = YES;
        
        progressView.distanceSize = 0;
        
        progressView.fillColor = randColor;
        
        progressView.cleanEmpty = YES;
        
        [self addSubview:progressView];
        [linesArray addObject:progressView];
    }
    
    self.audioLines = linesArray;
}

#pragma mark - setters

-(void)setValues:(NSArray<NSNumber *> *)values
{
    _values = values;
    
    NSInteger minCount = MIN(values.count, _countLines);
    NSInteger levelHight = 0;
    for (NSInteger pos = minCount-1; pos>=0; pos--)
    {
        //experimental data :)
        float currentPerc = MAX(0,75 - fabs(([values[pos] floatValue]+5)/0.45));
        self.audioLines[pos].percent = currentPerc;
        
        if (currentPerc>57)
            levelHight++;
    }
    NSLog(@"levelHight = %li",(long)levelHight);
    if (levelHight == minCount-1) {
        [self animateBackground];
    }
//    if (maxPercent > 70.0) {
//        self.backgroundColor = [UIColor redColor];
//    }
}

-(void)animateBackground
{
    CGFloat red   = 255/255.0;
    CGFloat blu   = 87/255.0;
    CGFloat green = 81/255.0;
    UIColor *bangColor = [UIColor colorWithRed:red green:green blue:blu alpha:1.0];
    self.layer.backgroundColor = bangColor.CGColor;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGFloat red1   = 218/255.0;
        CGFloat blu1   = 187/255.0;
        CGFloat green1 = 159/255.0;
        UIColor *bgColor = [UIColor colorWithRed:red1 green:green1 blue:blu1 alpha:1.0];
        
        self.layer.backgroundColor = bgColor.CGColor;
    } completion:NULL];
}

@end
