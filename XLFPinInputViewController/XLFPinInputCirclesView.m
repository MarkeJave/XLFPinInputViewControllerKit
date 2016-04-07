//
//  XLFPinInputCirclesView.m
//  XLFPinInputViewController
//
//  Created by Marike Jave on 20.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

#import "XLFPinInputCirclesView.h"
#import "XLFPinInputCircleView.h"

@interface XLFPinInputCirclesView ()

@property (nonatomic, strong) NSMutableArray *circleViews;
@property (nonatomic, readonly, assign) CGFloat circlePadding;

@property (nonatomic, assign) NSUInteger numShakes;
@property (nonatomic, assign) NSInteger shakeDirection;
@property (nonatomic, assign) CGFloat shakeAmplitude;
@property (nonatomic, strong) XLFPinInputCirclesViewShakeCompletionBlock shakeCompletionBlock;

@end

@implementation XLFPinInputCirclesView

- (instancetype)init {
    NSAssert(NO, @"use initWithPinLength:");
    return nil;
}

- (instancetype)initWithPinLength:(NSUInteger)pinLength
{
    self = [super init];
    if (self)
    {
        self.layer.masksToBounds = YES;
        _pinLength = pinLength;
        
        _circleViews = [NSMutableArray array];
        NSMutableString *format = [NSMutableString stringWithString:@"H:|"];
        NSMutableDictionary *views = [NSMutableDictionary dictionary];
        
        for (NSUInteger i = 0; i < _pinLength; i++)
        {
            XLFPinInputCircleView* circleView = [[XLFPinInputCircleView alloc] init];
            circleView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:circleView];
            [_circleViews addObject:circleView];
            NSString *name = [NSString stringWithFormat:@"circle%lu", (unsigned long)i];
            if (i > 0) {
                [format appendString:@"-(padding)-"];
            }
            [format appendFormat:@"[%@]", name];
            views[name] = circleView;

            [self addConstraint:[NSLayoutConstraint constraintWithItem:circleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        }
        
        [format appendString:@"|"];
        NSDictionary *metrics = @{ @"padding" : @(self.circlePadding) };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views]];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.pinLength * [XLFPinInputCircleView diameter] + (self.pinLength - 1) * self.circlePadding,
                      [XLFPinInputCircleView diameter]);
}

- (CGFloat)circlePadding
{
    return 2.0f * [XLFPinInputCircleView diameter];
}

- (void)fillCircleAtPosition:(NSUInteger)position
{
    NSParameterAssert(position < [self.circleViews count]);
    [self.circleViews[position] setFilled:YES];
}

- (void)unfillCircleAtPosition:(NSUInteger)position
{
    NSParameterAssert(position < [self.circleViews count]);
    [self.circleViews[position] setFilled:NO];
}

- (void)unfillAllCircles
{
    for (XLFPinInputCircleView *view in self.circleViews) {
        view.filled = NO;
    }
}

static const NSUInteger XLFTotalNumberOfShakes = 6;
static const CGFloat XLFInitialShakeAmplitude = 40.0f;

- (void)shakeWithCompletion:(XLFPinInputCirclesViewShakeCompletionBlock)completion
{
    self.numShakes = 0;
    self.shakeDirection = -1;
    self.shakeAmplitude = XLFInitialShakeAmplitude;
    self.shakeCompletionBlock = completion;
    [self performShake];
}

- (void)performShake
{
    [UIView animateWithDuration:0.03f animations:^ {
        self.transform = CGAffineTransformMakeTranslation(self.shakeDirection * self.shakeAmplitude, 0.0f);
    } completion:^(BOOL finished) {
        if (self.numShakes < XLFTotalNumberOfShakes)
        {
            self.numShakes++;
            self.shakeDirection = -1 * self.shakeDirection;
            self.shakeAmplitude = (XLFTotalNumberOfShakes - self.numShakes) * (XLFInitialShakeAmplitude / XLFTotalNumberOfShakes);
            [self performShake];
        } else {
            self.transform = CGAffineTransformIdentity;
            if (self.shakeCompletionBlock) {
                self.shakeCompletionBlock();
                self.shakeCompletionBlock = nil;
            }
        }
    }];
}

@end
