//
//  XLFPinView.m
//  XLFPinInputViewController
//
//  Created by Marike Jave on 21.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

#import "XLFPinView.h"
#import "XLFPinInputCirclesView.h"
#import "XLFPinNumPadView.h"
#import "XLFPinNumButton.h"

@interface XLFPinView () <XLFPinNumPadViewDelegate>

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) XLFPinInputCirclesView *inputCirclesView;
@property (nonatomic, strong) XLFPinNumPadView *numPadView;
@property (nonatomic, strong) UIButton *bottomButton;

@property (nonatomic, assign) CGFloat paddingBetweenPromptLabelAndInputCircles;
@property (nonatomic, assign) CGFloat paddingBetweenInputCirclesAndNumPad;
@property (nonatomic, assign) CGFloat paddingBetweenNumPadAndBottomButton;

@property (nonatomic, strong) NSMutableString *input;

@end

@implementation XLFPinView

- (instancetype)init {
    NSAssert(NO, @"use initWithDelegate:");
    return nil;
}

- (instancetype)initWithDelegate:(id<XLFPinViewDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        _input = [NSMutableString string];

        _promptLabel = [[UILabel alloc] init];
        _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 22.0f : 18.0f];
        [_promptLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel
                                                      forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_promptLabel];

        _inputCirclesView = [[XLFPinInputCirclesView alloc] initWithPinLength:[_delegate pinLengthForPinView:self]];
        _inputCirclesView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_inputCirclesView];

        _numPadView = [[XLFPinNumPadView alloc] initWithDelegate:self];
        _numPadView.translatesAutoresizingMaskIntoConstraints = NO;
        _numPadView.backgroundColor = self.backgroundColor;
        [self addSubview:_numPadView];

        _bottomButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _bottomButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        [self updateBottomButton];
        [self addSubview:_bottomButton];
        [_bottomButton setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel
                                                       forAxis:UILayoutConstraintAxisHorizontal];


        [self addConstraint:[NSLayoutConstraint constraintWithItem:_numPadView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_numPadView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:40.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_inputCirclesView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_numPadView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_inputCirclesView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_numPadView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:-30.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_promptLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_inputCirclesView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:-20.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_promptLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_inputCirclesView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];

        // bottom botton
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomButton
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_numPadView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:-10.0f]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_numPadView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_bottomButton
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:10.0f]];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    CGFloat height = (self.promptLabel.intrinsicContentSize.height + self.paddingBetweenPromptLabelAndInputCircles +
                      self.inputCirclesView.intrinsicContentSize.height + self.paddingBetweenInputCirclesAndNumPad +
                      self.numPadView.intrinsicContentSize.height);
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        height += self.paddingBetweenNumPadAndBottomButton + self.bottomButton.intrinsicContentSize.height;
    }
    return CGSizeMake(self.numPadView.intrinsicContentSize.width, height);
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.numPadView.backgroundColor = self.backgroundColor;
}

- (NSString *)promptTitle
{
    return self.promptLabel.text;
}

- (void)setPromptTitle:(NSString *)promptTitle
{
    self.promptLabel.text = promptTitle;
}

- (UIColor *)promptColor
{
    return self.promptLabel.textColor;
}

- (void)setPromptColor:(UIColor *)promptColor
{
    self.promptLabel.textColor = promptColor;
}

- (BOOL)hideLetters
{
    return self.numPadView.hideLetters;
}

- (void)setHideLetters:(BOOL)hideLetters
{
    self.numPadView.hideLetters = hideLetters;
}

#pragma mark - Public

- (void)updateBottomButton
{
    if ([self.input length] == 0) {
        [self.bottomButton setTitle:@"取消"
                           forState:UIControlStateNormal];
        [self.bottomButton removeTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.bottomButton setTitle:@"删除"
                           forState:UIControlStateNormal];
        [self.bottomButton removeTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - User Interaction

- (void)cancel:(id)sender
{
    [self.delegate cancelButtonTappedInPinView:self];
}

- (void)delete:(id)sender
{
    if ([self.input length] < 2) {
        [self resetInput];
    } else {
        [self.input deleteCharactersInRange:NSMakeRange([self.input length] - 1, 1)];
        [self.inputCirclesView unfillCircleAtPosition:[self.input length]];
    }
}

#pragma mark - XLFPinNumPadViewDelegate

- (void)pinNumPadView:(XLFPinNumPadView *)pinNumPadView numberTapped:(NSUInteger)number
{
    NSUInteger pinLength = [self.delegate pinLengthForPinView:self];

    if ([self.input length] >= pinLength) {
        return;
    }

    [self.input appendString:[NSString stringWithFormat:@"%lu", (unsigned long)number]];
    [self.inputCirclesView fillCircleAtPosition:[self.input length] - 1];

    [self updateBottomButton];

    if ([self.input length] < pinLength) {
        return;
    }

    if ([self.delegate pinView:self isPinValid:self.input])
    {
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.delegate correctPinWasEnteredInPinView:self];
        });

    } else {

        [self.inputCirclesView shakeWithCompletion:^{
            [self resetInput];
            [self.delegate incorrectPinWasEnteredInPinView:self];
        }];
    }

}

#pragma mark - Util

- (void)resetInput
{
    self.input = [NSMutableString string];
    [self.inputCirclesView unfillAllCircles];
    [self updateBottomButton];
}

@end
