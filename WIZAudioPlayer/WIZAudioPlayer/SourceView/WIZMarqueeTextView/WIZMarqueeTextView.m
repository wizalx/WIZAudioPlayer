//
//  WIZMarqueeTextView.m
//  customElementh
//
//  Created by a.vorozhishchev on 05/02/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import "WIZMarqueeTextView.h"

@interface WIZMarqueeTextView()
{
    UIFont *font;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UILabel *infiniteLabel;
@end

@implementation WIZMarqueeTextView

#pragma mark - initialization

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self customInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self customInit];
    }
    
    return self;
}

-(void)customInit
{
    [[NSBundle bundleForClass:[self class]] loadNibNamed:@"WIZMarqueeTextView" owner:self options:nil];
    
    [self addSubview:self.contentView];
    
    self.contentView.frame = self.bounds;
    
    font = [UIFont systemFontOfSize:14];
    _text = @"";
    _duration = 5.0f;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    //FIXME: load failure position
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(0.01 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self setText:self.text];
    });
}

#pragma mark - setters

-(void)setFontSize:(float)fontSize
{
    _fontSize = fontSize;
    font = [UIFont systemFontOfSize:fontSize];
    [self setText:_text];
}

-(void)setDuration:(float)duration
{
    _duration = duration;
    [self setText:_text];
}

-(void)setText:(NSString *)text
{
    _text = text;
    
    //calculate width text
    float widthText = [self widthOfString:_text withFont:font];
    
    //clear current view and animations
    [self.scrollView.layer removeAllAnimations];
    [self.textLabel removeFromSuperview];
    [self.infiniteLabel removeFromSuperview];
    
    if (_isBounced) {
        [self bouncedText:widthText];
    } else {
        [self infiniteText:widthText];
    }
    
}

-(void)setIsBounced:(BOOL)isBounced
{
    _isBounced = isBounced;
    [self setText:_text];
}

#pragma mark - prepare to animation

-(void)bouncedText:(float)widthText
{
    self.scrollView.contentSize = CGSizeMake(MAX(widthText, self.frame.size.width), self.frame.size.height);
    
    //create label
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAX(widthText, self.frame.size.width), self.frame.size.height)];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = font;
    self.textLabel.text = _text;
    
    [self.scrollView addSubview:self.textLabel];
    if (widthText > self.frame.size.width)
        [self marqueeBouncedAnimation];
}

-(void)infiniteText:(float)widthText
{
    self.scrollView.contentSize = CGSizeMake(MAX(widthText, self.frame.size.width) * 2, self.frame.size.height);
    
    
    NSLog(@"width = %.2f \n widthContent = %.2f",widthText,MAX(widthText, self.frame.size.width) * 2);
    
    //create labels
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAX(widthText, self.frame.size.width), self.frame.size.height)];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = font;
    self.textLabel.text = _text;
    
    self.infiniteLabel = [[UILabel alloc] initWithFrame:CGRectMake(MAX(widthText, self.frame.size.width) + 16, 0, MAX(widthText, self.frame.size.width), self.frame.size.height)];
    self.infiniteLabel.textAlignment = NSTextAlignmentCenter;
    self.infiniteLabel.font = font;
    self.infiniteLabel.text = _text;
    
    [self.scrollView addSubview:self.textLabel];
    [self.scrollView addSubview:self.infiniteLabel];
    
    [self marqueeInfinite];
    
}

#pragma mark - animation

-(void)marqueeBouncedAnimation
{
    self.scrollView.contentOffset = CGPointMake(0,0);
    [UIView animateWithDuration:_duration delay:2.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat) animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.frame.size.width, 0);
    } completion:nil];
}

-(void)marqueeInfinite
{
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [UIView animateWithDuration:_duration delay:2.0 options:(UIViewAnimationOptionCurveLinear  | UIViewAnimationOptionRepeat) animations:^{
        self.scrollView.contentOffset = CGPointMake((self.scrollView.contentSize.width/2 + 8), 0);
        
    } completion:^(BOOL finished) {
        if (finished) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.frame.size.width, 0);
        }
        
    }];
}

#pragma mark - helper

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

@end
