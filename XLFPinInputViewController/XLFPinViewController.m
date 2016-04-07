//
//  XLFPinViewController.m
//  XLFPinViewController
//
//  Created by Marike Jave on 11.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

#import "XLFPinViewController.h"
#import "XLFPinView.h"
#import "UIImage+ImageEffects.h"

@interface XLFPinViewController () <XLFPinViewDelegate>

@property (nonatomic, strong) XLFPinView *pinView;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, assign) NSArray *blurViewContraints;

@end

@implementation XLFPinViewController

- (instancetype)init {
    NSAssert(NO, @"use initWithDelegate:");
    return nil;
}

- (instancetype)initWithDelegate:(id<XLFPinViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _backgroundColor = [UIColor whiteColor];
        _translucentBackground = NO;
        _promptTitle = @"请输入密码";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
    }
    
    self.pinView = [[XLFPinView alloc] initWithDelegate:self];
    self.pinView.backgroundColor = self.view.backgroundColor;
    self.pinView.promptTitle = self.promptTitle;
    self.pinView.promptColor = self.promptColor;
    self.pinView.hideLetters = self.hideLetters;
    self.pinView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.pinView];
    // center pin view

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0f constant:0.0f]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeRight
                                                         multiplier:1.0f constant:0.0f]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f constant:0.0f]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f constant:0.0f]];
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if ([self.backgroundColor isEqual:backgroundColor]) {
        return;
    }
    _backgroundColor = backgroundColor;
    if (! self.translucentBackground) {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
    }
}

- (void)setTranslucentBackground:(BOOL)translucentBackground
{
    if (self.translucentBackground == translucentBackground) {
        return;
    }
    _translucentBackground = translucentBackground;
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        self.pinView.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
        [self removeBlurView];
    }
}

- (void)setPromptTitle:(NSString *)promptTitle
{
    if ([self.promptTitle isEqualToString:promptTitle]) {
        return;
    }
    _promptTitle = [promptTitle copy];
    self.pinView.promptTitle = self.promptTitle;
}

- (void)setPromptColor:(UIColor *)promptColor
{
    if ([self.promptColor isEqual:promptColor]) {
        return;
    }
    _promptColor = promptColor;
    self.pinView.promptColor = self.promptColor;
}

- (void)setHideLetters:(BOOL)hideLetters
{
    if (self.hideLetters == hideLetters) {
        return;
    }
    _hideLetters = hideLetters;
    self.pinView.hideLetters = self.hideLetters;
}

#pragma mark - Blur

- (void)addBlurView
{
    self.blurView = [[UIImageView alloc] initWithImage:[self blurredContentImage]];
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.blurView belowSubview:self.pinView];
    NSDictionary *views = @{ @"blurView" : self.blurView };
    NSMutableArray *constraints =
    [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|"
                                                                           options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|"
                                                                             options:0 metrics:nil views:views]];
    self.blurViewContraints = constraints;
    [self.view addConstraints:self.blurViewContraints];
}

- (void)removeBlurView
{
    [self.blurView removeFromSuperview];
    self.blurView = nil;
    [self.view removeConstraints:self.blurViewContraints];
    self.blurViewContraints = nil;
}

- (UIImage*)blurredContentImage
{
    UIView *contentView = [[UIApplication sharedApplication] keyWindow];

    UIGraphicsBeginImageContext(self.view.bounds.size);
    [contentView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image applyBlurWithRadius:20.0f tintColor:[UIColor colorWithWhite:1.0f alpha:0.3f]
                saturationDeltaFactor:1.8f maskImage:nil];
}

#pragma mark - XLFPinViewDelegate

- (NSUInteger)pinLengthForPinView:(XLFPinView *)pinView
{
    NSUInteger pinLength = [self.delegate pinLengthForPinViewController:self];
    NSAssert(pinLength > 0, @"PIN length must be greater than 0");
    return MAX(pinLength, (NSUInteger)1);
}

- (BOOL)pinView:(XLFPinView *)pinView isPinValid:(NSString *)pin
{
    return [self.delegate pinViewController:self isPinValid:pin];
}

- (void)cancelButtonTappedInPinView:(XLFPinView *)pinView
{
    if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasCancelled:)]) {
        [self.delegate pinViewControllerWillDismissAfterPinEntryWasCancelled:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasCancelled:)]) {
            [self.delegate pinViewControllerDidDismissAfterPinEntryWasCancelled:self];
        }
    }];
}

- (void)correctPinWasEnteredInPinView:(XLFPinView *)pinView
{
    if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasSuccessful:)]) {
        [self.delegate pinViewControllerWillDismissAfterPinEntryWasSuccessful:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasSuccessful:)]) {
            [self.delegate pinViewControllerDidDismissAfterPinEntryWasSuccessful:self];
        }
    }];
}

- (void)incorrectPinWasEnteredInPinView:(XLFPinView *)pinView
{
    if ([self.delegate userCanRetryInPinViewController:self]) {
        if ([self.delegate respondsToSelector:@selector(incorrectPinEnteredInPinViewController:)]) {
            [self.delegate incorrectPinEnteredInPinViewController:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:)]) {
            [self.delegate pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:self];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:)]) {
                [self.delegate pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:self];
            }
        }];
    }
}

- (void)clear;{

}

@end
