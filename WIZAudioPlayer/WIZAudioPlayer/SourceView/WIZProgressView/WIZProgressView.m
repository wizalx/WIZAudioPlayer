//
//  WIZProgressView.m
//  customElementh
//
//  Created by a.vorozhishchev on 25/01/2019.
//  Copyright © 2019 a.vorozhishchev. All rights reserved.
//

#import "WIZProgressView.h"

typedef enum
{
    typeEmpty = 0,
    typeFill
} typeCircle;


@interface WIZProgressView() <UIGestureRecognizerDelegate>
{
    float widthItem;
    float diametrCircle;
    float distanceBetweenCircle;
    NSMutableArray <NSNumber*> * circles;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UILongPressGestureRecognizer *gesture;

@end

@implementation WIZProgressView

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

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    //FIXME: load failure position
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(0.01 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self setCountLoaded:self->_countLoaded];
    });
}

-(void)customInit
{
    [[NSBundle bundleForClass:[self class]] loadNibNamed:@"WIZProgressView" owner:self options:nil];
    
    [self addSubview:self.contentView];
    
    self.contentView.frame = self.bounds;
    
    //add gesture
    self.gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handleLongTap:)];
    
    [self.contentView addGestureRecognizer:self.gesture];
    
    //default values
    
    _countCircle = 4;
    _fillColor = [UIColor darkGrayColor];
    _distanceSize = 15.0;
    _verticalLine = NO;
    
    //init circles array
    
    circles = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *tempEmptyArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < _countCircle; i++)
        [tempEmptyArray addObject:@(typeEmpty)];
    
    circles = [NSMutableArray arrayWithArray:tempEmptyArray];
    
    [self updateView];
}

#pragma mark - setters

-(void)setCountCircle:(NSInteger)countCircle
{
    if (countCircle>0)
        _countCircle = countCircle;
    else
        _countCircle = 1;
    
    [self updateView];
}



-(void)setCountLoaded:(NSInteger)countLoaded
{
    if (countLoaded <= _countCircle)
        _countLoaded = countLoaded;
    else
        _countLoaded = _countCircle;
    
    //format array
    NSMutableArray *tempEmptyArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < self.countCircle; i++)
    {
        if (!_reverseFill) {
            if (i < countLoaded)
                [tempEmptyArray addObject:@(typeFill)];
            else
                [tempEmptyArray addObject:@(typeEmpty)];
        } else {
            if (i < self.countCircle-countLoaded) {
                [tempEmptyArray addObject:@(typeEmpty)];
            } else {
                [tempEmptyArray addObject:@(typeFill)];
            }
        }
        
    }
    
    circles = [NSMutableArray arrayWithArray:tempEmptyArray];
    
    [self updateView];
    
}

-(void)setPercent:(float)percent
{
    _percent = percent;
    float percentFromOneCircle = 100/_countCircle;
    NSInteger countOfPercent = fabsf(percent/percentFromOneCircle);
    [self setCountLoaded:countOfPercent];
}

-(void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self updateView];
}

-(void)setCleanEmpty:(BOOL)cleanEmpty
{
    _cleanEmpty = cleanEmpty;
    [self updateView];
}

-(void)setDistanceSize:(float)distanceSize
{
    _distanceSize = distanceSize;
    [self setCountLoaded:_countLoaded];
}

-(void)setEmptyImage:(UIImage *)emptyImage
{
    _emptyImage = emptyImage;
    [self updateView];
}

-(void)setFillImage:(UIImage *)fillImage
{
    _fillImage = fillImage;
    [self updateView];
}

-(void)setVerticalLine:(BOOL)verticalLine
{
    _verticalLine = verticalLine;
    [self updateView];
}

-(void)setReverseFill:(BOOL)reverseFill
{
    _reverseFill = reverseFill;
    
    [self setCountLoaded:_countLoaded];
}

#pragma mark - update

-(void)updateView
{
    //remove all objects on view
    for (UIImageView* view in self.subviews) {
        if (view.tag > 0) {
            [view removeFromSuperview];
        }
    }
    
    //calculate positions
    if (!_verticalLine)
        [self updateHorizontalView];
    else
        [self updateVerticalView];
    
    
}

-(void)updateHorizontalView
{
    //separate view
    widthItem =  self.bounds.size.width / _countCircle;
    
    //calculate values
    diametrCircle = widthItem - _distanceSize;
    
    if (diametrCircle > self.bounds.size.height)
        diametrCircle = self.bounds.size.height;
    
    distanceBetweenCircle = widthItem - diametrCircle;
    float yPosition = (self.frame.size.height - diametrCircle)/2;
    for (int i = 0; i < circles.count; i++) {
        float xPosition = ((distanceBetweenCircle/2)*(1+i*2))+diametrCircle*i;
        float diametrEdit = diametrCircle;
        float yEdit = yPosition;
        float xEdit = xPosition;
        
        UIImageView *circleView = [[UIImageView alloc] initWithFrame:CGRectMake(xEdit, yEdit, diametrEdit, diametrEdit)];
        
        circleView.tag = i + 1;
        
        typeCircle type = [circles[i] intValue];
        
        switch (type) {
            case typeEmpty:
            {
                if (!_emptyImage) {
                    circleView = [self emptyCircleViewFromView:circleView];
                } else {
                    circleView = [self emptyImageViewFromView:circleView];
                }
            }
                break;
            case typeFill:
                if (!_fillImage) {
                    circleView = [self fillCircleViewFromView:circleView];
                } else {
                    circleView = [self fillImageViewFromView:circleView];
                }
                break;
            default:
                break;
        }
        
        [self addSubview:circleView];
    }
}

-(void)updateVerticalView
{
    //separate view
    widthItem =  self.bounds.size.height / _countCircle;
    
    //calculate values
    diametrCircle = widthItem - _distanceSize;
    
    if (diametrCircle > self.bounds.size.width)
        diametrCircle = self.bounds.size.width;
    
    distanceBetweenCircle = widthItem - diametrCircle;
    
    float xPosition = (self.frame.size.width - diametrCircle)/2;
    for (int i = 0; i < circles.count; i++) {
        float yPosition = ((distanceBetweenCircle/2)*(1+i*2))+diametrCircle*i;
        float diametrEdit = diametrCircle;
        float yEdit = yPosition;
        float xEdit = xPosition;
        
        UIImageView *circleView = [[UIImageView alloc] initWithFrame:CGRectMake(xEdit, yEdit, diametrEdit, diametrEdit)];
        
        circleView.tag = i + 1;
        
        typeCircle type = [circles[i] intValue];
        
        switch (type) {
            case typeEmpty:
            {
                if (!_emptyImage) {
                    circleView = [self emptyCircleViewFromView:circleView];
                } else {
                    circleView = [self emptyImageViewFromView:circleView];
                }
            }
                break;
            case typeFill:
                if (!_fillImage) {
                    circleView = [self fillCircleViewFromView:circleView];
                } else {
                    circleView = [self fillImageViewFromView:circleView];
                }
                break;
            default:
                break;
        }
        
        [self addSubview:circleView];
    }
}

#pragma mark - Create objects

-(UIImageView*)emptyCircleViewFromView:(UIImageView*)circleView
{
    circleView.layer.cornerRadius = circleView.bounds.size.height / 2;
    circleView.layer.masksToBounds = YES;
    
    circleView.layer.borderWidth = 2;
    if (!_cleanEmpty) {
        circleView.layer.borderColor = [_fillColor CGColor];
    } else {
        circleView.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    
    
    return circleView;
}

-(UIImageView*)fillCircleViewFromView:(UIImageView*)circleView
{
    circleView.layer.cornerRadius = circleView.bounds.size.height / 2;
    circleView.layer.masksToBounds = YES;
    
    circleView.backgroundColor = _fillColor;
    
    return circleView;
}

-(UIImageView*)emptyImageViewFromView:(UIImageView*)circleView
{
    circleView.contentMode = UIViewContentModeScaleAspectFit;
    circleView.image = _emptyImage;
    
    return circleView;
}

-(UIImageView*)fillImageViewFromView:(UIImageView*)circleView
{
    circleView.contentMode = UIViewContentModeScaleAspectFit;
    circleView.image = _fillImage;
    
    return circleView;
}

#pragma mark - gesture

-(void)handleLongTap:(UILongPressGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:self.contentView];
    
    //registration vertical or horizontal
    float locationPosition;
    if (_verticalLine)
        locationPosition = location.y;
    else
        locationPosition = location.x;
    
    //check reverse
    if (!_reverseFill) {
        if (locationPosition > widthItem/2) {
            NSInteger countOfSelectCircle = locationPosition/widthItem;
            [self setCountLoaded:MIN(countOfSelectCircle + 1, _countCircle)];
        } else {
            [self setCountLoaded:0];
        }
    } else {
        if (locationPosition < widthItem*(_countCircle-1)+widthItem/2) {
            NSInteger countOfSelectCircle = locationPosition/widthItem;
            [self setCountLoaded:_countCircle - countOfSelectCircle];
        } else {
            [self setCountLoaded:0];
        }
    }
    
}

@end
