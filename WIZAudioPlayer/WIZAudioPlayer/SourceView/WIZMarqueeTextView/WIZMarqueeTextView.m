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
    float widthText = [self widthOfString:text withFont:font];
    
    [self.scrollView.layer removeAllAnimations];
    
    self.scrollView.contentSize = CGSizeMake(MAX(widthText, self.frame.size.width), self.frame.size.height);
    
    [self.textLabel removeFromSuperview];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAX(widthText, self.frame.size.width), self.frame.size.height)];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
//    self.textLabel.backgroundColor = [UIColor lightGrayColor];
    self.textLabel.font = font;
    self.textLabel.text = text;
    
    [self.scrollView addSubview:self.textLabel];
    if (widthText > self.frame.size.width)
         [self marqueeAnimationRight];
    
   
}

#pragma mark - animation

-(void)marqueeAnimationRight
{
    [UIView animateWithDuration:_duration delay:2.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat) animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.frame.size.width, 0);
    } completion:nil];
}

#pragma mark - helper

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

@end
